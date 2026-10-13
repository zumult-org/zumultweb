#########################################
# Dockerfile for setting up the ZuMult Application.
# This installs dependencies to the system, 
# then compiles the code using maven
# and in the second stepsinstalls it in 
# a Tomcat application server.
#########################################
#
# Build stage
#
FROM maven:3.6.3-openjdk-17-slim AS build

LABEL org.opencontainers.image.source=https://github.com/zumult-org/zumultweb
LABEL org.opencontainers.image.authors="Anne Ferger"

ARG GITHUB_PAT
ARG GITHUB_USERNAME
ENV HOME=/usr/app
RUN mkdir -p $HOME
ADD . $HOME
WORKDIR $HOME
RUN mvn clean package -s docker-config/settings.xml "-Dproject.packaging=war" "-Dgithub.token=${GITHUB_PAT}" "-Dgithub.username=${GITHUB_USERNAME}"
# the WAR is produced by the build above; copying it from the build context
# only worked if someone had run mvn package on the host beforehand
RUN cp target/zumultweb.war target/zumultapi.war
#
# Deploy stage
#
# Ubuntu base pinned: the unpinned tag now points to 26.04, where libc++1
# no longer pulls in libunwind (Praat failed to start, 2026-10-13).
# Stays on Tomcat 9, see zumult-org/zumultapi#278.
FROM tomcat:9.0-jdk17-temurin-resolute
ARG WAR_FILE=/usr/app/target/zumultapi.war
ARG PRAAT_URL=https://github.com/praat/praat/releases/download/v6.4.44a/praat6444_linux-intel64.tar.gz
LABEL org.opencontainers.image.source=https://github.com/zumult-org/zumultapi

ENV CATALINA_WEBAPP=${CATALINA_HOME}/webapps

USER root:root

RUN apt-get update \
    && apt-get install --no-install-recommends -y unzip ffmpeg git git-lfs libc++1 nano libgtk-3-0t64 llvm-libunwind1
ENV HOME=/usr/app
ENV ZUMULT_CONFIG_PATH=/usr/app/Configuration.xml
ENV CORPUSDATA=/home/corpusdata
ENV JAVA_TOOL_OPTIONS=-Djavax.xml.transform.TransformerFactory="net.sf.saxon.TransformerFactoryImpl"
ENV PATH=$PATH:/home/praat
ENV PRAAT_PATH=/home

VOLUME ["/home/corpusdata"]

RUN mkdir -p $HOME
WORKDIR $HOME
COPY --from=build $WAR_FILE /usr/app/zumultapi.war
COPY --from=build $HOME/docker-entrypoint.sh /usr/app/docker-entrypoint.sh
COPY --from=build $HOME/docker-config/server.xml /usr/app/server.xml
COPY --from=build $HOME/docker-config/Configuration.xml /usr/app/Configuration.xml
COPY --from=build $HOME/docker-config/web.xml /usr/app/web.xml
RUN mkdir -p $CORPUSDATA
# The demo corpus is NOT cloned into the image any more. Mount a clone of
# zumult-org/exmaraldademocorpus (src/main/java/data) at /home/corpusdata.
# Reasons: the image does not grow by ~5 GB of LFS media, a corpus update
# is a git pull instead of a rebuild, and the bundled MTAS index under
# data/indices comes along.

# Praat ends up in $PRAAT_PATH=/home, i.e. /home/praat, matching
# <praat-path> in docker-config/Configuration.xml.
WORKDIR $PRAAT_PATH
RUN curl -Ls ${PRAAT_URL} -o praat.tar.gz && gunzip praat.tar.gz && tar xvf praat.tar && chmod +x praat && rm praat.tar
WORKDIR $HOME


EXPOSE 8080
# configuration and deployment as tomcat webapp   
RUN cp -f /usr/app/server.xml ${CATALINA_HOME}/conf/server.xml \
    && unzip -q /usr/app/zumultapi.war -d ${CATALINA_WEBAPP}/zumultapi \
    && mkdir -p ${CATALINA_WEBAPP}/zumultapi/downloads \
    && rm -Rf ${CATALINA_WEBAPP}/ROOT \
    && chmod 755 /usr/app/docker-entrypoint.sh \
    && cp -f /usr/app/web.xml ${CATALINA_WEBAPP}/zumultapi/WEB-INF/web.xml


HEALTHCHECK CMD curl --fail http://localhost:8080/zumultapi || exit 1

ENTRYPOINT ["/usr/app/docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]

############################################################
# Docker image for the ZuMult web application.
#
# This is a multi-stage build:
# 1. Build stage: compile the application using Maven and
#    package it as a WAR file.
# 2. Runtime stage: install the WAR file and required
#    dependencies in an Apache Tomcat environment.
#
# Corpus data are not included in the image. They are
# provided separately through a bind mount at runtime.
############################################################

# Stage 1: Build the application using Maven and Java 17.
FROM maven:3.6.3-openjdk-17-slim AS build

# Image metadata.
LABEL org.opencontainers.image.source=https://github.com/zumult-org/zumultweb
LABEL org.opencontainers.image.authors="Thomas Schmidt (linguisticbits.de)"

# Credentials for downloading the zumultapi dependency
# from GitHub Packages during the Maven build.
# TODO: Replace build arguments with BuildKit secrets.
ARG GITHUB_PAT
ARG GITHUB_USERNAME

# Set the working directory for compiling the application.
# Docker creates this directory if it does not exist.
WORKDIR /usr/app

# Copy the source code and build configuration into the image.
COPY . /usr/app

# Compile and package the ZuMult web application as a WAR file.
# The custom Maven settings provide access to the zumultapi
# dependency hosted on GitHub Packages.
RUN mvn clean package \
    -s docker-config/settings.xml \
    "-Dgithub.token=${GITHUB_PAT}" \
    "-Dgithub.username=${GITHUB_USERNAME}"

############################################################
# Stage 2: Runtime environment
#
# Install the compiled ZuMult web application in Apache
# Tomcat 9 with Java 17.
#
# Tomcat 9 is required for compatibility with the Java EE
# servlet API (javax.servlet).
############################################################
FROM tomcat:9.0-jdk17-temurin-resolute

# Download location for the Linux x86-64 version of Praat.
ARG PRAAT_URL=https://github.com/praat/praat/releases/download/v6.4.44a/praat6444_linux-intel64.tar.gz

# Metadata for the final Docker image.
LABEL org.opencontainers.image.source=https://github.com/zumult-org/zumultweb
LABEL org.opencontainers.image.authors="Thomas Schmidt (linguisticbits.de)"

# Tomcat directory for deployed web applications.
ENV CATALINA_WEBAPP=${CATALINA_HOME}/webapps

# Install operating-system dependencies as root.
# TODO: Run Tomcat as a non-root user in the final image.
USER root:root

# Install:
# - unzip: extract the WAR during image construction
# - ffmpeg: audio/video processing
# - git, git-lfs: Git operations (review runtime requirement)
# - libc++1, GTK 3, libunwind: native libraries for Praat
# - nano: interactive debugging (optional)
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
       unzip \
       ffmpeg \
       git \
       git-lfs \
       libc++1 \
       nano \
       libgtk-3-0t64 \
       llvm-libunwind1 \
    && rm -rf /var/lib/apt/lists/*


# Directory containing the ZuMult application and its configuration.
ENV APP_HOME=/usr/app

# Location of the main ZuMult configuration file.
ENV ZUMULT_CONFIG_PATH=${APP_HOME}/Configuration.xml

# Location of corpus data inside the container.
# The data are supplied through a read-only bind mount at runtime.
ENV CORPUSDATA=/home/corpusdata

# Use Saxon as the default JAXP XSLT processor.
ENV JAVA_TOOL_OPTIONS="-Djavax.xml.transform.TransformerFactory=net.sf.saxon.TransformerFactoryImpl"

# Directory in which the Praat executable will be installed.
# The resulting executable path is /home/praat.
ENV PRAAT_PATH=/home

# Corpus data are provided through an explicit bind mount
# when starting the container. No Docker-managed volume is
# declared here.

# Set the application working directory, creating it if necessary.
WORKDIR ${APP_HOME}


# Copy the compiled application from the Maven build stage.
COPY --from=build /usr/app/target/zumultweb.war ${APP_HOME}/zumultweb.war

# Copy the container startup script.
COPY --from=build /usr/app/docker-entrypoint.sh ${APP_HOME}/docker-entrypoint.sh

# Copy the Tomcat server configuration.
COPY --from=build /usr/app/docker-config/server.xml ${APP_HOME}/server.xml

# Copy the ZuMult application configuration.
COPY --from=build /usr/app/docker-config/Configuration.xml ${APP_HOME}/Configuration.xml

# Copy the web application deployment descriptor.
COPY --from=build /usr/app/docker-config/web.xml ${APP_HOME}/web.xml
 

# Download and install Praat for phonetic analysis.
# The executable will be located at /home/praat, as expected
# by the ZuMult Configuration.xml.
WORKDIR ${PRAAT_PATH}

RUN curl -fLsS "${PRAAT_URL}" -o praat.tar.gz \
    && tar -xzf praat.tar.gz \
    && chmod +x praat \
    && rm praat.tar.gz

# Verify that the required native libraries are available.
RUN ldd /home/praat \
    && ! ldd /home/praat | grep -q "not found"

# Return to the ZuMult application directory.
WORKDIR ${APP_HOME}



EXPOSE 8080

# Install the custom Tomcat configuration.
# This includes the context for serving mounted corpus media.
RUN cp -f ${APP_HOME}/server.xml ${CATALINA_HOME}/conf/server.xml

# Deploy the compiled ZuMult application under /zumultapi.
RUN unzip -q ${APP_HOME}/zumultweb.war -d ${CATALINA_WEBAPP}/zumultapi \
    && mkdir -p ${CATALINA_WEBAPP}/zumultapi/downloads \
    && cp -f ${APP_HOME}/web.xml ${CATALINA_WEBAPP}/zumultapi/WEB-INF/web.xml

# Remove the unused default Tomcat application.
RUN rm -rf ${CATALINA_WEBAPP}/ROOT

# Make the container startup script executable.
RUN chmod 755 ${APP_HOME}/docker-entrypoint.sh

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -fsS http://localhost:8080/zumultapi/ > /dev/null || exit 1

ENTRYPOINT ["/usr/app/docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]

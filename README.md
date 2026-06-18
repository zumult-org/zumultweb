## Deploying using docker

Build image (also builds war and deploys using tomcat) and clone the EXMARaLDA demo corpus:

`docker build --build-arg GITHUB_PAT={your_github_pat} --build-arg GITHUB_USERNAME={your_github_username} . -t zumult`

Run the image in container:

`docker run --rm -p 8080:8080 --name zumult zumult:latest`

and visit http://localhost:8080/zumultapi/

Specifiying a different (local) folder as the corpusdata folder for container:

`docker run --rm -p 8080:8080 -v /your/local/path/to/data:/home/corpusdata --name zumult zumult:latest`

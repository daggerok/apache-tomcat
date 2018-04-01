# apache-tomcat [![Build Status](https://travis-ci.org/daggerok/apache-tomcat.svg?branch=master)](https://travis-ci.org/daggerok/apache-tomcat)
Apache Tomcat docker image automation build

## Tags

- [latest](https://github.com/daggerok/apache-tomcat/blob/master/Dockerfile) (based on [openjdk:8u151-jdk-alpine](https://hub.docker.com/_/openjdk/) image with JCE installed)
- [9.0.6](https://github.com/daggerok/apache-tomcat/blob/9.0.6/Dockerfile) (based on [openjdk:8u151-jdk-alpine](https://hub.docker.com/_/openjdk/) image with JCE installed)
- [9.0.2](https://github.com/daggerok/apache-tomcat/blob/9.0.2/Dockerfile) (based on [openjdk:8u151-jdk-alpine](https://hub.docker.com/_/openjdk/) image with JCE installed)
- [8.5.29](https://github.com/daggerok/apache-tomcat/blob/8.5.29/Dockerfile) (based on [openjdk:8u151-jdk-alpine](https://hub.docker.com/_/openjdk/) image with JCE installed)
- [8.5.24](https://github.com/daggerok/apache-tomcat/blob/8.5.24/Dockerfile) (based on [openjdk:8u151-jdk-alpine](https://hub.docker.com/_/openjdk/) image with JCE installed)

**Exposed ports**:

- 8080 - deployed web apps

## Usage:

### Health-check

Assuming you have `/health` in your `app`:

```

FROM daggerok/apache-tomcat:9.0.6
HEALTHCHECK --interval=2s --retries=22 \
        CMD wget -q --spider http://127.0.0.1:8080/app/health/ || exit 1
ADD ./build/libs/*.war ${TOMCAT_HOME}/webapps/app.war

```

### Remote debug

```

FROM daggerok/apache-tomcat:9.0.2-alpine
ARG JPDA_OPTS_ARG="${JAVA_OPTS} -agentlib:jdwp=transport=dt_socket,address=1043,server=y,suspend=n"
ENV JPDA_OPTS="${JPDA_OPTS_ARG}"
EXPOSE 5005
COPY ./target/*.war ${TOMCAT_HOME}/webapps/

```

### Multi-deployment

```

FROM daggerok/apache-tomcat:8.5.29-alpine
COPY ./path/to/some/*.war ./path/to/another/*.war ${TOMCAT_HOME}/webapps/

```

### Shell command

```

docker run --rm --name tomcat -d -p 8080:8080 daggerok/tomcat:8.5.24

```

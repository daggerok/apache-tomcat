# apache-tomcat [![Build Status](https://travis-ci.org/daggerok/apache-tomcat.svg?branch=master)](https://travis-ci.org/daggerok/apache-tomcat)
Apache Tomcat docker image automation build

## Tags

- 9.0.2 (based on openjdk:8u151-jdk-alpine image with JCE installed)
- 8.5.29 (based on openjdk:8u151-jdk-alpine image with JCE installed)
- 8.5.24 (based on openjdk:8u151-jdk-alpine image with JCE installed)

**Exposed ports**:

- 8080 - deployed apps

## Usage:

### Health-check

Assuming you have `/health` in your `app`:

```

FROM daggerok/apache-tomcat:9.0.2
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

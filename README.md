# apache-tomcat [![Build Status](https://travis-ci.org/daggerok/apache-tomcat.svg?branch=master)](https://travis-ci.org/daggerok/apache-tomcat)
Apache Tomcat 9.0.2 docker image (Linux Alpine, OpenJDK 8u151)

**Exposed ports**:

- 8080 - deployed apps

### Usage:

```

FROM daggerok/apache-tomcat:9.0.2
ADD ./build/libs/*.war ${TOMCAT_HOME}/webapps/
```

#### Remote debug:

```

FROM daggerok/apache-tomcat:9.0.2-alpine
ARG JPDA_OPTS_ARG=" ${JAVA_OPTS} -agentlib:jdwp=transport=dt_socket, address=1043, server=y, suspend=n "
ENV JPDA_OPTS="${JPDA_OPTS_ARG}"
EXPOSE 5005
COPY ./build/libs/*.war ./target/*.ear ${TOMCAT_HOME}/webapps/
```

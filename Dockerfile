# git clone https://github.com/daggerok/apache-tomcat
# docker build -t daggerok/apache-tomcat -f apache-tomcat/Dockerfile .
# docker tag daggerok/apache-tomcat daggerok/apache-tomcat:9.0.2-alpine
# docker tag daggerok/apache-tomcat daggerok/apache-tomcat:9.0.2
# docker tag daggerok/apache-tomcat daggerok/apache-tomcat:alpine
# docker tag daggerok/apache-tomcat daggerok/apache-tomcat:latest
# docker push daggerok/apache-tomcat

FROM openjdk:8u151-jdk-alpine
MAINTAINER Maksim Kostromin https://github.com/daggerok/docker

ARG TOMCAT_USER_ARG="tomcat"
ARG TOMCAT_ADMIN_USER_ARG="admin"
ARG TOMCAT_ADMIN_PASSWORD_ARG="Admin.123"
ARG TOMCAT_VERSION_ARG=9.0.2
ARG TOMCAT_FILE_ARG="apache-tomcat-${TOMCAT_VERSION_ARG}"
ARG TOMCAT_URL_ARG="http://apache.ip-connect.vn.ua/tomcat/tomcat-9/v${TOMCAT_VERSION_ARG}/bin/${TOMCAT_FILE_ARG}.zip"

ENV TOMCAT_USER=${TOMCAT_USER_ARG} \
    TOMCAT_ADMIN_USER=${TOMCAT_ADMIN_USER_ARG} \
    TOMCAT_ADMIN_PASSWORD=${TOMCAT_ADMIN_PASSWORD_ARG} \
    TOMCAT_FILE=${TOMCAT_FILE_ARG} \
    TOMCAT_URL=${TOMCAT_URL_ARG}
#ENV TOMCAT_URL="http://apache.ip-connect.vn.ua/tomcat/tomcat-7/v7.0.82/bin/apache-tomcat-7.0.82.zip" \
#ENV TOMCAT_URL="http://apache.ip-connect.vn.ua/tomcat/tomcat-8/v8.5.24/bin/apache-tomcat-8.5.24.zip" \
#ENV TOMCAT_URL="http://apache.ip-connect.vn.ua/tomcat/tomcat-9/v9.0.2/bin/apache-tomcat-9.0.2.zip" \
ENV TOMCAT_USER_HOME="/home/${TOMCAT_USER}"
ENV TOMCAT_HOME="${TOMCAT_USER_HOME}/${TOMCAT_FILE}"

RUN apk --no-cache --update add busybox-suid bash wget ca-certificates unzip sudo openssh-client shadow \
 && addgroup ${TOMCAT_USER}-group \
 && echo "${TOMCAT_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
 && sed -i "s/.*requiretty$/Defaults !requiretty/" /etc/sudoers \
 && adduser -h ${TOMCAT_USER_HOME} -s /bin/bash -D -u 1025 ${TOMCAT_USER} ${TOMCAT_USER}-group \
 && usermod -a -G wheel ${TOMCAT_USER} \
 && apk --no-cache del busybox-suid shadow \
 && rm -rf /var/cache/apk/* /tmp/*

USER ${TOMCAT_USER}
WORKDIR ${TOMCAT_USER_HOME}

CMD /bin/bash
EXPOSE 8080
ENTRYPOINT /bin/bash ${TOMCAT_HOME}/bin/catalina.sh start \
        && mkdir -p ${TOMCAT_HOME}/logs \
        && touch ${TOMCAT_HOME}/logs/catalina.out \
        && tail -f ${TOMCAT_HOME}/logs/catalina.out

RUN wget ${TOMCAT_URL} -O "${TOMCAT_USER_HOME}/${TOMCAT_FILE}.zip" \
 && unzip "${TOMCAT_USER_HOME}/${TOMCAT_FILE}.zip" -d ${TOMCAT_USER_HOME} \
 && rm -rf "${TOMCAT_USER_HOME}/${TOMCAT_FILE}.zip"

## apply base image:
#FROM daggerok/apache-tomcat:9.0.2-alpine
## healthy check:
#HEALTHCHECK --interval=1s --timeout=3s --retries=30 \
# CMD wget -q --spider http://127.0.0.1:8080/plain-http-servlet/ \
#  || exit 1
## debug:
#ARG JPDA_OPTS_ARG=" ${JAVA_OPTS} -agentlib:jdwp=transport=dt_socket, address=1043, server=y, suspend=n "
#ENV JPDA_OPTS="${JPDA_OPTS_ARG}"
#EXPOSE 5005
## deploy apps:
#COPY ./path/to/*.war ./path/to/another/*.war ${TOMCAT_HOME}/webapps/

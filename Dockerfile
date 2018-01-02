##### USAGE BEGIN #####
#
# # apply base image:
# FROM daggerok/apache-tomcat:8.5.24
#
# # healthy check:
# HEALTHCHECK --interval=1s --timeout=3s --retries=30 \
# CMD wget -q --spider http://127.0.0.1:8080/plain-http-servlet/ \
#  || exit 1
#
# # debug:
# ARG JPDA_OPTS_ARG=" ${JAVA_OPTS} -agentlib:jdwp=transport=dt_socket, address=1043, server=y, suspend=n "
# ENV JPDA_OPTS="${JPDA_OPTS_ARG}"
# EXPOSE 5005
#
# # deploy apps:
# COPY ./path/to/*.war ./path/to/another/*.war ${TOMCAT_HOME}/webapps/
#
##### USAGE END #####

FROM openjdk:8u151-jdk-alpine
MAINTAINER Maksim Kostromin https://github.com/daggerok/docker

ARG TOMCAT_RELEASE=8
ARG TOMCAT_VERSION=8.5.24
ARG TOMCAT_USER_ARG="tomcat"
ARG TOMCAT_FILE_ARG="apache-tomcat-${TOMCAT_VERSION}"
ARG TOMCAT_URL_ARG="https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_RELEASE}/v${TOMCAT_VERSION}/bin/${TOMCAT_FILE_ARG}.zip"

ENV JAVA_VERSION="7"
ENV TOMCAT_USER=${TOMCAT_USER_ARG} \
    TOMCAT_GROUP=${TOMCAT_USER_ARG}-group \
    TOMCAT_FILE=${TOMCAT_FILE_ARG} \
    TOMCAT_URL=${TOMCAT_URL_ARG}
ENV TOMCAT_USER_HOME="/home/${TOMCAT_USER}"
ENV TOMCAT_HOME="${TOMCAT_USER_HOME}/${TOMCAT_FILE}"

RUN apk --no-cache --update add busybox-suid bash wget ca-certificates unzip sudo openssh-client shadow \
 && addgroup ${TOMCAT_GROUP} \
 && echo "${TOMCAT_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
 && sed -i "s/.*requiretty$/Defaults !requiretty/" /etc/sudoers \
 && adduser -h ${TOMCAT_USER_HOME} -s /bin/bash -D -u 1025 ${TOMCAT_USER} ${TOMCAT_GROUP} \
 && usermod -a -G wheel ${TOMCAT_USER} \
 && apk del busybox-suid shadow \
 && rm -rf /var/cache/apk/* /tmp/*

USER ${TOMCAT_USER}
WORKDIR ${TOMCAT_USER_HOME}

CMD /bin/bash
EXPOSE 8080
ENTRYPOINT /bin/bash ${TOMCAT_HOME}/bin/catalina.sh start \
        && touch ${TOMCAT_HOME}/logs/catalina.out \
        && chown -R ${TOMCAT_USER}:${TOMCAT_GROUP} ${TOMCAT_HOME}/logs/catalina.out \
        && tail -f ${TOMCAT_HOME}/logs/catalina.out

RUN wget ${TOMCAT_URL} -O "${TOMCAT_USER_HOME}/${TOMCAT_FILE}.zip" \
 && unzip "${TOMCAT_USER_HOME}/${TOMCAT_FILE}.zip" -d ${TOMCAT_USER_HOME} \
 && rm -rf "${TOMCAT_USER_HOME}/${TOMCAT_FILE}.zip"

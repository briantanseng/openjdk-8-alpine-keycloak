FROM java:openjdk-8-alpine

RUN apk update && \
    apk --no-cache add wget bash \
 && rm -rf /var/cache/apk/*

ENV KEYCLOAK_VERSION 4.3.0.Final
ENV MSSQL_JDBC_VERSION 7.0.0.jre8

RUN wget -nv https://downloads.jboss.org/keycloak/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz && \
    tar xfz keycloak-$KEYCLOAK_VERSION.tar.gz -C / && \
    mv /keycloak-$KEYCLOAK_VERSION /keycloak && \
    rm -rf /keycloak-$KEYCLOAK_VERSION.tar.gz

RUN addgroup -g 1000 keycloak && \
    adduser -u 1000 -D -h /keycloak -s /bin/bash -G keycloak keycloak

RUN mkdir -p /keycloak/modules/system/layers/base/com/microsoft/sqlserver/jdbc/main && \
    wget -nv http://central.maven.org/maven2/com/microsoft/sqlserver/mssql-jdbc/$MSSQL_JDBC_VERSION/mssql-jdbc-$MSSQL_JDBC_VERSION.jar && \
    mv mssql-jdbc-$MSSQL_JDBC_VERSION.jar /keycloak/modules/system/layers/base/com/microsoft/sqlserver/jdbc/main/mssql-jdbc.jar

# Set the default JAVA_OPTS
ENV JAVA_OPTS -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Addresses=true -Djava.security.egd=file:/dev/./urandom

ADD configuration/standalone.xml /keycloak/standalone/configuration/standalone.xml
ADD databases/mssql/module.xml /keycloak/modules/system/layers/base/com/microsoft/sqlserver/jdbc/main

RUN chmod -R 755 /keycloak

WORKDIR /keycloak
USER keycloak

ADD docker-entrypoint.sh /keycloak/

EXPOSE 8080

HEALTHCHECK --interval=20s --timeout=5s \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/ || exit 1

CMD /keycloak/docker-entrypoint.sh

FROM openjdk:8-jdk-alpine
VOLUME /tmp
ADD workplace/target/*jar app.jar
ENTRYPOINT [ "java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/app.jar" ]


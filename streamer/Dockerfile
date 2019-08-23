FROM maven:3-ibmjava-8-alpine

WORKDIR /app

COPY pom.xml pom.xml

RUN mvn -B -f pom.xml -s /usr/share/maven/ref/settings-docker.xml dependency:resolve

COPY . .

CMD ["mvn", "compile", "exec:java"]
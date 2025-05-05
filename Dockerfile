FROM tomcat:9.0

# Instala curl para baixar o Jolokia agent
RUN apt-get update && apt-get install -y curl

# Baixa o Jolokia Agent JAR
RUN curl -L -o /usr/local/tomcat/lib/jolokia-agent.jar https://repo1.maven.org/maven2/org/jolokia/jolokia-jvm/1.7.2/jolokia-jvm-1.7.2-agent.jar

# Copia o Jenkins WAR
COPY jenkins.war /usr/local/tomcat/webapps/jenkins.war

# Define as variáveis para habilitar o Jolokia agent
ENV JAVA_OPTS="-javaagent:/usr/local/tomcat/lib/jolokia-agent.jar=host=0.0.0.0,port=8778"
ENV CATALINA_OPTS="-javaagent:/usr/local/tomcat/lib/jolokia-agent.jar=host=0.0.0.0,port=8778"

# Expõe portas do Tomcat e Jolokia
EXPOSE 8080 8778

CMD ["catalina.sh", "run"]

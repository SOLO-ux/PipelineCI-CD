FROM tomcat:8.0.20-jre8

RUN mkdir /usr/local/tomcat/webapps/myapp

COPY /kubernetes/MCI /usr/local/tomcat/webapps/MCI

# Kafka and Zookeeper

FROM openjdk:8-jdk

# Install Kafka, Zookeeper and other needed things
RUN apt-get update
RUN apt-get install -y wget supervisor dnsutils 
RUN rm -rf /var/lib/apt/lists/* 
RUN apt-get clean 
RUN wget -q http://apache.rediris.es/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz -O /tmp/spark.tgz && \
    tar xfz /tmp/spark.tgz -C /opt 

CMD ["supervisord", "-n"]


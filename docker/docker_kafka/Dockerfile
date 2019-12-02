# Kafka and Zookeeper

FROM openjdk:8-jdk

ENV ZOOKEEPER_VERSION 3.5.5
ENV ZOOKEEPER_HOME /opt/zookeeper-"$ZOOKEEPER_VERSION"

RUN wget http://apache.org/dist/zookeeper/zookeeper-"$ZOOKEEPER_VERSION"/apache-zookeeper-"$ZOOKEEPER_VERSION"-bin.tar.gz -O /tmp/zookeeper-"$ZOOKEEPER_VERSION".tgz

ENV SCALA_VERSION 2.12
ENV KAFKA_VERSION 2.3.0
ENV KAFKA_HOME /opt/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION"

# Install Kafka, Zookeeper and other needed things
RUN apt-get update
RUN apt-get install -y zookeeper wget supervisor dnsutils 
RUN rm -rf /var/lib/apt/lists/* 
RUN apt-get clean 
RUN wget -q http://apache.uvigo.es/kafka/"$KAFKA_VERSION"/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz -O /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz && \
    tar xfz /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz -C /opt 


# 2181 is zookeeper, 9092 is kafka
EXPOSE 2181 9092

CMD ["supervisord", "-n"]


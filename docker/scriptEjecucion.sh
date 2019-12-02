#!/bin/bash

s=$(pwd)

sudo apt update
sudo apt install -y xterm
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
sudo apt install docker-ce
sudo usermod -aG docker ${USER}
su - ${USER} &
id -nG
sudo usermod -aG docker $USER

cd $s

cd docker_kafka
docker build -t bdfi/kafka .
cd ../docker_spark
docker build -t bdfi/spark .
cd ../docker_server
docker build -t bdfi/server .
cd ..

xterm -e "docker-compose up;bash" &

sleep 60

xterm -e "docker exec -it kafka /opt/kafka_2.12-2.3.0/bin/zookeeper-server-start.sh /opt/kafka_2.12-2.3.0/config/zookeeper.properties;bash" &
sleep 15
xterm -e "docker exec -it kafka /opt/kafka_2.12-2.3.0/bin/kafka-server-start.sh /opt/kafka_2.12-2.3.0/config/server.properties;bash" &
sleep 15 
docker exec -it kafka /opt/kafka_2.12-2.3.0/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic flight_delay_classification_request

docker exec -it mongo /practica/resources/import_distances.sh

sleep 10

xterm -e "docker exec -it spark /opt/spark-2.4.4-bin-hadoop2.7/bin/spark-submit --class es.upm.dit.ging.predictor.MakePrediction --packages org.mongodb.spark:mongo-spark-connector_2.11:2.3.2,org.apache.spark:spark-sql-kafka-0-10_2.11:2.4.0 /practica/flight_prediction/target/scala-2.11/flight_prediction_2.11-0.1.jar;bash" &

sleep 10

xterm -e "docker exec -it server python3 /resources/web/predict_flask.py;bash" &

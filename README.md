# BigData-Predictor

The following system is the basic architecture for the development of a flight predictor assignment. In order to implement the solution, the next systems have been used:

  - Flask server for the development of the web interface. Python language is used.
  - Apache Spark to create the data model and make the predictions. The data model is generated using the algorithm RandomForest. The training process is done PySpark. Onece we have the model any client can generate a request for a new flight and the system will predict the possible delay using the model.
  - Kafka and Zookeeper as a messagging system based on a publish/subscribe system. A topic is generated and all consumer can see the messages related to it.
  - MongoDB as the database to save the predictions made by Spark.

### Development without modifications

For the development of the system it is needed to download the file from GitHub:
> https://github.com/ging/practica_big_data_2019

Afterwards, all the systems are installed executing the scriptInstalacion.sh in the selected directory to develop the services:

```sh
$ ./scriptInstalacion.sh
```
Using this script everything is installed and executed:

 - All the services are downloaded and installed
 - The data model is trained.
 - Kafka and Zookeeper is started up so as to communicate the web service with the prediction job using the topic "flight_delay_classification_request".
 - MongoDB is launched services where the web service look for the prediction, which has been previously saved by Spark Streaming in the database.
 - Spark is started to generate the model and, then, the predictions, that are allocated later in Mongo database.
 - The web service is launched to make a request in the Web Application.

### Development with spark-submit

Spark-submit allow us to execute the prediction job without using IntelliJ. This means, generating a file .jar. This step is also included in the scriptInstalation.sh explained before. The next command is used:

```sh
$ /opt/spark/bin/spark-submit --class es.upm.dit.ging.predictor.MakePrediction --packages org.mongodb.spark:mongo-spark-connector_2.11:2.3.2,org.apache.spark:spark-sql-kafka-0-10_2.11:2.4.0 /target/scala-2.12/flight_prediction_2.12-0.1.jar
```

were the --class argument is the .scala class of the project to make the prediction and package is the file .jar generated by SBT utils.

We were looking for a solution before the teachers uploaded the possible solution to create the jar file and be able to compile it with spark-submit. In scriptInstalacion.sh you can see the existence of compilarSpark() method. This method is mainly responsible for changing the Scala version . This is because Spark 2.4.4 comes with the version of Scala 2.11 which was not favorable for the compilation of the prediction job, that will be going to be executed later with spark-submit. So, using this method the Scala version could be changed and so, the job would compile correctly using spark-submit.



### Docker development

The development using Docker has been done following the next steps:
- Creating the Dockerfiles in order to generate the images of the different services Spark, Kafka and Zookeeper and the web service.
- Generating the docker images.
- Creating the docker-compose.yml file so as to connect all the containers.
- Executing the docker-compose.yml

**Create the Dockerfiles**

The dockerfiles can be found in the docker folder of the repository and it has been decided to create the next ones:
- Kafka+Zookeeper Dockerfile because they always are executed together. This Dockerfile has a image base of openjdk:8-jdk so it isn't needed to install java. In addition, it is necessary to expose the ports 2181 for zookeeper and 9092 for kafka.
- Spark Dockerfile. This Dockerfile also has a image base of openjdk:8-jdk, downloads and installs spark.
- WebService Dockerfile. This Dockerfile has a image base of python:3.7 and includes by copying, the requieremnts.txt and the other files needed to execute the web interface.


With these Dockerfiles we generate the images we are going to use in the docker-compose.yml file. The docker-compose.yml can be executed using the next command in the directory where we have the docker-compose.yml file:

```sh
$ sudo docker-compose up
```

However, to make this task easier it has been developed a scriptEjecucion.sh. So, for the executiong of the system using docker, you must use the next command when you are in the principal folder of the project (/bigdata-predictor):

```sh
$ cd docker
$ ./scriptEjecucion.sh
```

This script installs what is needed for the depployment of the docker environment:
- Installation of Docker.
- Execution of the Dockerfiles to create the different images.
- Execution of the docker-compose.yml.
- Start up of the kafka and zookeeper services and the creation of the kafka topics as well.
- Start mongo.
- Execution of the prediction job using spark-submit.
- Execution of the web server interface. 

It can be noticed that if we use docker for the implementation we are adding a new layer, so the hostname (localhost) is changed, so we have to indicate the correct hostname and path.

----

## References

1. [https://github.com/ging/practica_big_data_2019](https://github.com/ging/practica_big_data_2019)
2. [https://hub.docker.com/r/bde2020/spark-base](https://hub.docker.com/r/bde2020/spark-base)
3. [https://github.com/ging/fiware-global-summit-berlin-2019-ml](https://github.com/ging/fiware-global-summit-berlin-2019-ml)
  




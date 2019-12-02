#!/bin/bash

#ayuda(){
#	echo "./scriptInstalacion [Opcion 1] [Opcion 2]"
#	echo "##Opcion 1##"
#	echo "completeInstalation [Opcion2]"
#	echo "runWithSbt"
#	echo "runWithSparkSubmit"
#	echo "trainModel"
#	echo "	##Opcion 2##"
#	echo "	runWithSbt"
#	echo "	runWithSparkSubmit"
#}


###Instalar todo lo necesario
installation(){
	sudo apt install -y openjdk-8-jdk
	
	sudo apt install -y python-pip
	sudo apt install -y python3-pip
	
	echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
	sudo apt install -y curl
	curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add
	sudo apt-get update
	sudo apt-get install -y sbt
	
	wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
	echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
	sudo apt-get update
	sudo apt-get install -y mongodb-org

	wget http://apache.rediris.es/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz
	tar -xvzf spark-2.4.4-bin-hadoop2.7.tgz

	wget http://ftp.cixug.es/apache/zookeeper/current/apache-zookeeper-3.5.6-bin.tar.gz
	tar -xvzf apache-zookeeper-3.5.6-bin.tar.gz

	wget http://apache.uvigo.es/kafka/2.3.0/kafka_2.12-2.3.0.tgz
	tar -xvzf kafka_2.12-2.3.0.tgz

	sudo apt install -y xterm	

	git clone https://github.com/ging/practica_big_data_2019.git

	cd practica_big_data_2019
	resources/download_data.sh

	for line in $(cat requirements.txt); do  pip install $line; done
	pip install pyspark
	for line in $(cat requirements.txt); do  pip3 install $line; done
	pip3 install pyspark

	mkdir data
	mv origin_dest_distances.jsonl data/
	resources/import_distances.sh

	cd ..
}

normalInit(){
	##Start mongo
	sudo service mongod start
	##zookeper y kafka
	cd kafka_2.12-2.3.0
	xterm -e "bin/zookeeper-server-start.sh config/zookeeper.properties;bash" &
	xterm -e "bin/kafka-server-start.sh config/server.properties;bash" &
	bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic flight_delay_classification_request
	cd ..
}

entrenarModelo(){
	###Entrenar modelo
	cd spark-2.4.4-bin-hadoop2.7
	export SPARK_HOME=`pwd`
	
	cd ../practica_big_data_2019
	mv simple_flight_delay_features.jsonl.bz2 data/
	python3 resources/train_spark_mllib_model.py .
	cd ..
}

crearPaquete(){
	###Crear paquete
	cd practica_big_data_2019
	sed -i 's:val base_path= "/home/user/Desktop/practica_big_data_2019":val base_path= "'`pwd`'":g' flight_prediction/src/main/scala/es/upm/dit/ging/predictor/MakePrediction.scala
	cd flight_prediction
	sbt clean
	sbt compile
	sbt package
	cd ../../
}

compilarSpark(){
	###Compilar spark con scala 2.12.9
	git clone https://github.com/apache/spark.git
	cd spark
	git checkout tags/v2.4.4
	sed -i 's/unidocGenjavadocVersion := "0.11",/unidocGenjavadocVersion := "0.14",/g' project/SparkBuild.scala
	./dev/change-scala-version.sh 2.12
	./build/sbt -Dscala.version=2.12.9 package
	cd ..
}

sparkSubmit(){
	##Ejecutar con spark-submit
	xterm -e "spark-2.4.4-bin-hadoop2.7/bin/spark-submit --class es.upm.dit.ging.predictor.MakePrediction --packages org.mongodb.spark:mongo-spark-connector_2.11:2.3.2,org.apache.spark:spark-sql-kafka-0-10_2.11:2.4.0 	practica_big_data_2019/flight_prediction/target/scala-2.11/flight_prediction_2.11-0.1.jar;bash" &
}

runSbt(){
	cd practica_big_data_2019/flight_prediction
	sbt clean
	sbt compile
	xterm -e "sbt 'runMain es.upm.dit.ging.predictor.MakePrediction';bash" &
	cd ../../
}

pythonServer(){
	##Ejecutar servidor web
	cd practica_big_data_2019
	export PROJECT_HOME=`pwd`
	cd resources/web/
	xterm -e "python3 predict_flask.py;bash" &

	firefox -new-window http://localhost:5000/flights/delays/predict_kafka
}

installation
normalInit
entrenarModelo
crearPaquete
sparkSubmit
pythonServer

# if [ "$1" == "completeInstalation" ]; then
	# echo "instalacionCompleta"
	# if [ "$2" == "runWithSbt" ]; then
		# echo "run with sbt"
		# installation
		# normalInit
		# entrenarModelo
		# crearPaquete
		# compilarSpark
		# runSbt
		# pythonServer
	# elif [ "$2" == "runWithSparkSubmit" ]; then
		# echo "run with spark-submit"
		# installation
		# normalInit
		# entrenarModelo
		# crearPaquete
		# compilarSpark
		# sparkSubmit
		# pythonServer
	# else
		# echo "ayuda"
		# ayuda
	# fi
# elif [ "$1" == "runWithSbt" ]; then
	# echo "run with sbt"
	# normalInit
	# runSbt
	# pythonServer
# elif [ "$1" == "runWithSparkSubmit" ]; then
	# echo "run with spark-submit"
	# normalInit
	# sparkSubmit
	# pythonServer
# elif [ "$1" == "trainModel" ]; then
	# echo "train model"
	# entrenarModelo
# else 
	# echo "ayuda"
	# ayuda
# fi





# Kafka and Zookeeper

FROM python:3.7

COPY ./requirements.txt /requirements.txt
COPY ./resources/web /resources/web

ENV PROJECT_HOME=/
RUN pip3 install -r /requirements.txt
RUN apt-get update
RUN apt-get install -y supervisor  

CMD chmod +x /resources/web/predict_flask.py

CMD ["supervisord", "-n"]

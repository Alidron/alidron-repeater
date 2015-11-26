FROM alidron/alidron-base-python:2
MAINTAINER Axel Voitier <axel.voitier@gmail.com>

RUN pip install python-consul

COPY . /usr/src/alidron-repeater
WORKDIR /usr/src/alidron-repeater

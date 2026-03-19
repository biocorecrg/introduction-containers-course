FROM ubuntu:22.04

WORKDIR ~

RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y wget

ENTRYPOINT ["/usr/bin/wget"]
CMD ["https://upload.wikimedia.org/wikipedia/commons/7/77/Blue_Whale_Cartoon.jpg"]

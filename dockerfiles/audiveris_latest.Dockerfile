## This container builds and runs the latest development branch version of the 
# Audiveris music notation software https://github.com/Audiveris/audiveris
# Image build process is copied from https://github.com/weidi/audiveris-docker/blob/master/Dockerfile
# Previous pushed dev image at https://hub.docker.com/r/toprock/audiveris is from a year ago.

FROM debian:stretch-slim

RUN apt-get update && apt-get install -y  \
  curl \
  wget \
  git \
  tesseract-ocr \
  tesseract-ocr-eng

RUN wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.deb \
  && apt install -y ./jdk-17_linux-x64_bin.deb \
  && rm ./jdk-17_linux-x64_bin.deb

ENV JAVA_HOME=/usr/lib/jvm/jdk-17/ 
ENV PATH=$PATH:$JAVA_HOME/bin 

RUN  git clone --branch development https://github.com/Audiveris/audiveris.git audiveris-build  && \
  cd audiveris-build && \
  ./gradlew build && \
  mkdir /audiveris-extract && \
  tar -xvf /audiveris-build/build/distributions/Audiveris*.tar -C /audiveris-extract && \
  mv /audiveris-extract/Audiveris*/* /audiveris-extract/ &&\
  rm -r /audiveris-build

CMD ["sh", "-c", "/audiveris-extract/bin/Audiveris -batch -export -output /output/ $(ls /input/*.jpg /input/*.png /input/*.pdf)"]
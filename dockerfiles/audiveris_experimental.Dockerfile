## This container builds the latest prototype version (>6.0) of the
# Audiveris music notation software https://github.com/Audiveris/audiveris
# Image build process is copied and modified from https://github.com/weidi/audiveris-docker/blob/master/Dockerfile
# TODO: Docker Compose file for running the detection algorithm in the background

FROM debian:stretch-slim

RUN apt-get update && apt-get install -y  \
  curl \
  wget \
  git \
  openjdk-8-jdk \
  tesseract-ocr \
  tesseract-ocr-eng

RUN  git clone --branch dws https://github.com/Audiveris/audiveris.git audiveris-build  && \
  cd audiveris-build && \
  ./gradlew build && \
  mkdir /audiveris-extract && \
  tar -xvf /audiveris-build/build/distributions/Audiveris*.tar -C /audiveris-extract && \
  mv /audiveris-extract/Audiveris*/* /audiveris-extract/ &&\
  rm -r /audiveris-build

## add the model weights from google drive
RUN mkdir /audiveris-extract/res && \
  wget "https://drive.google.com/u/0/uc?id=1iXr3KGCVgzCGP9CUo1tefis3GFBwCxSQ&export=download" -O /audiveris-extract/res/patch_classifier.h5

CMD ["sh", "-c", "/audiveris-extract/bin/Audiveris -batch -export -output /output/ $(ls /input/*.jpg /input/*.png /input/*.pdf)"]
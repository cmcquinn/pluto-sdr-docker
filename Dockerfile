FROM debian:buster-slim
LABEL maintainer="cameron.mcquinn@gmail.com"
COPY init.sh /tmp/init.sh
RUN /tmp/init.sh
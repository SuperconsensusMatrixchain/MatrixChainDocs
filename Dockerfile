### 构建docker容器
FROM ubuntu:18.04
USER root
RUN apt update \
	&& apt install git npm \
	&& npm install -g gitbook-cli \
	&& git clone https://github.com/superconsensus/MatrixChainDocs.git \
	&& cd MatrixChainDocs
EXPOSE 4000
CMD gitbook serve
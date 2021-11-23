build:
	sudo docker build -t matrixchaindocs:v1.0 .
run:
	sudo docker run -p 4000:80 --name matrixchaindocs -d matrixchaindocs:v1.0
stop:
	sudo docker stop matrixchaindocs
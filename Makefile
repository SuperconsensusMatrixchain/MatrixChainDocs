build:
	sudo docker build -t matrixchaindocs:v1.0 .
run:
	sudo docker run -p 4000:80 --name matrixchaindocs -d matrixchaindocs:v1.0
stop:
	sudo docker stop matrixchaindocs
rebuild:
	## 重新构建,用于更新内容
	# 停掉容器
	sudo docker stop matrixchaindocs
	# 删除容器
	sudo docker rm matrixchaindocs
	# 删除镜像
	sudo docker rmi matrixchaindocs:v1.0
	# 重新build
	sudo docker build -t matrixchaindocs:v1.0 .
all:
	make -C client release && make -C server run

binary:
	cd InferRules && ./gradlew build -x test && tar xvf ./build/distributions/InferRules-1.0-SNAPSHOT.tar -C ./build/distributions

docker:
	docker build --platform linux/amd64 --tag auto-comby-ubuntu-20.04 .

run:
	docker run --platform linux/amd64 -p 8080:8080 -e SERVER_URL='http://localhost:8080' auto-comby-ubuntu-20.04

.PHONY:
	all binary docker run

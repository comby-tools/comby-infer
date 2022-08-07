all:
	make -C client release && make -C server run

docker:
	docker build --platform linux/amd64 --tag auto-comby-ubuntu-20.04 .

run:
	docker run --platform linux/amd64 -p 8080:8080 auto-comby-ubuntu-20.04

.PHONY:
	all docker run

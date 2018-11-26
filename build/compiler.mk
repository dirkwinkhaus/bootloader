build-compiler:
	docker build -t widi/preos-compiler src/infrastructure/docker/

setup-compiler: build-compiler
	docker run -v `pwd`/iso:/iso -v `pwd`/src:/source -v `pwd`/rc:/release --name=compiler -d -it widi/preos-compiler

bash-compiler:
	docker exec -it compiler /bin/bash

start-compiler:
	docker start compiler

stop-compiler:
	docker stop compiler

remove-compiler: stop-compiler
	docker rm compiler

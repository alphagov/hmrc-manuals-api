#!make

build-deploy:
	make build
	make deploy
up:
	docker-compose pull
	docker-compose up -d --build --remove-orphans

start:
	docker-compose start

stop-all-containers:
	echo "Stopping all containers"
	ids=$$(docker ps -a -q) && if [ "$${ids}" != "" ]; then docker stop $${ids}; fi

stop:
	docker-compose stop

open:
	open "http://localhost:3071"

build:
	docker build -t marcelovani/hmrc-manuals-api:latest .

deploy:
	docker push marcelovani/hmrc-manuals-api:latest

test:
	docker-compose exec -i gds_api sh -c "bundle exec rake"

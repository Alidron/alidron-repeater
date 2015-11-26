image_name = alidron/alidron-repeater
rpi_image_name = alidron/rpi-alidron-repeater
registry = registry.tinigrifi.org:5000

network_name = alidron
container_name = alidron-repeater
consul_host = 192.168.1.5

.PHONY: clean clean-dangling build build-rpi push push-rpi pull pull-rpi run run-it run-rpi bash bash-rpi exec-bash stop logs

clean:
	docker rmi $(image_name) || true

clean-dangling:
	docker rmi `docker images -q -f dangling=true` || true

build: clean-dangling
	docker build --force-rm=true -t $(image_name) .

build-rpi: clean-dangling
	docker build --force-rm=true -t $(rpi_image_name) -f Dockerfile-rpi .

push:
	docker tag -f $(image_name) $(registry)/$(image_name)
	docker push $(registry)/$(image_name)

push-rpi:
	docker tag -f $(rpi_image_name) $(registry)/$(rpi_image_name)
	docker push $(registry)/$(rpi_image_name)

pull:
	docker pull $(registry)/$(image_name)
	docker tag $(registry)/$(image_name) $(image_name)

pull-rpi:
	docker pull $(registry)/$(rpi_image_name)
	docker tag $(registry)/$(rpi_image_name) $(rpi_image_name)

run:
	docker run -d --net=$(network_name) --name=$(container_name) -p 2340:2340 -e "DONT_IP=`hostname -I`" $(image_name) python zbeacon_repeater.py $(consul_host)

run-it:
	docker run -it --rm --net=$(network_name) --name=$(container_name) -p 2340:2340 -e "DONT_IP=`hostname -I`" $(image_name) python zbeacon_repeater.py $(consul_host)

run-rpi:
	docker run -d --net=$(network_name) --name=$(container_name)-rpi -p 2340:2340 -e "DONT_IP=`hostname -I`" $(rpi_image_name) python zbeacon_repeater.py $(consul_host)

run-rpi-it:
	docker run -it --rm --net=$(network_name) --name=$(container_name)-rpi -p 2340:2340 -e "DONT_IP=`hostname -I`" $(rpi_image_name) python zbeacon_repeater.py $(consul_host)

bash:
	docker run -it --rm --net=$(network_name) -p 2340:2340 -e "DONT_IP=`hostname -I`" $(image_name) bash

bash-rpi:
	docker run -it --rm --net=$(network_name)-rpi -p 2340:2340 -e "DONT_IP=`hostname -I`" $(rpi_image_name) bash

exec-bash:
	docker exec -it $(container_name) bash

stop:
	docker stop -t 5 $(container_name)
	docker rm $(container_name)

logs:
	docker logs -f $(container_name)

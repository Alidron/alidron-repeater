# Copyright 2015 - Alidron's authors
#
# This file is part of Alidron.
# 
# Alidron is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Alidron is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License
# along with Alidron.  If not, see <http://www.gnu.org/licenses/>.

image_name = alidron/alidron-repeater
rpi_image_name = alidron/rpi-alidron-repeater
private_rpi_registry = neuron.local:6667

network_name = alidron
container_name = alidron-repeater
consul_host = 192.168.1.5

.PHONY: clean clean-dangling build build-rpi push push-rpi push-rpi-priv pull pull-rpi pull-rpi-priv run run-it run-rpi bash bash-rpi exec-bash stop stop-rpi logs logs-rpi

clean:
	docker rmi $(image_name) || true

clean-dangling:
	docker rmi `docker images -q -f dangling=true` || true

build: clean-dangling
	docker build --force-rm=true -t $(image_name) .

build-rpi: clean-dangling
	docker build --force-rm=true -t $(rpi_image_name) -f Dockerfile-rpi .

push:
	docker push $(image_name)

push-rpi:
	docker push $(rpi_image_name)

push-rpi-priv:
	docker tag -f $(rpi_image_name) $(private_rpi_registry)/$(rpi_image_name)
	docker push $(private_rpi_registry)/$(rpi_image_name)

pull:
	docker pull $(image_name)

pull-rpi:
	docker pull $(rpi_image_name)

pull-rpi-priv:
	docker pull $(private_rpi_registry)/$(rpi_image_name)
	docker tag $(private_rpi_registry)/$(rpi_image_name) $(rpi_image_name)

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
	docker stop -t 1 $(container_name)
	docker rm $(container_name)

stop-rpi:
	docker stop -t 3 $(container_name)-rpi
	docker rm $(container_name)-rpi

logs:
	docker logs -f $(container_name)

logs-rpi:
	docker logs -f $(container_name)-rpi
	

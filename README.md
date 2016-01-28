Alidron repeater
================

[![build status](https://git.tinigrifi.org/ci/projects/6/status.png?ref=master)](https://git.tinigrifi.org/ci/projects/6?ref=master) [![Gitter](https://badges.gitter.im/gitterHQ/gitter.svg)](https://gitter.im/Alidron/talk)

Made to workaround an [issue](https://github.com/docker/docker/issues/17814) in Docker.

Listen for UDP broadcast from ZBeacon (through the original ZBeacon actor from Pyre).
Publish these packets on a PUB socket.
Other repeaters connect to the PUB sockets of all other repeaters.
Repeaters are discovered through the Consul service used by Docker to create its multi-host network.
Any packet received on the SUB socket is then repeated locally by a UDP broadcast, reusing ZBeacon class.

The Zbeacon and Pyre protocol had to be changed for this to work:
- Allow the Zbeacon actor to transmit an abitrary packet (API exposed through its internal actor pipe).
- PyreNode understand that if the received UDP packet is longer than normal, then it considers that the remaining bytes are the original IP address (as a string) instead of the one from which it received the packet from (which would be a repeater address).

Docker containers
=================

The Docker images are accessible on:
* x86: [alidron/alidron-repeater](https://hub.docker.com/r/alidron/alidron-repeater/)
* ARM/Raspberry Pi: [alidron/rpi-alidron-repeater](https://hub.docker.com/r/alidron/rpi-alidron-repeater/)

Dockerfiles are accessible from the Github repository:
* x86: [Dockerfile](https://github.com/Alidron/alidron-repeater/blob/master/Dockerfile)
* ARM/Raspberry Pi: [Dockerfile](https://github.com/Alidron/alidron-repeater/blob/master/Dockerfile-rpi)

Run
===

In the following command replace CONSUL_HOST with the address/IP of the consul service Docker is using for its multi-host networking.
```
$ docker run -d -p 2340:2340 -e "DONT_IP=`hostname -I`" alidron/alidron-repeater python zbeacon_repeater.py CONSUL_HOST
```

License and contribution policy
===============================

This project is licensed under LGPLv3.

To contribute, please, follow the [C4.1](http://rfc.zeromq.org/spec:22) contribution policy.

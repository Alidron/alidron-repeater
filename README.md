Made to workaround an [issue](https://github.com/docker/docker/issues/17814) in Docker.

Listen for UDP broadcast from ZBeacon (through the original ZBeacon actor from Pyre).
Publish these packets on a PUB socket.
Other repeaters connect to the PUB sockets of all other repeaters.
Repeaters are discovered through the Consul service used by Docker to create its multi-host network.
Any packet received on the SUB socket is then repeated locally by a UDP broadcast, reusing ZBeacon class.

The Zbeacon and Pyre protocol had to be changed for this to work:
- Allow the Zbeacon actor to transmit an abitrary packet (API exposed through its internal actor pipe).
- PyreNode understand that if the received UDP packet is longer than normal, then it considers that the remaining bytes are the original IP address (as a string) instead of the one from which it received the packet from (which would be a repeater address).

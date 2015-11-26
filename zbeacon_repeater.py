import os
import struct
import sys
import time
import zmq
from consul import Consul

from pyre.zbeacon import ZBeacon
from pyre.zactor import ZActor
from pyre.pyre_node import ZRE_DISCOVERY_PORT

DELAY_SYNC_REPEATERS = 1

class ZBeaconRepeater(object):

    def __init__(self):
        self.dont_ip = os.environ.get('DONT_IP', '').split(' ')
        self.other_repeaters = []
        self.consul = Consul(sys.argv[1])

        self.ctx = zmq.Context()
        self.poller = zmq.Poller()

        self.pub = self.ctx.socket(zmq.PUB)
        self.pub.bind('tcp://*:2340')

        self.sub = self.ctx.socket(zmq.SUB)
        self.sub.setsockopt(zmq.SUBSCRIBE, b'')
        self.poller.register(self.sub, zmq.POLLIN)

        self.beacon = ZActor(self.ctx, ZBeacon)
        self.beacon.send_unicode('CONFIGURE', zmq.SNDMORE)
        self.beacon.send(struct.pack('I', ZRE_DISCOVERY_PORT))
        _ = self.beacon.recv_unicode() # Hostname
        filter_ = struct.pack('ccc', b'Z', b'R', b'E')
        self.beacon.send_unicode('SUBSCRIBE',zmq.SNDMORE)
        self.beacon.send(filter_)
        self.beacon_socket = self.beacon.resolve()
        self.poller.register(self.beacon_socket, zmq.POLLIN)

    def _connect_to_repeaters(self):
        print '>>>> syncing repeaters'
        docker_nodes = self.consul.kv.get('docker/nodes', recurse=True)
        for node in docker_nodes[1]:
            ip = node['Value'].split(':')[0]
            if ip in self.dont_ip:
                continue

            self._connect_to_repeater(ip)

    def _connect_to_repeater(self, ip):
        if ip in self.other_repeaters:
            return

        print '>>>> Connecting to repeater', ip
        endpoint = 'tcp://%s:%d' % (ip, 2340)
        self.sub.connect(endpoint)

        self.other_repeaters.append(ip)

    def run(self):
        try:
            time_sync_repeaters = time.time() + DELAY_SYNC_REPEATERS
            while True:
                if time.time() >= time_sync_repeaters:
                    self._connect_to_repeaters()
                    time_sync_repeaters = time.time() + DELAY_SYNC_REPEATERS

                items = dict(self.poller.poll(0.1))
                while len(items) > 0:
                    for fd, ev in items.items():
                        if (self.sub == fd) and (ev == zmq.POLLIN):
                            data = self.sub.recv_multipart()
                            print '>>>> From SUB:', data
                            self.beacon.send_unicode('SEND BEACON', zmq.SNDMORE)
                            self.beacon.send(data[0])

                        elif (self.beacon_socket == fd) and (ev == zmq.POLLIN):
                            addr, data = self.beacon_socket.recv_multipart()
                            print '>>>> From UDP:', data + addr
                            self.pub.send(data + addr)

                    items = dict(self.poller.poll(0))
        finally:
            self.beacon.destroy()
            self.sub.close()
            self.pub.close()

if __name__ == '__main__':
    repeater = ZBeaconRepeater()
    repeater.run()

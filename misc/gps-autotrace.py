#! /usr/bin/python3

from optparse import OptionParser
from os import sys
import time
import json
from warnings import warn

class AutoTrace:
    def __init__(self, argv):
        parser = OptionParser()
        parser.add_option("-d", "--dir", dest="dir", default="~/Tracks",
                          help="write tracks to DIR", metavar="DIR")
        parser.add_option("-q", "--quiet",
                          action="store_false", dest="verbose", default=True,
                          help="don't print status messages to stderr")
        parser.add_option("-T", "--test", dest="test", action="store_true",
                          help="take input on stdin, prefix commands with echo")

        (self.opts, self.args) = parser.parse_args(argv[1:])

    def event(self, tag, info=None):
        print("  ev: %s:%s" % (tag, info))

    events = { 'EOF', 'DEVICES' }
    def do_read(self):
        stream_from = sys.stdin if self.opts.test else self.watch_pipe()
        dec = json.JSONDecoder()
        for ln in stream_from:
            data = dec.decode(ln)
            if self.opts.verbose:
                print( data )
            self.do_line(data)
        self.event('EOF')

    _state = {}
    no_event = { 'time','satsused' }
    def state(self, key, val):
        if self._state.get(key) == val:
            pass
        else:
            old = self._state.get(key)
            self._state[key] = val
            if not key in self.no_event:
                self.event('state', { 'key': key, 'old': old, 'new': val })


    # {'proto_major': 3, 'proto_minor': 8, 'rev': '3.9', 'class': 'VERSION', 'release': '3.9'}
    def _VERSION(self, data):
        if data['proto_major'] == 3 and data['proto_minor'] == 8:
            pass
        elif data['proto_major'] == 3:
            warn("Unexpected proto_minor in %s" % str(data))
        else:
            raise Exception("Unexpected data protocol %s" % str(data))
        self.state('version', data)

    # {'devices': [{'class': 'DEVICE', 'flags': 1, 'parity': 'N', 'activated': '2014-10-10T07:51:44.092Z', 'native': 1, 'path': '/dev/rfcomm0', 'stopbits': 1, 'bps': 57600, 'cycle': 1.0, 'driver': 'Generic NMEA'}], 'class': 'DEVICES'}
    def _DEVICES(self, data):
        #devs = { dev['path']: dev for dev in data['devices'] }
        #self.event('DEVICES', devs)
        pass

    # {'enable': True, 'class': 'WATCH', 'timing': False, 'scaled': False, 'nmea': False, 'raw': 0, 'json': True}
    def _WATCH(self, data):
        self.state('watch', data)

    # {'path': '/dev/rfcomm0', 'activated': 0, 'class': 'DEVICE'}
    # {'path': '/dev/rfcomm0', 'activated': '2014-10-10T07:51:55.524Z', 'driver': 'Generic NMEA', 'bps': 57600, 'parity': 'N', 'class': 'DEVICE', 'stopbits': 1, 'flags': 1, 'native': 1, 'cycle': 1.0}
    def _DEVICE(self, data):
        self.state(data['path'], data['activated'])

    # {'class': 'TPV', 'speed': 0.0, 'tag': 'RMC', 'lon': 0.1, 'track': 0.0,
    #   'mode': 3, 'climb': 0.0, 'lat': 52.1, 'epv': 460.0,
    #   'device': '/dev/rfcomm0', 'ept': 0.005, 'alt': 0.0,
    #   'time': '2014-10-10T07:53:01.192Z'}
    def _TPV(self, data):
        self.state('time', data['time'])
        self.state('mode', data['mode'])
        self.state('boxed', self.in_box(data))

    # {'class': 'SKY', 'hdop': 9.1, 'tag': 'GSV',
    #   'device': '/dev/rfcomm0', 'vdop': 20.0,
    #   'satellites': [{'az': 219, 'used': True, 'PRN': 31, 'el': 56, 'ss': 40},
    #                  {'az': 291, 'used': False, 'PRN': 16, 'el': 20, 'ss': 0}, ... ], 'pdop': 22.0}
    def _SKY(self, data):
        satsused = [ s['PRN'] for s in data['satellites'] if s['used'] ]
        self.state('satsused', satsused)


    for_CLASS = { 'VERSION': _VERSION, 'DEVICES': _DEVICES, 'WATCH': _WATCH,
                  'DEVICE': _DEVICE, 'SKY': _SKY, 'TPV':_TPV }
    def do_line(self, data):
        dclass = data.get('class')
        fn = self.for_CLASS.get(dclass)
        if fn == None:
            warn("No handler for class=%s in %s" % (dclass, data))
        else:
            return fn(self, data)


    def in_box(self, tpv):
        return True

exit( AutoTrace(sys.argv).do_read() )

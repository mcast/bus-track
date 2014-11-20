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

    def do_read(self):
        stream_from = sys.stdin if self.opts.test else self.watch_pipe()
        dec = json.JSONDecoder()
        for ln in stream_from:
            data = dec.decode(ln)
            if self.opts.verbose:
                print( data )
            self.do_line(data)
            time.sleep(2)

    def _VERSION(self, data): pass
    def _DEVICES(self, data):
        print("devs %s" % data['devices'])

    for_CLASS = { 'VERSION': _VERSION, 'DEVICES': _DEVICES }
    def do_line(self, data):
        dclass = data.get('class')
        fn = self.for_CLASS.get(dclass)
        if fn == None:
            warn("No handler for class:%s" % dclass)
        else:
            return fn(self, data)

exit( AutoTrace(sys.argv).do_read() )

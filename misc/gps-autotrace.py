#! /usr/bin/python3

from optparse import OptionParser
from os import sys
import time
import json

class AutoTrace:
    def main(self, argv):
        parser = OptionParser()
        parser.add_option("-d", "--dir", dest="dir", default="~/Tracks",
                          help="write tracks to DIR", metavar="DIR")
        parser.add_option("-q", "--quiet",
                          action="store_false", dest="verbose", default=True,
                          help="don't print status messages to stderr")
        parser.add_option("-T", "--test", dest="test", action="store_true",
                          help="take input on stdin, prefix commands with echo")

        (opts, args) = parser.parse_args(argv[1:])
        self.opts = opts
        print( { 'o': opts, 'a':args } )

        stream_from = sys.stdin if opts.test else self.watch_pipe()

        dec = json.JSONDecoder()
        for ln in stream_from:
            data = dec.decode(ln)
            print( data )

            time.sleep(2)

        return 3

exit( AutoTrace().main(sys.argv) )

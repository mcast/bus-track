#! /usr/bin/python3

from optparse import OptionParser
from os import sys

def main(argv):
    parser = OptionParser()
    parser.add_option("-d", "--dir", dest="dir", default="~/Tracks",
                      help="write tracks to DIR", metavar="DIR")
    parser.add_option("-q", "--quiet",
                      action="store_false", dest="verbose", default=True,
                      help="don't print status messages to stderr")
    (opts, args) = parser.parse_args(argv[1:])

    print( { 'o': opts, 'a':args } )
    return 3

exit( main(sys.argv) )

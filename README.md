-*- org -*-

(Attempting polyglot github-flavoured-markdown / org-mode,
so I can tick off the TODO items on the web.)

* History
** Aims **
This is starting off as a bus tracker for the local Campus bus.

I figure someone else might benefit from it, so I hope to avoid
hardwiring "campus" as the sole morning destination / evening
departure.  In the absence of any other usage, this is likely to slip.

** Implementation
+ [2014-09-08 Mon] :: proof of concept Leaflet.js to test on my devices
+ [2014-11-25 Tue] :: remember that it exists and publish it

* [0/10] Plans
+ [ ] disconnected operation
  + [ ] gather data, possibly over multiple journeys
  + [ ] upload when told
  + [ ] upload opportunistically
+ [ ] add gulp.js support
+ [ ] connected operation
  + upload promptly
  + (extra plugin) to download and render recent data from other users
  + [ ] use BERT not JSON
+ [ ] is the .jar file still a good file bundling method?
+ [ ] manage a static set of map tiles
  + the area of a bus route, plus some distance margin, at some zoom level
  + periodic updates
  + [ ] work out how big this needs to be
+ [ ] serve from local file:///
+ [ ] serve by http[s] with offline store
+ [ ] upload of arbitrary GPS tracks
  + window them (to a polygon, and by time) to exclude irrelevant or
    private data
  + client-side for the untrusting
  + server-side for the impatient or technophobic
+ [ ] automated bus stop format conversions
  + input .kml (nb. they are not public)
  + convert (with gpsbabel) to a .gpx and extract the waypoints
  + Note that this is a workaround for something better, which is not
    yet planned.  Just take the data we have and mash it into a form
    which can be used.
  + See bfg-docs.git/routes/ (unpublished)
+ [ ] battery usage
  + Maybe it can run all the time, but sleep until bus o'clock, and
    then sleep some more if you aren't on a bus route.
+ mcra
  + [ ] import relevant stuff from another org-mode file I keep

* Feature requests
** [0/2] WIBNI, with real-time data
+ [ ] connect stranded passengers with drivers heading out of town on their way to < destination >
+ [ ] self-counting bus queues
  + people waiting at later stops count themselves
  + system can predict where the bus will become full
  + some alternative arrangements could be planned at this point,
    rather than waiting for passengers to be refused boarding.

-*- org -*-

- (Attempting polyglot github-flavoured-markdown / org-mode,
  so I can tick off the TODO items on the web.)
- Export is possible, but a poor second choice for me
  - http://orgmode.org/manual/Markdown-export.html
  - https://github.com/alexhenning/ORGMODE-Markdown
  - http://stackoverflow.com/questions/10383986/emacs-mode-for-stack-overflows-markdown#answer-10386560

* History
# History
** Aims
This is starting off as a bus tracker for the local Campus bus.

I figure someone else might benefit from it, so I hope to avoid
hardwiring "campus" as the sole morning destination / evening
departure.  In the absence of any other usage, this is likely to slip.

** Implementation
- [2014-09-08 Mon] :: proof of concept Leaflet.js to test on my devices
- [2014-11-25 Tue] :: remember that it exists and publish it

* [1/18] Plans
# Plans
1. [X] standard map with tiles
2. [ ] define route data model
   - [ ] agree a sensible stop-id
     - route-id "/" i, for i in stops list index :: does not admit that stops may be degenerate, served by multiple routes
     - digest(name, pos, type) :: can be arranged to match between routes
   - [ ] define data model for route
     - each route = { id: shaNfoo, name: n, description: txt, seats: n, stops: [ { name: n, description: txt, scheduled: midnight_seconds_localtime, pos: [x,y], type: pickup|dropoff|waypoint }, ... ] }
       - name should indicate road direction/side
     - holding a list of such current routes
   - [ ] define mapping to/from .kml / .gpx / geojson
     - GeoJSON would have a GeoBERT analogue
     - gpsbabel might do the work for us
3. [ ] display some bus stops
   - [ ] stop markers on map, by type
   - [ ] linear route pictogram below the map panel
4. [ ] GPS(map)-to-pictogram linkage
5. [ ] Working Firefox + gpsd
    - options, if it's an old-protocol problem
      - fix it
      - old gpsd
      - old Firefox
      - some kind of ugly GPS v3 -> v2 protocol bridge
    - links
      - http://esr.ibiblio.org/?p=3617
      - https://bugzilla.mozilla.org/show_bug.cgi?id=492328
      - https://bugzilla.mozilla.org/buglist.cgi?component=Geolocation&product=Core&bug_status=__open__
5. [ ] pictogram position override linkage
   - "we are actually >here<"
   - for GPS outage / replacement
   - [ ] via pictogram
   - [ ] via map
   - [ ] pictogram-to-GPS(map) reverse linkage
6. [ ] define data model for route-stats
   - { route-id: i, name: n, stop-info: [ ... ], date: iso8601 } :: report info for a route, many fields optional
     - name or id :: may be unknown at collection time, possibly even server-side after all reports are in
     - author :: who made the report
     - gpxlog :: should accept a GPS track in various formats, extract features later?
   - actual # seats :: note the "bus" serving the "route" could be more than one vehicle, as when vehicle large enough for contacted seat count is not available
   - { stop: id, actual-pos: [x,y], actual-time: iso8601, boarding: { type: count }, overflow: { type: count }, actual-type: t, comment: txt } :: report info for a stop, many fields optional
     - boarding and overflow counts could include people, small people, bikes, wheelchairs
       - Define a standard set, maybe allow extras for when the Martians land.
     - boarding and overflow counts are positive as the bus fills; we can compare directly with seat count
     - there may be multiple and conflicting reports of occupancy
       - Driver-to-Security passenger counts: incl/excl minors
     - clientside operator may be aware of uncertainty in any count (number fumble or distraction)
       - The dict could be abused to carry this, and it might be more portable than storing a number±error in the value
     - the waypoint type reports
       - can be gathered in full auto
       - they map to a simple .gpx log
       - may be useful for spotting traffic jams
       - tradeoff in record time spacing: precision vs. battery life + data size
7. [ ] disconnected operation
   - [ ] gather data, possibly over multiple journeys
   - [ ] upload when told
   - [ ] upload opportunistically
8. [ ] connected operation
   - upload promptly
   - (extra plugin) to download and render recent data from other users
   - [ ] use BERT not JSON
9. [ ] deployment, client
   - [ ] is the .jar file still a good file bundling method?
   - [ ] serve from local file:///
   - [ ] serve by http[s] with offline store
   - [ ] add gulp.js support
10. [ ] deployment, server
    - clearly a server-side will be needed, but spec is thin
11. [ ] server content, initially manually built
    - [ ] static bundles of map tiles
    - [ ] static bundle route info
12. [ ] server actions
    - [ ] table of {user:email, API-key:rnd, actions-permitted: [] } in YAGNI style
      - We have https?  Secret tokens are adequate
      - maintain manually, shouldn't be a great burden
      - linear search each time will be fine
    - [ ] POST a new route-stats report file
      - add an outer wrapping of weblog stuff {IP, auth-user, date-time ..., data: POSTed }
      - imagine up a filename
      - bert2json2disk
13. [ ] analysis and action, from the recorded route-stats data
    - I notice that I defined data collection by what is available, likely or has happened in the past
    - building an archive might be useful
    - it is worthless until there is analysis or some realtime sharing
14. [ ] manage a static set of map tiles
    - the area of a bus route, plus some distance margin, at some zoom level
    - periodic updates
    - [ ] work out how big this needs to be
15. [ ] consider extra features for route model (supplementary data, excluded from id if that is a digest?)
    - extra name/url for the region, by which we could obtain bundle of current map tiles
    - dates of route currency, e.g. Christmas special, scheduled detour
    - alternative waypoint set per route pair, as used for dodging traffic jams
    - alternative stops set, as used to shortcut to destination when bus is full
    - parent-id linkage to previous incarnations of the route, probably carrying the same name
    - RT# linkage for known problems with route/stop
    - hyperlinks to relevant policies, timetable pages, discussion channels
16. [ ] upload of arbitrary GPS tracks
    - window them (to a polygon, and by times of week)
      - to exclude irrelevant or private data
      - client-side for the untrusting
      - server-side for the impatient or technophobic
    - derive such polygons from bus route,
      - probably like a function of distance-envelope = const_metres * ( scheduled_speed / mph ) ^ const_pow
    - might be better to window only by stationary points (stops = below 6mph), then include track between
17. [ ] automated bus stop format conversions
    - input .kml (nb. they are not public)
    - convert (with gpsbabel) to a .gpx and extract the waypoints
    - Note that this is a workaround for something better, which is not
      yet planned.  Just take the data we have and mash it into a form
      which can be used.
    - See bfg-docs.git/routes/ (not public)
18. [ ] battery usage
    - Maybe it can run all the time, but sleep until bus o'clock, and
      then sleep some more if you aren't on a bus route.
19. mcra
    - [ ] import relevant stuff from another org-mode file I keep

* Feature requests
# Feature requests
** [0/2] WIBNI, with real-time data
- [ ] connect stranded passengers with drivers heading out of town on their way to < destination >
- [ ] self-counting bus queues
  - people waiting at later stops count themselves
  - system can predict where the bus will become full
  - some alternative arrangements could be planned at this point,
    rather than waiting for passengers to be refused boarding.

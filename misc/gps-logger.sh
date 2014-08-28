#! /bin/sh

# On beeep = Ubuntu Lucid
#
# /etc/default/gpsd
#   GPSD_OPTIONS=-n DEVICES=/dev/rfcomm0
#
# /etc/bluetooth/rfcomm.conf
#   rfcomm0 { bind yes; device 00:0C:A5:00:E0:45; comment "ye olde navman"; }

uppit() {
    if rfcomm show /dev/rfcomm0; then
        echo OK
        true
    else
        sleep 8
        sudo rfcomm connect /dev/rfcomm0 &
        sleep 2
        false
    fi
}

if rfcomm show /dev/rfcomm0; then
    # rfcomm0: 00:0F:3D:4C:12:94 -> 00:0C:A5:00:E0:45 channel 1 connected [reuse-dlc release-on-hup tty-attached]
    echo Already connected
else
    echo Nobble bluetooth
    set -x
    sudo /etc/init.d/gpsd stop; echo RC=$?
    sleep 1
    sudo rfcomm release /dev/rfcomm0; echo RC=$?
    sleep 5
    echo Frob bluetooth
    sudo killall rfcomm
    sudo rfcomm connect /dev/rfcomm0 &
    uppit || uppit || uppit || uppit
    set +x
fi

if ! pidof gpsd >/dev/null; then
    echo Start gpsd
    sudo /etc/init.d/gpsd start; echo RC=$?
fi


if pidof gpxlogger >/dev/null; then
    echo Logger running - leave
else
    gpxlogger > ~/track-$( date +%Ft%T ).gpx &
    echo gpxlogger on $!
fi

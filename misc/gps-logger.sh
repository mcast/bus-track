#! /bin/sh

# On beeep = Ubuntu Lucid
#
# /etc/default/gpsd
#   GPSD_OPTIONS=-n DEVICES=/dev/rfcomm0
#
# /etc/bluetooth/rfcomm.conf
#   rfcomm0 { bind yes; device 00:0C:A5:00:E0:45; comment "ye olde navman"; }
#
# /etc/sudoers - append, dn't insert!
#   mca1001		beeep = NOPASSWD: /usr/bin/rfcomm connect /dev/rfcomm0 , /usr/bin/rfcomm release /dev/rfcomm0 , /etc/init.d/gpsd stop , /etc/init.d/gpsd start , /usr/bin/killall rfcomm


bt_is_plugged() {
    hcitool dev | grep -qE 'hci[0-9]'
    # Devices:
    # 	hci0	00:0F:3D:4C:12:94
}

bt_is_conn() {
    rfcomm show /dev/rfcomm0 > /dev/null
    # rfcomm0: 00:0F:3D:4C:12:94 -> 00:0C:A5:00:E0:45 channel 1 connected [reuse-dlc release-on-hup tty-attached]
}

uppit() {
    if bt_is_conn; then
        echo Connected OK
        true
    elif ! bt_is_plugged; then
        echo Unplugged, give up connecting
        true
    else
        echo $( date +%Ft%T ) Trying connect...
        sudo /usr/bin/rfcomm connect /dev/rfcomm0 &
        sleep 3
        bt_is_conn || sleep 7
        false
    fi
}

main() {
    if bt_is_plugged; then
        if bt_is_conn; then
            # Already connected
            gps_get_tracking
            sleep 10
        else
            echo Nobble bluetooth, restart
            pidof gpsd >/dev/null && sudo /etc/init.d/gpsd stop
            sleep 1
            sudo /usr/bin/rfcomm release /dev/rfcomm0
            sleep 5
            echo Frob bluetooth
            sudo /usr/bin/killall rfcomm
            # 6*10sec
            uppit || uppit || uppit || uppit || uppit || uppit
        fi
    else
        # Finished, for now
        pidof gpxlogger >/dev/null && killall -INT gpxlogger
        pidof gpsd      >/dev/null && sudo /etc/init.d/gpsd stop
        killall -INT gpsmon # else it spins
        sleep 5
    fi
}

gps_get_tracking() {
    if ! pidof gpsd >/dev/null; then
        echo Start gpsd
        sudo /etc/init.d/gpsd start
    fi

    if ! pidof gpxlogger >/dev/null; then
        mkdir -p ~/Tracks
        gpxlogger > ~/Tracks/track-$( date +%Ft%T ).gpx &
        echo Started gpxlogger, pid $!
    fi
}

while true; do
    echo $(date +%Ft%T ) loop
    main
done

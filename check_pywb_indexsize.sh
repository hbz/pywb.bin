#!/bin/bash
#
# Monitoring der pywb Indexe
#
# Die Indexe der pywb sollen nicht größer als 10GB werden. Dieses Skipt wird von monit aufgerufen 
# und schickt eine Mail, sobald der Indexe die kritische Größe erreicht.
# Das Skript erwartet die Angabe der maximalen Größe in MB.
#
# Aufruf in monit Konfiguration mit absoluten Pfaden
# $ /opt/pywb/bin/check_pywb_indexsize.sh -i /opt/pywb/collections/weltweit/indexes/index.cdxj -m 10000 -l weltweit.log

usage() { echo "Usage: $0 [-i <pywb index>] [-m <max size in MB>] [-l <logfile>]" 1>&2; exit 1; }

while getopts ":i:m:l:" option; do
    case "${option}" in
        i ) INDEX=${OPTARG};;
        m ) MAXSIZE=${OPTARG};;
        l ) LOG=${OPTARG};;
	\?) usage;;
    esac
done

shift $(($OPTIND -1))

LOGDIR="/opt/pywb/logs"
logfile=$LOGDIR/$LOG

size=$(du -m "$INDEX" | cut -f 1)
time=`date +%F\ %T`
echo $time, $size >> $logfile

if [ $size -ge $MAXSIZE ]; then
    echo "$INDEX: $size > $MAXSIZE MB"
    exit 1
else
    echo "$INDEX: $size < $MAXSIZE MB"
    exit 0
fi

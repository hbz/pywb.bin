#!/bin/bash
# Fügt eine WARC-Datei zu einer bestehenden Sammlung hinzu.
# Beispielaufruf: $0 wayback /data/wpull-data/<NAMESPACE>:1/20240101/WEB-mysite.com-20240101.warc.gz
coll=$1
warcfile=$2
echo "adding warc file $warcfile to collection $coll"
pywb_basedir=/opt/pywb
collections=$pywb_basedir/collections
warcbase=`basename $warcfile`
actdir=$PWD
cd $pywb_basedir
/opt/pywb/Python3/bin/wb-manager add $coll $warcfile
if [ -f $collections/$coll/archive/$warcbase ]; then
  rm $collections/$coll/archive/$warcbase
fi
ln -s $warcfile $collections/$coll/archive/$warcbase
cd $actdir

exit 0

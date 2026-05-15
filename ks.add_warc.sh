#!/bin/bash
# Fügt eine WARC-Datei zu einer bestehenden Sammlung hinzu.
# Beispielaufruf: $0 wayback /data2/cdn-data/edoweb_cdn:29/20190708/WEB-strato-editor.com-slideshow-common.css-20190708.warc.gz

scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $scriptdir
source variables.conf

coll=$1
warcfile=$2
echo "adding warc file $warcfile to collection $coll"
pywb_basedir=/opt/pywb
collections=$pywb_basedir/collections
warcbase=`basename $warcfile`
actdir=$PWD
cd $pywb_basedir
$python_env/bin/wb-manager add --unpack-wacz $coll $warcfile
if [ -f $collections/$coll/archive/$warcbase ]; then
  rm $collections/$coll/archive/$warcbase
fi
ln -s $warcfile $collections/$coll/archive/$warcbase
cd $actdir

exit 0

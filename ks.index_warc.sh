#!/bin/bash
# Fügt eine WARC-Datei zu einer bestehenden Sammlung hinzu.
# Benutze dafür wb-manager index
# Beispielaufruf: $0 test_index /data2/cdn-data/edoweb_cdn:29/20190708/WEB-strato-editor.com-slideshow-common.css-20190708.warc.gz
coll=$1
warcfile=$2
echo "indexing warc file $warcfile in collection $coll"
pywb_basedir=/opt/pywb
collections=$pywb_basedir/collections
warcbase=`basename $warcfile`
if [ -L $collections/$coll/archive/$warcbase ]; then
  rm $collections/$coll/archive/$warcbase
fi
ln -s $warcfile $collections/$coll/archive/$warcbase
actdir=$PWD
cd $pywb_basedir
wb-manager index $coll $collections/$coll/archive/$warcbase
cd $actdir

exit 0

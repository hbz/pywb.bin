#!/bin/bash
# Fügt alle public-data zu einer Sammlung hinzu. Legt dazu den Index index.cdxj (neu) an.
# Fügt auch alle cdn-data hinzu.
# Dazu wird wb-manager index benutzt.
# Beispielaufruf: ./ks.index_public-data.sh public
echo "********************************************************************************"
echo `date`
echo "START Initially indexing all public-data and cdn-data in Collection $coll"
echo "********************************************************************************"
coll=$1
pywb_basedir=/opt/pywb
collection=$pywb_basedir/collections/$coll
# Sicherungskopie des aktuellen Index machen
cd $collection/indexes
index_cdxj_bak=""
datetimestamp=""
if [ -f index.cdxj ]; then
  datetimestamp=`date +'%Y%m%d%H%M%S%3N'`
  index_cdxj_bak=index.$datetimestamp.cdxj
  mv index.cdxj $index_cdxj_bak
fi
if [ -n "$index_cdxj_bak" ]; then
  echo "index.cdxj gab es schon; temporär umbenannt nach $index_cdxj_bak"
fi
dataverz=/data/public-data
cd $dataverz
for warcfile in *:*/20*/*.warc.gz *:*/20*/warcs/*.warc.gz; do
  if [ -f $dataverz/$warcfile ]; then
    echo "warcfile=$dataverz/$warcfile"
    /opt/pywb/bin/ks.index_warc.sh $coll $dataverz/$warcfile
  fi
done
dataverz=/data/cdn-data
cd $dataverz
for warcfile in *:*/20*/*.warc.gz ; do
  if [ -f $dataverz/$warcfile ]; then
    echo "warcfile=$dataverz/$warcfile"
    /opt/pywb/bin/ks.index_warc.sh $coll $dataverz/$warcfile
  fi
done
echo "neuen Index index.cdxj aufgebaut"
# Umbenennung der Sicherungskopie
cd $collection/indexes
if [ -n "$index_cdxj_bak" ]; then
  mv $index_cdxj_bak index.cdxj.$datetimestamp
  echo "schon vorhandenen und umbenannten Index $index_cdxj_bak nach index.cdxj.$datetimestamp umbenannt und dadurch deaktiviert"
fi
echo "********************************************************************************"
echo `date`
echo "ENDE initially indexing all public-data and cdn-data in Collection $coll"
echo "********************************************************************************"
exit 0

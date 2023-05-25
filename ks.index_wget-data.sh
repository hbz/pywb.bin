#!/bin/bash
# Fügt alle wget-data zu einer Sammlung hinzu. Legt dazu den Index index_wget.cdxj (neu) an.
# Dazu wird wb-manager index benutzt.
# Beispielaufruf: ./ks.index_wget-data.sh lesesaal
echo "********************************************************************************"
echo `date`
echo "START Initially indexing all wget-data in Collection $coll"
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
#dataverz=/data2/wget-data
dataverz=/data/wget-data
cd $dataverz
for warcfile in edoweb:*/20*/warcs/*.warc.gz ; do
  if [ -f $dataverz/$warcfile ]; then
    echo "warcfile=$dataverz/$warcfile"
    /opt/pywb/bin/ks.index_warc.sh $coll $dataverz/$warcfile
  fi
done
# Umbenennung des Index
cd $collection/indexes
if [ -f index_wget.cdxj ]; then
  datetimestamp=`date +'%Y%m%d%H%M%S%3N'`
  mv index_wget.cdxj index_wget.cdxj.$datetimestamp
  echo "schon vorhandenen Index index_wget.cdxj umbenannt nach index_wget.cdxj.$datetimestamp"
fi
mv index.cdxj index_wget.cdxj
echo "neu aufgebauten Index umbenannt nach index_wget.cdxj"
if [ -n "$index_cdxj_bak" ]; then
  mv $index_cdxj_bak index.cdxj
  echo "schon vorhandenen und gesicherten Index $index_cdxj_bak wieder zurück benannt nach index.cdxj"
fi
echo "********************************************************************************"
echo `date`
echo "ENDE initially indexing all wget-data in Collection $coll"
echo "********************************************************************************"
exit 0

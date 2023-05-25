#!/bin/bash
# ***************************************************************************
# Automatisches Indexieren neuer Webschnitte in PyWB
# Autor: Ingolf Kuss
# Änderungshistorie:
# +------------------+------------+-----------------------------------------+
# | Autor            | Datum      | Beschreibung                            |
# +------------------+------------+-----------------------------------------+
# | Ingolf Kuss      | 16.09.2019 | Neuanlage                               |
# | Ingolf Kuss      | 16.01.2020 | vervollständigt                         |
# | Ingolf Kuss      | 22.05.2020 | Anpassungen für wayback-test im Betrieb mit edoweb-test
# | Ingolf Kuss      | 26.04.2022 | Maximale Häppchengröße für den aktuellen Index index.cdxj eingeführt.
# |                  |            | Bei Überschreiten der max. Größe wird ein neuen Index angefangen.
# +------------------+------------+-----------------------------------------+
# ***************************************************************************
# Aktualisiert index.cdxj. Maximale Indexgröße 10 GB (Größe anpassbar in der Shell-Variable 'happengroesse').
# Die einzelnen Teilindexe werden index01.cdxj, index02.cdxj, ... genannt; der letzte (< 10 GB) index.cdxj

#data_basedir=/data/edoweb-test
#data_basedir=/data2
#data_basedir=/data
data_basedir=/opt/toscience
#happengroesse=10000000000 # Dateigröße in Byte
happengroesse=2000000000 # Dateigröße in Byte
#happengroesse=1000000000 # Dateigröße in Byte
pywb_basedir=/opt/pywb
collections=$pywb_basedir/collections
archive_lesesaal=$collections/lesesaal/archive
archive_weltweit=$collections/weltweit/archive
logfile=$pywb_basedir/logs/ks.auto_add.log
echo "" >> $logfile
echo "********************************************************************************" >> $logfile
echo `date`
echo `date` >> $logfile
echo "START Auto adding new web harvests"
echo "START Auto adding new web harvests" >> $logfile
echo "Max. Indexgröße = $happengroesse Bytes" >> $logfile
echo "********************************************************************************" >> $logfile
actdir=$PWD

# bash-Funktionen
function update_collection {
  # Aktualisiert alle neu hinzugekommenen oder kürzlich geänderten Webarchivdateien eines Verzeichnisses (z.B. wpull-data/) in einem pywb-Archiv (u.a. pywb-Index)
  local dataverz=$1;
  local suchmuster=$2;
  local archivename=$3
  local archive=$4;
  # Schleife über alle im Datenverzeichnis angelegten WARC-Dateien
  cd $dataverz
  for warcfile in $suchmuster ; do
    # echo "warcfile=$dataverz/$warcfile" >> $logfile
    if [ "$warcfile" = "$suchmuster" ]; then
      # echo "Sammlung $archivename, Verzeichnis $dataverz: keine WARC-Datei gefunden."
      break
    fi
    warcbase=`basename $warcfile`
    # Gibt es schon einen gleichnamigen symbolischen Link im Archiv ?
    if [ -f $archive/$warcbase ]; then
      # echo "Archivfile existiert" >> $logfile
      # Ist das Archivfile neuer ?
      if test `find $archive/$warcbase -prune -newer $dataverz/$warcfile`; then
        # echo "Archivfile ist neuer. Nichts zu tun." >> $logfile
        continue
      fi
      echo "Archivfile ist älter" >> $logfile
      # Archivfile (symbolischer Link) löschen
      rm $archive/$warcbase
    fi
    # Archivfile exsitiert noch nicht oder ist älter
    echo "warcfile=$dataverz/$warcfile" >> $logfile
    echo "Warcfile wird hinzugefügt." >> $logfile
    /opt/pywb/bin/ks.add_warc.sh $archivename $dataverz/$warcfile >> $logfile
  done
}

function rename_large_index {
  local coll=$1;
  collection=$collections/$coll
  cd $collection/indexes
  size=0
  if [ -f "index.cdxj" ]; then
    for word in `du -b index.cdxj`; do size=$word; break; done
  fi
  if [ $size -gt $happengroesse ]; then
    echo "Größe des aktuellen Index ($size Byte) überschreitet Portionsgröße ($happengroesse Byte)." >> $logfile
    # Ermittle nächste Happennummer
    last_indexname="index00.cdxj"
    if [ -f "index01.cdxj" ]; then
     for word in `ls index??.cdxj | sort -r`; do last_indexname=$word; break; done
    fi
    echo "Last Indexname: $last_indexname" >> $logfile
    last_index_nr=0
    if [[ "$last_indexname" =~ index(..).cdxj ]]; then
      last_index_nr=${BASH_REMATCH[1]}  	
    fi
    echo "Last index no: $last_index_nr"  >> $logfile
    next_happen_nummer=$last_index_nr
    ((next_happen_nummer++))
    echo "Next index no: $next_happen_nummer"  >> $logfile
    # Aktuellen Index umbenennen nach printf("index%02d.cdxj", $next_happen_nummer)
    printf -v newIndexName 'index%02d.cdxj' $next_happen_nummer
    mv index.cdxj $newIndexName
    echo "Aktuellen Index index.cdxj umbenannt nach $newIndexName" >> $logfile
  fi
}

# ************************
# Beginn Hauptverarbeitung
# ************************
# I. Lesesaal-Sammlung
# I.1. Ggfs. Umbenennung des aktuellen Index, falls dieser schon zu groß ist
#      Es wird dann automatisch ein neuer Index index.cdxj begonnen.
rename_large_index lesesaal

# I.2 Neuindexierung der neu hinzu gekommenen WARC-Archive in der Lesesaal-Sammlung
# i. wpull-data
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
echo "START auto-indexing new wpull harvests" >> $logfile
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
update_collection $data_basedir/wpull-data "edoweb:*/20*/*.warc.gz" lesesaal $archive_lesesaal

# ii. heritrix-data
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
echo "START auto-indexing new heritrix harvests" >> $logfile
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
update_collection $data_basedir/heritrix-data "edoweb:*/20*/warcs/*.warc.gz" lesesaal $archive_lesesaal

# iii. cdn-data
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
echo "START auto-indexing new cdn harvests in restricted access collection" >> $logfile
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
update_collection $data_basedir/cdn-data "edoweb_cdn:*/20*/*.warc.gz" lesesaal $archive_lesesaal

# II. Weltweit-Sammlung
# II.1. Ggfs. Umbenennung des aktuellen Index, falls dieser schon zu groß ist
#       Es wird dann automatisch ein neuer Index index.cdxj begonnen.
rename_large_index weltweit

# II.2 Neuindexierung der neu hinzu gekommenen WARC-Archive in der Weltweit-Sammlung
# i. cdn-data
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
echo "START auto-indexing new cdn harvests in public collection" >> $logfile
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
update_collection $data_basedir/cdn-data "edoweb_cdn:*/20*/*.warc.gz" weltweit $archive_weltweit

# ii. public-data
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
echo "START auto-indexing new public harvests (soft links)" >> $logfile
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
update_collection $data_basedir/public-data "edoweb:*/20*/*.warc.gz" weltweit $archive_weltweit
update_collection $data_basedir/public-data "edoweb:*/20*/warcs/*.warc.gz" weltweit $archive_weltweit

echo "********************************************************************************" >> $logfile
echo `date`
echo `date` >> $logfile
echo "ENDE Auto adding new web harvests"
echo "ENDE Auto adding new web harvests" >> $logfile
echo "********************************************************************************" >> $logfile
cd $actdir
exit 0

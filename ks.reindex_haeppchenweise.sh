#!/bin/bash
# Baut index.cdxj neu auf. Aber in Häppchen zu je 10 GB.
# Die einzelnen Teilindexe werden index01.cdxj, index02.cdxj, ... genannt; der letzte (< 10 GB) index.cdxj
# *** ACHTUNG ! Während der des Neuaufbaus MUSS der auto-Indexer in der Crontab ausgeschaltet sein !!! ***
# *** es ist jedoch keine Downtime nötig, da die alten Indexe temporär umbenannt werden und solange weiter aktiv sind,
#     bis die neuen Indexe fertig sind ***
# Beispielaufruf: ./ks.index_public-data.sh weltweit
# +------------------+------------+-----------------------------------------------------------------+
# | Autor            | Datum      | Grund                                                           |
# +------------------+------------+-----------------------------------------------------------------+
# | Ingolf Kuss      | 07.04.2022 | Neuanlage für die Erstindexierung auf edoweb-test2              |
# | Ingolf Kuss      | 02.02.2026 | Editiert für Re-Indexierung häppchenweise auf edoweb2, TOS-1347 |
# +------------------+------------+-----------------------------------------------------------------+
coll=$1
data_basedir=/data2
# data_basedir=/data/edoweb-test  # für wayback-test
happengroesse=10000000000 # Dateigröße in Byte
pywb_basedir=/opt/pywb
collections=$pywb_basedir/collections
collection=$collections/$coll
coll_archive=$collection/archive
logfile=$pywb_basedir/logs/ks.reindex_haeppchenweise.`date +'%Y%m%d%H%M%S'`.log
next_happen_nummer=1
echo "********************************************************************************" >> $logfile
echo `date`
echo `date` >> $logfile
echo "BEGINN Häppchenweise Neuaufbau des index index.cdxj in der Sammlung $coll"
echo "BEGINN Häppchenweise Neuaufbau des index index.cdxj in der Sammlung $coll" >> $logfile
echo "Databasedir = $data_basedir" >> $logfile
echo "Häppchengröße = $happengroesse" >> $logfile
echo "********************************************************************************" >> $logfile
actdir=$PWD

# bash-Funktionen
function index_basedir {
  # Indexiert alle Webarchivdateien eines Verzeichnisses (z.B. public-data/)
  #  in einem pywb-Archiv und einem pywb-Teilindex (indexNN.cdxj)
  local dataverz=$1;
  local suchmuster=$2;
  # Schleife über alle im Datenverzeichnis angelegten WARC-Dateien
  cd $dataverz
  for warcfile in $suchmuster ; do
    if [ -f $dataverz/$warcfile ]; then
      # echo "warcfile=$dataverz/$warcfile" >> $logfile
      warcbase=`basename $warcfile`
      # Gibt es schon einen gleichnamigen symbolischen Link im Archiv ?
      if [ -f $coll_archive/$warcbase ]; then
        # Archivfile (symbolischer Link) löschen
        rm $coll_archive/$warcbase
      fi
      # Archivfile immer neu indexieren
      echo "Warcfile=$dataverz/$warcfile wird hinzugefügt." >> $logfile
      # Prüfen, ob der index index.cdxj schon größer als die Häppchengröße ist.
      cd $collection/indexes
      size=0
      if [ -f "index.cdxj" ]; then
        for word in `du -b index.cdxj`; do size=$word; break; done
      fi
      if [ $size -gt $happengroesse ]; then
        # Index umbenennen nach printf("index%02d.cdxj", $next_happen_nummer)
        printf -v newIndexName 'index%02d.cdxj' $next_happen_nummer
        mv index.cdxj $newIndexName
        echo "neu aufgebauten Teilindex umbenannt nach $newIndexName" >> $logfile
        ((next_happen_nummer++))
      fi
      cd $dataverz
      # und neuen Index anfangen (das sollte von selber geschehen)
      # WARC-Datei zu index.cdxj hinzufügen
      /opt/pywb/bin/ks.index_warc.sh $coll $dataverz/$warcfile >> $logfile
    fi
  done
  }
# ENDE Bash-Funktionen

### BEGINN Hauptverarbeitung ###
if [ "$coll" != "lesesaal" ] && [ "$coll" != "wayback" ] && [ "$coll" != "weltweit" ] && [ "$coll" != "public" ]; then
  echo "ERROR: Indexname \"$coll\" nicht bekannt! Keine Aktionen." >> $logfile
  echo "ERROR: Indexname \"$coll\" nicht bekannt! Keine Aktionen."
  cd $actdir
  exit 0
fi

# Aktuellen Index index.cdxj temporär umbenennen
cd $collection/indexes
index_cdxj_bak=""
# datetimestamp=`date +'%Y%m%d%H%M%S%3N'`
datetimestamp=`date +'%Y%m%d%H%M%S'`
if [ -f index.cdxj ]; then
  index_cdxj_bak=index.$datetimestamp.cdxj
  mv index.cdxj $index_cdxj_bak
  echo "index.cdxj gab es schon; temporär umbenannt nach $index_cdxj_bak" >> $logfile
fi

# Auch alle aktuellen partiellen Indexe umbenennen
index_partial_bak=""
akt_partial_number=1;
printf -v index_partial 'index%02d.cdxj' $akt_partial_number
while [ -f $index_partial ]; do
  printf -v index_partial_bak "index%02d.$datetimestamp.cdxj" $akt_partial_number
  mv $index_partial $index_partial_bak
  echo "$index_partial gab es schon; umbenannt nach $index_partial_bak." >> $logfile
  ((akt_partial_number++))
  printf -v index_partial 'index%02d.cdxj' $akt_partial_number
done
((akt_partial_number--))
echo "$akt_partial_number Backup-Teilindexe angelegt." >> $logfile


# *******************************
# Beginn der Neuindexierung
# *******************************
if [[ "$coll" == "lesesaal" || "$coll" == "wayback" ]]; then
  # Index mit eingeschränkter Zugriffsberechtigung (Lesesaal) neu aufbauen
  # 1. wget-data
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
  echo "START auto-indexing wget harvests" >> $logfile
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
  index_basedir $data_basedir/heritrix-data "edoweb:*/20*/warcs/*.warc.gz"
  
  # 2. heritrix-data
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
  echo "START auto-indexing heritrix harvests" >> $logfile
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
  index_basedir $data_basedir/heritrix-data "edoweb:*/20*/warcs/*.warc.gz"

  # 3. wpull-data
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
  echo "START auto-indexing wpull harvests" >> $logfile
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
  index_basedir $data_basedir/wpull-data "edoweb:*/20*/*.warc.gz"

  # 4. cdn-data
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
  echo "START auto-indexing cdn harvests in restricted access collection" >> $logfile
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
  index_basedir $data_basedir/cdn-data "edoweb_cdn:*/20*/*.warc.gz"

  # 5. btrix-data
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
  echo "START auto-indexing browsertrix harvests in restricted access collection" >> $logfile
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
  index_basedir $data_basedir/btrix-data "edoweb:*/20*/archive/*.warc.gz"
  
elif [[ "$coll" == "weltweit" || "$coll" == "public" ]]; then
  # Öffentlich zugänglichen Index neu aufbauen
  # 1. public-data
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
  echo "START auto-indexing public harvests in public access collection" >> $logfile
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
  index_basedir $data_basedir/public-data "edoweb:*/20*/*.warc.gz edoweb:*/20*/*/*.warc.gz"

  # 2. cdn-data
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
  echo "START auto-indexing cdn harvests in public access collection" >> $logfile
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
  index_basedir $data_basedir/cdn-data "edoweb_cdn:*/20*/*.warc.gz"
fi

# Nach erfolgreicher Reindexierung:
# Umbenennung (und dadurch Deaktivierung) des gesicherten alten Indexes
if [ -n "$index_cdxj_bak" ]; then
  mv $index_cdxj_bak index.cdxj.$datetimestamp
  echo "Schon vorhandenen und umbenannten Index $index_cdxj_bak nach index.cdxj.$datetimestamp umbenannt und dadurch deaktiviert." >> $logfile
fi

# Auch alle alten Teilindexe umbenennen und dadurch deaktivieren
index_partial_bak=""
akt_partial_number=1;
printf -v index_partial_bak "index%02d.$datetimestamp.cdxj" $akt_partial_number
while [ -f $index_partial_bak ]; do
  printf -v index_partial_deakt "index%02d.cdxj.$datetimestamp" $akt_partial_number
  mv $index_partial_bak $index_partial_deakt
  echo "$index_partial_bak gab es schon; umbenannt nach $index_partial_deakt und dadurch deaktiviert." >> $logfile
  ((akt_partial_number++))
  printf -v index_partial_bak "index%02d.$datetimestamp.cdxj" $akt_partial_number
done
((akt_partial_number--))
echo "$akt_partial_number Backup-Teilindexe deaktiviert." >> $logfile

echo "********************************************************************************" >> $logfile
echo `date`
echo `date` >> $logfile
echo "ENDE Reindexierung aller Webharvests häppchenweise, Sammlung $coll"
echo "ENDE Reindexierung aller Webharvests häppchenweise, Sammlung $coll" >> $logfile
echo "********************************************************************************" >> $logfile
cd $actdir
exit 0

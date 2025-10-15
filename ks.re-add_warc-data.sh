#!/bin/bash
# ***************************************************************************
# Fügt Archive (aus /data2/wpull-data, /data2/heritrix-data oder /data2/public-data) hinzu,
# die schon vor dem letzen Update (ks.auto_add.sh)
# im Index gewesen waren (Meldungen "Archivfile existiert" + "Archivfile ist neuer. Nichts zu tun."),
# aber die aus dem Index verschwunden sind (weil dieser gelöscht wurde).
# Dazu wird eine Liste durchgegangen, die zuvor aus ks.auto_add.log gewonnen wurde.
# Sie enthält alle zu indexierenden WARC-Archive mit vollem Pfadnamen ("$dataverz/$warcfile")
# Autor: Kuss, 17.09.2019
# KS 13.10.2025:
# Um einen Teilindex indexMN.cdxj (wieder) aufzubauen, 
# muss zunächst der aktuelle Index index.cdxj gesichert werden:
#   mv index.cdxj index.bak.cdxj
# Außerdem muss der aktuelle Cron-Job ks.auto_add.sh deaktiviert werden.
# Nachdem dieses Skript dann gelaufen ist (es kann auch mehrfach laufen),
# müssen die Indexe umbenannt werden:
#   mv index.cdxj indexMN.cdxj
#   mv index.bak.cdxj index.cdxj
# Dann den Cronjob wieder aktivieren. Für Jira-Tickets TOS-1313 und TOS-1315.
# ***************************************************************************
# Argument 1: Collection
coll=$1
liste=$2
# Beispielaufruf: ./ks.re-add_warc-data.sh lesesaal /tmp/added_warcfiles_wpull_20240921-20250227.txt
archive=/opt/pywb/collections/$coll/archive
logfile=/opt/pywb/logs/ks.re-add_warc-data.log
echo "" >> $logfile
echo "********************************************************************************" >> $logfile
echo `date` >> $logfile
echo "START Re-Adding Collection $coll"
echo "START Re-Adding Collection $coll" >> $logfile
echo "********************************************************************************" >> $logfile

while read warcfile
do
  echo "warcfile=$warcfile" >> $logfile
  warcbase=`basename $warcfile`
  # Archivfile (symbolischer Link) löschen
  rm $archive/$warcbase
  echo "Warcfile wird hinzugefügt." >> $logfile
  /opt/pywb/bin/ks.add_warc.sh $coll $warcfile >> $logfile
done < $liste

exit 0

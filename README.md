# pywb-scripts
Skripte, um Web-Inhalte in pywb zu importieren.
Autor: I. Kuss  
Erstanlagedatum  : 29.Januar 2020  
Änderung / Grund : 13.10.2023 / Erstindexierung auf tardis-01
Änderung / Grund : 15.01.2024 / Ersteinrichtung nwweb-test

# Einrichtung
```bash
$ ssh wayback@tardis-01
$ cd /opt/pywb
$ git clone https://github.com/hbz/pywb.bin.git bin  
```
# i.) Erstmaliges Hinzufügen von Webinhalten zu Python-Wayback Index & Archiv
#     Gesamtindexierung des vorhandenen Bestandes

# I. Lesesaal-Sammlung
Neuaufbau der pywb-Sammlung "Lesesaal"  
ssh wayback@wayback  
Löschen der Sammlung "Lesesaal"  
cd /opt/pywb
. Python3/bin/activate
cd bin
./ks.remove_collection.sh wayback  
Neuanlage der Sammlung "Lesesaal"  
cd /opt/pywb  
wb-manager init wayback  

Aufteilung auf multiple Indizes in der Sammlung "lesesaal"  
  mkdir /opt/pywb/logs
# 1. Index:   index.cdxj       enthält: wpull-data, cdn-data  
#    Neuerzeugung des Index:  
#    cd /opt/pywb/bin
#    ./ks.index_wpull-data.sh wayback  >> /opt/pywb/logs/ks.index_wpull-data.log  
# 2. Index:   index_htrx.cdxj  enthält: heritrix-data  
#   Neuerzeugung des Index:  
#   ./ks.index_heritrix-data.sh wayback  >> /opt/pywb/logs/ks.index_heritrix-data.log  
1.+2. zusammenfassen und häppchenweise ausführen ! (z.Zt. 7 * 10 GB groß!):
   Index: index.cdxj   enthält: wpull-data, heritrix-data, cdn-data
    Neuerzeugung des Index:  
    cd /opt/pywb/bin
    nohup ./ks.reindex_haeppchenweise.sh >> /opt/pywb/logs/ks.auto_add_cron.log & 
    # läuft seit Freitag, 13.Oktober, 18:35 Uhr.
    # Muss sieben Indexe index01.cdjx, ..., index07.cdjx erzeugen und einen aktuellen Index index.cdxj.
    # fertig Dienstag, 17. Oktober, 23:05 Uhr.
3. Index:   index_wget.cdxj  enthält: wget-data  
   Neuerzeugung des Index:  
   ./ks.index_wget-data.sh wayback  >> /opt/pywb/logs/ks.index_wget-data.log  

# II. Weltweit-Sammlung
Neuaufbau der pywb-Sammlung "Weltweit"  
ssh wayback@tardis-01  
Löschen der Sammlung "Weltweit"  
cd /opt/pywb/bin/  
./ks.remove_collection.sh public  
Neuanlage der Sammlung "Weltweit"  
cd /opt/pywb  
wb-manager init public  

Ein Index:  index.cdxj       enthält: public-data, cdn-data  
    ACHTUNG !! Die Verzeichnisse  
    /opt/regal/wpull-data, /opt/regal/heritrix-data und /opt/regal/wget-data  
    müssen auf dem wayback-Server eingerichtet sein, jeweils als symbolische Verknüpfungen zu  
    /data2/wpull-data,     /data2/heritrix-data     bzw. /data2/wget-data  ,  
   weil die Links in /data2/public-data darauf verweisen !  
   Neuerzeugung des Index:  
   cd /opt/pywb/bin
   # Das muss eigentlich auch noch häppchenweise geschehen !! Z.Zt. 20,6 GB groß
   ./ks.index_public-data.sh public  >> /opt/pywb/logs/ks.index_public-data.log  
    # läuft seit Mittwoch, 18.Oktober, 18:13 Uhr.
    # fertig Sonntag, 22. Oktober, 04:10 Uhr.

# ii.) Automatischer Update des Index und der Sammlung der Archivdateien für neu hinzugekommene oder aktualisierte Crawl-Vorgänge
Achtung: Funktioniert nicht für gelöschte Crawl-Archive !  
ks.auto_add.sh >> /opt/pywb/logs/ks.auto_add_cron.log  
Das als cronjob einstellen:
# m h  dom mon dow   Befehl
# Indexierung neu geharvesteter Webschnitte (Python-Wayback) (seit 22.05.2020)
0 * * * * /opt/pywb/bin/ks.auto_add.sh >> /opt/pywb/logs/ks.auto_add_cron.log

# iii.) Überwachung, dass die Indizes nicht zu groß werden
### Dieser Schritt braucht nicht mehr gemacht zu werden, da es seit Mai 2020 in ks.auto_add.sh integriert ist !!!
# Monitoring der pywb Indexe

Die Indexe der pywb sollen nicht größer als 10GB werden. Dieses Skipt wird von monit aufgerufen  
und schickt eine Mail, sobald der Indexe die kritische Größe erreicht.  
Das Skript erwartet die Angabe der maximalen Größe in MB.  

Aufruf:  
$ check_pywb_indexsize.sh <pywb-index> <maximale Größe>  
Aufruf in monit Konfiguration mit absoluten Pfaden  
$ /opt/pywb/bin/check_pywb_indexsize.sh /opt/pywb/collections/weltweit/indexes/index.cdxj 10000  


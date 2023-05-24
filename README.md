# pywb-scripts
scripts for managing content in pywb
Autor: I. Kuss  
Erstanlagedatum: 29.Januar 2020  

# Einrichtung
```bash
$ ssh wayback@wayback
$ cd /opt/pywb
$ git clone https://github.com/hbz/pywb.bin.git bin  
```
# i.) Erstmaliges Hinzufügen von Webinhalten zu Python-Wayback Index & Archiv
#     Gesamtindexierung des vorhandenen Bestandes

# I. Lesesaal-Sammlung
Neuaufbau der pywb-Sammlung "Lesesaal"  
ssh wayback@wayback  
Löschen der Sammlung "Lesesaal"  
cd /opt/pywb/bin/  
./ks.remove_collection.sh lesesaal  
Neuanlage der Sammlung "Lesesaal"  
cd /opt/pywb  
/opt/pywb/Python3/bin/wb-manager init lesesaal  

Aufteilung auf multiple Indizes in der Sammlung "lesesaal"  
1. Index:   index.cdxj       enthält: wpull-data, cdn-data  
   Neuerzeugung des Index:  
   ./ks.index_wpull-data.sh lesesaal  >> /opt/pywb/logs/ks.index_wpull-data.log  
2. Index:   index_htrx.cdxj  enthält: heritrix-data  
   Neuerzeugung des Index:  
   ./ks.index_heritrix-data.sh lesesaal  >> /opt/pywb/logs/ks.index_heritrix-data.log  
3. Index:   index_wget.cdxj  enthält: wget-data  
   Neuerzeugung des Index:  
   ./ks.index_wget-data.sh lesesaal  >> /opt/pywb/logs/ks.index_wget-data.log  

# II. Weltweit-Sammlung
Neuaufbau der pywb-Sammlung "Weltweit"  
ssh wayback@wayback2  
Löschen der Sammlung "Weltweit"  
cd /opt/pywb/bin/  
./ks.remove_collection.sh weltweit  
Neuanlage der Sammlung "Weltweit"  
cd /opt/pywb  
/opt/pywb/Python3/bin/wb-manager init weltweit  

Ein Index:  index.cdxj       enthält: public-data, cdn-data  
    ACHTUNG !! Die Verzeichnisse  
    /opt/regal/wpull-data, /opt/regal/heritrix-data und /opt/regal/wget-data  
    müssen auf dem wayback-Server eingerichtet sein, jeweils als symbolische Verknüpfungen zu  
    /data2/wpull-data,     /data2/heritrix-data     bzw. /data2/wget-data  ,  
   weil die Links in /data2/public-data darauf verweisen !  
   Neuerzeugung des Index:  
   ./ks.index_public-data.sh weltweit  >> /opt/pywb/logs/ks.index_public-data.log  

# ii.) Automatischer Update des Index und der Sammlung der Archivdateien für neu hinzugekommene oder aktualisierte Crawl-Vorgänge
Achtung: Funktioniert nicht für gelöschte Crawl-Archive !  
ks.auto_add.sh >> /opt/pywb/logs/ks.auto_add_cron.log  

# iii.) Überwachung, dass die Indizes nicht zu groß werden
# Monitoring der pywb Indexe

Die Indexe der pywb sollen nicht größer als 10GB werden. Dieses Skipt wird von monit aufgerufen  
und schickt eine Mail, sobald der Indexe die kritische Größe erreicht.  
Das Skript erwartet die Angabe der maximalen Größe in MB.  

Aufruf:  
$ check_pywb_indexsize.sh <pywb-index> <maximale Größe>  
Aufruf in monit Konfiguration mit absoluten Pfaden  
$ /opt/pywb/bin/check_pywb_indexsize.sh /opt/pywb/collections/weltweit/indexes/index.cdxj 10000  


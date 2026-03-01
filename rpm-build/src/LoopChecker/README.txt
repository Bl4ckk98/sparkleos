È NECESSARIO INSTALLARE I REQUIREMENTS. Bisogna essere fuori dalla VPN aziendale.

Questo codice controlla, dato in input un pcap in formato JSON, se sono presenti dei loop tramite una conta dei Transaction ID (TCAP).

Comando base per fare il pcap: sudo tcpdump -i any -v -w /tmp/loop_check.pcap "net 93.186.0.0/16"

ISTRUZIONI:
- Apri il pcap che vuoi controllare.
- File > Esporta decodifiche di pacchetti > Come JSON.
- Il file si deve necessariamente chiamare "pcap" ed avere estensione json, altrimenti fallirà.
- Ti verrà chiesto di selezionare una soglia da controllare. Questo valore va scelto con attenzione anche sulla base del tempo di cattura. Se hai fatto un pcap di un minuto, non ha senso dare un threshold di 100.
- L'output verrà salvato su un file txt.
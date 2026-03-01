import time
from collections import defaultdict
from colorama import Fore, init

init(autoreset=True)  # Permette di ripristinare il colore di default dopo ogni stampa colorata

def get_threshold():
    while True:
        try:
            threshold = int(input("Per favore, inserisci un threshold: "))
            if threshold <= 1:
                raise ValueError("Il threshold deve essere maggiore di 1.")
            return threshold
        except ValueError as e:
            print(f"Errore: {e}")

def extract_transaction_ids(text_file, threshold):
    # Leggi il file come testo
    try:
        print("Sto leggendo il file...")
        with open(text_file, 'r', encoding='utf-8', errors = 'ignore') as f:
            text = f.read()
    except FileNotFoundError as e:
        print(f"Errore: {e}")
        time.sleep(5)
        return None, False

    # Estrai tutti i transaction id
    print("Sto estraendo i Transaction IDs...")
    transaction_ids = defaultdict(int)
    for line in text.split('\n'):
        if 'tcap.tid' in line:
            # Estrae l'ID di transazione, inclusi i ":"
            transaction_id = line.split('tcap.tid":')[-1].strip().strip('",')
            #transaction_id = line.split('sccp.calling.digits":')[-1].strip().strip('",')
            transaction_ids[transaction_id] += 1

    # Controlla se qualsiasi transaction ID supera il threshold
    loop_found = any(freq > threshold for freq in transaction_ids.values())
    if loop_found:
        print(Fore.RED + "Trovato un possibile loop con il threshold selezionato.")
    else:
        print(Fore.GREEN + "Nessun loop trovato con il threshold selezionato.")

    return transaction_ids, loop_found

def write_transaction_ids_to_file(transaction_ids, threshold, output_file):
    # Ordina gli id di transazione in base alla frequenza in modo decrescente
    print("Sto ordinando i Transaction IDs...")
    sorted_transaction_ids = sorted(transaction_ids.items(), key=lambda x: x[1], reverse=True)

    # Scrivi gli id di transazione e le loro frequenze in un file
    print("Scrivo il file...")
    with open(output_file, 'w') as f:
        for tid, freq in sorted_transaction_ids:
            if freq > threshold:
                f.write(f'Il Transaction ID {tid} si verifica {freq} volte.\n')

def main():
    while True:
        text_file = 'pcap.json'
        output_file = 'output.txt'

        threshold = get_threshold()
        transaction_ids, loop_found = extract_transaction_ids(text_file, threshold)

        if transaction_ids is not None and loop_found:
            write_transaction_ids_to_file(transaction_ids, threshold, output_file)
            print(f'Output salvato nel file {output_file}.')
            time.sleep(5)
            break
        elif transaction_ids is not None and not loop_found:
            time.sleep(5)
            break
        else:
            continue

if __name__ == "__main__":
    main()

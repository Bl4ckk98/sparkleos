import customtkinter as ctk
from tkinter import messagebox
import re
import os
import subprocess

# Impostazioni globali per il tema
ctk.set_appearance_mode("Dark")  # Imposta la modalità dark (mi saltavano gli occhi)
ctk.set_default_color_theme("blue")  # Imposta il tema di colore (purtroppo solo blue, dark-blue e green)

# Validazione formato IPv4
def is_valid_ipv4(ip):
    pattern = re.compile(r"^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$")
    return pattern.match(ip) is not None

# Sanificazione dell'input (tolgo gli spazi)
def sanitize_input(ip):
    return ip.strip()

def create_batch_action():
    client_name = client_entry.get().strip().upper()
    if not client_name:
        messagebox.showerror("Errore", "Il nome del cliente è obbligatorio.")
        return

    # Configurazioni di gateway e interfacce mappate dal foglio flussi
    gateway_interface_config = {
        "CATANIA STP": {"primary": ("10.15.86.161", "eth3"), "secondary": ("10.15.86.177", "eth4")},
        "MILANO STP": {"primary": ("10.17.87.36", "eth3"), "secondary": ("10.17.87.52", "eth4")},
        "CATANIA DRA": {"primary": ("10.15.86.225", "eth1"), "secondary": ("10.15.86.241", "eth2")},
        "MILANO DRA": {"primary": ("10.17.87.100", "eth1"), "secondary": ("10.17.87.116", "eth2")},
        "NEW YORK DRA": {"primary": ("10.18.87.161", "eth1"), "secondary": ("10.18.87.177", "eth2")},
        "MIAMI DRA": {"primary": ("10.16.87.129", "eth1"), "secondary": ("10.16.87.145", "eth2")}
    }

    # Salva i comandi in un file con nome dinamico
    filename = f"{client_name}_commands.txt"
    with open(filename, 'w') as file:
        for section_title, entries in ip_entry_widgets.items():
            base_key = section_title[:-2]  # Es "CATANIA STP"
            # Utilizza un dizionario per tracciare i commenti scritti per primario e secondario
            comment_written = {"primary": False, "secondary": False}
    
            for entry_type, entry_widget in entries.items():
                ips = sanitize_input(entry_widget.get()).split(',')  # Separa gli IP inseriti sulla base della virgola
                for ip in ips:
                    ip = ip.strip()  # Rimuove gli spazi bianchi all'inizio e alla fine di ciascun IP
                    if is_valid_ipv4(ip):
                        gateway, interface = gateway_interface_config[base_key][entry_type]
                        route_command = f"sudo route add {ip} gw {gateway} dev {interface}" 
                        
                        if not comment_written[entry_type]:
                            # Scrivi il nome della sezione e il commento solo una volta per tipo di cella (primario o secondario)
                            file.write(f'{section_title} {entry_type}\n')
                            echo_comment_command = f'echo "# {client_name}" >> /etc/sysconfig/network-scripts/route-{interface}'
                            file.write(echo_comment_command + "\n")
                            comment_written[entry_type] = True
    
                        if "STP" in base_key:
                            echo_ip_command = f'echo "{ip}/32 via {gateway} dev {interface}" >> /etc/sysconfig/network-scripts/route-{interface}'
                        else:  # Per i DRA ometti "dev <interfaccia>"
                            echo_ip_command = f'echo "{ip}/32 via {gateway}" >> /etc/sysconfig/network-scripts/route-{interface}'
    
                        # Scrivi i comandi nel file per ogni ciclo
                        file.write(route_command + "\n")
                        file.write(echo_ip_command + "\n\n")
    
        if not file.tell():  # Controlla se il file è vuoto (nessun comando scritto)
            messagebox.showerror("Errore", "Inserire almeno un indirizzo IP valido.")
            return
    
    subprocess.run(['start', '', filename], shell=True)


# Creazione della finestra principale
root = ctk.CTk()
root.title("Route Adder")
root.geometry("700x800")

# Funzione per creare le label con testo centrato
def create_label(text, container):
    label = ctk.CTkLabel(container, text=text, anchor='center')
    label.pack(side='top', fill='x', padx=10, pady=5)

# Sezione per la descrizione
description_frame = ctk.CTkFrame(root)
description_frame.pack(fill='x', expand=True, padx=10, pady=20)
create_label("Aggiungi gli IP del cliente nel nodo corrispondente. Il campo di sinistra va messo per gli IP che si raggiungono\ncon GW primario, mentre quelli di destra per gli IP che si raggiungono con GW secondario.\nIl Nome Cliente verrà usato per il commento nelle rotte di backup.\nPer inserire più IP bisogna separarli con una virgola.", description_frame)

# Sezione CLIENTE
client_frame = ctk.CTkFrame(root)
client_frame.pack(pady=10, fill='x', padx=20)
client_label = ctk.CTkLabel(client_frame, text="NOME CLIENTE")
client_label.pack(side='left', padx=10)
client_entry = ctk.CTkEntry(client_frame)
client_entry.pack(side='left', fill='x', expand=True)


# Funzione per creare sottosezioni con campi di input affiancati

ip_entry_widgets = {}

def create_subsection(title, container):
    global ip_entry_widgets
    subsection_frame = ctk.CTkFrame(container)
    subsection_frame.pack(side='left',fill='both', expand=True, padx=10, pady=5)

    label = ctk.CTkLabel(subsection_frame, text=title)
    label.pack(side='top', padx=10)

    # Crea widget di input primario e secondario
    primary_ip_entry = ctk.CTkEntry(subsection_frame)
    primary_ip_entry.pack(side='left', expand=True, padx=5)
    secondary_ip_entry = ctk.CTkEntry(subsection_frame)
    secondary_ip_entry.pack(side='left', expand=True, padx=5)

    # Organizza i widget di input in un dizionario con chiavi "primary" e "secondary" per gestire le interfacce
    ip_entry_widgets[title] = {"primary": primary_ip_entry, "secondary": secondary_ip_entry}

# Funzione per creare una riga di sottosezioni
def create_subsection_row(titles, container):
    row_frame = ctk.CTkFrame(container)
    row_frame.pack(fill='x', expand=True, pady=5)
    for title in titles:
        create_subsection(title, row_frame)

# Sezione STP
stp_frame = ctk.CTkFrame(root)
stp_frame.pack(fill='x', expand=True, padx=10, pady=10)
create_label("STP", stp_frame)
create_subsection_row(["CATANIA STP 3", "CATANIA STP 4"], stp_frame)
create_subsection_row(["MILANO STP 3", "MILANO STP 4"], stp_frame)

# Sezione DRA
dra_frame = ctk.CTkFrame(root)
dra_frame.pack(fill='x', expand=True, padx=10, pady=10)
create_label("DRA", dra_frame)
create_subsection_row(["CATANIA DRA 1", "CATANIA DRA 2"], dra_frame)
create_subsection_row(["MILANO DRA 1", "MILANO DRA 2"], dra_frame)
create_subsection_row(["NEW YORK DRA 1", "NEW YORK DRA 2"], dra_frame)
create_subsection_row(["MIAMI DRA 1", "MIAMI DRA 2"], dra_frame)

# Sezione CREATE
create_frame = ctk.CTkFrame(root)
create_frame.pack(fill='x', expand=True, padx=10, pady=5)
create_button = ctk.CTkButton(create_frame, text="CREA BATCH", corner_radius=10, command=create_batch_action)
create_button.pack(side='top', pady=5)

# Avvio della GUI
root.resizable(False, False) # Vieta il resize della finestra (RIP 1366x768)
root.mainloop()
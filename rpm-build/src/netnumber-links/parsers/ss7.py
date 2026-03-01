import re
from utils import extract_field, extract_all_values, read_file, parse_blocks

# ---------------------------------------------------------------------------
# Link header parsing
# ---------------------------------------------------------------------------

LINK_HEADER_RE = re.compile(
    r"ss7_(\w+)_stp_link::(\w+)\s+\S+\.(\S+)",
    re.IGNORECASE,
)

CONNECTION_REF_RE = re.compile(r"connection\s*=\s*&(\S+)")


def parse_link_block(block: dict) -> dict | None:
    """
    Analizza un blocco di tipo ss7_*_stp_link e restituisce un dict con
    i campi estratti oppure None se non è un link block.
    """
    header = block["header"]
    m = LINK_HEADER_RE.match(header)
    if not m:
        return None

    instance = m.group(1).lower()   # es. "itu" o "ansi"
    link_type = m.group(2).lower()  # es. "m3ua" o "m2pa"
    link_name = m.group(3)          # es. "LK00-CAT3-STP-4644-SIESTPIP"

    body = block["body"]
    description = extract_field(body, "description") or "N/A"
    slc = extract_field(body, "slc")
    if slc is None:
        slc = "N/A"

    # Riferimento alla connection
    cm = CONNECTION_REF_RE.search(body)
    connection_ref = cm.group(1) if cm else None

    return {
        "Nome Link": link_name,
        "Descrizione": description,
        "Istanza": instance,
        "Tipo": link_type,
        "SLC": slc,
        "connection_ref": connection_ref,  # chiave temporanea, rimossa dopo
        "Endpoint Locale": "N/A",
        "Endpoint Remoto": "N/A",
    }


# ---------------------------------------------------------------------------
# Connection & Binding parsing
# ---------------------------------------------------------------------------

CONNECTION_HEADER_RE = re.compile(
    r"ss7_\w+_stp_connection::\w+\s+(\S+)",
    re.IGNORECASE,
)

BINDING_HEADER_RE = re.compile(
    r"ss7_\w+_stp_binding\s+(\S+)",
    re.IGNORECASE,
)


def build_connection_map(blocks: list[dict]) -> dict[str, dict]:
    """
    Costruisce una mappa  nome_connessione -> {host: [...], port: str}
    dai blocchi di tipo connection.
    """
    conn_map = {}
    for block in blocks:
        m = CONNECTION_HEADER_RE.match(block["header"])
        if not m:
            continue
        name = m.group(1)
        body = block["body"]
        hosts = extract_all_values(body, "host")
        port = extract_field(body, "port") or ""
        conn_map[name] = {"hosts": hosts, "port": port}
    return conn_map


def build_binding_map(blocks: list[dict]) -> dict[str, dict]:
    """
    Costruisce una mappa  nome_binding -> {host: [...], port: str}
    dai blocchi di tipo binding.
    """
    bind_map = {}
    for block in blocks:
        m = BINDING_HEADER_RE.match(block["header"])
        if not m:
            continue
        name = m.group(1)
        body = block["body"]
        hosts = extract_all_values(body, "host")
        port = extract_field(body, "port") or ""
        bind_map[name] = {"hosts": hosts, "port": port}
    return bind_map


def format_endpoint(hosts: list[str], port: str) -> str:
    """Formatta l'endpoint come  IP1,IP2:PORTA."""
    if not hosts and not port:
        return "N/A"
    ip_part = ",".join(hosts) if hosts else "?"
    return f"{ip_part}:{port}" if port else ip_part


def find_local_binding(connection_name: str, connection_port: str, bind_map: dict[str, dict]) -> str:
    """
    Cerca il binding locale che corrisponde alla connessione.
    """
    if not connection_name:
        return "N/A"

    parts = connection_name.split(".")
    if len(parts) < 3:
        return "N/A"

    binding_prefix = f"{parts[0]}.{parts[1]}"

    if binding_prefix in bind_map:
        bdata = bind_map[binding_prefix]
        return format_endpoint(bdata["hosts"], bdata["port"])

    mid_part = parts[1]
    candidates = []
    for bname, bdata in bind_map.items():
        bparts = bname.split(".")
        if len(bparts) >= 2 and bparts[1] == mid_part:
            candidates.append(bdata)

    if candidates:
        all_hosts = []
        port = ""
        for c in candidates:
            all_hosts.extend(c["hosts"])
            port = c["port"]
        return format_endpoint(all_hosts, port)

    return "N/A"


# ---------------------------------------------------------------------------
# Main SS7 process handler
# ---------------------------------------------------------------------------

def process_ss7_file(filepath: str) -> list[dict]:
    """
    Legge il file, estrae i blocchi SS7, risolve connessioni e binding,
    e restituisce una lista di dict pronti per l'Excel.
    """
    content = read_file(filepath)
    blocks = parse_blocks(content, prefix="ss7_")

    conn_map = build_connection_map(blocks)
    bind_map = build_binding_map(blocks)

    rows = []
    for block in blocks:
        link = parse_link_block(block)
        if link is None:
            continue

        conn_ref = link.pop("connection_ref")

        if conn_ref and conn_ref in conn_map:
            cdata = conn_map[conn_ref]
            link["Endpoint Remoto"] = format_endpoint(cdata["hosts"], cdata["port"])
            conn_port = cdata["port"]
        else:
            conn_port = ""

        link["Endpoint Locale"] = find_local_binding(conn_ref, conn_port, bind_map)

        rows.append(link)

    return rows

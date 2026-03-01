import re

def read_file(path: str) -> str:
    """Legge un file e restituisce il contenuto come stringa."""
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        return f.read()

def parse_blocks(content: str, prefix: str = "") -> list[dict]:
    """
    Estrae i blocchi dal file.
    Se prefix è specificato, la riga di inizio blocco deve iniziare con quel prefisso (es. 'ss7_').
    Ogni blocco è delimitato da '{' ... '}' e preceduto da un'intestazione.
    """
    blocks = []
    lines = content.splitlines()
    n = len(lines)
    i = 0

    while i < n:
        line = lines[i]
        stripped = line.strip()

        # Cerca una riga che apre un blocco
        if (not prefix or stripped.startswith(prefix)) and "{" in stripped:
            parts = stripped.split("{", 1)
            header_part = parts[0].strip()
            rest = parts[1]

            open_braces = line.count("{") - line.count("}")
            body_lines = []

            if rest.strip().endswith("}") and open_braces == 0:
                # Blocco su una sola riga
                body_lines.append(rest.strip().removesuffix("}"))
            else:
                body_lines.append(rest)

            j = i + 1
            while j < n and open_braces > 0:
                bl = lines[j]
                open_braces += bl.count("{") - bl.count("}")
                body_lines.append(bl)
                j += 1

            blocks.append(
                {
                    "header": header_part,
                    "body": "\n".join(body_lines),
                    "start_line": i,
                }
            )
            i = j
        else:
            i += 1

    return blocks

def extract_field(body: str, field: str) -> str | None:
    """
    Estrae il valore di un campo del tipo  field=value  oppure  field=[value].
    Restituisce None se non trovato.
    """
    pattern = rf'{re.escape(field)}\s*=\s*(?:\[([^\]]*)\]|"([^"]*)"|([\S]+))'
    m = re.search(pattern, body)
    if m:
        return (m.group(1) or m.group(2) or m.group(3) or "").strip()
    return None

def extract_all_values(body: str, field: str) -> list[str]:
    """Estrae tutti i valori di un campo (utile per host multipli)."""
    pattern = rf'{re.escape(field)}\s*=\s*(?:\[([^\]]*)\]|"([^"]*)"|([\S]+))'
    results = []
    for m in re.finditer(pattern, body):
        val = (m.group(1) or m.group(2) or m.group(3) or "").strip()
        if val:
            results.append(val)
    return results

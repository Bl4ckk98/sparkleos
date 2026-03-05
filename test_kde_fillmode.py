import urllib.request
import json

# Check KDE plasma docs or something similar, or just search duckduckgo
def search(query):
    url = f"https://lite.duckduckgo.com/lite/"
    data = urllib.parse.urlencode({'q': query}).encode('utf-8')
    req = urllib.request.Request(url, data=data, headers={'User-Agent': 'Mozilla/5.0'})
    html = urllib.request.urlopen(req).read().decode('utf-8')
    return html

print("Ready")

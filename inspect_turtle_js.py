import urllib.request
import re

url = "https://adblock.turtlecute.org/js/index.js"
req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
with urllib.request.urlopen(req) as response:
    js = response.read().decode('utf-8')

print("Total length:", len(js))
# Find how domains are tested
matches = re.findall(r'.{0,100}(?:http|url|test|check|domain|status).{0,100}', js)
for m in matches[:15]:
    print("MATCH:", m)

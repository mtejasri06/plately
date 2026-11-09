"""Run ONCE (needs internet):  python3 tools/download_images.py
Downloads a real photo for every recipe into assets/images/<slug>.jpg
(Wikipedia article photo first, generic cuisine food photo as fallback)."""
import json, os, re, sys, time, urllib.parse, urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'assets', 'images')
UA = {'User-Agent': 'PlatelyApp/1.0 (recipe photo downloader)'}
os.makedirs(OUT, exist_ok=True)

def slug(s): return re.sub(r'[^a-z0-9]+', '-', s.lower()).strip('-')
def get(url, timeout=25):
    return urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=timeout).read()

src = open(os.path.join(ROOT, 'lib', 'data', 'recipes_data.dart'), encoding='utf-8').read()
items = re.findall(r"name: '((?:[^'\\]|\\.)*)', cuisine: '([^']*)'", src)
items += [('Chicken biryani', 'Indian'), ('Pizza margherita', 'Italian'), ('Sushi', 'Japanese'),
          ('Taco', 'Mexican'), ('Pad thai', 'Thai')]

def wiki_urls(name):
    try:
        j = json.loads(get('https://en.wikipedia.org/api/rest_v1/page/summary/' +
                           urllib.parse.quote(name.replace(' ', '_'))))
        t = (j.get('thumbnail') or {}).get('source')
        if t: return [re.sub(r'/\d+px-', '/640px-', t), t]
    except Exception: pass
    return []

ok = fb = bad = 0
for n, (name, cuisine) in enumerate(items, 1):
    dest = os.path.join(OUT, slug(name) + '.jpg')
    if os.path.exists(dest) and os.path.getsize(dest) > 2000: continue
    urls = wiki_urls(name)
    urls.append('https://loremflickr.com/640/420/%s,food?lock=%d' % (urllib.parse.quote(cuisine.lower()), n))
    done = False
    for i, u in enumerate(urls):
        try:
            data = get(u)
            if len(data) > 2000:
                open(dest, 'wb').write(data)
                done = True
                if u.startswith('https://loremflickr'): fb += 1
                else: ok += 1
                break
        except Exception: time.sleep(0.5)
    if not done: bad += 1; print('FAILED:', name)
    print('[%d/%d] %s' % (n, len(items), name)); sys.stdout.flush()
    time.sleep(0.15)
print('\nDone. exact photos: %d, generic fallbacks: %d, failed: %d' % (ok, fb, bad))

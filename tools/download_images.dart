// Replace tools/download_images.dart with this file, then:  dart run tools/download_images.dart
// Skips photos you already have. Tries: exact Wikipedia article -> Wikipedia search -> Wikimedia Commons search.
import 'dart:convert';
import 'dart:io';

String slug(String s) =>
    s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');

Future<List<int>> get(HttpClient c, String url) async {
  final req = await c.getUrl(Uri.parse(url));
  req.headers.set('User-Agent', 'PlatelyApp/1.0 (recipe photo downloader)');
  req.followRedirects = true;
  req.maxRedirects = 8;
  final res = await req.close();
  if (res.statusCode != 200) {
    await res.drain();
    throw 'status ${res.statusCode}';
  }
  final b = <int>[];
  await for (final d in res) {
    b.addAll(d);
  }
  return b;
}

Future<dynamic> json(HttpClient c, String url) async => jsonDecode(utf8.decode(await get(c, url)));

Future<List<String>> exact(HttpClient c, String name) async {
  try {
    final j = await json(c,
        'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(name.replaceAll(' ', '_'))}');
    final t = (j['thumbnail'] as Map?)?['source'] as String?;
    return t == null ? [] : [t.replaceFirst(RegExp(r'/\d+px-'), '/640px-'), t];
  } catch (_) {
    return [];
  }
}

Future<List<String>> wikiSearch(HttpClient c, String q) async {
  try {
    final j = await json(c,
        'https://en.wikipedia.org/w/api.php?action=query&format=json&generator=search&gsrlimit=4&prop=pageimages&piprop=thumbnail&pithumbsize=640&gsrsearch=${Uri.encodeComponent(q)}');
    final pages = ((j['query']?['pages']) as Map?)?.values.toList() ?? [];
    pages.sort((a, b) => ((a['index'] as int?) ?? 9).compareTo((b['index'] as int?) ?? 9));
    return [for (final p in pages) if (p['thumbnail'] != null) p['thumbnail']['source'] as String];
  } catch (_) {
    return [];
  }
}

Future<List<String>> commons(HttpClient c, String q) async {
  try {
    final j = await json(c,
        'https://commons.wikimedia.org/w/api.php?action=query&format=json&generator=search&gsrnamespace=6&gsrlimit=5&prop=imageinfo&iiprop=url&iiurlwidth=640&gsrsearch=${Uri.encodeComponent(q)}');
    final pages = ((j['query']?['pages']) as Map?)?.values.toList() ?? [];
    return [
      for (final p in pages)
        if (p['imageinfo'] != null && (p['imageinfo'][0]['thumburl'] ?? '').toString().toLowerCase().endsWith('.jpg'))
          p['imageinfo'][0]['thumburl'] as String
    ];
  } catch (_) {
    return [];
  }
}

bool isImage(List<int> b) =>
    b.length > 2000 && ((b[0] == 0xFF && b[1] == 0xD8) || (b[0] == 0x89 && b[1] == 0x50));

Future<bool> tryUrls(HttpClient c, List<String> urls, File dest) async {
  for (final u in urls) {
    try {
      final data = await get(c, u);
      if (isImage(data)) {
        dest.writeAsBytesSync(data);
        return true;
      }
    } catch (_) {}
  }
  return false;
}

Future<void> main() async {
  final c = HttpClient()..connectionTimeout = const Duration(seconds: 20);
  Directory('assets/images').createSync(recursive: true);
  final src = File('lib/data/recipes_data.dart').readAsStringSync();
  final items = RegExp(r"name: '((?:[^'\\]|\\.)*)', cuisine: '([^']*)'")
      .allMatches(src)
      .map((m) => [m[1]!, m[2]!])
      .toList();
  items.addAll([
    ['Chicken biryani', 'Indian'], ['Pizza margherita', 'Italian'], ['Sushi', 'Japanese'],
    ['Taco', 'Mexican'], ['Pad thai', 'Thai'],
  ]);
  var got = 0, failed = <String>[];
  for (var n = 0; n < items.length; n++) {
    final name = items[n][0], cuisine = items[n][1];
    final dest = File('assets/images/${slug(name)}.jpg');
    if (dest.existsSync() && dest.lengthSync() > 2000) continue;
    var ok = await tryUrls(c, await exact(c, name), dest);
    if (!ok) ok = await tryUrls(c, await wikiSearch(c, '$name dish'), dest);
    if (!ok) ok = await tryUrls(c, await wikiSearch(c, '$name $cuisine food'), dest);
    if (!ok) ok = await tryUrls(c, await commons(c, '$name food'), dest);
    if (ok) {
      got++;
    } else {
      failed.add(name);
    }
    stdout.writeln('[${n + 1}/${items.length}] ${ok ? 'OK    ' : 'FAILED'} $name');
    await Future.delayed(const Duration(milliseconds: 150));
  }
  stdout.writeln('\nDone. new photos: $got, still missing: ${failed.length}');
  if (failed.isNotEmpty) stdout.writeln('Missing: ${failed.join(', ')}');
  exit(0);
}

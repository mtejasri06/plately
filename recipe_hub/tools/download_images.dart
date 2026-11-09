// Run once from the project folder:  dart run tools/download_images.dart
// Downloads a photo for every recipe into assets/images/ (needs internet).
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
  var exact = 0, generic = 0, failed = 0;
  for (var n = 0; n < items.length; n++) {
    final name = items[n][0], cuisine = items[n][1];
    final dest = File('assets/images/${slug(name)}.jpg');
    if (dest.existsSync() && dest.lengthSync() > 2000) continue;
    final urls = <String>[];
    try {
      final j = jsonDecode(utf8.decode(await get(c,
          'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(name.replaceAll(' ', '_'))}')));
      final t = (j['thumbnail'] as Map?)?['source'] as String?;
      if (t != null) urls.addAll([t.replaceFirst(RegExp(r'/\d+px-'), '/640px-'), t]);
    } catch (_) {}
    urls.add('https://loremflickr.com/640/420/${cuisine.toLowerCase()},food?lock=$n');
    var done = false;
    for (final u in urls) {
      try {
        final data = await get(c, u);
        if (data.length > 2000) {
          dest.writeAsBytesSync(data);
          done = true;
          u.contains('loremflickr') ? generic++ : exact++;
          break;
        }
      } catch (_) {}
    }
    if (!done) {
      failed++;
      stdout.writeln('FAILED: $name');
    }
    stdout.writeln('[${n + 1}/${items.length}] $name');
    await Future.delayed(const Duration(milliseconds: 150));
  }
  stdout.writeln('\nDone. exact: $exact, generic: $generic, failed: $failed');
  exit(0);
}

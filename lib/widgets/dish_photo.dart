import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Looks up a real photo of the dish (Wikipedia article image), cached per name.
class _Photos {
  static final Map<String, Future<List<String>>> _cache = {};
  static Future<List<String>> lookup(String name) => _cache.putIfAbsent(name, () async {
        try {
          final title = Uri.encodeComponent(name.trim().replaceAll(' ', '_'));
          final r = await http
              .get(Uri.parse('https://en.wikipedia.org/api/rest_v1/page/summary/$title'));
          if (r.statusCode != 200) return <String>[];
          final t = (jsonDecode(r.body)['thumbnail'] as Map?)?['source'] as String?;
          if (t == null) return <String>[];
          // Try a bigger size first; Wikimedia rejects sizes above the original, so keep the safe one too.
          return [t.replaceFirst(RegExp(r'/\d+px-'), '/640px-'), t];
        } catch (_) {
          return <String>[];
        }
      });
}

class DishPhoto extends StatelessWidget {
  final String name;
  final String cuisine;
  final Color color;
  const DishPhoto({super.key, required this.name, required this.cuisine, required this.color});

  Widget _placeholder({bool loading = false}) => ColoredBox(
        color: color.withOpacity(.18),
        child: Center(
            child: loading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(Icons.restaurant, color: color, size: 36)),
      );

  Widget _chain(List<String> urls) {
    if (urls.isEmpty) return _placeholder();
    return Image.network(urls.first,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        loadingBuilder: (_, child, p) => p == null ? child : _placeholder(loading: true),
        errorBuilder: (_, __, ___) => _chain(urls.sublist(1)));
  }

  static String slug(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');

  /// 1) bundled photo (assets/images, from tools/download_images.py)  2) live web lookup  3) placeholder.
  @override
  Widget build(BuildContext context) => Image.asset('assets/images/${slug(name)}.jpg',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => _network());

  Widget _network() {
    final fb =
        'https://loremflickr.com/640/420/${Uri.encodeComponent(cuisine.toLowerCase())},food?lock=${name.hashCode.abs() % 1000}';
    return FutureBuilder<List<String>>(
      future: _Photos.lookup(name),
      builder: (_, s) {
        if (s.connectionState != ConnectionState.done) return _placeholder(loading: true);
        return _chain([...?s.data, fb]);
      },
    );
  }
}

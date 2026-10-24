import 'dart:io';
import 'dart:math';

const tmpl = r'''
        \        ___--===--___
         \    __=     ___   - \
            _/     o           |
         /==   \     __-- o    |
        |   o   -            _/
         \__    \    -   o //
          -===============-       - dan quayle''';

List<String> wrap(String text, int width) {
  final out = <String>[];
  var line = '';
  for (final word in text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty)) {
    if (line.isEmpty) {
      line = word;
    } else if (line.length + word.length + 1 > width) {
      out.add(line);
      line = word;
    } else {
      line = '$line $word';
    }
  }
  if (line.isNotEmpty) out.add(line);
  return out;
}

void show(String quote, int width) {
  final wraps = wrap(quote, width);
  if (wraps.isEmpty) wraps.add('...');
  final maxwidth = wraps.map((l) => l.length).reduce(max);
  final b = StringBuffer();
  b.writeln(' ${'_' * (maxwidth + 2)}');
  for (var i = 0; i < wraps.length; i++) {
    final single = wraps.length == 1;
    final last = i == wraps.length - 1;
    b.write(i == 0 ? (single ? '< ' : '/ ') : (last ? '\\ ' : '| '));
    b.write(wraps[i].padRight(maxwidth));
    b.writeln(i == 0 ? (single ? ' >' : ' \\') : (last ? ' /' : ' |'));
  }
  b.writeln(' ${'-' * (maxwidth + 2)}');
  b.write(tmpl);
  stdout.writeln(b);
}

void loadFile(String path, Set<String> quotes) {
  try {
    for (final line in File(path).readAsLinesSync()) {
      if (line.length > 4 && !line.startsWith('#')) quotes.add(line);
    }
  } catch (_) {}
}

const usage = '''usage of potatoe:
  --text -t
        print quote text only
  --width -w int
        specify width for text wrapping''';

void main(List<String> args) {
  var text = false;
  int? width;
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (a == '-t' || a == '--text') {
      text = true;
    } else if (a == '-h' || a == '--help') {
      print(usage);
      return;
    } else if (a == '-w' || a == '--width') {
      if (i + 1 < args.length) width = int.tryParse(args[++i]);
    } else if (a.startsWith('-w=') || a.startsWith('--width=')) {
      width = int.tryParse(a.substring(a.indexOf('=') + 1));
    } else {
      stderr.writeln(usage);
      exitCode = 2;
      return;
    }
  }

  final quotes = <String>{};
  for (final f in [
    './quotes.txt',
    '/usr/lib/potatoe/quotes.txt',
    '/var/lib/potatoe/quotes.txt',
  ]) {
    loadFile(f, quotes);
  }
  final list = quotes.isEmpty ? ['no quotes'] : quotes.toList();
  final selected = list[Random().nextInt(list.length)];

  if (text) {
    print(selected);
    return;
  }
  if (width == null) {
    final cols = stdout.hasTerminal ? stdout.terminalColumns : 100;
    width = (0.64 * cols).floor();
  }
  show(selected, width);
}

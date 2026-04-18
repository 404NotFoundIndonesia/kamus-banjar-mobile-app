import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';

final FlutterTts _tts = FlutterTts();

Future<void> speakWord(String text) async {
  await _tts.setLanguage("id-ID");
  await _tts.setPitch(1.0);
  await _tts.speak(text);
}

void copyWordToClipboard(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text)).then((_) {
    Fluttertoast.showToast(
      msg: "Kata $text disalin ke papan klip",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: const Color.fromARGB(255, 72, 93, 112),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  });
}

TextSpan highlightWord(String text, String targets) {
  List<TextSpan> spans = [];
  List<String> targetList = targets.split(';').map((e) => e.trim()).toList();
  if (targetList.isEmpty) {
    return TextSpan(text: text);
  }
  String pattern = targetList.map(RegExp.escape).join('|');
  RegExp regExp = RegExp(pattern, caseSensitive: false);
  Iterable<RegExpMatch> matches = regExp.allMatches(text);
  int lastMatchEnd = 0;
  for (RegExpMatch match in matches) {
    if (match.start > lastMatchEnd) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
    }
    String matchedWord = match.group(0) ?? '';
    spans.add(
      TextSpan(
        text: matchedWord.toLowerCase(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
    lastMatchEnd = match.end;
  }
  if (lastMatchEnd < text.length) {
    spans.add(TextSpan(text: text.substring(lastMatchEnd)));
  }
  return TextSpan(children: spans);
}

String toTitleCase(String text) {
  return text
      .split(' ')
      .map((e) => e[0].toUpperCase() + e.substring(1).toLowerCase())
      .join(' ');
}

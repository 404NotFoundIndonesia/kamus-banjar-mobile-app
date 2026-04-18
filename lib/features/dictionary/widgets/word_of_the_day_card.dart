import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/dictionary_repository.dart';
import 'package:kamus_banjar_mobile_app/core/services/community_service.dart';
import 'package:kamus_banjar_mobile_app/features/dictionary/views/word_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordOfTheDayCard extends StatefulWidget {
  final DictionaryRepository dictionaryRepository;

  const WordOfTheDayCard({super.key, required this.dictionaryRepository});

  @override
  State<WordOfTheDayCard> createState() => _WordOfTheDayCardState();
}

class _WordOfTheDayCardState extends State<WordOfTheDayCard> {
  static const _keyDate = 'wotd_date';
  static const _keyWord = 'wotd_word';
  static const _keyDefinition = 'wotd_definition';
  static const _keyDismissed = 'wotd_dismissed_date';

  String? _word;
  String? _definition;
  bool _hidden = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _init() async {
    if (!mounted) return;
    final service = context.read<CommunityService>();
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();

    if (prefs.getString(_keyDismissed) == today) return;

    final cachedDate = prefs.getString(_keyDate);
    if (cachedDate == today) {
      final word = prefs.getString(_keyWord);
      final definition = prefs.getString(_keyDefinition);
      if (word != null && definition != null) {
        if (mounted) setState(() { _word = word; _definition = definition; _hidden = false; });
        return;
      }
    }

    try {
      final wotd = await service.getWordOfTheDay();
      if (!mounted) return;
      final definition = wotd.meanings.isNotEmpty &&
              wotd.meanings.first.definitions.isNotEmpty
          ? wotd.meanings.first.definitions.first.definition
          : '';

      await prefs.setString(_keyDate, today);
      await prefs.setString(_keyWord, wotd.word);
      await prefs.setString(_keyDefinition, definition);

      if (mounted) {
        setState(() {
          _word = wotd.word;
          _definition = definition;
          _hidden = false;
        });
      }
    } catch (_) {
      // silently fail — card just doesn't show
    }
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDismissed, _todayString());
    setState(() => _hidden = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_hidden || _word == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 16),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WordView(
              dictionaryRepository: widget.dictionaryRepository,
              word: _word!,
            ),
          ),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          decoration: BoxDecoration(
            color: isDark
                ? const Color.fromARGB(255, 18, 41, 58)
                : const Color.fromARGB(255, 219, 239, 255),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kata Hari Ini',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.lightBlue.shade200
                            : Colors.blue.shade700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _word!,
                      style: GoogleFonts.poppins().copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    if (_definition != null && _definition!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        _definition!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: _dismiss,
                icon: Icon(Icons.close,
                    size: 18, color: Colors.grey.shade500),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

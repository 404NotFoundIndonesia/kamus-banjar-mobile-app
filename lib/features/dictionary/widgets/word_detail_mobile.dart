import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kamus_banjar_mobile_app/core/models/word.dart';
import 'package:kamus_banjar_mobile_app/core/utils/word_class_util.dart';
import 'package:kamus_banjar_mobile_app/features/dictionary/widgets/word_detail_helpers.dart';
import 'package:kamus_banjar_mobile_app/features/word_types/word_type_view.dart';
import 'package:kamus_banjar_mobile_app/shared/widgets/bookmark_button_state.dart';

class WordDetailsMobile extends StatelessWidget {
  const WordDetailsMobile({super.key, required this.word});
  final Word word;

  @override
  Widget build(BuildContext context) {
    int index = 0;
    word.word = toTitleCase(word.word);
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 85.4),
        child: IntrinsicHeight(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 8, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          word.word,
                          style: GoogleFonts.poppins().copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 32,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 2),
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12),
                        iconSize: 24,
                        color: Colors.blue,
                        onPressed: () => speakWord(word.word),
                      ),
                      IconButton(
                        icon: const Icon(Icons.content_copy),
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12),
                        iconSize: 20,
                        color: Colors.grey.shade600,
                        onPressed: () => copyWordToClipboard(context, word.word),
                      ),
                      BookmarkButton(word: word.word),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color.fromARGB(255, 18, 41, 58)
                          : const Color.fromARGB(255, 219, 239, 255),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...word.definitions.expand((meaning) {
                          index += 1;
                          return meaning.map((def) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (index > 1) const SizedBox(height: 8),
                                if (def.definition.isNotEmpty)
                                  Wrap(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8),
                                        child: Text(
                                          def.definition,
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const WordTypeView(),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 51, 163, 255),
                                            borderRadius:
                                                BorderRadius.circular(24),
                                          ),
                                          child: Text(
                                            getWordClass(def.partOfSpeech),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                if (def.examples.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      ...def.examples.map((example) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  '[bjn] ',
                                                  style: TextStyle(
                                                      fontFamily: "monospace"),
                                                ),
                                                Expanded(
                                                  child: Text.rich(
                                                    highlightWord(
                                                        example.bjn, word.word),
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  '[id]  ',
                                                  style: TextStyle(
                                                      fontFamily: "monospace"),
                                                ),
                                                Expanded(
                                                  child: Text.rich(
                                                    highlightWord(example.id,
                                                        def.definition),
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                              ],
                            );
                          }).toList();
                        }),
                      ],
                    ),
                  ),
                ),
                if (word.derivatives.isNotEmpty) const SizedBox(height: 24),
                if (word.derivatives.isNotEmpty)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color.fromARGB(255, 39, 27, 15)
                            : const Color.fromARGB(255, 255, 218, 138),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            'Turunan',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...word.derivatives.asMap().entries.map((entry) {
                            final derivative = entry.value;
                            derivative.word = toTitleCase(derivative.word);
                            return Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color.fromARGB(255, 75, 56, 25)
                                    : const Color.fromARGB(255, 255, 243, 192),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (derivative.word.isNotEmpty)
                                    Wrap(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 4),
                                          child: Text(
                                            derivative.word,
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 36,
                                          width: 36,
                                          child: IconButton(
                                            icon: const Icon(
                                                Icons.volume_up_outlined),
                                            padding: EdgeInsets.zero,
                                            iconSize: 24,
                                            color: Colors.grey.shade600,
                                            onPressed: () => speakWord(
                                                derivative.syllable.isNotEmpty
                                                    ? derivative.syllable
                                                        .replaceAll('.', ' ')
                                                    : derivative.word),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 36,
                                          width: 36,
                                          child: IconButton(
                                            icon:
                                                const Icon(Icons.content_copy),
                                            iconSize: 20,
                                            color: Colors.grey.shade600,
                                            onPressed: () =>
                                                copyWordToClipboard(
                                                    context, derivative.word),
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (derivative.syllable.isNotEmpty)
                                    Text(
                                      derivative.syllable,
                                      style: TextStyle(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ...derivative.definitions.map((def) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8),
                                              child: Text(
                                                def.definition,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const WordTypeView(),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    top: 3),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? const Color(0xFFFB8C00)
                                                      : Colors.orange,
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                ),
                                                child: Text(
                                                  getWordClass(
                                                      def.partOfSpeech),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        if (def.examples.isNotEmpty) ...[
                                          ...def.examples.map((example) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 8),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      '[bjn] ',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              "monospace"),
                                                    ),
                                                    Expanded(
                                                      child: Text.rich(
                                                        highlightWord(
                                                            example.bjn,
                                                            derivative.word),
                                                        style: TextStyle(
                                                          color: Theme.of(
                                                                      context)
                                                                  .brightness ==
                                                              Brightness.dark
                                                              ? Colors.white
                                                              : Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      '[id]  ',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              "monospace"),
                                                    ),
                                                    Expanded(
                                                      child: Text.rich(
                                                        highlightWord(example.id,
                                                            def.definition),
                                                        style: TextStyle(
                                                          color: Theme.of(
                                                                      context)
                                                                  .brightness ==
                                                              Brightness.dark
                                                              ? Colors.white
                                                              : Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          }),
                                        ],
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

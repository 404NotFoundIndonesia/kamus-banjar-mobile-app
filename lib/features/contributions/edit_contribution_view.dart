import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kamus_banjar_mobile_app/core/models/contribution.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/contribution_repository.dart';
import 'package:kamus_banjar_mobile_app/core/services/contribution_service.dart';
import 'package:kamus_banjar_mobile_app/core/utils/word_class_util.dart';
import 'package:kamus_banjar_mobile_app/shared/widgets/custom_app_bar.dart';
import 'package:kamus_banjar_mobile_app/shared/widgets/gradient_background.dart';
import 'package:provider/provider.dart';

// Reuse alphabet constant
const _banjarAlphabet = [
  'a', 'b', 'c', 'd', 'g', 'h', 'i', 'j', 'k', 'l',
  'm', 'n', 'p', 'r', 's', 't', 'u', 'w', 'y',
];

class _ExampleData {
  final TextEditingController bjn;
  final TextEditingController id;
  _ExampleData({String bjn = '', String id = ''})
      : bjn = TextEditingController(text: bjn),
        id = TextEditingController(text: id);
  void dispose() {
    bjn.dispose();
    id.dispose();
  }
}

class _DefinitionData {
  String? pos;
  final TextEditingController definition;
  final List<_ExampleData> examples;
  _DefinitionData({this.pos, String def = '', List<_ExampleData>? examples})
      : definition = TextEditingController(text: def),
        examples = examples ?? [];
  void dispose() {
    definition.dispose();
    for (final e in examples) {
      e.dispose();
    }
  }
}

class _MeaningData {
  final List<_DefinitionData> definitions;
  _MeaningData({required this.definitions});
  void dispose() {
    for (final d in definitions) {
      d.dispose();
    }
  }
}

class _DerivDefData {
  String? pos;
  final TextEditingController definition;
  _DerivDefData({this.pos, String def = ''})
      : definition = TextEditingController(text: def);
  void dispose() => definition.dispose();
}

class _DerivativeData {
  final TextEditingController word;
  final TextEditingController syllables;
  final List<_DerivDefData> definitions;
  _DerivativeData({
    String word = '',
    String syllables = '',
    required this.definitions,
  })  : word = TextEditingController(text: word),
        syllables = TextEditingController(text: syllables);
  void dispose() {
    word.dispose();
    syllables.dispose();
    for (final d in definitions) {
      d.dispose();
    }
  }
}

class EditContributionView extends StatefulWidget {
  final Contribution contribution;

  const EditContributionView({super.key, required this.contribution});

  @override
  State<EditContributionView> createState() => _EditContributionViewState();
}

class _EditContributionViewState extends State<EditContributionView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _wordCtrl;
  late TextEditingController _syllablesCtrl;
  late String? _alphabet;
  late List<_MeaningData> _meanings;
  late List<_DerivativeData> _derivatives;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final w = widget.contribution.word;
    _wordCtrl = TextEditingController(text: w.word);
    _syllablesCtrl = TextEditingController(text: w.syllables);
    _alphabet = w.alphabet.isNotEmpty ? w.alphabet : null;

    _meanings = w.meanings.map((m) {
      return _MeaningData(
        definitions: m.definitions.map((d) {
          return _DefinitionData(
            pos: d.partOfSpeech,
            def: d.definition,
            examples: d.examples.map((e) {
              return _ExampleData(bjn: e.bjn, id: e.id);
            }).toList(),
          );
        }).toList(),
      );
    }).toList();

    if (_meanings.isEmpty) {
      _meanings = [
        _MeaningData(definitions: [_DefinitionData()])
      ];
    }

    _derivatives = w.derivatives.map((deriv) {
      return _DerivativeData(
        word: deriv.word,
        syllables: deriv.syllables,
        definitions: deriv.definitions.map((d) {
          return _DerivDefData(pos: d.partOfSpeech, def: d.definition);
        }).toList(),
      );
    }).toList();
  }

  @override
  void dispose() {
    _wordCtrl.dispose();
    _syllablesCtrl.dispose();
    for (final m in _meanings) {
      m.dispose();
    }
    for (final d in _derivatives) {
      d.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_alphabet == null) {
      Fluttertoast.showToast(
        msg: 'Pilih abjad terlebih dahulu.',
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    final repo = context.read<ContributionRepository>();
    setState(() => _isSubmitting = true);

    try {
      final meaningsJson = _meanings.map((m) {
        return {
          'definitions': m.definitions.map((d) {
            return {
              'partOfSpeech': d.pos ?? '',
              'definition': d.definition.text.trim(),
              'examples': d.examples.map((e) {
                return {
                  'bjn': e.bjn.text.trim(),
                  'id': e.id.text.trim(),
                };
              }).toList(),
            };
          }).toList(),
        };
      }).toList();

      final derivativesJson = _derivatives.map((deriv) {
        return {
          'word': deriv.word.text.trim(),
          'syllables': deriv.syllables.text.trim(),
          'definitions': deriv.definitions.map((d) {
            return {
              'partOfSpeech': d.pos ?? '',
              'definition': d.definition.text.trim(),
            };
          }).toList(),
        };
      }).toList();

      await repo.edit(
        widget.contribution.id,
        WordSubmitRequest(
          word: _wordCtrl.text.trim(),
          syllables: _syllablesCtrl.text.trim().isEmpty
              ? null
              : _syllablesCtrl.text.trim(),
          alphabet: _alphabet!,
          meanings: meaningsJson,
          derivatives: derivativesJson.isEmpty ? null : derivativesJson,
        ),
      );

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Kiriman berhasil diperbarui!',
          backgroundColor: Colors.green.shade700,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isClipped = MediaQuery.of(context).viewPadding.top == 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(title: 'Edit Usulan', isClipped: isClipped),
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionCard(
                      isDark: isDark,
                      title: 'Informasi Kata',
                      children: [
                        TextFormField(
                          controller: _wordCtrl,
                          decoration: const InputDecoration(labelText: 'Kata *'),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _syllablesCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Suku Kata',
                            hintText: 'con-toh',
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _alphabet,
                          decoration:
                              const InputDecoration(labelText: 'Abjad *'),
                          items: _banjarAlphabet
                              .map((l) => DropdownMenuItem(
                                    value: l,
                                    child: Text(l.toUpperCase()),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _alphabet = v),
                          validator: (v) => v == null ? 'Pilih abjad' : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._buildMeaningsSection(isDark),
                    const SizedBox(height: 16),
                    ..._buildDerivativesSection(isDark),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Perbarui Usulan',
                              style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMeaningsSection(bool isDark) {
    final widgets = <Widget>[];
    for (int mi = 0; mi < _meanings.length; mi++) {
      final meaning = _meanings[mi];
      widgets.add(
        _sectionCard(
          isDark: isDark,
          title: 'Makna ${mi + 1}',
          trailing: _meanings.length > 1
              ? TextButton(
                  onPressed: () => setState(() {
                    meaning.dispose();
                    _meanings.removeAt(mi);
                  }),
                  child: const Text('Hapus',
                      style: TextStyle(color: Colors.red)),
                )
              : null,
          children: [
            ..._buildDefinitionsInMeaning(meaning, mi, isDark),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () =>
                  setState(() => meaning.definitions.add(_DefinitionData())),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Tambah Definisi'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32)),
              ),
            ),
          ],
        ),
      );
      widgets.add(const SizedBox(height: 8));
    }
    widgets.add(
      OutlinedButton.icon(
        onPressed: () => setState(() => _meanings.add(
            _MeaningData(definitions: [_DefinitionData()]))),
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Tambah Makna'),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.blue.shade50,
          side: const BorderSide(color: Colors.blue),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
      ),
    );
    return widgets;
  }

  List<Widget> _buildDefinitionsInMeaning(
      _MeaningData meaning, int mi, bool isDark) {
    final widgets = <Widget>[];
    for (int di = 0; di < meaning.definitions.length; di++) {
      final def = meaning.definitions[di];
      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? const Color.fromARGB(80, 25, 118, 210)
                : const Color.fromARGB(255, 240, 248, 255),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Definisi ${di + 1}',
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  if (meaning.definitions.length > 1)
                    GestureDetector(
                      onTap: () => setState(() {
                        def.dispose();
                        meaning.definitions.removeAt(di);
                      }),
                      child: Text('Hapus',
                          style: TextStyle(
                              color: Colors.red.shade600, fontSize: 13)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: def.pos,
                decoration: const InputDecoration(
                  labelText: 'Kelas Kata *',
                  isDense: true,
                ),
                items: wordClasses.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text('${e.key} — ${e.value}'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => def.pos = v),
                validator: (v) => v == null ? 'Pilih kelas kata' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: def.definition,
                decoration: const InputDecoration(
                  labelText: 'Definisi *',
                  isDense: true,
                ),
                maxLines: 2,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 8),
              ..._buildExamples(def),
              TextButton.icon(
                onPressed: () =>
                    setState(() => def.examples.add(_ExampleData())),
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Tambah Contoh',
                    style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  List<Widget> _buildExamples(_DefinitionData def) {
    return def.examples.asMap().entries.map((entry) {
      final ei = entry.key;
      final ex = entry.value;
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  TextFormField(
                    controller: ex.bjn,
                    decoration: const InputDecoration(
                      labelText: 'Kalimat Banjar',
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: ex.id,
                    decoration: const InputDecoration(
                      labelText: 'Terjemahan Indonesia',
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() {
                ex.dispose();
                def.examples.removeAt(ei);
              }),
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child:
                    Icon(Icons.close, size: 18, color: Colors.red.shade400),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildDerivativesSection(bool isDark) {
    final widgets = <Widget>[];
    for (int di = 0; di < _derivatives.length; di++) {
      final deriv = _derivatives[di];
      widgets.add(
        _sectionCard(
          isDark: isDark,
          title: 'Turunan ${di + 1}',
          trailing: TextButton(
            onPressed: () => setState(() {
              deriv.dispose();
              _derivatives.removeAt(di);
            }),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
          children: [
            TextFormField(
              controller: deriv.word,
              decoration: const InputDecoration(labelText: 'Kata Turunan *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: deriv.syllables,
              decoration: const InputDecoration(
                  labelText: 'Suku Kata', hintText: 'con-toh'),
            ),
            const SizedBox(height: 8),
            ..._buildDerivDefinitions(deriv),
            OutlinedButton.icon(
              onPressed: () =>
                  setState(() => deriv.definitions.add(_DerivDefData())),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Tambah Definisi'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32)),
              ),
            ),
          ],
        ),
      );
      widgets.add(const SizedBox(height: 8));
    }
    widgets.add(
      OutlinedButton.icon(
        onPressed: () => setState(() => _derivatives.add(_DerivativeData(
            word: '', syllables: '', definitions: [_DerivDefData()]))),
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Tambah Turunan'),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.blue),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
      ),
    );
    return widgets;
  }

  List<Widget> _buildDerivDefinitions(_DerivativeData deriv) {
    return deriv.definitions.asMap().entries.map((entry) {
      final di = entry.key;
      final def = entry.value;
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: def.pos,
                    decoration: const InputDecoration(
                      labelText: 'Kelas Kata *',
                      isDense: true,
                    ),
                    items: wordClasses.entries
                        .map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text('${e.key} — ${e.value}'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => def.pos = v),
                    validator: (v) => v == null ? 'Pilih kelas kata' : null,
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: def.definition,
                    decoration: const InputDecoration(
                      labelText: 'Definisi *',
                      isDense: true,
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                  ),
                ],
              ),
            ),
            if (deriv.definitions.length > 1) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() {
                  def.dispose();
                  deriv.definitions.removeAt(di);
                }),
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Icon(Icons.close,
                      size: 18, color: Colors.red.shade400),
                ),
              ),
            ],
          ],
        ),
      );
    }).toList();
  }

  Widget _sectionCard({
    required bool isDark,
    required String title,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color.fromARGB(255, 18, 41, 58)
            : const Color.fromARGB(255, 219, 239, 255),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

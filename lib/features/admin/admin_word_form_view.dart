import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kamus_banjar_mobile_app/core/models/word.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/admin_repository.dart';
import 'package:kamus_banjar_mobile_app/core/services/contribution_service.dart';
import 'package:kamus_banjar_mobile_app/core/utils/word_class_util.dart';
import 'package:kamus_banjar_mobile_app/shared/widgets/custom_app_bar.dart';
import 'package:kamus_banjar_mobile_app/shared/widgets/gradient_background.dart';
import 'package:provider/provider.dart';

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

class AdminWordFormView extends StatefulWidget {
  final Word? word;

  const AdminWordFormView({super.key, this.word});

  @override
  State<AdminWordFormView> createState() => _AdminWordFormViewState();
}

class _AdminWordFormViewState extends State<AdminWordFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _wordCtrl;
  late TextEditingController _syllablesCtrl;
  String? _alphabet;
  late List<_MeaningData> _meanings;
  late List<_DerivativeData> _derivatives;
  bool _isSubmitting = false;

  bool get _isEditing => widget.word != null;

  @override
  void initState() {
    super.initState();
    final w = widget.word;
    _wordCtrl = TextEditingController(text: w?.word ?? '');
    _syllablesCtrl = TextEditingController(text: w?.syllables ?? '');
    _alphabet = (w != null && w.alphabet.isNotEmpty) ? w.alphabet : null;

    if (w != null && w.meanings.isNotEmpty) {
      _meanings = w.meanings.map((m) {
        return _MeaningData(
          definitions: m.definitions.map((d) {
            return _DefinitionData(
              pos: d.partOfSpeech,
              def: d.definition,
              examples: d.examples
                  .map((e) => _ExampleData(bjn: e.bjn, id: e.id))
                  .toList(),
            );
          }).toList(),
        );
      }).toList();
    } else {
      _meanings = [
        _MeaningData(definitions: [_DefinitionData()])
      ];
    }

    if (w != null) {
      _derivatives = w.derivatives.map((deriv) {
        return _DerivativeData(
          word: deriv.word,
          syllables: deriv.syllables,
          definitions: deriv.definitions
              .map((d) => _DerivDefData(pos: d.partOfSpeech, def: d.definition))
              .toList(),
        );
      }).toList();
    } else {
      _derivatives = [];
    }
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

    final repo = context.read<AdminRepository>();
    setState(() => _isSubmitting = true);

    try {
      final meaningsJson = _meanings.map((m) {
        return {
          'definitions': m.definitions.map((d) {
            return {
              'partOfSpeech': d.pos ?? '',
              'definition': d.definition.text.trim(),
              'examples': d.examples.map((e) {
                return {'bjn': e.bjn.text.trim(), 'id': e.id.text.trim()};
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

      final request = WordSubmitRequest(
        word: _wordCtrl.text.trim(),
        syllables: _syllablesCtrl.text.trim().isEmpty
            ? null
            : _syllablesCtrl.text.trim(),
        alphabet: _alphabet!,
        meanings: meaningsJson,
        derivatives: derivativesJson.isEmpty ? null : derivativesJson,
      );

      if (_isEditing) {
        await repo.updateWord(widget.word!.id!, request);
      } else {
        await repo.createWord(request);
      }

      if (mounted) {
        Fluttertoast.showToast(
          msg: _isEditing
              ? 'Kata berhasil diperbarui!'
              : 'Kata berhasil ditambahkan!',
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

  Widget _sectionCard({
    required bool isDark,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isClipped = MediaQuery.of(context).viewPadding.top == 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final posOptions = wordClasses.keys.toList();

    return Scaffold(
      appBar: CustomAppBar(
        title: _isEditing ? 'Edit Kata' : 'Tambah Kata',
        isClipped: isClipped,
      ),
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
                          decoration:
                              const InputDecoration(labelText: 'Kata *'),
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
                          validator: (v) => v == null ? 'Wajib dipilih' : null,
                        ),
                      ],
                    ),
                    ..._meanings.asMap().entries.map((entry) {
                      final mi = entry.key;
                      final m = entry.value;
                      return _sectionCard(
                        isDark: isDark,
                        title: 'Makna ${mi + 1}',
                        children: [
                          ...m.definitions.asMap().entries.map((de) {
                            final di = de.key;
                            final d = de.value;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (di > 0)
                                  Container(
                                    height: 1,
                                    color: Colors.black12,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                              initialValue: d.pos,
                                        decoration: const InputDecoration(
                                            labelText: 'Kelas Kata'),
                                        items: posOptions
                                            .map((p) => DropdownMenuItem(
                                                value: p,
                                                child: Text(
                                                    '$p — ${wordClasses[p] ?? p}')))
                                            .toList(),
                                        onChanged: (v) =>
                                            setState(() => d.pos = v),
                                      ),
                                    ),
                                    if (m.definitions.length > 1)
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle,
                                            color: Colors.red),
                                        onPressed: () => setState(() {
                                          d.dispose();
                                          m.definitions.removeAt(di);
                                        }),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: d.definition,
                                  decoration: const InputDecoration(
                                      labelText: 'Definisi *'),
                                  maxLines: 2,
                                  validator: (v) => v == null || v.trim().isEmpty
                                      ? 'Wajib diisi'
                                      : null,
                                ),
                                ...d.examples.asMap().entries.map((ee) {
                                  final ei = ee.key;
                                  final ex = ee.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              TextFormField(
                                                controller: ex.bjn,
                                                decoration:
                                                    const InputDecoration(
                                                        labelText:
                                                            'Contoh [bjn]'),
                                              ),
                                              const SizedBox(height: 4),
                                              TextFormField(
                                                controller: ex.id,
                                                decoration:
                                                    const InputDecoration(
                                                        labelText:
                                                            'Terjemahan [id]'),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle,
                                              color: Colors.red),
                                          onPressed: () => setState(() {
                                            ex.dispose();
                                            d.examples.removeAt(ei);
                                          }),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: () => setState(
                                      () => d.examples.add(_ExampleData())),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Tambah Contoh'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(32)),
                                  ),
                                ),
                              ],
                            );
                          }),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => setState(() =>
                                      m.definitions.add(_DefinitionData())),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Tambah Definisi'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(32)),
                                  ),
                                ),
                              ),
                              if (_meanings.length > 1) ...[
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: () => setState(() {
                                    m.dispose();
                                    _meanings.removeAt(mi);
                                  }),
                                  icon: Icon(Icons.delete_outline,
                                      size: 16,
                                      color: Colors.red.shade600),
                                  label: Text('Hapus Makna',
                                      style: TextStyle(
                                          color: Colors.red.shade600)),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: Colors.red.shade400),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(32)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      );
                    }),
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _meanings.add(
                          _MeaningData(
                              definitions: [_DefinitionData()]))),
                      icon: const Icon(Icons.add, color: Colors.blue),
                      label: const Text('Tambah Makna',
                          style: TextStyle(color: Colors.blue)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.blue.shade50,
                        side: const BorderSide(color: Colors.blue),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_derivatives.isNotEmpty)
                      _sectionCard(
                        isDark: isDark,
                        title: 'Kata Turunan',
                        children: _derivatives.asMap().entries.map((entry) {
                          final ki = entry.key;
                          final deriv = entry.value;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (ki > 0)
                                Container(
                                  height: 1,
                                  color: Colors.black12,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text('Turunan ${ki + 1}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle,
                                        color: Colors.red),
                                    onPressed: () => setState(() {
                                      deriv.dispose();
                                      _derivatives.removeAt(ki);
                                    }),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: deriv.word,
                                decoration:
                                    const InputDecoration(labelText: 'Kata *'),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Wajib diisi'
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: deriv.syllables,
                                decoration: const InputDecoration(
                                    labelText: 'Suku Kata'),
                              ),
                              ...deriv.definitions.asMap().entries.map((de) {
                                final di = de.key;
                                final d = de.value;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            DropdownButtonFormField<String>(
                                              initialValue: d.pos,
                                              decoration: const InputDecoration(
                                                  labelText: 'Kelas Kata'),
                                              items: posOptions
                                                  .map((p) => DropdownMenuItem(
                                                      value: p,
                                                      child: Text(p)))
                                                  .toList(),
                                              onChanged: (v) =>
                                                  setState(() => d.pos = v),
                                            ),
                                            const SizedBox(height: 4),
                                            TextFormField(
                                              controller: d.definition,
                                              decoration: const InputDecoration(
                                                  labelText: 'Definisi *'),
                                              validator: (v) =>
                                                  v == null || v.trim().isEmpty
                                                      ? 'Wajib diisi'
                                                      : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (deriv.definitions.length > 1)
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle,
                                              color: Colors.red),
                                          onPressed: () => setState(() {
                                            d.dispose();
                                            deriv.definitions.removeAt(di);
                                          }),
                                        ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: () => setState(() =>
                                    deriv.definitions.add(_DerivDefData())),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Tambah Definisi'),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(32)),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _derivatives.add(
                          _DerivativeData(
                              definitions: [_DerivDefData()]))),
                      icon: const Icon(Icons.add, color: Colors.blue),
                      label: const Text('Tambah Turunan',
                          style: TextStyle(color: Colors.blue)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.blue.shade50,
                        side: const BorderSide(color: Colors.blue),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              _isEditing ? 'Perbarui Kata' : 'Tambah Kata'),
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
}

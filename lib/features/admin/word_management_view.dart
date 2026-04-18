import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kamus_banjar_mobile_app/core/models/word.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/admin_repository.dart';
import 'package:kamus_banjar_mobile_app/features/admin/admin_word_form_view.dart';
import 'package:kamus_banjar_mobile_app/shared/widgets/custom_app_bar.dart';
import 'package:kamus_banjar_mobile_app/shared/widgets/gradient_background.dart';
import 'package:provider/provider.dart';

class WordManagementView extends StatefulWidget {
  const WordManagementView({super.key});

  @override
  State<WordManagementView> createState() => _WordManagementViewState();
}

class _WordManagementViewState extends State<WordManagementView> {
  final List<Word> _items = [];
  int _page = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  String? _statusFilter;
  String? _sourceFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchPage(1));
  }

  Future<void> _fetchPage(int page) async {
    if (_isLoading || _isLoadingMore) return;
    final repo = context.read<AdminRepository>();

    if (page == 1) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final result = await repo.listWords(
        status: _statusFilter,
        source: _sourceFilter,
        page: page,
      );
      setState(() {
        if (page == 1) {
          _items
            ..clear()
            ..addAll(result.words);
        } else {
          _items.addAll(result.words);
        }
        _page = result.page;
        _totalPages = result.totalPages;
      });
    } catch (e) {
      if (page == 1) {
        setState(() => _error = e.toString());
      } else {
        Fluttertoast.showToast(
          msg: 'Gagal memuat.',
          backgroundColor: Colors.red.shade700,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _delete(Word w) async {
    if (w.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kata'),
        content: Text(
            'Hapus kata "${w.word}"? Kata akan dinonaktifkan (soft delete).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final repo = context.read<AdminRepository>();
    try {
      await repo.deleteWord(w.id!);
      setState(() => _items.removeWhere((e) => e.id == w.id));
      Fluttertoast.showToast(
        msg: 'Kata berhasil dihapus.',
        backgroundColor: Colors.green.shade700,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isClipped = MediaQuery.of(context).viewPadding.top == 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(title: 'Kelola Kata', isClipped: isClipped),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminWordFormView(),
            ),
          );
          _fetchPage(1);
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kata'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                _FilterBar(
                  statusFilter: _statusFilter,
                  sourceFilter: _sourceFilter,
                  onStatusChanged: (v) {
                    setState(() => _statusFilter = v);
                    _fetchPage(1);
                  },
                  onSourceChanged: (v) {
                    setState(() => _sourceFilter = v);
                    _fetchPage(1);
                  },
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(113, 33, 149, 243),
                            backgroundColor: Color.fromARGB(41, 33, 149, 243),
                          ),
                        )
                      : _error != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(_error!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.red)),
                                    const SizedBox(height: 16),
                                    OutlinedButton(
                                      onPressed: () => _fetchPage(1),
                                      child: const Text('Coba Lagi'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : _items.isEmpty
                              ? const Center(
                                  child: Text('Tidak ada kata.',
                                      style: TextStyle(fontSize: 16)),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 8, 16, 100),
                                  itemCount: _items.length +
                                      (_page < _totalPages ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == _items.length) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8),
                                        child: OutlinedButton(
                                          onPressed: _isLoadingMore
                                              ? null
                                              : () =>
                                                  _fetchPage(_page + 1),
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor:
                                                Colors.blue.shade50,
                                            side: const BorderSide(
                                                color: Colors.blue),
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                            ),
                                          ),
                                          child: _isLoadingMore
                                              ? const SizedBox(
                                                  height: 18,
                                                  width: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2),
                                                )
                                              : const Text(
                                                  'Muat Lebih Banyak'),
                                        ),
                                      );
                                    }
                                    final w = _items[index];
                                    return _WordCard(
                                      word: w,
                                      isDark: isDark,
                                      onEdit: w.id == null
                                          ? null
                                          : () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      AdminWordFormView(
                                                          word: w),
                                                ),
                                              );
                                              _fetchPage(1);
                                            },
                                      onDelete: () => _delete(w),
                                    );
                                  },
                                ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final String? statusFilter;
  final String? sourceFilter;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onSourceChanged;

  const _FilterBar({
    required this.statusFilter,
    required this.sourceFilter,
    required this.onStatusChanged,
    required this.onSourceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String?>(
              key: ValueKey('status_$statusFilter'),
              initialValue: statusFilter,
              decoration: const InputDecoration(
                labelText: 'Status',
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Semua')),
                DropdownMenuItem(value: 'active', child: Text('Aktif')),
                DropdownMenuItem(value: 'pending', child: Text('Menunggu')),
                DropdownMenuItem(value: 'rejected', child: Text('Ditolak')),
              ],
              onChanged: onStatusChanged,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String?>(
              key: ValueKey('source_$sourceFilter'),
              initialValue: sourceFilter,
              decoration: const InputDecoration(
                labelText: 'Sumber',
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Semua')),
                DropdownMenuItem(value: 'official', child: Text('Resmi')),
                DropdownMenuItem(
                    value: 'community', child: Text('Komunitas')),
              ],
              onChanged: onSourceChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  final Word word;
  final bool isDark;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  const _WordCard({
    required this.word,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final w = word;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color.fromARGB(255, 18, 41, 58)
            : const Color.fromARGB(255, 219, 239, 255),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  w.word,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              if (w.source != null)
                _SourceBadge(source: w.source!),
            ],
          ),
          if (w.syllables.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              w.syllables,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (onEdit != null)
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined,
                      size: 16, color: Colors.blue),
                  label:
                      const Text('Edit', style: TextStyle(color: Colors.blue)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                  ),
                ),
              if (onEdit != null) const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline,
                    size: 16, color: Colors.red.shade600),
                label: Text('Hapus',
                    style: TextStyle(color: Colors.red.shade600)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.shade400),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final String source;

  const _SourceBadge({required this.source});

  @override
  Widget build(BuildContext context) {
    final isOfficial = source == 'official';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isOfficial
            ? const Color.fromARGB(255, 51, 163, 255)
            : Colors.orange,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        isOfficial ? 'Resmi' : 'Komunitas',
        style: const TextStyle(
            fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

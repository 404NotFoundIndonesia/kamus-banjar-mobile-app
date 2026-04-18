import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kamus_banjar_mobile_app/core/models/contribution.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/contribution_repository.dart';
import 'package:kamus_banjar_mobile_app/features/contributions/edit_contribution_view.dart';
import 'package:kamus_banjar_mobile_app/shared/widgets/custom_app_bar.dart';
import 'package:kamus_banjar_mobile_app/shared/widgets/gradient_background.dart';
import 'package:provider/provider.dart';

class MyContributionsView extends StatefulWidget {
  const MyContributionsView({super.key});

  @override
  State<MyContributionsView> createState() => _MyContributionsViewState();
}

class _MyContributionsViewState extends State<MyContributionsView> {
  final List<Contribution> _items = [];
  int _page = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchPage(1));
  }

  Future<void> _fetchPage(int page) async {
    if (_isLoading || _isLoadingMore) return;
    final repo = context.read<ContributionRepository>();
    if (page == 1) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    } else {
      setState(() => _isLoadingMore = true);
    }
    try {
      final result = await repo.getMine(page: page);
      setState(() {
        if (page == 1) {
          _items
            ..clear()
            ..addAll(result.contributions);
        } else {
          _items.addAll(result.contributions);
        }
        _page = result.page;
        _totalPages = result.totalPages;
      });
    } catch (e) {
      if (page == 1) {
        setState(() => _error = e.toString());
      } else {
        Fluttertoast.showToast(
          msg: 'Gagal memuat lebih banyak.',
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

  Future<void> _delete(Contribution c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Usulan'),
        content: Text('Hapus usulan kata "${c.word.word}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final repo = context.read<ContributionRepository>();
    try {
      await repo.delete(c.id);
      setState(() => _items.removeWhere((e) => e.id == c.id));
      Fluttertoast.showToast(
        msg: 'Usulan berhasil dihapus.',
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

    return Scaffold(
      appBar: CustomAppBar(title: 'Usulan Saya', isClipped: isClipped),
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
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
                                  style: const TextStyle(color: Colors.red)),
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
                            child: Text(
                              'Belum ada usulan kata.',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                            itemCount:
                                _items.length + (_page < _totalPages ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _items.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: OutlinedButton(
                                    onPressed: _isLoadingMore
                                        ? null
                                        : () => _fetchPage(_page + 1),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade50,
                                      side:
                                          const BorderSide(color: Colors.blue),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(32),
                                      ),
                                    ),
                                    child: _isLoadingMore
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : const Text('Muat Lebih Banyak'),
                                  ),
                                );
                              }
                              return _ContributionCard(
                                contribution: _items[index],
                                onEdit: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditContributionView(
                                          contribution: _items[index]),
                                    ),
                                  );
                                  _fetchPage(1);
                                },
                                onDelete: () => _delete(_items[index]),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _ContributionCard extends StatelessWidget {
  final Contribution contribution;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ContributionCard({
    required this.contribution,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = contribution;
    final canEdit = c.action == 'submitted' || c.action == 'rejected';

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
                  c.word.word,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              _StatusBadge(action: c.action),
            ],
          ),
          if (c.action == 'rejected' && c.notes != null) ...[
            const SizedBox(height: 6),
            Text(
              c.notes!,
              style: TextStyle(
                  fontSize: 13, color: Colors.red.shade600),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            _formatDate(c.createdAt),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          if (canEdit) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined,
                      size: 16, color: Colors.blue),
                  label: const Text('Edit',
                      style: TextStyle(color: Colors.blue)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline,
                      size: 16, color: Colors.red.shade600),
                  label: Text('Hapus',
                      style: TextStyle(color: Colors.red.shade600)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade400),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String action;

  const _StatusBadge({required this.action});

  @override
  Widget build(BuildContext context) {
    Color bg;
    String label;
    switch (action) {
      case 'submitted':
        bg = Colors.blue;
        label = 'Menunggu';
        break;
      case 'approved':
        bg = Colors.green.shade600;
        label = 'Disetujui';
        break;
      case 'rejected':
        bg = Colors.red.shade600;
        label = 'Ditolak';
        break;
      case 'revised':
        bg = Colors.orange;
        label = 'Direvisi';
        break;
      default:
        bg = Colors.grey;
        label = action;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

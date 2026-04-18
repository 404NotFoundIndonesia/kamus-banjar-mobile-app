import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kamus_banjar_mobile_app/core/models/contribution.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/admin_repository.dart';
import 'package:kamus_banjar_mobile_app/shared/widgets/custom_app_bar.dart';
import 'package:kamus_banjar_mobile_app/shared/widgets/gradient_background.dart';
import 'package:provider/provider.dart';

const _tabs = ['Semua', 'Menunggu', 'Disetujui', 'Ditolak'];
const _tabStatuses = [null, 'submitted', 'approved', 'rejected'];

class ContributionReviewView extends StatelessWidget {
  const ContributionReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final isClipped = MediaQuery.of(context).viewPadding.top == 0.0;

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: CustomAppBar(title: 'Review Usulan', isClipped: isClipped),
        body: Stack(
          children: [
            const GradientBackground(),
            Column(
              children: [
                TabBar(
                  tabs: _tabs.map((t) => Tab(text: t)).toList(),
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                ),
                Expanded(
                  child: TabBarView(
                    children: List.generate(
                      _tabs.length,
                      (i) => _ContributionTab(status: _tabStatuses[i]),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContributionTab extends StatefulWidget {
  final String? status;

  const _ContributionTab({required this.status});

  @override
  State<_ContributionTab> createState() => _ContributionTabState();
}

class _ContributionTabState extends State<_ContributionTab>
    with AutomaticKeepAliveClientMixin {
  final List<Contribution> _items = [];
  int _page = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  @override
  bool get wantKeepAlive => true;

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
      final result = await repo.listContributions(
          status: widget.status, page: page);
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

  Future<void> _approve(Contribution c) async {
    final repo = context.read<AdminRepository>();
    try {
      await repo.approve(c.id);
      setState(() => _items.removeWhere((e) => e.id == c.id));
      Fluttertoast.showToast(
        msg: 'Usulan disetujui.',
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

  Future<void> _reject(Contribution c) async {
    final notesController = TextEditingController();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tolak Usulan "${c.word.word}"',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                hintText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Tolak'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    final repo = context.read<AdminRepository>();
    try {
      final notes =
          notesController.text.trim().isEmpty ? null : notesController.text.trim();
      await repo.reject(c.id, notes: notes);
      setState(() => _items.removeWhere((e) => e.id == c.id));
      Fluttertoast.showToast(
        msg: 'Usulan ditolak.',
        backgroundColor: const Color.fromARGB(255, 72, 93, 112),
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
    super.build(context);

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(113, 33, 149, 243),
          backgroundColor: Color.fromARGB(41, 33, 149, 243),
        ),
      );
    }

    if (_error != null) {
      return Center(
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
      );
    }

    if (_items.isEmpty) {
      return const Center(
        child: Text('Tidak ada usulan.', style: TextStyle(fontSize: 16)),
      );
    }

    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: _items.length + (_page < _totalPages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton(
                onPressed: _isLoadingMore ? null : () => _fetchPage(_page + 1),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  side: const BorderSide(color: Colors.blue),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32)),
                ),
                child: _isLoadingMore
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Muat Lebih Banyak'),
              ),
            );
          }

          final c = _items[index];
          return _ContributionCard(
            contribution: c,
            onApprove: c.action == 'submitted' ? () => _approve(c) : null,
            onReject: c.action == 'submitted' ? () => _reject(c) : null,
          );
        },
      ),
    );
  }
}

class _ContributionCard extends StatelessWidget {
  final Contribution contribution;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _ContributionCard({
    required this.contribution,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = contribution;

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
          const SizedBox(height: 4),
          Text(
            _formatDate(c.createdAt),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          if (c.action == 'rejected' && c.notes != null) ...[
            const SizedBox(height: 6),
            Text(
              c.notes!,
              style: TextStyle(fontSize: 13, color: Colors.red.shade600),
            ),
          ],
          if (onApprove != null || onReject != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onApprove != null)
                  OutlinedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check, size: 16, color: Colors.green),
                    label: const Text('Setujui',
                        style: TextStyle(color: Colors.green)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                    ),
                  ),
                if (onApprove != null && onReject != null)
                  const SizedBox(width: 8),
                if (onReject != null)
                  OutlinedButton.icon(
                    onPressed: onReject,
                    icon: Icon(Icons.close, size: 16, color: Colors.red.shade600),
                    label: Text('Tolak',
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

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}';
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
          color: bg, borderRadius: BorderRadius.circular(24)),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

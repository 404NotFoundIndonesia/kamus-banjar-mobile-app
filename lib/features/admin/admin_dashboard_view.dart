import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kamus_banjar_mobile_app/core/models/admin_stats.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/admin_repository.dart';
import 'package:kamus_banjar_mobile_app/features/admin/contribution_review_view.dart';
import 'package:kamus_banjar_mobile_app/features/admin/user_management_view.dart';
import 'package:kamus_banjar_mobile_app/features/admin/word_management_view.dart';
import 'package:kamus_banjar_mobile_app/features/admin/wotd_scheduler_view.dart';
import 'package:kamus_banjar_mobile_app/shared/widgets/custom_app_bar.dart';
import 'package:kamus_banjar_mobile_app/shared/widgets/gradient_background.dart';
import 'package:provider/provider.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  AdminStats? _stats;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchStats());
  }

  Future<void> _fetchStats() async {
    final repo = context.read<AdminRepository>();
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final stats = await repo.getStats();
      setState(() => _stats = stats);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isClipped = MediaQuery.of(context).viewPadding.top == 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(title: 'Admin', isClipped: isClipped),
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _fetchStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    _StatsCard(
                        stats: _stats, isLoading: _isLoading, error: _error),
                    const SizedBox(height: 24),
                    Text(
                      'Aksi Cepat',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _QuickActionGrid(isDark: isDark),
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

class _StatsCard extends StatelessWidget {
  final AdminStats? stats;
  final bool isLoading;
  final String? error;

  const _StatsCard({
    required this.stats,
    required this.isLoading,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
          Text(
            'Statistik',
            style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(113, 33, 149, 243),
                backgroundColor: Color.fromARGB(41, 33, 149, 243),
              ),
            )
          else if (error != null)
            Text(error!, style: TextStyle(color: Colors.red.shade600))
          else if (stats == null)
            const SizedBox.shrink()
          else
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2,
              children: [
                _StatTile(
                  label: 'Kata Resmi',
                  value: stats!.wordsOfficial.toString(),
                  color: Colors.blue,
                ),
                _StatTile(
                  label: 'Kata Komunitas',
                  value: stats!.wordsCommunity.toString(),
                  color: Colors.green.shade600,
                ),
                _StatTile(
                  label: 'Menunggu Review',
                  value: stats!.wordsPending.toString(),
                  color: Colors.orange,
                ),
                _StatTile(
                  label: 'Total Pengguna',
                  value: stats!.usersTotal.toString(),
                  color: Colors.purple,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  final bool isDark;

  const _QuickActionGrid({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(
        icon: Icons.rate_review_outlined,
        label: 'Review Usulan',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const ContributionReviewView()),
        ),
      ),
      _ActionItem(
        icon: Icons.menu_book_outlined,
        label: 'Kelola Kata',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WordManagementView()),
        ),
      ),
      _ActionItem(
        icon: Icons.people_outline,
        label: 'Kelola Pengguna',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UserManagementView()),
        ),
      ),
      _ActionItem(
        icon: Icons.calendar_today_outlined,
        label: 'Atur Kata Hari Ini',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WotdSchedulerView()),
        ),
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: actions
          .map((a) => _QuickActionCard(item: a, isDark: isDark))
          .toList(),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _ActionItem item;
  final bool isDark;

  const _QuickActionCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? const Color.fromARGB(255, 18, 41, 58)
              : const Color.fromARGB(255, 219, 239, 255),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: Colors.blue, size: 28),
            const SizedBox(height: 8),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

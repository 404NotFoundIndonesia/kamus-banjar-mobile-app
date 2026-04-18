import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kamus_banjar_mobile_app/core/models/user.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/admin_repository.dart';
import 'package:kamus_banjar_mobile_app/shared/widgets/custom_app_bar.dart';
import 'package:kamus_banjar_mobile_app/shared/widgets/gradient_background.dart';
import 'package:provider/provider.dart';

class UserManagementView extends StatefulWidget {
  const UserManagementView({super.key});

  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  final List<User> _items = [];
  int _page = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  String? _roleFilter;
  bool? _activeFilter;

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
      final result = await repo.listUsers(
        role: _roleFilter,
        active: _activeFilter,
        page: page,
      );
      setState(() {
        if (page == 1) {
          _items
            ..clear()
            ..addAll(result.users);
        } else {
          _items.addAll(result.users);
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

  Future<void> _toggleActive(User u) async {
    final repo = context.read<AdminRepository>();
    try {
      if (u.isActive) {
        await repo.deactivateUser(u.id);
      } else {
        await repo.activateUser(u.id);
      }
      setState(() {
        final idx = _items.indexWhere((e) => e.id == u.id);
        if (idx != -1) {
          _items[idx] = User(
            id: u.id,
            name: u.name,
            email: u.email,
            role: u.role,
            isActive: !u.isActive,
          );
        }
      });
      Fluttertoast.showToast(
        msg: u.isActive ? 'Pengguna dinonaktifkan.' : 'Pengguna diaktifkan.',
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

  Future<void> _promote(User u) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Jadikan Admin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jadikan "${u.name}" sebagai admin?'),
            const SizedBox(height: 8),
            const Text(
              'Tindakan ini tidak dapat dibatalkan melalui aplikasi.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Jadikan Admin',
                style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final repo = context.read<AdminRepository>();
    try {
      await repo.promoteUser(u.id);
      setState(() {
        final idx = _items.indexWhere((e) => e.id == u.id);
        if (idx != -1) {
          _items[idx] = User(
            id: u.id,
            name: u.name,
            email: u.email,
            role: 'admin',
            isActive: u.isActive,
          );
        }
      });
      Fluttertoast.showToast(
        msg: '${u.name} sekarang admin.',
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
      appBar: CustomAppBar(title: 'Kelola Pengguna', isClipped: isClipped),
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                _FilterBar(
                  roleFilter: _roleFilter,
                  activeFilter: _activeFilter,
                  onRoleChanged: (v) {
                    setState(() => _roleFilter = v);
                    _fetchPage(1);
                  },
                  onActiveChanged: (v) {
                    setState(() => _activeFilter = v);
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
                                  child: Text('Tidak ada pengguna.',
                                      style: TextStyle(fontSize: 16)),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 8, 16, 32),
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
                                                  BorderRadius.circular(
                                                      32),
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
                                    final u = _items[index];
                                    return _UserCard(
                                      user: u,
                                      isDark: isDark,
                                      onToggleActive: () => _toggleActive(u),
                                      onPromote:
                                          u.role == 'user' ? () => _promote(u) : null,
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
  final String? roleFilter;
  final bool? activeFilter;
  final ValueChanged<String?> onRoleChanged;
  final ValueChanged<bool?> onActiveChanged;

  const _FilterBar({
    required this.roleFilter,
    required this.activeFilter,
    required this.onRoleChanged,
    required this.onActiveChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String?>(
              key: ValueKey('role_$roleFilter'),
              initialValue: roleFilter,
              decoration: const InputDecoration(
                labelText: 'Role',
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Semua')),
                DropdownMenuItem(value: 'user', child: Text('Pengguna')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: onRoleChanged,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<bool?>(
              key: ValueKey('active_$activeFilter'),
              initialValue: activeFilter,
              decoration: const InputDecoration(
                labelText: 'Status',
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Semua')),
                DropdownMenuItem(value: true, child: Text('Aktif')),
                DropdownMenuItem(value: false, child: Text('Nonaktif')),
              ],
              onChanged: onActiveChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final User user;
  final bool isDark;
  final VoidCallback onToggleActive;
  final VoidCallback? onPromote;

  const _UserCard({
    required this.user,
    required this.isDark,
    required this.onToggleActive,
    required this.onPromote,
  });

  @override
  Widget build(BuildContext context) {
    final u = user;

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
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue.shade400,
                child: Text(
                  u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.name,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    Text(u.email,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              _RoleBadge(role: u.role),
            ],
          ),
          if (!u.isActive) ...[
            const SizedBox(height: 6),
            Text(
              'Akun nonaktif',
              style: TextStyle(fontSize: 12, color: Colors.red.shade600),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton(
                onPressed: onToggleActive,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: u.isActive
                          ? Colors.red.shade400
                          : Colors.green.shade400),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32)),
                ),
                child: Text(
                  u.isActive ? 'Nonaktifkan' : 'Aktifkan',
                  style: TextStyle(
                      color: u.isActive
                          ? Colors.red.shade600
                          : Colors.green.shade600),
                ),
              ),
              if (onPromote != null) ...[
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onPromote,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                  ),
                  child: const Text('Jadikan Admin',
                      style: TextStyle(color: Colors.orange)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAdmin = role == 'admin';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isAdmin
            ? (isDark ? const Color(0xFFFB8C00) : Colors.orange)
            : const Color.fromARGB(255, 51, 163, 255),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        isAdmin ? 'Admin' : 'Pengguna',
        style: const TextStyle(
            fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kamus_banjar_mobile_app/core/models/comment.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/auth_repository.dart';
import 'package:kamus_banjar_mobile_app/core/services/community_service.dart';
import 'package:kamus_banjar_mobile_app/features/auth/login_view.dart';
import 'package:kamus_banjar_mobile_app/features/auth/register_view.dart';
import 'package:provider/provider.dart';

class CommentSection extends StatefulWidget {
  final String word;

  const CommentSection({super.key, required this.word});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  List<Comment> _comments = [];
  bool _isLoading = true;
  String? _error;

  String? _replyToId;
  String? _replyToUser;

  final _inputController = TextEditingController();
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadComments());
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final service = context.read<CommunityService>();
      final comments = await service.getComments(widget.word);
      if (mounted) setState(() { _comments = comments; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _isLoading = false; _error = 'Gagal memuat komentar.'; });
    }
  }

  Future<void> _postComment() async {
    final body = _inputController.text.trim();
    if (body.isEmpty) return;

    final auth = context.read<AuthRepository>();
    if (!auth.isAuthenticated) return;

    setState(() => _isPosting = true);
    try {
      final service = context.read<CommunityService>();
      final comment = await service.postComment(
        auth.accessToken!,
        widget.word,
        body,
        parentId: _replyToId,
      );
      _inputController.clear();
      if (!mounted) return;
      setState(() {
        _replyToId = null;
        _replyToUser = null;
        if (comment.parentId == null) {
          _comments.add(comment);
        } else {
          final idx = _comments.indexWhere((c) => c.id == comment.parentId);
          if (idx != -1) {
            _comments[idx] =
                _comments[idx].copyWith(replies: [..._comments[idx].replies, comment]);
          } else {
            _loadComments();
          }
        }
      });
    } catch (_) {
      Fluttertoast.showToast(
        msg: 'Gagal mengirim komentar. Coba lagi.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Future<void> _deleteComment(String commentId, {String? parentId}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Komentar'),
        content:
            const Text('Apakah Anda yakin ingin menghapus komentar ini?'),
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

    final auth = context.read<AuthRepository>();
    final service = context.read<CommunityService>();
    try {
      await service.deleteOwnComment(
          auth.accessToken!, widget.word, commentId);
      if (!mounted) return;
      setState(() {
        if (parentId == null) {
          _comments.removeWhere((c) => c.id == commentId);
        } else {
          final idx = _comments.indexWhere((c) => c.id == parentId);
          if (idx != -1) {
            _comments[idx] = _comments[idx].copyWith(
              replies: _comments[idx]
                  .replies
                  .where((r) => r.id != commentId)
                  .toList(),
            );
          }
        }
      });
    } catch (_) {
      Fluttertoast.showToast(
        msg: 'Gagal menghapus komentar. Coba lagi.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays >= 365) return '${(diff.inDays / 365).floor()} tahun lalu';
    if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()} bulan lalu';
    if (diff.inDays > 0) return '${diff.inDays} hari lalu';
    if (diff.inHours > 0) return '${diff.inHours} jam lalu';
    if (diff.inMinutes > 0) return '${diff.inMinutes} menit lalu';
    return 'Baru saja';
  }

  Widget _buildComment(
    Comment comment, {
    bool isReply = false,
    String? parentId,
  }) {
    final auth = context.read<AuthRepository>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOwn = auth.user?.id == comment.userId;

    return Padding(
      padding: EdgeInsets.only(
        left: isReply ? 20 : 0,
        bottom: 8,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? const Color.fromARGB(255, 18, 41, 58)
              : const Color.fromARGB(255, 243, 248, 255),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  comment.userName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isDark
                        ? Colors.lightBlue.shade200
                        : Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _relativeTime(comment.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(comment.body, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Row(
              children: [
                if (!isReply)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _replyToId = comment.id;
                        _replyToUser = comment.userName;
                      });
                    },
                    child: Text(
                      'Balas',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (isOwn) ...[
                  if (!isReply) const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _deleteComment(
                      comment.id,
                      parentId: parentId,
                    ),
                    child: Text(
                      'Hapus',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_replyToUser != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Text(
                  'Membalas ${_replyToUser!}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() {
                    _replyToId = null;
                    _replyToUser = null;
                  }),
                  child: Icon(Icons.close, size: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey.shade800
                      : const Color.fromARGB(255, 243, 243, 243),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _inputController,
                  maxLines: 3,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    hintText: 'Tulis komentar...',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isPosting ? null : _postComment,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _isPosting ? Colors.grey.shade400 : Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _isPosting
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginNudge(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (ctx) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Masuk untuk berkomentar →',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(60),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginView()),
                          );
                        },
                        child: const Text('Masuk',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blue),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(60),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterView()),
                          );
                        },
                        child: const Text('Daftar',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      child: Text(
        'Masuk untuk berkomentar →',
        style: TextStyle(
          fontSize: 14,
          color: Colors.blue.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthRepository>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Text(
            'Komentar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(113, 33, 149, 243),
                backgroundColor: Color.fromARGB(41, 33, 149, 243),
              ),
            ),
          )
        else if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(_error!,
                style: TextStyle(color: Colors.red.shade600, fontSize: 13)),
          )
        else if (_comments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Belum ada komentar. Jadilah yang pertama!',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: _comments.map((comment) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildComment(comment),
                    ...comment.replies.map(
                      (reply) => _buildComment(
                        reply,
                        isReply: true,
                        parentId: comment.id,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: auth.isAuthenticated
              ? _buildInput(context)
              : _buildLoginNudge(context),
        ),
      ],
    );
  }
}

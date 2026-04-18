import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kamus_banjar_mobile_app/core/models/word.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/auth_repository.dart';
import 'package:kamus_banjar_mobile_app/core/services/community_service.dart';
import 'package:kamus_banjar_mobile_app/shared/widgets/login_nudge.dart';
import 'package:provider/provider.dart';

class VoteRow extends StatefulWidget {
  final Word word;

  const VoteRow({super.key, required this.word});

  @override
  State<VoteRow> createState() => _VoteRowState();
}

class _VoteRowState extends State<VoteRow> {
  late int _upCount;
  late int _downCount;
  int? _userVote;
  bool _isVoting = false;

  @override
  void initState() {
    super.initState();
    _upCount = widget.word.votes?.up ?? 0;
    _downCount = widget.word.votes?.down ?? 0;
  }

  Future<void> _vote(int direction) async {
    if (_isVoting) return;

    final auth = context.read<AuthRepository>();
    if (!auth.isAuthenticated) {
      showLoginNudge(context);
      return;
    }

    final service = context.read<CommunityService>();
    final prevUp = _upCount;
    final prevDown = _downCount;
    final prevUserVote = _userVote;

    setState(() {
      _isVoting = true;
      if (_userVote == direction) {
        if (direction == 1) { _upCount--; } else { _downCount--; }
        _userVote = null;
      } else {
        if (_userVote == 1) { _upCount--; }
        if (_userVote == -1) { _downCount--; }
        if (direction == 1) { _upCount++; } else { _downCount++; }
        _userVote = direction;
      }
    });

    try {
      await service.vote(
        auth.accessToken!,
        widget.word.word.toLowerCase(),
        direction,
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _upCount = prevUp;
          _downCount = prevDown;
          _userVote = prevUserVote;
        });
      }
      Fluttertoast.showToast(
        msg: 'Terjadi kesalahan. Coba lagi.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      if (mounted) setState(() => _isVoting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Row(
        children: [
          if (widget.word.source == 'community')
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFFFB8C00) : Colors.orange,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Komunitas',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (widget.word.votes != null) ...[
            GestureDetector(
              onTap: () => _vote(1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_upward,
                    size: 14,
                    color: _userVote == 1
                        ? Colors.green.shade600
                        : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '$_upCount',
                    style: TextStyle(
                      fontSize: 13,
                      color: _userVote == 1
                          ? Colors.green.shade600
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _vote(-1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_downward,
                    size: 14,
                    color: _userVote == -1
                        ? Colors.red.shade600
                        : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '$_downCount',
                    style: TextStyle(
                      fontSize: 13,
                      color: _userVote == -1
                          ? Colors.red.shade600
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

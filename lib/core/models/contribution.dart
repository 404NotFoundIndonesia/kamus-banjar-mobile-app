import 'package:kamus_banjar_mobile_app/core/models/word.dart';

class ContributionPage {
  final List<Contribution> contributions;
  final int page;
  final int totalPages;
  final int total;

  const ContributionPage({
    required this.contributions,
    required this.page,
    required this.totalPages,
    required this.total,
  });
}

class Contribution {
  final String id;
  final String wordId;
  final Word word;
  final String contributorId;
  final String? reviewerId;
  final String action;
  final String? notes;
  final DateTime createdAt;

  const Contribution({
    required this.id,
    required this.wordId,
    required this.word,
    required this.contributorId,
    this.reviewerId,
    required this.action,
    this.notes,
    required this.createdAt,
  });

  factory Contribution.fromJson(Map<String, dynamic> json) => Contribution(
        id: json['id'] as String,
        wordId: json['word_id'] as String,
        word: Word.fromJson(json['word'] as Map<String, dynamic>),
        contributorId: json['contributor_id'] as String,
        reviewerId: json['reviewer_id'] as String?,
        action: json['action'] as String,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

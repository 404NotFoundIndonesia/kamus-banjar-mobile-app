class TopContributor {
  final String userId;
  final String name;
  final int approvedCount;

  const TopContributor({
    required this.userId,
    required this.name,
    required this.approvedCount,
  });

  factory TopContributor.fromJson(Map<String, dynamic> json) => TopContributor(
        userId: json['user_id'] as String,
        name: json['name'] as String,
        approvedCount: json['approved_count'] as int,
      );
}

class AdminStats {
  final int wordsOfficial;
  final int wordsCommunity;
  final int wordsPending;
  final int wordsRejected;
  final int usersTotal;
  final int usersActive;
  final int usersInactive;
  final int contributionsPending;
  final int contributionsThisWeek;
  final int contributionsThisMonth;
  final List<TopContributor> topContributors;

  const AdminStats({
    required this.wordsOfficial,
    required this.wordsCommunity,
    required this.wordsPending,
    required this.wordsRejected,
    required this.usersTotal,
    required this.usersActive,
    required this.usersInactive,
    required this.contributionsPending,
    required this.contributionsThisWeek,
    required this.contributionsThisMonth,
    required this.topContributors,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    final words = json['words'] as Map<String, dynamic>? ?? {};
    final users = json['users'] as Map<String, dynamic>? ?? {};
    final contributions = json['contributions'] as Map<String, dynamic>? ?? {};
    final topList = json['top_contributors'] as List? ?? [];

    return AdminStats(
      wordsOfficial: words['official'] as int? ?? 0,
      wordsCommunity: words['community'] as int? ?? 0,
      wordsPending: words['pending'] as int? ?? 0,
      wordsRejected: words['rejected'] as int? ?? 0,
      usersTotal: users['total'] as int? ?? 0,
      usersActive: users['active'] as int? ?? 0,
      usersInactive: users['inactive'] as int? ?? 0,
      contributionsPending: contributions['pending'] as int? ?? 0,
      contributionsThisWeek: contributions['this_week'] as int? ?? 0,
      contributionsThisMonth: contributions['this_month'] as int? ?? 0,
      topContributors: topList
          .map((e) => TopContributor.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

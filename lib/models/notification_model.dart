class NotificationItem {
  final int id;
  final String titleEn;
  final String titleAr;
  final String bodyEn;
  final String bodyAr;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final DateTime? sentAt;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.bodyEn,
    required this.bodyAr,
    this.imageUrl,
    this.data,
    this.sentAt,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as int,
      titleEn: json['title_en'] as String? ?? '',
      titleAr: json['title_ar'] as String? ?? '',
      bodyEn: json['body_en'] as String? ?? '',
      bodyAr: json['body_ar'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data']) : null,
      sentAt: json['sent_at'] != null ? DateTime.tryParse(json['sent_at']) : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  String title(String lang) => lang == 'ar' ? titleAr : titleEn;
  String body(String lang) => lang == 'ar' ? bodyAr : bodyEn;

  /// Route to navigate to when tapped (from data payload).
  String? get route => data?['route'] as String?;

  /// Time ago string.
  String timeAgo(bool isAr) {
    final now = DateTime.now();
    final diff = now.difference(sentAt ?? createdAt);
    if (diff.inMinutes < 1) return isAr ? 'الآن' : 'Just now';
    if (diff.inMinutes < 60) return isAr ? '${diff.inMinutes} د' : '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return isAr ? '${diff.inHours} س' : '${diff.inHours}h ago';
    if (diff.inDays < 7) return isAr ? '${diff.inDays} ي' : '${diff.inDays}d ago';
    return isAr ? '${diff.inDays ~/ 7} أ' : '${diff.inDays ~/ 7}w ago';
  }
}

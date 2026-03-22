class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    this.isPublished = false,
    this.startsAt,
    this.endsAt,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String content;
  final bool isPublished;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime createdAt;

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String? ?? '',
        isPublished: json['is_published'] as bool? ?? false,
        startsAt: json['starts_at'] != null
            ? DateTime.parse(json['starts_at'] as String).toLocal()
            : null,
        endsAt: json['ends_at'] != null
            ? DateTime.parse(json['ends_at'] as String).toLocal()
            : null,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      );

  bool get isActive {
    if (!isPublished) return false;
    final now = DateTime.now();
    if (startsAt != null && now.isBefore(startsAt!)) return false;
    if (endsAt != null && now.isAfter(endsAt!)) return false;
    return true;
  }
}

class SitePage {
  const SitePage({
    required this.key,
    required this.title,
    required this.content,
    this.isPublished = true,
  });
  final String key;
  final String title;
  final String content;
  final bool isPublished;

  factory SitePage.fromJson(Map<String, dynamic> json) => SitePage(
        key: json['key'] as String,
        title: json['title'] as String,
        content: json['content'] as String? ?? '',
        isPublished: json['is_published'] as bool? ?? true,
      );
}

class Article {
  final int? id;
  final String title;
  final String description;
  final String content;
  final String category;
  final String imageUrl;
  final String publishedAt;
  final String personalNote; // <-- Add this line

  Article({
    this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.category,
    required this.imageUrl,
    required this.publishedAt,
    this.personalNote = '', // <-- Add this line (default empty)
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'General',
      imageUrl: json['image_url'] ?? '',
      publishedAt: json['published_at'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'category': category,
      'image_url': imageUrl,
      'published_at': publishedAt,
      'personal_note': personalNote, // <-- Add this line
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? 'General',
      imageUrl: map['image_url'] ?? '',
      publishedAt: map['published_at'] ?? '',
      personalNote: map['personal_note'] ?? '', // <-- Add this line
    );
  }
}
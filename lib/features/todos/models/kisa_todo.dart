class KisaTodo {
  final String id;
  final String createdBy;
  final String text;
  final bool isCompleted;
  final String category;
  final String priority;
  final DateTime createdAt;

  const KisaTodo({
    required this.id,
    required this.createdBy,
    required this.text,
    this.isCompleted = false,
    this.category = '🍿 Movie',
    this.priority = 'Med',
    required this.createdAt,
  });

  KisaTodo copyWith({
    String? id,
    String? createdBy,
    String? text,
    bool? isCompleted,
    String? category,
    String? priority,
    DateTime? createdAt,
  }) {
    return KisaTodo(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory KisaTodo.fromJson(Map<String, dynamic> json) {
    return KisaTodo(
      id: json['id'] as String,
      createdBy: (json['created_by'] as String?) ?? '',
      text: (json['text'] as String?) ?? '',
      isCompleted: (json['is_completed'] as bool?) ?? false,
      category: (json['category'] as String?) ?? '🍿 Movie',
      priority: (json['priority'] as String?) ?? 'Med',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_by': createdBy,
      'text': text,
      'is_completed': isCompleted,
      'category': category,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

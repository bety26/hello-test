// Not kağıdında kullanılabilecek renkler (hex)
const List<String> kNoteColors = [
  '#FFD68A', // amber
  '#A8E6CF', // nane
  '#FFABAB', // mercan
  '#F8B4D9', // pembe
  '#B5D4F4', // gök mavisi
  '#C9B8FF', // lavanta
  '#FFF2A8', // limon
  '#DADAE6', // gri
];

const double kMinNoteFontSize = 12;
const double kMaxNoteFontSize = 28;
const double kDefaultNoteFontSize = 16;

// Bir not kağıdı
class Note {
  final String id;
  final String workspaceId;
  final String title;
  final String content;
  final String colorHex;
  final double fontSize;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.workspaceId,
    required this.title,
    required this.content,
    required this.colorHex,
    required this.fontSize,
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isEmpty => title.trim().isEmpty && content.trim().isEmpty;

  Note copyWith({
    String? workspaceId,
    String? title,
    String? content,
    String? colorHex,
    double? fontSize,
    bool? isPinned,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      workspaceId: workspaceId ?? this.workspaceId,
      title: title ?? this.title,
      content: content ?? this.content,
      colorHex: colorHex ?? this.colorHex,
      fontSize: fontSize ?? this.fontSize,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    final created =
        DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now();
    return Note(
      id: json['id']?.toString() ?? '',
      workspaceId: json['workspaceId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      colorHex: json['colorHex']?.toString() ?? kNoteColors.first,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? kDefaultNoteFontSize,
      isPinned: json['isPinned'] as bool? ?? false,
      createdAt: created,
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? created,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'workspaceId': workspaceId,
    'title': title,
    'content': content,
    'colorHex': colorHex,
    'fontSize': fontSize,
    'isPinned': isPinned,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

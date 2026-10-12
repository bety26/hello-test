// Bir çalışma alanı (notların gruplandığı klasör benzeri yapı)
class Workspace {
  final String id;
  final String name;
  final int order;

  const Workspace({
    required this.id,
    required this.name,
    required this.order,
  });

  Workspace copyWith({String? name, int? order}) {
    return Workspace(
      id: id,
      name: name ?? this.name,
      order: order ?? this.order,
    );
  }

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Yeni Alan',
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'order': order,
  };
}

class Bandnames{
  final int count;
  final String name;
  Bandnames({required this.name, required this.count});

  Bandnames.fromJson(Map<String, Object?> json) : this(name: json['name']! as String, count: json['count']! as int);
  Map<String, Object?> toJson() {
    return {
      'name': name,
      'count': count,
    };
  }
}
class Iller {
  final String id;
  final String name;

  Iller({
    required this.id,
    required this.name,
  });

  factory Iller.fromDocument(Map<String, dynamic> json) {
    return Iller(
      id: json["id"],
      name: json["name"],
    );
  }
}

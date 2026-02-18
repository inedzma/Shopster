class Unit{
  final String id;
  final String name;

  Unit({required this.id, required this.name});

  Map<String, dynamic> toMap() {
    return{
      'id': id,
      'name': name,
    };
  }

  factory Unit.fromMap(Map<String, dynamic> map, String docId) {
    return Unit(
      id: docId,
      name: map['name'],
    );
  }
}
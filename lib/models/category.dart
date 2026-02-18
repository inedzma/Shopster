class Category{
  final String id;
  final String name;

  Category({required this.name, required this.id});

  Map<String, dynamic> toMap() {
    return{
      'id': id,
      'name': name,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map, String docId) {
    return Category(
      id: docId,
      name: map['name'],
    );
  }
}
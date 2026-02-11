class Household {
  final int id;
  final String name;
  final String inviteCode; // npr. "DOM-123"

  Household({required this.id, required this.name, required this.inviteCode});


  Map<String, dynamic> toMap() {
    return{
      'id': id,
      'name': name,
      'invite_code': inviteCode
    };
  }

  factory Household.fromMap(Map<String, dynamic> map){
    return Household(
      id: map['id'],
      name: map['name'],
      inviteCode: map['invite_code']
    );
  }
}
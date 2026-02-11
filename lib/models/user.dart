import 'package:mobile_apps/models/household.dart';

class User {
  final int id;
  final String name;
  final String email;
  final Household household;
  final String passwordHash;

  User({required this.id, required this.name, required this.email, required this.household, required this.passwordHash});

  Map<String, dynamic> toMap(){
    return{
      'id': id,
      'name': name,
      'email': email,
      'household_id': household.id,
      'password_hash': passwordHash,
    };
  }

  factory User.fromMap(Map<String, dynamic> map, Household household){
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      household: household,
      passwordHash: map['password_hash']
    );
  }
}
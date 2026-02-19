import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      // 1. Dobijemo householdId korisnika
      stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) return const Center(child: CircularProgressIndicator());
        String householdId = userSnapshot.data!['household_id'] ?? "";

        if (householdId.isEmpty) return const Center(child: Text("Niste povezani sa domaćinstvom."));

        return Scaffold(
          appBar: AppBar(
            title: const Text("Stanje u kući (Inventory)"),
            centerTitle: true,
          ),
          body: StreamBuilder<QuerySnapshot>(
            // 2. Slušamo promjene u inventory kolekciji za to domaćinstvo
            stream: FirebaseFirestore.instance
                .collection('inventory')
                .where('household_id', isEqualTo: householdId)
                .snapshots(),
            builder: (context, invSnapshot) {
              if (invSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!invSnapshot.hasData || invSnapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.kitchen_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("Vaš inventar je prazan.", style: TextStyle(fontSize: 18, color: Colors.grey)),
                      Text("Kupite nešto sa shopping liste!"),
                    ],
                  ),
                );
              }

              var docs = invSnapshot.data!.docs;

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var data = docs[index].data() as Map<String, dynamic>;

                  // Budući da u Inventory kolekciji čuvamo ID proizvoda,
                  // ovdje ćemo prikazati podatke koje smo denormalizovali (ako si ih dodala u servisu)
                  // ili povući osnovne informacije.

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(Icons.inventory_2_outlined, color: Colors.blue),
                      ),
                      title: FutureBuilder<DocumentSnapshot>(
                        // Dohvaćamo ime proizvoda iz products kolekcije jer imamo product_id
                        future: FirebaseFirestore.instance.collection('products').doc(data['product_id']).get(),
                        builder: (context, prodSnap) {
                          if (prodSnap.hasData) {
                            return Text(
                              prodSnap.data!['name'] ?? "Nepoznato",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            );
                          }
                          return const Text("Učitavam...");
                        },
                      ),
                      subtitle: Text("Zadnji put ažurirano: ${_formatDate(data['last_updated'])}"),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          "${data['current_quantity']}", // Ovdje možeš dodati i unit_name ako si ga spasila
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  // Pomoćna funkcija za formatiranje datuma
  String _formatDate(String isoDate) {
    try {
      DateTime dt = DateTime.parse(isoDate);
      return "${dt.day}.${dt.month}.${dt.year}.";
    } catch (e) {
      return "N/A";
    }
  }
}
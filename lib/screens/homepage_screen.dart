import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/household_service.dart';

class HomepageScreen extends StatelessWidget {
  const HomepageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Ovdje NE stavljaš Scaffold, jer će on biti u MainLayout-u!
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Dodajemo malu provjeru da se aplikacija ne sruši ako nema podataka
        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return const Center(child: Text("Podaci korisnika nisu pronađeni."));
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        String householdId = userData['household_id'] ?? "";
        String userName = userData['name'] ?? "Korisnik";

        // Koristimo Material kao podlogu da ne bi bilo onih žutih linija
        return Material(
          color: Colors.transparent, // Da zadrži boju pozadine iz Layouta
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Dobrodošli, $userName!',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 30),

                if (householdId.isEmpty) ...[
                  ElevatedButton(
                    onPressed: () => _showCreateHouseholdDialog(context),
                    child: const Text('Kreiraj novo domaćinstvo'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _showJoinHouseholdDialog(context),
                    child: const Text('Pridruži se domaćinstvu (KOD)'),
                  ),
                ] else ...[
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),
                  const SizedBox(height: 10),
                  const Text("Već ste član domaćinstva.",
                      style: TextStyle(fontSize: 18, color: Colors.black)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showJoinHouseholdDialog(BuildContext context) {
    final controller = TextEditingController();
    final householdService = HouseholdService();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pridruži se domaćinstvu'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Unesite 6-cifreni kod',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Odustani')),
          ElevatedButton(
            onPressed: () async {
              final code = controller.text.trim();
              if (code.length == 6) {
                // 1. Tražimo domaćinstvo u bazi preko tvog servisa
                final household = await householdService.findByInvitecode(code);

                if (household != null) {
                  final currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    // 2. Povezujemo korisnika sa tim domaćinstvom
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .update({'household_id': household.id});

                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Uspješno ste se pridružili!")),
                      );
                    }
                  }
                } else {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Pogrešan kod!")),
                    );
                  }
                }
              }
            },
            child: const Text('Pridruži se'),
          ),
        ],
      ),
    );
  }

  void _showCreateHouseholdDialog(BuildContext context) {
    final controller = TextEditingController();
    final householdService = HouseholdService();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo domaćinstvo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Unesite naziv (npr. Naš dom)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Odustani')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                String inviteCode = Random().nextInt(999999).toString().padLeft(6, '0');

                // 1. Kreiraj domaćinstvo
                await householdService.createHousehold(controller.text, inviteCode);

                // 2. Pronađi to novo domaćinstvo da dobiješ njegov ID (ili izmijeni servis da vraća ID)
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser != null) {
                  // Moramo povezati usera sa ovim domom
                  var householdQuery = await FirebaseFirestore.instance
                      .collection('households')
                      .where('invite_code', isEqualTo: inviteCode)
                      .get();

                  if (householdQuery.docs.isNotEmpty) {
                    String newHouseholdId = householdQuery.docs.first.id;

                    // 3. Updateuj usera u Firestore
                    await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
                      'household_id': newHouseholdId,
                    });
                  }
                }

                if (context.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Kreiraj'),
          ),
        ],
      ),
    );
  }
}
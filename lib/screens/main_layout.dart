import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_apps/screens/homepage_screen.dart';
import 'package:mobile_apps/screens/shopping_list_screen.dart';

class MainLayout extends StatelessWidget {
  final Widget body; // Ovdje primamo stranicu koju želimo prikazati
  final int activeIndex;

  const MainLayout({super.key, required this.body, this.activeIndex=0});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      // Slušamo korisnika da saznamo household_id
      stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
      builder: (context, userSnapshot) {
        String householdId = "";
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          householdId = userSnapshot.data!.get('household_id') ?? "";
        }

        return StreamBuilder<DocumentSnapshot>(
          // Slušamo domaćinstvo za AppBar titulu
          stream: householdId.isNotEmpty
              ? FirebaseFirestore.instance.collection('households').doc(householdId).snapshots()
              : null,
          builder: (context, householdSnapshot) {
            String title = "Shopster";
            if (householdSnapshot.hasData && householdSnapshot.data!.exists) {
              title = householdSnapshot.data!.get('name') ?? "Shopster";
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(title),
                centerTitle: true,
              ),
              drawer: Drawer(
                child: ListView(
                  children: [
                    const DrawerHeader(child: Text("Meni")),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text("Odjavi se"),
                      onTap: () => FirebaseAuth.instance.signOut(),
                    ),
                  ],
                ),
              ),
              // Ovdje ubacujemo proslijeđeni body (tvoj screen)
              body: body,
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: activeIndex,
                onTap: (index) {
                  if(index==activeIndex) return;
                  if(index==0){
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MainLayout(
                                body: HomepageScreen(),
                              activeIndex: 0,
                            )),);

                  }
                  else if(index==1){
                    Navigator.pushReplacement(
                        context,
                    MaterialPageRoute(builder: (context) => const MainLayout(
                        body: ShoppingListScreen(),
                        activeIndex: 1,
                    )));
                  }
                },
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Početna'),
                  BottomNavigationBarItem(icon: Icon(Icons.shopping_basket), label: 'Lista'),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
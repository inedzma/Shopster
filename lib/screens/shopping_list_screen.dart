import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_apps/services/products_service.dart';
import '../models/product.dart';
import '../services/shopping_service.dart';
import '../services/unit_category_service.dart';


class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {

  final _qtyController = TextEditingController(text: "1");
  final _unitController = TextEditingController();
  final _categoryController = TextEditingController();

  // Za Autocomplete nam trebaju stringovi
  String selectedUnit = "";
  String selectedCategory = "";
  String selectedProduct = "";

  final _shoppingService = ShoppingService();
  final _masterService = MasterDataService();
  final _productService = ProductsService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) return const Center(child: CircularProgressIndicator());
        String householdId = userSnapshot.data!['household_id'] ?? "";

        if (householdId.isEmpty) return const Center(child: Text("Prvo kreirajte domaćinstvo!"));

        return Column(
          children: [
            // GORNJI DIO: FORMA (Ovo je sada fiksno i neće se "zaključati")
            _buildAddForm(householdId),

            const Divider(),

            // DONJI DIO: LISTA (Samo se ovaj dio osvježava kad dodaš nešto)
            Expanded(
              child: _buildItemList(householdId),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddForm(String householdId) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: StreamBuilder(
                    stream: _productService.getProducts(),
                    builder: (context, snapshot) {
                      List<Product> products = snapshot.data ?? [];
                      return Autocomplete<Product>(
                        displayStringForOption: (Product p) => p.name,
                        optionsBuilder: (TextEditingValue textEditingalue) {
                          if(textEditingalue.text== '') return const Iterable<Product>.empty();
                          return products.where((Product p) => p.name.toLowerCase().contains(textEditingalue.text.toLowerCase()));
                        },
                        onSelected: (Product p) {
                          setState(() {
                            selectedProduct = p.name;
                            selectedUnit = p.unit.name;
                            selectedCategory = p.category.name;

                            _unitController.text = p.unit.name;
                            _categoryController.text = p.category.name;
                          });
                        },
                        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(labelText: "Artikal"),
                            onChanged: (val) => selectedProduct = val,
                          );
                        },
                      );
                    },
                 ),
              ),
              const SizedBox(width: 10),
              SizedBox(width: 60, child: TextField(controller: _qtyController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Kol."))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // PAMETNA JEDINICA (Autocomplete)
              Expanded(
                child: _buildAutocompleteField(
                  label: "Jedinica (kg, kom...)",
                  stream: _masterService.getUnits().map((list) => list.map((u) => u.name).toList()),
                  onSelected: (val) => selectedUnit = val,
                ),
              ),
              const SizedBox(width: 10),
              // PAMETNA KATEGORIJA (Autocomplete)
              Expanded(
                child: _buildAutocompleteField(
                  label: "Kategorija",
                  stream: _masterService.getCategories().map((list) => list.map((c) => c.name).toList()),
                  onSelected: (val) => selectedCategory = val,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.blue, size: 40),
                onPressed: () async {
                  if (selectedProduct.isNotEmpty) {
                    await _shoppingService.quickAddToList(
                      householdId: householdId,
                      productName: selectedProduct,
                      quantity: double.tryParse(_qtyController.text) ?? 1.0,
                      unit: selectedUnit,
                      category: selectedCategory,
                    );
                    setState(() {
                      selectedProduct = "";
                    });
                    _qtyController.text = "1";
                    FocusScope.of(context).unfocus();
                    // Resetuj autocomplete polja (opcionalno)
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Unesite naziv artikla"),)
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // POMOĆNI WIDGET ZA AUTOCOMPLETE
  Widget _buildAutocompleteField({required String label, required Stream<List<String>> stream, required Function(String) onSelected}) {
    return StreamBuilder<List<String>>(
      stream: stream,
      builder: (context, snapshot) {
        List<String> options = snapshot.data ?? [];
        return Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') return options;
            return options.where((String option) => option.contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: onSelected,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onSelected, // Da bi radilo i ako korisnik samo kuca a ne klikne na ponuđeno
              decoration: InputDecoration(labelText: label),
            );
          },
        );
      },
    );
  }

  Widget _buildItemList(String householdId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('households')
          .doc(householdId)
          .collection('shopping_lists') // Provjeri da li je ovaj naziv isti u servisu!
          .doc('main_list')
          .collection('items')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var docs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['product_name'] ?? ""),
              subtitle: Text("${data['quantity']} ${data['unit_name']} - ${data['category_name']}"),
              trailing: Checkbox(
                value: data['is_bought'] ?? false,
                onChanged: (val) => docs[index].reference.update({'is_bought': val}),
              ),
            );
          },
        );
      },
    );
  }
}
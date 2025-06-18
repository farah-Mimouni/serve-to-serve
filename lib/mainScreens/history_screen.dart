import 'dart:convert';
import 'package:client/authentication/auth_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added FirebaseAuth import
import 'package:flutter/material.dart';
import 'package:client/assistant_methods/assistant_methods.dart';
import 'package:client/global/global.dart';
import 'package:client/models/items.dart';
import 'package:client/mainScreens/order_details_screen.dart';
import 'package:client/widgets/order_card.dart';
import 'package:client/widgets/progress_bar.dart';
import 'package:client/widgets/simple_Appbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Récupérer les données du profil utilisateur depuis Firestore ou sharedPreferences
  Future<Map<String, dynamic>> fetchUserProfile() async {
    final userId = sharedPreferences?.getString("uid");
    if (userId == null) return {};

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get();
      return userDoc.exists ? userDoc.data()! : {};
    } catch (e) {
      print('Erreur lors de la récupération du profil utilisateur: $e');
      return {};
    }
  }

  // Récupérer les articles pour une commande
  Future<List<Map<String, dynamic>>> fetchItemsForOrder(
      List<String> productIds) async {
    List<Map<String, dynamic>> items = [];
    final itemIds = separateOrderItemIds(productIds);
    final quantities = separateOrderItemQuantities(productIds);

    if (itemIds.isEmpty) {
      print('Aucun ID d\'article trouvé dans productIds: $productIds');
      return items;
    }

    print('Traitement des itemIds: $itemIds');
    print('Traitement des quantités: $quantities');

    try {
      const batchSize = 10;
      for (var i = 0; i < itemIds.length; i += batchSize) {
        final batchIds = itemIds.sublist(
            i, i + batchSize > itemIds.length ? itemIds.length : i + batchSize);

        // Filtrer les ID d'articles invalides (comme "garbageValue")
        final validBatchIds = batchIds
            .where((id) =>
                    id.isNotEmpty &&
                    !id.toLowerCase().contains('garbage') &&
                    id.length >
                        5 // Validation de base pour une longueur d'ID raisonnable
                )
            .toList();

        if (validBatchIds.isEmpty) {
          print('Aucun ID d\'article valide dans le lot: $batchIds');
          continue;
        }

        print('Requête Firestore pour les ID valides: $validBatchIds');

        final snapshot = await FirebaseFirestore.instance
            .collection("items")
            .where("itemId", whereIn: validBatchIds)
            .get();

        print('Trouvé ${snapshot.docs.length} articles dans Firestore');

        for (var doc in snapshot.docs) {
          final itemData = doc.data();
          final itemIdFromDoc = itemData['itemId'] as String?;

          if (itemIdFromDoc == null) {
            print(
                'Attention: Le document d\'article ${doc.id} n\'a pas de champ itemId');
            continue;
          }

          // Trouver l'index en utilisant le champ itemId, pas l'ID du document
          final index = itemIds.indexOf(itemIdFromDoc);

          if (index != -1 && index < quantities.length) {
            try {
              final quantityStr = quantities[index];
              final quantity = int.parse(quantityStr);
              itemData['quantity'] = quantity;
              items.add(itemData);
              print(
                  'Article ajouté: ${itemIdFromDoc} avec quantité: $quantity');
            } catch (e) {
              print(
                  'Erreur lors de l\'analyse de la quantité pour l\'article ${itemIdFromDoc}: $e');
              // Ajouter l'article avec une quantité par défaut de 1
              itemData['quantity'] = 1;
              items.add(itemData);
            }
          } else {
            print(
                'Impossible de trouver la quantité correspondante pour l\'article: $itemIdFromDoc');
            // Ajouter l'article avec une quantité par défaut de 1
            itemData['quantity'] = 1;
            items.add(itemData);
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération des articles: $e');
    }

    print('Nombre final d\'articles: ${items.length}');
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final userId = sharedPreferences?.getString("uid");
    if (userId == null) {
      return Scaffold(
        appBar: SimpleAppBar(title: "Profil"),
        body: const Center(
          child: Text(
            "Erreur: Utilisateur non connecté",
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: SimpleAppBar(title: "Profil"),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // En-tête du profil
              FutureBuilder<Map<String, dynamic>>(
                future: fetchUserProfile(),
                builder: (context, snapshot) {
                  final profile = snapshot.data ?? {};
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade700, Colors.blue.shade300],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: profile['photoUrl'] != null
                              ? NetworkImage(profile['photoUrl'])
                              : null,
                          child: profile['photoUrl'] == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          profile['name'] ?? 'Utilisateur',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          profile['email'] ?? 'Aucun email',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            FirebaseAuth.instance.signOut().then((value) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AuthScreen()));
                            });
                          },
                          child: const Text("Se déconnecter"),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Section Historique des commandes
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Commandes récentes",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(userId)
                          .collection("orders")
                          .limit(5) // Limite pour éviter les problèmes d'index
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          print('Erreur Firestore: ${snapshot.error}');
                          return Column(
                            children: [
                              const Text(
                                "Erreur lors du chargement des commandes",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.red),
                              ),
                              ElevatedButton(
                                onPressed: () => setState(() {}),
                                child: const Text("Réessayer"),
                              ),
                            ],
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: circularProgress());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text(
                            "Aucune commande récente",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          );
                        }

                        return Column(
                          children: snapshot.data!.docs.map((orderDoc) {
                            final orderData =
                                orderDoc.data() as Map<String, dynamic>;
                            final productIds = List<String>.from(
                                orderData['productIds'] ?? []);
                            final orderId = orderDoc.id;

                            if (productIds.isEmpty) {
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                      'Aucun article dans la commande $orderId'),
                                ),
                              );
                            }

                            return FutureBuilder<List<Map<String, dynamic>>>(
                              future: fetchItemsForOrder(productIds),
                              builder: (context, itemSnapshot) {
                                if (itemSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(child: circularProgress());
                                }

                                if (itemSnapshot.hasError) {
                                  print(
                                      'Erreur de récupération d\'articles: ${itemSnapshot.error}');
                                  return Card(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Text(
                                              'Erreur lors du chargement des articles pour la commande $orderId'),
                                          Text('Erreur: ${itemSnapshot.error}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                if (!itemSnapshot.hasData ||
                                    itemSnapshot.data!.isEmpty) {
                                  return Card(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('N° de commande: $orderId'),
                                          Text(
                                              'ID des produits: ${productIds.join(", ")}'),
                                          const Text(
                                              'Aucun article valide trouvé pour cette commande',
                                              style: TextStyle(
                                                  color: Colors.orange)),
                                          Text(
                                              'Montant total: ${orderData['totolAmmount'] ?? 'N/A'}'),
                                          Text(
                                              'Statut: ${orderData['status'] ?? 'N/A'}'),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                final items = itemSnapshot.data!;
                                double calculatedTotal = 0;
                                List<String> quantities = [];
                                for (var item in items) {
                                  final quantity =
                                      item['quantity'] as int? ?? 1;
                                  final itemModel = Items.fromJson(item);
                                  final price = (itemModel.isOfferValid &&
                                          itemModel.discountedPrice != null)
                                      ? itemModel.discountedPrice!
                                      : itemModel.originalPrice ?? 0.0;
                                  calculatedTotal += quantity * price;
                                  quantities.add(quantity.toString());
                                }

                                return OrderCard(
                                  itemCount: items.length,
                                  data: items,
                                  orderId: orderId,
                                  totalAmount:
                                      calculatedTotal.toStringAsFixed(2),
                                  seperateQuantitiesList: quantities,
                                );
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Section Commentaires
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Commentaires",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              "Nous apprécions vos commentaires !",
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Partagez vos impressions",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                // TODO: Implémenter la soumission de commentaires
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Commentaire envoyé !")),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Envoyer le commentaire",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

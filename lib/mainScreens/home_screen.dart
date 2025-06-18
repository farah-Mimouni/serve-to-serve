import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:client/assistant_methods/assistant_methods.dart';
import 'package:client/models/items.dart';
import 'package:client/models/sellers.dart';
import 'package:client/widgets/sellers_design.dart';
import 'package:client/widgets/my_drower.dart';
import 'package:client/widgets/progress_bar.dart';
import 'package:client/authentication/auth_screen.dart';
import 'package:client/global/global.dart';
import 'package:client/mainScreens/address_screen.dart';
import 'package:client/mainScreens/history_screen.dart';
import 'package:client/mainScreens/my_orders_screen.dart';
import 'package:client/mainScreens/search_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'item_detail_screen.dart';
import 'mapScreen.dart';

// Color scheme for consistency
const primaryColor = Colors.green;
const secondaryColor = Colors.lightGreen;
const backgroundColor = Color(0xFFF5F5F5);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> carouselItems = [
    "assets/images/slider/8.jpg",
    "assets/images/slider/487fc5dd27a0e7a5e1a6f3837962da54.jpg",
    "assets/images/slider/pizza napolitaine.jpg",
    "assets/images/slider/12.jpg",
  ];

  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'toute';
  final List<String> categories = [
    'toute',
    'Pizzas',
    'Restaurants',
    'Boulangeries',
    'Superettes',
  ];
  int _selectedIndex = 0; // For bottom navigation

  @override
  void initState() {
    super.initState();
    clearCartNow(context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        // Already on HomeScreen
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MapScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyOrdersScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/welcome.png', // Path to your logo image
              height: 50, // Adjust height as needed
              fit: BoxFit.contain,
            ),
            const Text(
              "Save to Serve",
              style: TextStyle(
                fontFamily: "Signatra",
                fontSize: 20,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 8), // Add some spacing between text and logo
          ],
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapScreen()),
              );
            },
          ),
        ],
      ),
      //drawer: MyDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== 1. SEARCH BAR =====
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher ',
                      prefixIcon: const Icon(Icons.search, color: primaryColor),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {}); // Trigger rebuild for search filtering
                    },
                  ),
                ),
                // ===== 2. CAROUSEL =====
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: CarouselSlider.builder(
                    itemCount: carouselItems.length,
                    itemBuilder: (context, index, realIndex) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            carouselItems[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image,
                                  size: 50, color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    },
                    options: CarouselOptions(
                      height: 200,
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.85,
                      enableInfiniteScroll: true,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 3),
                      enlargeCenterPage: true,
                      enlargeStrategy: CenterPageEnlargeStrategy.scale,
                    ),
                  ),
                ),
                // ===== 3. CATEGORY FILTERS =====
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(
                              categories[index],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _selectedCategory == categories[index]
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            selected: _selectedCategory == categories[index],
                            selectedColor: primaryColor,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = categories[index];
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // ===== 4. SURPLUS FOOD SECTION =====
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.recycling,
                          color: primaryColor, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        "Offres récents",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SurplusFoodListScreen(
                                category: _selectedCategory,
                                searchQuery: _searchController.text,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "Voir tout",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
// Dynamic Surplus Food Items from Firestore
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('items')
                      .where('status', isEqualTo: 'available')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: 350,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 300,
                                margin: const EdgeInsets.only(left: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Error loading items. Please try again.",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "No surplus items available.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    var items = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final title =
                          data['title']?.toString().toLowerCase() ?? '';
                      final sellerName =
                          data['sellerName']?.toString().toLowerCase() ?? '';
                      final category =
                          data['category']?.toString().toLowerCase() ?? '';
                      final searchQuery = _searchController.text.toLowerCase();
                      final matchesSearch = title.contains(searchQuery) ||
                          sellerName.contains(searchQuery);
                      bool matchesCategory = true;

                      // Filter out expired offers
                      final offerEndTime = data['offerEndTime'] is Timestamp
                          ? (data['offerEndTime'] as Timestamp?)?.toDate()
                          : DateTime.tryParse(
                              data['offerEndTime']?.toString() ?? '');
                      final isOfferValid = offerEndTime == null ||
                          DateTime.now().isBefore(offerEndTime);

                      if (_selectedCategory != 'toute') {
                        final selectedCategoryLower =
                            _selectedCategory.toLowerCase();
                        if (_selectedCategory == 'Pizzas') {
                          matchesCategory = title.contains('pizza');
                        } else {
                          matchesCategory =
                              category.contains(selectedCategoryLower) ||
                                  sellerName.contains(selectedCategoryLower);
                        }
                      }

                      return matchesSearch && matchesCategory && isOfferValid;
                    }).toList();

                    return SizedBox(
                      height: 260,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final data =
                              items[index].data() as Map<String, dynamic>;
                          final item = Items.fromJson({
                            ...data,
                            'itemId': items[index].id,
                            'discountedPrice': data['discountedPrice'] ?? null,
                            'isOfferValid': data['offerEndTime'] == null ||
                                (data['offerEndTime'] is Timestamp &&
                                    DateTime.now().isBefore(
                                        (data['offerEndTime'] as Timestamp)
                                            .toDate())),
                            'discountPercentage':
                                data['discountedPrice'] != null &&
                                        data['originalPrice'] != null
                                    ? ((data['originalPrice'] -
                                                data['discountedPrice']) /
                                            data['originalPrice'] *
                                            100)
                                        .toInt()
                                    : null,
                          });
                          return _buildSurplusFoodItem(
                            model: item,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ItemDetailsScreen(model: item),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
                // ===== 5. ECO-FRIENDLY BANNER =====
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.eco, color: primaryColor, size: 30),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Moins de gaspillage, plus d’économies ! Découvrez nos offres anti-gaspi dès maintenant",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ===== 6. SELLERS SECTION HEADER =====
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: const Text(
                    "Nos collaborateurs",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ===== 7. REGULAR SELLERS LIST =====
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection("sellers").snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      "Error loading sellers.",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const SliverToBoxAdapter(
                  child: Center(
                      child: CircularProgressIndicator(color: primaryColor)),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverAlignedGrid.extent(
                  maxCrossAxisExtent: 600,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    try {
                      Sellers sModel = Sellers.fromJson(
                        snapshot.data!.docs[index].data()
                            as Map<String, dynamic>,
                      );
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: SellersDesignWidget(
                          model: sModel,
                          context: context,
                        ),
                      );
                    } catch (e) {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              );
            },
          ),
          const SliverToBoxAdapter(
              child: SizedBox(height: 80)), // Space for bottom nav
        ],
      ),
      // ===== BOTTOM NAVIGATION BAR =====
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey.shade600,
          backgroundColor: Colors.white,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Accueil', // Home
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Carte', // Map
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.reorder_outlined),
              activeIcon: Icon(Icons.reorder),
              label: 'Commandes', // Orders
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_2_rounded),
              activeIcon: Icon(Icons.person),
              label: 'Profil', // Profile
            ),
          ]),
    );
  }

  Widget _buildSurplusFoodItem({
    required Items model,
    required VoidCallback onTap,
  }) {
    // Determine what to show as primary text
    bool showSellerNameFirst =
        _selectedCategory == 'All' || _selectedCategory == 'Pizzas';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(left: 12, bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: model.itemImageBase64 != null &&
                      model.itemImageBase64!.isNotEmpty
                  ? Image.memory(
                      base64Decode(model.itemImageBase64!),
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 120,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image,
                            size: 50, color: Colors.grey),
                      ),
                    )
                  : Container(
                      height: 120,
                      color: Colors.grey.shade200,
                      child:
                          const Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    showSellerNameFirst ? model.title! : model.sellerName!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    showSellerNameFirst
                        ? 'by ${model.sellerName}'
                        : model.title!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  if (model.isOfferValid && model.discountPercentage != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${model.formattedDiscountPercentage}% OFF',
                        style: const TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Fin de l’offre dans  ${model.timeRemaining!.inHours}h ${model.timeRemaining!.inMinutes % 60}m',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.redAccent.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SurplusFoodListScreen extends StatelessWidget {
  final String category;
  final String searchQuery;

  const SurplusFoodListScreen({
    super.key,
    required this.category,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'save to serve article',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('items')
            .where('status', isEqualTo: 'available')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Error loading items.",
                style: TextStyle(color: Colors.redAccent),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: primaryColor));
          }

          var items = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final title = data['title']?.toString().toLowerCase() ?? '';
            final sellerName =
                data['sellerName']?.toString().toLowerCase() ?? '';
            final categoryFromData =
                data['category']?.toString().toLowerCase() ?? '';

            final matchesSearch = title.contains(searchQuery.toLowerCase()) ||
                sellerName.contains(searchQuery.toLowerCase());
            bool matchesCategory = true;

            if (category != 'toute') {
              final selectedCategoryLower = category.toLowerCase();

              if (category == 'Pizzas') {
                matchesCategory = title.contains('pizza');
              } else {
                matchesCategory =
                    categoryFromData.contains(selectedCategoryLower) ||
                        sellerName.contains(selectedCategoryLower);
              }
            }

            return matchesSearch && matchesCategory;
          }).toList();

          if (items.isEmpty) {
            return const Center(
              child: Text(
                "No items match your criteria.",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          bool showSellerNameFirst =
              category == 'toute' || category == 'Pizzas';

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final data = items[index].data() as Map<String, dynamic>;
              final item = Items.fromJson({
                ...data,
                'itemId': items[index].id,
                'discountedPrice': data['discountedPrice'] ?? null,
                'isOfferValid': data['discountedPrice'] != null &&
                    data['discountedPrice'] < data['originalPrice'],
                'discountPercentage': data['discountedPrice'] != null
                    ? ((data['originalPrice'] - data['discountedPrice']) /
                            data['originalPrice'] *
                            100)
                        .toInt()
                    : null,
              });
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: item.itemImageBase64 != null &&
                          item.itemImageBase64!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            base64Decode(item.itemImageBase64!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image,
                                    color: Colors.grey),
                          ),
                        )
                      : const Icon(Icons.image, color: Colors.grey),
                  title: Text(
                    showSellerNameFirst ? item.title! : item.sellerName!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    showSellerNameFirst ? 'by ${item.sellerName}' : item.title!,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  trailing: Text(
                    item.isOfferValid && item.discountedPrice != null
                        ? '\$${item.formattedDiscountedPrice}'
                        : '\$${item.formattedOriginalPrice}',
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDetailsScreen(model: item),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

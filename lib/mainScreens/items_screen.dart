import 'package:client/widgets/items_design.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:client/models/items.dart';
import 'package:client/models/menus.dart';
import 'package:client/widgets/progress_bar.dart';
import '../mainScreens/mapScreen.dart';

class ItemsScreen extends StatefulWidget {
  final Menus? model;
  const ItemsScreen({super.key, this.model});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _searchController.addListener(() {
      if (_isMounted) {
        setState(() {
          _searchQuery = _searchController.text.trim().toLowerCase();
        });
      }
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.model == null) {
      return Scaffold(
        body: SliverFillRemaining(
          child: Center(
            child: Text(
              "Error: Menu data is missing",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto',
                  ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green[700],
        title: const Text(
          "Save to Serve",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: "Roboto",
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[700]!, Colors.lightGreen[300]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MapScreen()),
          );
        },
        backgroundColor: Colors.amber[600],
        child: const Icon(Icons.map, color: Colors.white),
        tooltip: 'voir Sellers dans Map',
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_isMounted) {
            setState(() {});
          }
        },
        child: CustomScrollView(
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[600]),
                            onPressed: () {
                              if (_isMounted) {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              }
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            // Header
            SliverPersistentHeader(
              pinned: true,
              delegate: TextWidgetHeader(
                title: "${widget.model!.menuTitle ?? 'Menu'} produits",
              ),
            ),
            // Items Grid
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("sellers")
                  .doc(widget.model!.sellerUID)
                  .collection("menus")
                  .doc(widget.model!.menuId)
                  .collection("items")
                  .orderBy("publishedDate", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverFillRemaining(
                    child: Center(child: circularProgress()),
                  );
                }
                if (snapshot.hasError) {
                  debugPrint("Error loading items: ${snapshot.error}");
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Error loading items: ${snapshot.error}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.red[400],
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Roboto',
                            ),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  debugPrint(
                      "No items found for menuID: ${widget.model!.menuId}");
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'No items found.'
                            : 'No items match your search.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Roboto',
                            ),
                      ),
                    ),
                  );
                }

                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = data['title']?.toString().toLowerCase() ?? '';
                  debugPrint("Checking item: $title, query: $_searchQuery");
                  return _searchQuery.isEmpty || title.contains(_searchQuery);
                }).toList();

                debugPrint("Filtered items count: ${filteredDocs.length}");

                return SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverAlignedGrid.extent(
                    maxCrossAxisExtent: 600,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      try {
                        Items model = Items.fromJson(
                          filteredDocs[index].data() as Map<String, dynamic>,
                        );
                        debugPrint("Rendering item $index: ${model.title}");
                        return AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: ItemsDesignWidget(
                            model: model,
                            context: context,
                          ),
                        );
                      } catch (e) {
                        debugPrint("Error parsing item $index: $e");
                        return const SliverToBoxAdapter(
                            child: SizedBox.shrink());
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Sample TextWidgetHeader implementation to avoid UnimplementedError
class TextWidgetHeader extends SliverPersistentHeaderDelegate {
  final String title;

  TextWidgetHeader({required this.title});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
      ),
    );
  }

  @override
  double get maxExtent => 60.0;
  @override
  double get minExtent => 60.0;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

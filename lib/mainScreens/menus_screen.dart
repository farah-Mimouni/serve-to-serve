import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:client/assistant_methods/assistant_methods.dart';
import 'package:client/models/menus.dart';
import 'package:client/models/sellers.dart';
import 'package:client/widgets/menus_design.dart';
import 'package:client/widgets/my_drower.dart';
import 'package:client/widgets/progress_bar.dart';
import 'package:client/widgets/text_widget_header.dart';
import '../splashScreen/splash_screen.dart';

class MenusScreen extends StatefulWidget {
  final Sellers? model;
  const MenusScreen({super.key, this.model});

  @override
  State<MenusScreen> createState() => _MenusScreenState();
}

class _MenusScreenState extends State<MenusScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.model == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "Error: Seller data is missing",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green[700],
        leading: IconButton(
          onPressed: () {
            clearCartNow(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MySplashScreen(),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
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
        iconTheme: const IconThemeData(color: Colors.white),
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
      drawer: MyDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: TextWidgetHeader(
              title: "${widget.model!.sellerName ?? 'Unknown Seller'}'s Menus",
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("sellers")
                  .doc(widget.model!.sellerUID)
                  .collection("menus")
                  .orderBy("publishedDate", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  debugPrint("Error loading menus: ${snapshot.error}");
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        "Error loading menus",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.red[400],
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return SliverToBoxAdapter(
                    child: Center(child: circularProgress()),
                  );
                }
                if (snapshot.data!.docs.isEmpty) {
                  debugPrint(
                      "No menus available for seller: ${widget.model!.sellerUID}");
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        "No menus available",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  );
                }
                return SliverAlignedGrid.extent(
                  maxCrossAxisExtent: 600,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    try {
                      Menus model = Menus.fromJson(
                        snapshot.data!.docs[index].data()
                            as Map<String, dynamic>,
                      );
                      debugPrint("Menu $index: ${model.menuTitle}");
                      return AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: MenusDesignWidget(
                          model: model,
                          context: context,
                        ),
                      );
                    } catch (e) {
                      debugPrint("Error parsing menu $index: $e");
                      return const SizedBox.shrink();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

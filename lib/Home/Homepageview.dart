import 'package:flutter/material.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageState();
}

class _HomePageState extends State<HomePageView> {
  final borderRadius = BorderRadius.circular(20);
  int index = 2;
  final PageController _pageController = PageController(initialPage: 2);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 5,
          backgroundColor: Colors.green,
        ),
        body: PageView(
          onPageChanged: (value) {
            setState(() {
              index = value;
            });
          },
          controller: _pageController,
          children: const [
            // MyDashboard(),
            // DeliveryPage(),
            // Home(),
            // DiningHome(),
            // signUp(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          backgroundColor: Colors.green,
          elevation: 0,
          onTap: (value) {
            _pageController.animateToPage(value,
                duration: const Duration(milliseconds: 2000),
                curve: Curves.elasticOut);
          },
          currentIndex: index,
          items: const [
            BottomNavigationBarItem(
                backgroundColor: Colors.green,
                icon: Icon(Icons.dashboard),
                label: "Dashboard"),
            BottomNavigationBarItem(
                backgroundColor: Colors.green,
                icon: Icon(Icons.delivery_dining),
                label: "Delivery"),
            BottomNavigationBarItem(
                backgroundColor: Colors.green,
                icon: Icon(Icons.home),
                label: "Home"),
            BottomNavigationBarItem(
                backgroundColor: Colors.green,
                icon: Icon(Icons.dining),
                label: "Dining"),
            BottomNavigationBarItem(
                backgroundColor: Colors.green,
                icon: Icon(Icons.settings),
                label: "Settings"),
          ],
        ),
      ),
    );
  }
}

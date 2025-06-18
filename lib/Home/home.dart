import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(const Home());
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _DiningPagePageState();
}

class _DiningPagePageState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView();
  }
}

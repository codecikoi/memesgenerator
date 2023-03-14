import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:memesgenerator/presentation/main/main_page.dart';

void main() async {
  EquatableConfig.stringify = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}

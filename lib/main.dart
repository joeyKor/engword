


import 'package:flutter/material.dart';

import 'main_page.dart';



void main() {

  runApp(const MyApp());

}



// MyApp is the root widget of the application.

class MyApp extends StatelessWidget {

  const MyApp({super.key});



  @override

  Widget build(BuildContext context) {

    return MaterialApp(

      title: 'EngWord',

      // Apply a dark theme to the application.

      theme: ThemeData.dark(),

      home: const MainPage(),

    );

  }

}

import 'package:firebase_core/firebase_core.dart';
import 'package:new_project_directory/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:new_project_directory/LoginPage.dart';


//import 'package:ruidos_de_calma/MyHomePage.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});


  @override
  State createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp>{

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Firebase Tutorial",
      home: LoginPage(),
    );
  }
}





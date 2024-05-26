import 'package:flutter/material.dart';

class AboutApp extends StatefulWidget{
  const AboutApp({super.key});

  @override
  State<AboutApp> createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text(
          "About App",
        style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
        ), 
        ),
      content: SizedBox(width: double.infinity, height: MediaQuery.of(context).size.height / 4,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
            "SpeedScroll is a map application that provides shortest-time based route.",
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20.0),
              ),
            ],
          ),
        )
      ),
        actions: [
        TextButton(
          onPressed: (){
            Navigator.of(context).pop();
          }, 
          child: const Text(
            "Cancel",
            style: TextStyle(fontSize: 20),
          ))
    ],
  ); 
}
}

import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Padding(padding: EdgeInsets.all(10), child: Text("HomePage")),
        backgroundColor: Colors.blue,
      ),

      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 27, 7, 31), width: 3),
          color: Colors.blueGrey,
          borderRadius: BorderRadius.all(Radius.circular(3)),
        ),

        margin: EdgeInsets.all(70),
        height: 250,
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.network(
                "https://img.pikbest.com/origin/10/41/85/35HpIkbEsTU62.png!sw800",
              ),
              Text("scrollable logo of flutter",style: TextStyle(color: Colors.white,fontSize: 20),),
            ],
          ),
        ),
      ),
    );
  }
}

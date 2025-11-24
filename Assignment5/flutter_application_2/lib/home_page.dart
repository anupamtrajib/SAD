import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 144, 136, 136),
        foregroundColor: const Color.fromARGB(255, 213, 213, 246),
        title: const Text("Home Page"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text("Name"),
              accountEmail: const Text("email"),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage("assets/profile.png"),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.contact_mail_outlined),
              title: const Text("ContactUs"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text("Logout"),
              onTap: () {},
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Image.network(
                "https://mir-s3-cdn-cf.behance.net/projects/404/f5149f152346171.Y3JvcCw2MDAwLDQ2OTMsMCw1MzQ.jpg",
                width: 420,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              color: const Color.fromARGB(255, 220, 214, 214),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: const [
                      Icon(Icons.money, size: 40, color: Colors.amber),
                      SizedBox(height: 3),
                      Text(
                        "Deposit",
                        style: TextStyle(fontSize: 15, color: Color.fromARGB(255, 51, 44, 197)),
                      ),
                    ],
                  ),
                  Column(
                    children: const [
                      Icon(Icons.monetization_on_sharp, size: 40, color: Color.fromARGB(255, 153, 104, 121)),
                      SizedBox(height: 3),
                      Text(
                        "Withdraw",
                        style: TextStyle(fontSize: 15, color: Color.fromARGB(255, 51, 44, 197)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Hello, User!",
              style: TextStyle(fontSize: 40, color: Colors.deepPurple),
            ),
            
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                fixedSize: const Size(160, 60),
              ),
              child: const Text("Submit", style: TextStyle(color:Colors.white, fontSize: 20)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

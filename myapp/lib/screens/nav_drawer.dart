import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class nav_drawer extends StatelessWidget {
  const nav_drawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Awesome App"),
      ),

      // MAIN PAGE BODY
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [

          const ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
            subtitle: Text("Go to Home Page"),
            trailing: Icon(Icons.arrow_forward),
          ),

          const ListTile(
            leading: Icon(Icons.person),
            title: Text("Profile"),
            subtitle: Text("View Profile"),
            trailing: Icon(Icons.arrow_forward),
          ),

          const ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
            subtitle: Text("App Settings"),
            trailing: Icon(Icons.arrow_forward),
          ),
          
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/todo');
            },
            child: const Text("Open Todo"),
          ),

          const SizedBox(height: 20),
        ],
      ),

      // DRAWER
      drawer: Drawer(
        child: ListView(
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 4, 42, 147),
              ),
              child: Text(
                "Heyy Pretty",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),

            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
            ),

            ListTile(
              leading: Icon(Icons.person),
              title: Text("Profile"),
            ),

            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
            ),

            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
            ),
          ],
        ),
      ),

      // GOOGLE NAV BAR
      bottomNavigationBar: GNav(
        color: Colors.lime,
        tabs: const [
          GButton(icon: Icons.add),
          GButton(icon: Icons.access_alarm),
          GButton(icon: Icons.airplanemode_inactive_outlined),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.edit),
      ),
    );
  }
}
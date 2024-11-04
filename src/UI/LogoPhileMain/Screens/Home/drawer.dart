import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logophile/data/currentuserdata.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/ProfilePage/profilepage.dart';

class LogoPhileDrawer extends StatelessWidget {
  const LogoPhileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration:
                const BoxDecoration(color: Color.fromARGB(221, 38, 35, 35)),
            accountName: Text(currentuser.name,
                style: const TextStyle(color: Colors.white)),
            accountEmail: Text(
              currentuser.email,
              style: const TextStyle(color: Colors.white),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(currentuser.imageId),
            ),
            arrowColor: Theme.of(context).colorScheme.onPrimary,
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Setting"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text("Liked"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text("Following"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text("Profile"),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return ProfilePage(
                    person: currentuser,
                    iscurrentuser: true,
                  );
                },
              ));
            },
          ),
          ListTile(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
            leading: const Icon(Icons.logout_rounded),
            title: const Text("Logout"),
          )
        ],
      ),
    );
  }
}

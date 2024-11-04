import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logophile/data/currentuserdata.dart';
import 'package:logophile/src/Bloc/Theme/theme_bloc.dart';
import 'package:logophile/src/Bloc/Theme/theme_event.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/Add/add_content.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/Home/drawer.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/Home/home.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/Explore/explore.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/YourZone/yourzone.dart';

class LogoPhile extends StatefulWidget {
  const LogoPhile({super.key});
  @override
  State<LogoPhile> createState() => _LogoPhileState();
}

class _LogoPhileState extends State<LogoPhile> {
  int _selected = 0;
  void changePage(int i) {
    setState(() {
      _selected = i;
    });
  }

  List<Widget> pages = [
    Home(),
    const Explore(),
    const AddContent(),
    const YourZone()
  ];

  void getusermetadata() async {
    var dbref = FirebaseDatabase.instance.ref("user/${currentuser.id}");
    var data = await dbref.child("public").get().then(
      (value) {
        return value.value;
      },
    ) as Map;
    currentuser.imageId = data['image'];
    final liked = await dbref.child("private").child("liked").get().then(
      (value) {
        return value.value as Map?;
      },
    );

    currentuser.about = data['about'];
    currentuser.name = data['user_name'];
    currentuser.interest = data['interest'];
    currentuser.likes = await dbref.child("metadata/likes").get().then(
      (value) {
        if (value.value == null) {
          return 0;
        }
        return value.value as int;
      },
    );
    currentuser.followers = await dbref.child("metadata/followers").get().then(
      (value) {
        if (value.value == null) {
          return 0;
        }
        return value.value as int;
      },
    );

    currentuser.liked = liked == null ? [] : liked.values.toList();
    currentuser.posts = data['posts'] ?? [];
    currentuser.saved = await dbref.child("private").child("saved").get().then(
      (value) {
        if (value.value == null) {
          return [];
        }
        final m = value.value as Map;
        return m.values.toList();
      },
    );
    currentuser.following =
        await dbref.child("private").child("following").get().then(
      (value) {
        if (value.value == null) {
          return [];
        }
        final m = value.value as Map;
        return m.values.toList();
      },
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    getusermetadata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool islight =
        (Theme.of(context).colorScheme.brightness == Brightness.light);

    return Scaffold(
      drawer: const LogoPhileDrawer(),
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/icons/LogoPhile.png'),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text("LogoPhile"),
        shadowColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
        actions: [
          IconButton(
              onPressed: () {
                if (islight) {
                  context.read<ThemeBloc>().add(DarkThemeEvent());
                } else {
                  context.read<ThemeBloc>().add(LightThemeEvent());
                }
              },
              icon: Icon(islight
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined)),
          Builder(builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: CircleAvatar(
                foregroundImage: currentuser.imageId == ""
                    ? null
                    : NetworkImage(currentuser.imageId),
                child: currentuser.imageId != ""
                    ? null
                    : Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
              ),
            );
          }),
        ],
      ),
      body: pages[_selected],
      bottomNavigationBar: BottomNavigationBar(
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: () {
                  changePage(0);
                },
                icon: const Icon(Icons.home_filled)),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: () {
                  changePage(1);
                },
                icon: const Icon(Icons.explore)),
            label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: () {
                  changePage(2);
                },
                icon: const Icon(Icons.create)),
            label: "Create",
          ),
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: () {
                  changePage(3);
                },
                icon: const Icon(Icons.person_pin_circle_sharp)),
            label: "Your Zone",
          )
        ],
        currentIndex: _selected,
        selectedItemColor: Theme.of(context).colorScheme.onPrimary,
        unselectedItemColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}

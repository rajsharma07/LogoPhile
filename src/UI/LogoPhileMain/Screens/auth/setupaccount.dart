import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logophile/src/UI/LogoPhileMain/logophileui.dart';

class AccountSetup extends StatefulWidget {
  const AccountSetup({super.key, required this.uid, required this.name});
  final String uid;
  final String name;

  @override
  State<AccountSetup> createState() => _AccountSetupState();
}

class _AccountSetupState extends State<AccountSetup> {
  final ImagePicker picker = ImagePicker();
  final databaseref = FirebaseDatabase.instance.ref('user');
  File? _profileImage;
  final abouttextcontroller = TextEditingController();
  bool _isloading = false;
  final List<String> intrests = [];
  final List intrestsWidget = [
    [Icons.science, "Science"],
    [Icons.computer, "Technology"],
    [Icons.air_rounded, "Fiction"],
    [Icons.emoji_objects_outlined, "Science Fiction"],
    [Icons.school, "Education"],
    [Icons.info_outline_rounded, "Informative"],
    [Icons.emoji_emotions, "Entertainment"],
    [Icons.engineering, "Engineering"],
    [Icons.hourglass_empty_sharp, "Story"],
    [Icons.emoji_nature, "Romance"],
    [Icons.code, "Programming"],
    [Icons.people, "Politics"],
    [Icons.sports_basketball, "Sports"],
    [Icons.newspaper, "News"],
    [Icons.money, "Finance"],
    [Icons.fitness_center, "Fitness"],
    [Icons.monetization_on_sharp, "Economy"],
    [Icons.more_horiz, "others"]
  ];

  void pickImage() async {
    final selectedimge = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 50, maxHeight: 150);
    if (selectedimge != null) {
      setState(() {
        _profileImage = File(selectedimge.path);
      });
    }
    return;
  }

  void savetodb() async {
    setState(() {
      _isloading = true;
    });
    try {
      String imgurl = "null";
      if (_profileImage != null) {
        String extension = _profileImage!.path.split('.').last;
        final storageserver = FirebaseStorage.instance
            .ref('userImages')
            .child("${widget.uid}.$extension");
        await storageserver.putFile(_profileImage!);
        imgurl = await storageserver.getDownloadURL();
      }
      await databaseref.child(widget.uid).child("public").set({
        'user_name': widget.name,
        'image': imgurl,
        'about': abouttextcontroller.text,
        'interest': intrests,
        'posts': []
      });
      await databaseref
          .child(widget.uid)
          .child("private")
          .set({'liked': [], 'draft': [], 'postcounter': 0});

      await databaseref
          .child(widget.uid)
          .child("metadata")
          .set({'likes': 0, 'followers': 0});

      setState(() {
        _isloading = false;
      });
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) {
          return LogoPhile();
        },
      ));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Something Went wrong")));
      setState(() {
        _isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SetUp your Profile"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 10,
        shadowColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          TextButton.icon(
            style: ButtonStyle(
              backgroundColor:
                  WidgetStatePropertyAll(Theme.of(context).colorScheme.primary),
              shadowColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.onPrimary),
              elevation: const WidgetStatePropertyAll(10),
            ),
            iconAlignment: IconAlignment.end,
            onPressed: () {
              savetodb();
            },
            label: Text(
              "Enter LogoPhile",
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
            icon: _isloading
                ? CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary,
                  )
                : Icon(
                    Icons.arrow_right,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 18.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 70,
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              foregroundImage:
                  _profileImage == null ? null : FileImage(_profileImage!),
              child: _profileImage == null
                  ? IconButton(
                      onPressed: pickImage,
                      icon: const Icon(
                        Icons.add_a_photo,
                        size: 45,
                      ),
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "Describe yourself : ",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.left,
            ),
            TextField(
              controller: abouttextcontroller,
              maxLines: 5,
              minLines: 5,
              decoration: const InputDecoration(
                hintText: "About",
              ),
              cursorColor: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Select your interests:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Expanded(
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 4 / 1,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20),
                padding: const EdgeInsets.all(8),
                children: intrestsWidget.map(
                  (e) {
                    return InkWell(
                      onTap: () {
                        if (intrests.contains(e[1])) {
                          setState(() {
                            intrests.remove(e[1]);
                          });
                        } else {
                          setState(() {
                            intrests.add(e[1]);
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: (intrests.contains(e[1]))
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.primary,
                            border: Border.all(
                                color: Theme.of(context).colorScheme.onPrimary),
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(e[0]),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              e[1],
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const SizedBox(
              height: 15,
            )
          ],
        ),
      ),
    );
  }
}

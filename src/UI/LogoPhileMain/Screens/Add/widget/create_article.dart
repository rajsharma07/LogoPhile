import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logophile/Models/article.dart';
import 'package:logophile/data/currentuserdata.dart';
import 'package:logophile/src/Bloc/draft/draft_bloc.dart';
import 'package:logophile/src/Bloc/draft/draft_event.dart';
import 'package:logophile/src/Bloc/draft/draft_state.dart';
import 'package:logophile/src/Bloc/publish/publish_bloc.dart';
import 'package:logophile/src/Bloc/publish/publish_event.dart';
import 'package:logophile/src/Bloc/publish/publish_state.dart';

class CreateArticle extends StatefulWidget {
  const CreateArticle({super.key, this.a});
  final Article? a;
  @override
  State<CreateArticle> createState() => _CreateArticleState();
}

class _CreateArticleState extends State<CreateArticle> {
  final formkey = GlobalKey<FormState>();
  File? selectedImage;
  var title = "";
  var content = "";
  var description = "";
  List tags = [];
  void getImage() async {
    final imagepicked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);
    setState(() {
      selectedImage = imagepicked != null ? File(imagepicked.path) : null;
    });
  }

  void saveAsDraft(BuildContext ctx) async {
    if (formkey.currentState!.validate()) {
      formkey.currentState!.save();
      try {
        final userDbRef =
            FirebaseDatabase.instance.ref("user").child(currentuser.id);
        int id;
        String imgUrl = "";
        if (widget.a == null) {
          id = await userDbRef.child("private").child("postcounter").get().then(
            (value) {
              return value.value as int;
            },
          );
          id += 1;
          await userDbRef.child("private").child("postcounter").set(id);
        } else {
          imgUrl = widget.a!.imagePath;
          id = int.parse(widget.a!.uid);
        }

        if (selectedImage != null && imgUrl == "") {
          final storageInstance = FirebaseStorage.instance
              .ref("contentImages")
              .child(
                  "${currentuser.id}$id.${selectedImage!.path.split('.').last}");
          await storageInstance.putFile(selectedImage!);
          imgUrl = await storageInstance.getDownloadURL();
        }

        if (ctx.mounted) {
          ctx.read<DraftBloc>().add(SaveArticle(
              ctx: ctx,
              title: title,
              description: description,
              contentId: id.toString(),
              content: content,
              imageUrl: imgUrl,
              tags: tags as List<String>));
        }
      } on FirebaseException catch (error) {
        print("Error occured ${error.message}");
      }
    }
  }

  void publish(BuildContext ctx) async {
    if (formkey.currentState!.validate()) {
      formkey.currentState!.save();
      final userDbRef =
          FirebaseDatabase.instance.ref("user").child(currentuser.id);

      int id = await userDbRef.child("private").child("postcounter").get().then(
        (value) {
          return value.value as int;
        },
      );
      id += 1;
      await userDbRef.child("private").child("postcounter").set(id);
      String imgUrl = "";
      if (widget.a != null) {
        imgUrl = widget.a!.imagePath;
        await userDbRef
            .child("private")
            .child("drafts")
            .child(widget.a!.uid)
            .remove();
      }
      if (selectedImage != null) {
        final storageInstance = FirebaseStorage.instance
            .ref("contentImages")
            .child(
                "${currentuser.id}$id.${selectedImage!.path.split('.').last}");
        await storageInstance.putFile(selectedImage!);
        imgUrl = await storageInstance.getDownloadURL();
      }
      if (ctx.mounted) {
        ctx.read<PublishBloc>().add(PublishArticle(
            ctx: ctx,
            title: title,
            description: description,
            contentId: id.toString(),
            content: content,
            imageUrl: imgUrl,
            tags: tags as List<String>));
      }
    }
  }

  @override
  void initState() {
    if (widget.a != null) {
      title = widget.a!.title;
      content = widget.a!.content;
      description = widget.a!.description;
      tags = widget.a!.tags;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Article"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: formkey,
            child: Column(
              children: [
                TextFormField(
                  style: Theme.of(context).textTheme.headlineMedium,
                  cursorColor: Theme.of(context).colorScheme.onPrimary,
                  initialValue: widget.a == null ? null : title,
                  decoration: InputDecoration(
                    label: Text(
                      "Title",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter valid Title";
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    title = newValue!;
                  },
                ),
                const SizedBox(
                  height: 5,
                ),
                TextFormField(
                  maxLines: 2,
                  minLines: 2,
                  initialValue: widget.a == null ? null : description,
                  decoration: InputDecoration(
                    label: Text(
                      "Desctiption",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter valid description";
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    description = newValue!;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      border: Border.all(
                          style: BorderStyle.solid,
                          width: 1,
                          color: Theme.of(context).colorScheme.onPrimary)),
                  child: TextFormField(
                    initialValue: widget.a == null ? null : content,
                    style: const TextStyle(fontSize: 20),
                    decoration: const InputDecoration(
                      hintText: "Write content here",
                    ),
                    showCursor: true,
                    cursorColor: Theme.of(context).colorScheme.onPrimary,
                    maxLines: 20,
                    minLines: 12,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Cannot submit empty article!";
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      content = newValue!;
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    getImage();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 2,
                            color: Theme.of(context).colorScheme.onPrimary)),
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                        child: selectedImage == null
                            ? widget.a != null
                                ? Image.network(widget.a!.imagePath)
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Select Picture"),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Icon(Icons.add_a_photo),
                                    ],
                                  )
                            : Image.file(selectedImage!)),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  initialValue: widget.a == null ? null : tags.join("#"),
                  decoration: InputDecoration(
                      label: Row(
                        children: [
                          Icon(
                            Icons.tag,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          Text(
                            "Tags",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary),
                          ),
                        ],
                      ),
                      hintText:
                          "Enter tags related to your article!!\n Every tag should start with a '#' and should not contain any spaces!!"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter valid tags";
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    tags = newValue!.split("#").sublist(1);
                  },
                ),
                Row(
                  children: [
                    BlocProvider(
                      create: (context) => DraftBloc(),
                      child: BlocBuilder<DraftBloc, DraftState>(
                          builder: (context, state) {
                        return ElevatedButton.icon(
                          style: const ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.red)),
                          onPressed: state.isSaving
                              ? null
                              : () {
                                  saveAsDraft(context);
                                },
                          label: state.isSaving
                              ? const Text("Saving..",
                                  style: TextStyle(
                                      color: Color(0xfffff9f2),
                                      fontWeight: FontWeight.bold))
                              : const Text("Save",
                                  style: TextStyle(
                                      color: Color(0xfffff9f2),
                                      fontWeight: FontWeight.bold)),
                          icon: state.isSaving
                              ? const CircularProgressIndicator()
                              : const Icon(
                                  Icons.save,
                                  color: Color(0xfffff9f2),
                                ),
                        );
                      }),
                    ),
                    const Spacer(),
                    BlocProvider(
                        create: (context) => PublishBloc(),
                        child: BlocBuilder<PublishBloc, PublishState>(
                            builder: (context, state) {
                          return ElevatedButton.icon(
                            style: const ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(Colors.blue)),
                            onPressed: state.publishing
                                ? null
                                : () {
                                    publish(context);
                                  },
                            label: state.publishing
                                ? const Text(
                                    "Publishing...",
                                    style: TextStyle(
                                        color: Color(0xfffff9f2),
                                        fontWeight: FontWeight.bold),
                                  )
                                : const Text(
                                    "Publish",
                                    style: TextStyle(
                                        color: Color(0xfffff9f2),
                                        fontWeight: FontWeight.bold),
                                  ),
                            icon: state.publishing
                                ? const CircularProgressIndicator()
                                : const Icon(
                                    Icons.publish_rounded,
                                    color: Color(0xfffff9f2),
                                  ),
                          );
                        }))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

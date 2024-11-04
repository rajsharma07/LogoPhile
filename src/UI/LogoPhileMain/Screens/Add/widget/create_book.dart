import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logophile/Models/book.dart';
import 'package:logophile/data/currentuserdata.dart';
import 'package:logophile/src/Bloc/draft/draft_bloc.dart';
import 'package:logophile/src/Bloc/draft/draft_event.dart';
import 'package:logophile/src/Bloc/draft/draft_state.dart';
import 'package:logophile/src/Bloc/publish/publish_bloc.dart';
import 'package:logophile/src/Bloc/publish/publish_event.dart';
import 'package:logophile/src/Bloc/publish/publish_state.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/Add/widget/create_chapter.dart';

class CreateBook extends StatefulWidget {
  const CreateBook({super.key, this.b});
  final Book? b;
  @override
  State<CreateBook> createState() {
    return CreateBookState();
  }
}

class CreateBookState extends State<CreateBook> {
  final formkey = GlobalKey<FormState>();
  File? selectedImage;

  List<String> tags = [];
  final bookdbref = FirebaseDatabase.instance
      .ref("user")
      .child(currentuser.id)
      .child("content");
  final userdbref = FirebaseDatabase.instance.ref("user").child(currentuser.id);

  final List<Chapter> chapters = [];
  late Book currentbook;

  void getImage() async {
    final imagepicked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      selectedImage = imagepicked != null ? File(imagepicked.path) : null;
    });
  }

  void createNewBook() async {
    int i = await userdbref.child("private").child("postcounter").get().then(
      (value) {
        return value.value as int;
      },
    );
    i += 1;

    currentbook.id = i.toString();
  }

  void getchapters() async {
    final dbref = FirebaseDatabase.instance
        .ref("user")
        .child(currentuser.id)
        .child("content")
        .child(widget.b!.id)
        .child("chapters");
    for (var i in widget.b!.chapters) {
      final List<dynamic> pagesList =
          await dbref.child(i[0]).child("pages").get().then(
        (value) {
          return value.value as List;
        },
      );
      chapters.add(Chapter(
          id: i[0], title: i[1], bookId: widget.b!.id, pageId: pagesList));
      setState(() {});
    }
  }

  @override
  void initState() {
    currentbook = widget.b ?? Book();
    if (widget.b == null) {
      createNewBook();
    } else {
      getchapters();
    }
    super.initState();
  }

  void saveAsDraft(BuildContext ctx) async {
    if (formkey.currentState!.validate()) {
      formkey.currentState!.save();
      try {
        String imageUrl = "";
        if (widget.b != null) {
          imageUrl = widget.b!.imagePath;
        }
        if (selectedImage != null) {
          final storageInstance = FirebaseStorage.instance
              .ref("contentImages")
              .child(
                  "${currentuser.id}${currentbook.id}${selectedImage!.path.split(".").last}");
          await storageInstance.putFile(selectedImage!);
          imageUrl = await storageInstance.getDownloadURL();
        }

        if (widget.b == null) {
          await userdbref
              .child("private")
              .child("postcounter")
              .set(int.parse(currentbook.id));
        }
        if (ctx.mounted) {
          ctx.read<DraftBloc>().add(SaveBook(
              ctx: ctx,
              title: currentbook.title,
              description: currentbook.description,
              contentId: currentbook.id,
              imageUrl: imageUrl,
              tags: tags,
              chapters: chapters));
        }
      } on FirebaseException catch (error) {
        print("${error.message}");
      }
    }
  }

  void publish(BuildContext ctx) async {
    if (formkey.currentState!.validate()) {
      formkey.currentState!.save();
      try {
        String imageUrl = currentbook.imagePath;

        if (selectedImage != null) {
          final storageInstance = FirebaseStorage.instance
              .ref("contentImages")
              .child(
                  "${currentuser.id}${currentbook.id}${selectedImage!.path.split(".").last}");
          await storageInstance.putFile(selectedImage!);
          imageUrl = await storageInstance.getDownloadURL();
        }

        if (widget.b != null) {
          await FirebaseDatabase.instance
              .ref("user/${currentuser.id}/private/draft/${currentbook.id}")
              .remove();
        }

        if (widget.b == null) {
          await userdbref
              .child("private")
              .child("postcounter")
              .set(int.parse(currentbook.id));
        }
        if (ctx.mounted) {
          ctx.read<PublishBloc>().add(PublishBook(
              ctx: ctx,
              title: currentbook.title,
              description: currentbook.description,
              contentId: currentbook.id,
              imageUrl: imageUrl,
              tags: tags,
              chapters: chapters));
        }
      } on FirebaseException catch (error) {
        print("${error.message}");
      }
    }
  }

  void addchapter() async {
    Chapter? c = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return CreateChapter(
          dbref: bookdbref.child(currentbook.id),
          chapterid: int.parse(chapters.isEmpty ? "1" : chapters.last.id) + 1,
        );
      },
    ));
    if (c != null) {
      setState(() {
        chapters.add(c);
      });
    }
  }

  void editchapter(int index) async {
    String content = "";
    await bookdbref
        .child(currentbook.id)
        .child("chapters")
        .child(chapters[index].id)
        .child("pages")
        .get()
        .then(
      (value) {
        if (value.value != null) {
          List l = value.value as List;

          for (var i in l) {
            content += i["content"];
          }
        }
      },
    );
    if (mounted) {
      chapters[index] = await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) {
              return CreateChapter(
                dbref: bookdbref.child(currentbook.id),
                chapterid: int.parse(chapters[index].id),
                title: chapters[index].title,
                conent: content,
              );
            },
          )) ??
          chapters[index];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Book"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: formkey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: currentbook.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                  cursorColor: Theme.of(context).colorScheme.onPrimary,
                  decoration: const InputDecoration(
                    hintText: "Title of Book",
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Title cannot be empty!!";
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    currentbook.title = newValue!;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  initialValue: currentbook.description,
                  maxLines: 2,
                  minLines: 2,
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
                    currentbook.description = newValue!;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 2,
                          color: Theme.of(context).colorScheme.onPrimary)),
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                      child: widget.b != null
                          ? InkWell(
                              onTap: getImage,
                              child: Image.network(widget.b!.imagePath))
                          : selectedImage == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Select Picture"),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          getImage();
                                        },
                                        icon: const Icon(Icons.add_a_photo)),
                                  ],
                                )
                              : InkWell(
                                  onTap: () {
                                    getImage();
                                  },
                                  child: Image.file(
                                    selectedImage!,
                                  ),
                                )),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 2,
                          color: Theme.of(context).colorScheme.onPrimary)),
                  height: MediaQuery.of(context).size.height * 0.45,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Chapters",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          const Spacer(),
                          IconButton(
                              onPressed: () {
                                addchapter();
                              },
                              icon: const Icon(Icons.add))
                        ],
                      ),
                      Expanded(
                          child: ListView.builder(
                        itemCount: chapters.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () {
                              editchapter(index);
                            },
                            leading: Text("${index + 1}"),
                            title: Text(
                              chapters[index].title,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                            ),
                            trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    chapters.removeAt(index);
                                  });
                                }),
                          );
                        },
                      ))
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
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
                const SizedBox(
                  height: 20,
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
                          label: Text(state.isSaving ? "Saving..." : "Save",
                              style: const TextStyle(
                                  color: Color(0xfffff9f2),
                                  fontWeight: FontWeight.bold)),
                          icon: const Icon(
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
                            label: Text(
                              state.publishing ? "Publishing..." : "Publish",
                              style: const TextStyle(
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

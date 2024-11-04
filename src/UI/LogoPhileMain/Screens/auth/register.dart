import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/auth/login.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/auth/setupaccount.dart';

final authinstence = FirebaseAuth.instance;

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String? email;

  String? password;

  String? name;

  bool _isloading = false;

  var formkey = GlobalKey<FormState>();

  void createaccount() async {
    try {
      if (formkey.currentState!.validate()) {
        setState(() {
          _isloading = true;
        });
        formkey.currentState!.save();

        final cradential = await authinstence.createUserWithEmailAndPassword(
            email: email!, password: password!);
        setState(() {
          _isloading = false;
        });
        final userid = cradential.user?.uid;
        if (mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) {
              return AccountSetup(
                uid: userid!,
                name: name!,
              );
            },
          ));
        }
      }
    } on FirebaseAuthException catch (error) {
      setState(() {
        _isloading = false;
      });
      if (context.mounted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(error.message ?? "Some unknown error occured")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: formkey,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(30),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset("assets/icons/LogoPhile.png"),
                ),
              ),
              Text(
                "Register",
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(26, 232, 234, 246),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                    label: Text(
                      "Email",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim() == "" ||
                        !value.contains("@")) {
                      return "Enter valid email";
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    email = newValue;
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(26, 232, 234, 246),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                    label: Text(
                      "Name",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.trim() == "") {
                      return "Enter valid Name";
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    name = newValue;
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(26, 232, 234, 246),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    label: Text(
                      "Password",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.trim() == "") {
                      return "Enter valid password";
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    password = newValue;
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  createaccount();
                },
                style: ButtonStyle(
                  elevation: const WidgetStatePropertyAll(10),
                  shadowColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.onPrimary),
                  padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 15)),
                  backgroundColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.onPrimary),
                ),
                child: _isloading
                    ? CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : Text(
                        "Register",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text("or"),
              const SizedBox(
                height: 5,
              ),
              IconButton(
                  onPressed: () {},
                  icon: Image.asset("assets/icons/google.png")),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) {
                      return const Login();
                    },
                  ));
                },
                child: Text(
                  "Already have an account? Login",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

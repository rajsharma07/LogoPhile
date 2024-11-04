import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/auth/register.dart';

final authinstence = FirebaseAuth.instance;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailcontroller = TextEditingController(); 

  final passwordcontroller = TextEditingController();

  bool _isloading = false;

  void authentication(BuildContext ctx) async {
    setState(() {
      _isloading = true;
    });
    try {
      if (emailcontroller.text.trim() == "" || emailcontroller.text.isEmpty) {
        ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text("Enter valid email and Password")));
        return;
      }
      await authinstence.signInWithEmailAndPassword(
          email: emailcontroller.text, password: passwordcontroller.text);
    } on FirebaseAuthException catch (error) {
      setState(() {
        _isloading = false;
      });
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            content: Text(error.message ?? "Some unknown error occured")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(30),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset("assets/icons/LogoPhile.png"),
                ),
              ),
              Text(
                "Login",
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
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
                child: TextField(
                  controller: emailcontroller,
                  cursorColor: Theme.of(context).colorScheme.onPrimary,
                  decoration: InputDecoration(
                    label: Text(
                      "Email",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
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
                child: TextField(
                  controller: passwordcontroller,
                  obscureText: true,
                  cursorColor: Theme.of(context).colorScheme.onPrimary,
                  decoration: InputDecoration(
                    label: Text(
                      "Password",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      authentication(context);
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
                            "Login",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Text("or"),
                  const SizedBox(
                    width: 5,
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: Image.asset("assets/icons/google.png"))
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) {
                      return const Register();
                    },
                  ));
                },
                child: Text(
                  "Don't have an account? Register",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Theme.of(context).colorScheme.onPrimary),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

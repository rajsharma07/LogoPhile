import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logophile/data/currentuserdata.dart';
import 'package:logophile/src/Bloc/Theme/theme_bloc.dart';
import 'package:logophile/src/Bloc/Theme/theme_state.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/waitingScreen.dart';
import 'package:logophile/src/UI/LogoPhileMain/logophileui.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/auth/login.dart';

const ColorScheme lightScheme = ColorScheme.light(
    primary: Color(0xfffff9f3),
    onPrimary: Color(0xff001f3f),
    surface: Color(0xfffff9f3),
    secondary: Color(0xff0074d9));

const ColorScheme darkScheme = ColorScheme.dark(
    primary: Color(0xff001f3f),
    onPrimary: Color(0xfffff9f3),
    surface: Color(0xff001f3f),
    secondary: Color(0xff0074d9));

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: BlocProvider(
        create: (context) {
          return ThemeBloc();
        },
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(colorScheme: lightScheme),
              darkTheme: ThemeData(colorScheme: darkScheme),
              themeMode: state.mode,
              home: StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const WaitingScreen();
                  } else if (snapshot.hasData) {
                    currentuser.id = snapshot.data!.uid;
                    currentuser.email = snapshot.data!.email ?? "";

                    return const LogoPhile();
                  }
                  return const Login();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

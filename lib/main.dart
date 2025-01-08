import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saveily_2/bloc/account_bloc.dart';
import 'package:saveily_2/firebase_options.dart';
import 'package:saveily_2/screens/auth/welcomePage.dart';
import 'package:saveily_2/theme/color.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccountBloc(), // Provide the AccountBloc here
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Saveily",
        theme: ThemeData(
          fontFamily: 'Roboto',
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shadowColor: primaryColor,
              elevation: 13,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ),
        home: const WelcomePage(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spec_bot/pages/savedPage.dart';
import 'pages/mainPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: '',
    anonKey: '',
  );
  runApp(
    GetMaterialApp(
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 350),
      title: 'Spec Bot',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => MainPage(),),
        GetPage(name: '/saved', page: () => const SavedPage(),),
      ],
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
      ),
      home: MainPage(),
    );
  }
}

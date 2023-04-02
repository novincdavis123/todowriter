import 'package:flutter/material.dart';
import 'package:flame_splash_screen/flame_splash_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:todowriter/darkmode.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('todo_box');
  runApp(EasyLocalization(
    supportedLocales: [
      Locale('en', 'US'),
      Locale('en', 'GB'),
      Locale('en', 'HI'),
    ],
    path: 'assets/translations',
    saveLocale: true,
    fallbackLocale: Locale('en', 'US'),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      theme: ThemeData(primarySwatch: Colors.blue),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      home: MusiSplash(),
    );
  }
}

class MusiSplash extends StatelessWidget {
  const MusiSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FlameSplashScreen(
            theme: FlameSplashTheme.dark,
            showBefore: (BuildContext context) {
              return Text(
                "To be shown before flame animation",
                style: TextStyle(color: Colors.amber),
              );
            },
            onFinish: (BuildContext context) => Navigator.of(context)
                .pushReplacement(
                    MaterialPageRoute(builder: (context) => Darkmode()))));
  }
}

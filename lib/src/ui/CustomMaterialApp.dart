import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class CustomMaterialApp extends StatelessWidget {
  final String title;
  final Widget home;

  const CustomMaterialApp({
    Key? key,
    required this.title,
    required this.home,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return MaterialApp(
          title: title,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            textTheme: TextTheme(
              bodyLarge: TextStyle(
                fontFamily: userProvider.userPreferences.defaultFontId,
                fontSize: userProvider.userPreferences.fontSize,
              ),
              bodyMedium: TextStyle(
                fontFamily: userProvider.userPreferences.defaultFontId,
                fontSize: userProvider.userPreferences.fontSize,
              ),
              bodySmall: TextStyle(
                fontFamily: userProvider.userPreferences.defaultFontId,
                fontSize: userProvider.userPreferences.fontSize,
              ),
            ).apply(
              bodyColor: Colors.black,
              displayColor: Colors.black,
              fontFamily: userProvider.userPreferences.defaultFontId,
            ),
          ),
          home: home,
        );
      },
    );
  }
}

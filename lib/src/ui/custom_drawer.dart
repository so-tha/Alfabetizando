import 'dart:ui';
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final bool isDrawerOpen;
  final Function toggleDrawer;

  const CustomDrawer({
    super.key,
    required this.isDrawerOpen,
    required this.toggleDrawer,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (isDrawerOpen)
          GestureDetector(
            onTap: () => toggleDrawer(),
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(),
              ),
            ),
          ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          right: isDrawerOpen ? 0 : -300,
          top: 0,
          bottom: 0,
          child: Material(
            elevation: 5,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(60.0),
              bottomLeft: Radius.circular(60.0),
            ),
            child: Container(
              width: 300,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    color: const Color.fromRGBO(255, 203, 124, 1),
                    padding: const EdgeInsets.all(16.0),
                    child: const Text(
                      'Configurações',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Áudio e voz'),
                    onTap: () {},
                  ),
                  ListTile(
                    title: const Text('Fontes'),
                    onTap: () {},
                  ),
                  ListTile(
                    title: const Text('Cartões'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

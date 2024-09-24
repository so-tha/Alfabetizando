import 'package:flutter/material.dart';

import '../models/categories.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const CategoryCard({
    super.key,
    required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: 1,
          child: Container(
            decoration: ShapeDecoration(
              image: DecorationImage(
                image: AssetImage(imageUrl),
                fit: BoxFit.cover,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              shadows: const [
                BoxShadow(
                  color: Color.fromARGB(255, 226, 226, 226),
                  blurRadius: 2,
                  spreadRadius: 0,
                ),
              ],
            ),
            height: 140,
            width: double.infinity,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          capitalizeWords(title),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          
        ),
      ],
    );
  }}
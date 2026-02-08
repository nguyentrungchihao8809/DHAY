// lib/features/place/presentation/widgets/location_input_field.dart
import 'package:flutter/material.dart';

class LocationInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final Function(String)? onChanged; // 1. Khai báo tham số

  const LocationInputField({
    super.key,
    required this.hintText,
    required this.icon,
    this.onChanged, // 2. Thêm vào constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: onChanged, // 3. Truyền giá trị vào TextField thực tế
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
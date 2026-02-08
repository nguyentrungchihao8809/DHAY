// lib/features/place/presentation/widgets/recent_destination_item.dart
import 'package:flutter/material.dart';

class RecentDestinationItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap; // 1. Khai báo kiểu dữ liệu cho hàm nhấn

  const RecentDestinationItem({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap, // 2. Thêm vào constructor
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap, // 3. Gắn vào sự kiện onTap của ListTile
      leading: const CircleAvatar(
        backgroundColor: Colors.green,
        child: Icon(Icons.location_on, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
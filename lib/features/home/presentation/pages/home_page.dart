import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DHAY Home", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          // Nút Đăng xuất
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          "HELLO\nĐăng nhập thành công!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Đăng xuất"),
        content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () async {
              // 1. Xóa token trong máy
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('access_token');

              // 2. Quay về trang Login và xóa sạch lịch sử các trang trước
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            child: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
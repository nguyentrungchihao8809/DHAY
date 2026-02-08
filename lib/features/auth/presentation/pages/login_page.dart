import 'package:flutter/material.dart';
import '../../../../core/widgets/social_login_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  // features/auth/presentation/pages/login_page.dart

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          // Tăng padding để gom nội dung vào giữa giống Figma
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              // Khoảng cách từ đỉnh máy

              // LOGO: Không dùng Center. Dùng Align trái.
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/images/logo_dhay.png',
                  height: 120, // Kích thước logo vừa phải theo Figma
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 10),
              // Khoảng cách cực hẹp giữa logo và text

              const Text(
                "Đăng nhập vào DHAY",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Chào mừng bạn quay lại! Vui lòng nhập thông tin tài khoản.",
                style: TextStyle(
                  color: AppColors.greyText,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 32),

              // Form Inputs... (Giữ nguyên hoặc chỉnh padding dọc)
              const CustomTextField(
                hintText: "Nhập tên đăng nhập",
                prefixIcon: Icon(Icons.account_circle, size: 28),
              ),
              const SizedBox(height: 16),
              const CustomTextField(
                hintText: "Nhập mật khẩu",
                prefixIcon: Icon(Icons.lock, size: 28),
                isPassword: true,
              ),

              // Quên mật khẩu
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text(
                  "Quên mật khẩu? Đặt lại",
                  style: TextStyle(color: Colors.blueAccent, fontSize: 13),
                ),
              ),

              const SizedBox(height: 20),

              // Nút Đăng nhập: Trong Figma nó không dài hết cỡ, thường bo tròn mạnh
              Center(
                child: SizedBox(
                  width: 200,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: const Text("Đăng nhập",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Social Buttons: Trong thiết kế chúng có độ cao thấp hơn nút chính một chút
              SocialLoginButton(
                text: "Đăng nhập bằng Google",
                iconPath: 'assets/icons/google.png',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              SocialLoginButton(
                text: "Đăng nhập bằng Facebook",
                iconPath: 'assets/icons/facebook.png',
                onTap: () {},
              ),

              const SizedBox(height: 60),

              // Footer
              const Center(
                child: Text.rich(
                  TextSpan(
                    text: "From ",
                    style: TextStyle(color: Colors.black54),
                    children: [
                      TextSpan(
                        text: "DHAY",
                        style: TextStyle(color: AppColors.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
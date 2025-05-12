import 'package:bat_theme/bat_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/navigation/navigator.dart';

import '../../../../shared/res/res.dart';
import '../../../../shared/widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> _login() async {
    // AppFunction.showLoading(context);
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // ignore: use_build_context_synchronously
      // context.read<UserProvider>().saveEmailUser(_emailController.text.trim());
      // ignore: use_build_context_synchronously
      // AppFunction.hideLoading(context);

      AppNavigator.pushNamedAndClear(dashboardRoute);
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      // AppFunction.hideLoading(context);
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'Không tìm thấy tài khoản người dùng';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Sai mật khẩu';
      } else {
        errorMessage = 'Lỗi không xác định';
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  void initState() {
    FirebaseAuth.instance.setLanguageCode('vi');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = BatThemeData.of(context);
    return Scaffold(
      backgroundColor: theme.colors.background,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 109.h),
            Image.asset("assets/images/logo.png",
                color: theme.colors.primary, width: 174.w),
            SizedBox(height: 64.h),
            Text(
              'Login to your account',
              style: TextStyles.headline4.copyWith(
                  color: theme.colors.primary, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 48.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email',
                  style: theme.typography.bodyCopyMedium
                      .copyWith(color: theme.colors.tertiary),
                ),
                SizedBox(height: 8.h),
                TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your email',
                  ),
                  controller: _emailController,
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Password',
                  style: theme.typography.bodyCopyMedium
                      .copyWith(color: theme.colors.tertiary),
                ),
                SizedBox(height: 8.h),
                TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your password',
                  ),
                  controller: _passwordController,
                ),
              ],
            ),
            SizedBox(height: 64.h),
            AppButtonPrimary(
              label: 'Login',
              onPressed: () async {
                if (_emailController.text.trim().isEmpty ||
                    _passwordController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Vui lòng điền đầy đủ thông tin")),
                  );
                } else if (_emailController.text.trim().isNotEmpty &&
                    _passwordController.text.trim().isNotEmpty) {
                  _login();
                }
                // AppFunction.showLoading(context);
                // await Future.delayed(const Duration(milliseconds: 1500));
                // AppFunction.hideLoading(context);
              },
            ),
            const Spacer(),
            RichText(
              text: TextSpan(
                text: 'Don\'t have an account? ',
                style: theme.typography.bodyCopyMedium
                    .copyWith(color: theme.colors.tertiary.withOpacity(0.6)),
                children: [
                  TextSpan(
                    text: 'Create account',
                    style: theme.typography.bodyCopyMedium
                        .copyWith(color: theme.colors.primary),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => AppNavigator.pushNamed(registerRoute),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom * 2),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_page.dart';
import 'sign_up_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  // دالة تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  void _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  // دالة للانتقال إلى صفحة التسجيل
  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpPage()),
    );
  }

  // دالة تسجيل الدخول باستخدام Google
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تسجيل الدخول',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // خلفية الصفحة
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // محتوى الصفحة داخل وسط الشاشة
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'مرحبًا بك',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // حقل البريد الإلكتروني
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          prefixIcon: const Icon(Icons.email, color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // حقل كلمة المرور
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),

                      // زر تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.blue, Colors.purple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                            child: const Text(
                              'تسجيل الدخول',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // زر تسجيل الدخول باستخدام Google (تم استبدال الصورة بأيقونة)
                      ElevatedButton(
                        onPressed: _signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // تم تصغير الـ padding
                          minimumSize: const Size(120, 30), // تحديد الحد الأدنى للحجم
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // تصغير الزوايا
                          ),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.g_mobiledata, // أيقونة Google
                              size: 16, // حجم الأيقونة
                              color: Colors.red, // لون الأيقونة
                            ),
                            const SizedBox(width: 6), // مسافة صغيرة بين الأيقونة والنص
                            const Text(
                              'Google',
                              style: TextStyle(fontSize: 12, color: Colors.black87), // تم تصغير حجم النص
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // رابط التسجيل
                      TextButton(
                        onPressed: _navigateToSignUp,
                        child: const Text(
                          "ليس لديك حساب؟ اضغط هنا للتسجيل",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // رسالة الخطأ
                      if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // شريط سفلي ثابت
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                '© 2023 جميع الحقوق محفوظة',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
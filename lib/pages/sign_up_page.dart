import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // إضافة استيراد Firestore
import 'home_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // تعريف Firestore
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  // دالة تسجيل جديد
  Future<void> _signUp() async {
    try {
      // التحقق من صحة البريد الإلكتروني وكلمة المرور
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        setState(() {
          _errorMessage = "البريد الإلكتروني وكلمة المرور مطلوبان.";
        });
        return;
      }

      // إنشاء مستخدم جديد باستخدام Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // حفظ بيانات المستخدم في Firestore بعد التسجيل بنجاح
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': _emailController.text.trim(), // البريد الإلكتروني للمستخدم
        'createdAt': FieldValue.serverTimestamp(), // وقت الإنشاء تلقائيًا
      });

      // التنقل إلى الصفحة الرئيسية بعد التسجيل
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString(); // عرض رسالة الخطأ للمستخدم
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // شريط علوي مع لون متدرج
      appBar: AppBar(
        title: const Text(
          'تسجيل جديد',
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

      // الجسم الرئيسي للصفحة
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
                      // عنوان الصفحة
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

                      // زر التسجيل
                      ElevatedButton(
                        onPressed: _signUp,
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
                              'إنشاء حساب',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

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
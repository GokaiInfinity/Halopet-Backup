import 'package:flutter/material.dart';
import 'package:halopet_vetcare/core/app_theme.dart';
import 'package:halopet_vetcare/core/database.dart';
import 'package:halopet_vetcare/screens/auth/register_screen.dart';
import 'package:halopet_vetcare/screens/home/home_router.dart';
import 'package:halopet_vetcare/core/helpers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController(text: 'pemilik@halopet.test');
  final passwordController = TextEditingController(text: '123456');
  bool loading = false;
  bool isPasswordVisible = false;
  bool rememberMe = false;
  bool loginError = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      loading = true;
      loginError = false;
    });
    
    final user = await AppDatabase.instance.login(emailController.text, passwordController.text);
    
    if (!mounted) return;
    
    setState(() => loading = false);
    
    if (user == null) {
      setState(() => loginError = true);
      return;
    }
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeRouter(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkNavy, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Masuk', style: TextStyle(color: AppColors.darkNavy, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text('Selamat datang kembali', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkNavy)),
              const SizedBox(height: 8),
              Text(
                loginError ? 'Periksa kembali data akun yang dimasukkan.' : 'Masuk untuk melanjutkan perawatan hewanmu.',
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              ),
              const SizedBox(height: 32),
              
              const Text('Email atau nomor telepon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkNavy)),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'nama@email.com',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(Icons.mail_outline, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBlue)),
                ),
              ),
              const SizedBox(height: 20),
              
              const Text('Kata sandi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkNavy)),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Masukkan kata sandi',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20),
                    onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: loginError ? Colors.red : Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: loginError ? Colors.red : Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: loginError ? Colors.red : AppColors.primaryBlue)),
                ),
              ),
              if (loginError)
                const Padding(
                  padding: EdgeInsets.only(top: 8, left: 4),
                  child: Text('Email atau kata sandi tidak sesuai.', style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
                
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24, height: 24,
                        child: Checkbox(
                          value: rememberMe,
                          onChanged: (val) => setState(() => rememberMe = val ?? false),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          activeColor: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Ingat saya', style: TextStyle(fontSize: 13, color: AppColors.darkNavy)),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                    child: const Text('Lupa kata sandi?', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FA0C1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    loading ? 'Memproses...' : (loginError ? 'Coba lagi' : 'Masuk'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              
              if (loginError)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Gagal masuk', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('Pastikan email dan kata sandi sudah benar.', style: TextStyle(color: Colors.red, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (!loginError) ...[
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('atau', style: TextStyle(color: Colors.grey, fontSize: 12))),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    icon: Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png', width: 20, height: 20),
                    label: const Text('Masuk dengan Google', style: TextStyle(color: AppColors.darkNavy, fontSize: 14, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      showMessage(context, 'Fitur Google Login belum tersedia.');
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum punya akun? ', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                    child: const Text('Daftar sekarang', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

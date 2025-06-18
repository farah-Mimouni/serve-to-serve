import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:client/authentication/auth_screen.dart';
import 'package:client/global/global.dart';
import 'package:client/widgets/error_Dialog.dart';
import 'package:client/widgets/loading_dialog.dart';
import 'package:client/mainScreens/home_screen.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller for form fade-in
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void formValidation() {
    if (emailController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty) {
      loginNow();
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const ErrorDialog(
            message: "Entrez votre e-mail et mot de passe, s'il vous plaît.",
          );
        },
      );
    }
  }

  Future<void> loginNow() async {
    showDialog(
      context: context,
      builder: (c) {
        return const LoadingDialog(
          message: 'Connexion en cours..',
        );
      },
    );

    User? currentUser;
    try {
      UserCredential auth = await firebaseAuth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      currentUser = auth.user;
    } catch (error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) {
          return ErrorDialog(
            message: error.toString(),
          );
        },
      );
      return;
    }

    if (currentUser != null) {
      await readDataAndSetDataLocally(currentUser);
    }
  }

  Future<void> readDataAndSetDataLocally(User currentUser) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;

        if (userData["status"] == "Approved") {
          await sharedPreferences!.setString("uid", currentUser.uid);
          await sharedPreferences!.setString("email", userData["email"] ?? "");
          await sharedPreferences!.setString("name", userData["name"] ?? "");
          await sharedPreferences!.setString("photo", userData["photo"] ?? "");

          List<String> userCartList =
              (userData["userCart"] as List<dynamic>?)?.cast<String>() ??
                  ['garbageValue'];
          await sharedPreferences!.setStringList("userCart", userCartList);

          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          await firebaseAuth.signOut();
          Navigator.pop(context);
          Fluttertoast.showToast(
            msg: "Admin has blocked your account\n\nMail to: admin@gmail.com",
          );
        }
      } else {
        await firebaseAuth.signOut();
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
        showDialog(
          context: context,
          builder: (context) {
            return const ErrorDialog(
              message: "No record found",
            );
          },
        );
      }
    } catch (e) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) {
          return ErrorDialog(
            message: "Error retrieving user data: $e",
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Eco-friendly header
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Connectez-vous sur save to serve',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Login image
            Container(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/images/login.png',
                  height: 200, // Reduced for balance
                  semanticLabel: 'Login Illustration',
                ),
              ),
            ),
            // Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    data: Icons.email,
                    controller: emailController,
                    hintText: 'Email',
                    isObsecre: false,
                  ),
                  CustomTextField(
                    data: Icons.lock,
                    controller: passwordController,
                    hintText: 'Mot de passe',
                    isObsecre: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Login button
            ElevatedButton(
              onPressed: formValidation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32), // Forest Green
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Connexion'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert'; // Add for base64 encoding
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/widgets/custom_text_field.dart';
import 'package:client/widgets/error_Dialog.dart';
import 'package:client/widgets/loading_dialog.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart'; // Add for compression
import '../global/global.dart';
import '../mainScreens/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmePasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();
  String sellerImageBase64 = ""; // Store image as base64 string
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmePasswordController.dispose();
    super.dispose();
  }

  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  Future<void> formValidation() async {
    if (imageXFile == null) {
      showDialog(
          context: context,
          builder: (context) {
            return const ErrorDialog(message: "Sélectionnez une image");
          });
    } else {
      if (passwordController.text == confirmePasswordController.text) {
        if (confirmePasswordController.text.isNotEmpty &&
            nameController.text.isNotEmpty &&
            emailController.text.isNotEmpty) {
          showDialog(
              context: context,
              builder: (context) {
                return const LoadingDialog(
                  message: "Création du compte en cours...",
                );
              });

          // Compress and convert image to base64
          try {
            final bytes = await FlutterImageCompress.compressWithFile(
              imageXFile!.path,
              minWidth: 300,
              minHeight: 300,
              quality: 70,
            );
            sellerImageBase64 = base64Encode(bytes!);

            // Proceed with authentication
            authenticateSellerAndSignUp();
          } catch (e) {
            Navigator.pop(context);
            showDialog(
                context: context,
                builder: (context) {
                  return ErrorDialog(
                    message: "Error processing image: $e",
                  );
                });
          }
        } else {
          showDialog(
              context: context,
              builder: (context) {
                return const ErrorDialog(
                    message:
                        "Entrez les informations obligatoires pour vous inscrire.");
              });
        }
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return const ErrorDialog(
                  message: "Mot de passe non correspondant");
            });
      }
    }
  }

  void authenticateSellerAndSignUp() async {
    User? currentUser;

    await firebaseAuth
        .createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    )
        .then((auth) {
      currentUser = auth.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
              message: error.message.toString(),
            );
          });
    });
    if (currentUser != null) {
      saveDataToFireStore(currentUser!).then((value) {
        Navigator.pop(context);
        Route newRoute =
            MaterialPageRoute(builder: (context) => const HomeScreen());
        Navigator.pushReplacement(context, newRoute);
      });
    }
  }

  Future saveDataToFireStore(User currentUser) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({
        "uid": currentUser.uid,
        "email": currentUser.email,
        "name": nameController.text.trim(),
        "photo": sellerImageBase64, // Store base64 string instead of URL
        "status": "Approved",
        "userCart": ['garbageValue'],
      });

      // Save data locally
      sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences!.setString("uid", currentUser.uid);
      await sharedPreferences!.setString("email", currentUser.email.toString());
      await sharedPreferences!.setString("name", nameController.text.trim());
      await sharedPreferences!.setString("photo", sellerImageBase64);
      await sharedPreferences!.setStringList("userCart", ['garbageValue']);
    } catch (e) {
      print("Error saving to Firestore: $e");
      throw e;
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
                color: const Color(0xFF2E7D32).withOpacity(0.8), // Forest Green
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 16),
            // Profile image picker
            InkWell(
              onTap: _getImage,
              child: CircleAvatar(
                radius:
                    MediaQuery.of(context).size.width * 0.15, // Smaller size
                backgroundColor: Colors.white,
                backgroundImage: imageXFile == null
                    ? null
                    : FileImage(File(imageXFile!.path)),
                child: imageXFile == null
                    ? Icon(
                        Icons.add_photo_alternate,
                        size: MediaQuery.of(context).size.width * 0.15,
                        color: const Color(0xFFA5D6A7), // Mint Green
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            // Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    data: Icons.person,
                    controller: nameController,
                    hintText: 'nom',
                    isObsecre: false,
                  ),
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
                  CustomTextField(
                    data: Icons.lock,
                    controller: confirmePasswordController,
                    hintText: 'Confirmatiom Mot de passe',
                    isObsecre: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Sign Up button
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
              child: const Text(
                'Inscription',
                semanticsLabel: 'Sign Up Button',
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_tutorial/screen/auth/forgot_password.dart';
import 'package:supabase_tutorial/screen/auth/services/auth_services.dart';
import 'package:supabase_tutorial/screen/image/image_for_web.dart';
import 'package:supabase_tutorial/screen/auth/profile_screen.dart';
import 'package:supabase_tutorial/screen/auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  final supabase = Supabase.instance.client;

  Future<void> continueWithGoogle() async {
    try {
      String webClient = dotenv.env['WEB_CLIENT'] ?? '';
      String androidClient = dotenv.env['ANDROID_CLIENT'] ?? '';
      String iosClient = dotenv.env['IOS_CLIENT'] ?? '';

      GoogleSignIn signIn = GoogleSignIn.instance;
      await signIn.initialize(
        serverClientId: webClient,
        clientId: Platform.isAndroid ? androidClient : iosClient,
      );
      GoogleSignInAccount account = await signIn.authenticate();

      String idToken = account.authentication.idToken ?? '';
      final authorization =
          await account.authorizationClient.authorizationForScopes([
            'email',
            'profile',
          ]) ??
          await account.authorizationClient.authorizeScopes([
            'email',
            'profile',
          ]);

      final result = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: authorization.accessToken,
      );
      if (result.user != null && result.session != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ImageForWebScreen()),
          (context) => false,
        );
      } else {
        print("User Not Found");
      }
    } catch (e) {
      print("Continue with google: $e");
    }
  }

  Future<void> login() async {
    setState(() {
      loading = true;
    });

    try {
      final result = await supabase.auth.signInWithPassword(
        password: passwordController.text,
        email: emailController.text,
      );
      if (result.user != null && result.session != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
          (context) => false,
        );
      } else {
        if (kDebugMode) {
          print("User Not Found");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Login Screen $e");
      }
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    AuthServices.configDeepLink(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Login"))),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          spacing: 10,
          children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                hintText: "Enter your email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                hintText: "Enter your password",
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgotPasswordScreen(),
                  ),
                );
              },
              child: Container(
                height: 50,
                width: 130,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    "Forgot Password",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

            InkWell(
              onTap: () {
                login();
              },
              child: Container(
                height: 50,
                width: 130,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: loading
                    ? Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Center(
                        child: Text(
                          "Login",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                continueWithGoogle();
              },
              child: Center(child: Text("Continue with google.")),
            ),
            SizedBox(height: 50),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text("Register?"),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_tutorial/screen/auth/reset_password_screen.dart';

class AuthServices {
  static void configDeepLink(BuildContext context) {
    final appLinks = AppLinks();
    appLinks.uriLinkStream.listen((uri) {
      print("Uri Host: ${uri.host}");
      if (uri.host == 'password-reset') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
        );
      }
    });
  }

  static void getStorageFile() async {
    var supabase = Supabase.instance.client;
    supabase.storage.from("Bucket 1").list();
    print("Supabase images: ${supabase.storage.listBuckets()}");
  }
}

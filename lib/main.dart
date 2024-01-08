import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

final logger = Logger();

Future<User?> signInWithGoogle() async {
  // GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
  //   'email',
  //   'https://www.googleapis.com/auth/contacts.readonly',
  //   "https://www.googleapis.com/auth/userinfo.profile"
  // ]);
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  // final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

  if (googleUser == null) {
    return null; // 사용자가 로그인을 취소한 경우
  }

  logger.d("[signInWithGoogle] googleUser.authentication : ${googleUser.authentication}");
  logger.d("[signInWithGoogle] googleUser.authHeaders : ${googleUser.authHeaders}");
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  logger.d("[signInWithGoogle] googleAuth.accessToken : ${googleAuth.accessToken}");
  logger.d("[signInWithGoogle] googleAuth.idToken : ${googleAuth.idToken}");
  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  // Firebase에 사용자 정보 등록
  UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
  logger.d("[signInWithGoogle] userCredential.user : ${userCredential.user?.getIdToken()}");
  return userCredential.user;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Google Sign In Demo',
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Social Sign In Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Sign in with Google'),
              onPressed: () async {
                User? user = await signInWithGoogle();
                if (user != null) {
                  var idToken = await user.getIdToken();
                  logger.d('로그인 성공: ${user.displayName}');
                  logger.d('idToken: ${idToken}');
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Sign in with Apple'),
              onPressed: () async {
                print('애플로그인 클릭');
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Sign in with Kakao'),
              onPressed: () async {
                print('카카오 로그인 클릭');
              },
            ),
          ],
        ),
      ),
    );
  }
}

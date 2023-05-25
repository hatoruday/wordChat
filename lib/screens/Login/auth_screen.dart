import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:milchat/main.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  late String email;
  late String password;
  final _formKey = GlobalKey<FormState>();

  Future signInWithGoogle(BuildContext context) async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential);
    Navigator.pushNamed(context, "/readIt");
  }

  signIn() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        //print(value);
        if (value.user!.emailVerified) {
          //이메일 인증 여부
          // setState(() {
          //   isInput = false;
          // });
          Navigator.pushNamed(context, "/readIt"); //로그인되면 홈화면 이동한다.
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("이메일이 아직 인증되지 않음.")));
        }
        return value;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("계정을 찾을 수 없음.")));
      } else if (e.code == 'wrong-password') {
        showToast('wrong-password');
      } else {
        print(e.code);
      }
    }
  }

  //로그아웃 메서드
  //   signOut() async {
  //   await FirebaseAuth.instance.signOut();
  //   setState(() {
  //     isInput = true;
  //   });
  // }

  List<Widget> getInputWidget(
      BuildContext context, double screenWidth, double screenHeight) {
    return [
      SizedBox(
        height: screenHeight / 10,
      ),
      const Text(
        "ReadIt",
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.w700, fontSize: 50),
      ),
      const Text(
        "리드잇 로그인",
        style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 40,
            fontFamily: "Hobbang"),
        textAlign: TextAlign.center,
      ),
      SizedBox(
        height: screenHeight / 7,
      ),
      Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: 'email',
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    )),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 3.0,
                    )),
                // border: OutlineInputBorder(
                //     borderRadius: BorderRadius.circular(40),
                //     borderSide:
                //         const BorderSide(color: Colors.red, width: 3.0)),
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (value) {
                if (value?.isEmpty ?? false) {
                  return 'please enter email';
                }
                return null;
              },
              onSaved: (String? value) {
                email = value ?? "";
              },
            ),
            SizedBox(
              height: screenHeight / 30,
            ),
            TextFormField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: 'password',
                prefixIcon: const Icon(Icons.lock),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    )),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 3.0,
                    )),
              ),
              validator: (value) {
                if (value?.isEmpty ?? false) {
                  password = value ?? "";
                }
                return null;
              },
              obscureText: true,
              onSaved: (String? value) {
                password = value ?? "";
              },
            ),
          ],
        ),
      ),
      SizedBox(
        height: screenHeight / 30,
      ),
      ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState?.save();

              signIn();
            }
          },
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.black),
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(
                  vertical: 10.0, horizontal: 20.0))),
          child: const Text(
            "로그인",
            style: TextStyle(
                color: Colors.white, fontSize: 25, fontWeight: FontWeight.w300),
          )),
      SizedBox(
        height: screenHeight / 30,
      ),
      const Divider(
        height: 20.0,
        color: Colors.black,
        thickness: 2,
      ),
      const Text(
        "Or Login with",
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
      ),
      Row(
        children: [
          ElevatedButton(
              style: ButtonStyle(
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)))),
              onPressed: () {
                BuildContext beforeContext = context;
                signInWithGoogle(beforeContext);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  "images/google_logo.png",
                  width: 30,
                  height: 30,
                ),
              )),
        ],
      ),
      const SizedBox(
        height: 20,
      ),
      RichText(
        textAlign: TextAlign.right,
        text: TextSpan(
          text: '계정이 없다면, ',
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          children: <TextSpan>[
            TextSpan(
                text: "회원가입",
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pushNamed(context, "/register");
                  }),
          ],
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("로그인"),
      // ),
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
        ),
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/word_book2.png"), fit: BoxFit.cover)),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: getInputWidget(context, screenwidth, screenHeight),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
          Navigator.pushNamed(context, "/home"); //로그인되면 홈화면 이동한다.
        } else {
          showToast('emailVerified error');
        }
        return value;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showToast('user-not-found');
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

  List<Widget> getInputWidget() {
    return [
      const Text(
        "SignIn",
        style: TextStyle(
          color: Colors.indigo,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
      Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'email'),
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
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'password',
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
      ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState?.save();
              //print('email : $email, password : $password');
              signIn();
            }
          },
          child: const Text("로그인")),
      RichText(
        textAlign: TextAlign.right,
        text: TextSpan(
          text: '계정이 없다면, ',
          style: Theme.of(context).textTheme.bodyLarge,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("로그인"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: getInputWidget(),
      ),
    );
  }
}

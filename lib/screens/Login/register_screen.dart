
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:milchat/main.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  late String email;
  late String password;
  late String confirmPassword;
  final _formKey = GlobalKey<FormState>();
  bool isRegistered = false;

  signUp() async {
    try {
      if (password != confirmPassword) {
        showToast("비밀번호가 일치하지 않습니다. 다시 입력해주십시오.");
        return;
      }
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) {
        if (value.user!.email != null) {
          FirebaseAuth.instance.currentUser?.sendEmailVerification();
          setState(() {
            isRegistered = true;
          });
        }
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showToast('weak-passwkrd');
      } else if (e.code == 'email-already-in-use') {
        showToast('email-already-in-use');
      } else {
        showToast('other error');
        print(e.code);
      }
    }
  }

  List<Widget> getInputWidget() {
    return [
      const Text(
        "회원가입",
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
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
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
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
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
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? false) {
                    confirmPassword = value ?? "";
                  }
                  return null;
                },
                obscureText: true,
                onSaved: (String? value) {
                  confirmPassword = value ?? "";
                },
              ),
            ),
          ],
        ),
      ),
      ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState?.save();
              print('email : $email, password : $password');
              signUp();
            }
          },
          child: const Text("회원가입")),
    ];
  }

  List<Widget> getEmailVerifyWidget() {
    String resultEmail = FirebaseAuth.instance.currentUser!.email!;
    return [
      Text(
        "$resultEmail로 회원가입이 완료되었습니다! 이메일 인증이 필요합니다. 해당 이메일에서 이메일 인증을 완료해주십시오.",
        style: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.bold,
        ),
      ),
      ElevatedButton(
          onPressed: () {
            FirebaseAuth.instance.currentUser?.sendEmailVerification();
          },
          child: const Text("인증 메일 재발송")),
      ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("로그인하기")),
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
        children: isRegistered ? getEmailVerifyWidget() : getInputWidget(),
      ),
    );
  }
}

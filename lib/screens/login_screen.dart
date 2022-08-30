import 'package:flutter/material.dart';
import 'package:productos_app/providers/login_form_provider.dart';
import 'package:productos_app/ui/input_decorations.dart';
import 'package:productos_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
          child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 250),
            CardContainer(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text('Login',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 30),
                  ChangeNotifierProvider(
                      create: (context) => LoginFormProvider(),
                      child: const _loginForm()),
                ],
              ),
            ),
            const SizedBox(height: 50),
            const Text(
              'Crear una nueva cuenta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
          ],
        ),
      )),
    );
  }
}

class _loginForm extends StatelessWidget {
  const _loginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);

    return Container(
      child: Form(
        key: loginForm.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            TextFormField(
              onChanged: (value) => loginForm.email = value,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecorations.authInputDecoration(
                  hintText: 'john.doe@gmail.com',
                  labelText: 'Email',
                  prefixIcon: Icons.alternate_email_sharp),
              validator: (value) {
                String pattern =
                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                RegExp regExp = new RegExp(pattern);
                return regExp.hasMatch(value ?? '')
                    ? null
                    : 'It is not a email';
              },
            ),
            const SizedBox(height: 30),
            TextFormField(
              onChanged: (value) => loginForm.password = value,
              autocorrect: false,
              obscureText: true,
              decoration: InputDecorations.authInputDecoration(
                  hintText: '****',
                  labelText: 'Password',
                  prefixIcon: Icons.lock_outline),
              validator: (value) {
                return (value != null && value.length >= 6)
                    ? null
                    : 'Password must be at least 6 characters';
              },
            ),
            const SizedBox(height: 30),
            MaterialButton(
              onPressed: loginForm.isLoading
                  ? null
                  : () async {
                      if (!loginForm.isValidForm()) return;
                      FocusScope.of(context).unfocus();
                      loginForm.isLoading = true;
                      await Future.delayed(Duration(seconds: 2));
                      loginForm.isLoading = false;
                      Navigator.pushReplacementNamed(context, 'home');
                    },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              disabledColor: Colors.grey,
              elevation: 0,
              color: Colors.deepPurple,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                child: Text(
                  loginForm.isLoading ? 'Wait' : 'Login',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

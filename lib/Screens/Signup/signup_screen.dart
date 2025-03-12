import 'package:flutter/material.dart';
import 'package:measuremate/constants.dart';
import 'package:measuremate/responsive.dart';
import '../../components/background.dart';
import 'components/sign_up_top_image.dart';
import 'components/signup_form.dart';
import 'components/socal_sign_up.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: Responsive(
          mobile: MobileSignupScreen(
            usernameController: _usernameController,
            emailController: _emailController,
            passwordController: _passwordController,
          ),
          desktop: Row(
            children: [
              const Expanded(
                child: SignUpScreenTopImage(),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 450,
                      child: SignUpForm(
                        usernameController: _usernameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                      ),
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    const SocalSignUp(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MobileSignupScreen extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const MobileSignupScreen({
    Key? key,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SignUpScreenTopImage(),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: SignUpForm(
                usernameController: usernameController,
                emailController: emailController,
                passwordController: passwordController,
              ),
            ),
            const Spacer(),
          ],
        ),
      ],
    );
  }
}

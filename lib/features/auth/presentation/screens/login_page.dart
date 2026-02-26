import 'package:arsys/features/auth/application/auth_provider.dart';
import 'package:arsys/features/staff/presentation/home_page.dart';
import 'package:arsys/features/student/presentation/screens/student_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  Future<String?> _loginUser(LoginData data, WidgetRef ref) async {
    final authService = ref.read(authServiceProvider);
    final error = await authService.login(data.name, data.password);

    if (error == null) {
      // update auth token notifier
      ref.read(authTokenProvider.notifier).setToken(authService.token);
      return null;
    } else {
      return error;
    }
  }

  Future<String?> _recoverPassword(String name) {
    // This is not used but required by the package.
    return Future.value(null);
  }

  Future<String?> _signupUser(SignupData data) {
    // This is not used but required by the package.
    return Future.value(null);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FlutterLogin(
      title: 'ArSys',
      onLogin: (data) => _loginUser(data, ref),
      onSignup: _signupUser,
      onRecoverPassword: _recoverPassword,
      hideForgotPasswordButton: true,
      theme: LoginTheme(
        switchAuthTextColor: Colors.transparent,
      ),
      loginProviders: [
        LoginProvider(
          icon: FontAwesomeIcons.google,
          callback: () {
            // TODO: Implement Google Sign-In
            return Future.value('Google Sign-In is not implemented yet.');
          },
        ),
      ],
      onSubmitAnimationCompleted: () {
        final userRole = ref.read(userRoleProvider);

        if (userRole == 'staff') {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const HomePage(),
          ));
        } else if (userRole == 'student') {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const StudentHomePage(),
          ));
        } else {
          // Fallback to staff home page for now
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const HomePage(),
          ));
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cricket/controllers/controllers.dart';
import 'package:cricket/screens/screens.dart';
import 'package:cricket/ui/ui.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginController(),
      child: const _LoginScreenContent(),
    );
  }
}

class _LoginScreenContent extends StatelessWidget {
  const _LoginScreenContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LoginController>();
    final formKey = GlobalKey<FormState>();

    return ApiHandleUiWidget(
      apiCallStatus: controller.apiStatus,
      successWidget: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 48),
                    _buildLoginCard(context, controller),
                    const SizedBox(height: 24),
                    _buildLoginButton(context, formKey, controller),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Image.asset(
          'assets/logo.png',
          height: 200,
        ),
        const SizedBox(height: 20),
        Text(
          'Welcome Back!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Please sign in to continue',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context, LoginController controller) {
    return Card(
      elevation: 0,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildEmailField(controller),
            const SizedBox(height: 16),
            _buildPasswordField(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField(LoginController controller) {
    return TextFormField(
      controller: controller.emailController,
      decoration: InputDecoration(
        labelText: 'Username',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your username';
        }
        return null;
      },
      onSaved: controller.setEmail,
    );
  }

  Widget _buildPasswordField(BuildContext context, LoginController controller) {
    return TextFormField(
      controller: controller.passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            controller.obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: controller.togglePasswordVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      obscureText: controller.obscurePassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
      onSaved: controller.setPassword,
    );
  }

  Widget _buildLoginButton(BuildContext context, GlobalKey<FormState> formKey,
      LoginController controller) {
    return FilledButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          final result = await controller.login();
          if (result.success) {
            Navigator.pushReplacement(
              context,
              FadePageRoute(
                page: HomeScreen(initialUser: result.user!),
              ),
            );
          } else {
            showCustomSnackBar(context, result.message, false);
          }
        }
      },
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Sign In',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

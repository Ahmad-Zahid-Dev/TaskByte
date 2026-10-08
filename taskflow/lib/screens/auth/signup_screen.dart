import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/social_button.dart';
import '../../widgets/logo_tile.dart';
import '../../widgets/confetti_dots.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signUp(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) return;
    if (ok) {
      context.go(AppRoutes.home);
    } else {
      _showError(auth.error ?? AppStrings.genericError);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select((AuthProvider p) => p.loading);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const ConfettiDots(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
                    const Hero(tag: 'logo_tile', child: LogoTile(size: 80)),
                    const SizedBox(height: 32),
                    Text(
                          AppStrings.letsGetStarted,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                        )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 32),
                    AppTextField(
                      controller: _emailCtrl,
                      label: AppStrings.emailAddress,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                      showValidTick: true,
                      onChanged: (_) => setState(() {}),
                    ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _passCtrl,
                      label: AppStrings.password,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: Validators.password,
                    ).animate().fadeIn(delay: 150.ms, duration: 300.ms),
                    const SizedBox(height: 24),
                    AppButton(
                      label: AppStrings.signUp,
                      onPressed: _submit,
                      loading: loading,
                    ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
                    const SizedBox(height: 24),
                    _Divider(label: AppStrings.orSignUpWith),
                    const SizedBox(height: 20),
                    SocialButton(
                      label: AppStrings.continueWithGoogle,
                      logoAsset: const GoogleLogo(),
                      onPressed: () async {
                        final auth = context.read<AuthProvider>();
                        final router = GoRouter.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        final ok = await auth.signInWithGoogle();
                        if (!mounted) return;
                        if (ok) {
                          router.go(AppRoutes.home);
                        } else if (auth.error != null) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(auth.error!),
                              backgroundColor: AppColors.danger,
                            ),
                          );
                        }
                      },
                    ).animate().fadeIn(delay: 250.ms, duration: 300.ms),
                    const SizedBox(height: 32),
                    _Footer(
                      text: AppStrings.alreadyHaveAccount,
                      linkText: AppStrings.logIn,
                      onTap: () => context.go(AppRoutes.login),
                    ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.textSecondary, thickness: 0.4),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.textSecondary, thickness: 0.4),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.text,
    required this.linkText,
    required this.onTap,
  });

  final String text;
  final String linkText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$text ',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

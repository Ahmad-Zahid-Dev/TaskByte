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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
    final ok = await auth.signIn(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) return;
    if (ok) {
      context.go(AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? AppStrings.genericError),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _showForgotPassword() {
    showDialog<void>(
      context: context,
      builder: (_) => const _ForgotPasswordDialog(),
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
                          AppStrings.welcomeBack,
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
                      suffixIcon: TextButton(
                        onPressed: _showForgotPassword,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text(
                          AppStrings.forgotPassword,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 150.ms, duration: 300.ms),
                    const SizedBox(height: 24),
                    AppButton(
                      label: AppStrings.logIn,
                      onPressed: _submit,
                      loading: loading,
                    ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
                    const SizedBox(height: 24),
                    _Divider(label: AppStrings.orLogInWith),
                    const SizedBox(height: 20),
                    SocialButton(
                      label: AppStrings.continueWithGoogle,
                      logoAsset: const GoogleLogo(),
                      onPressed: () async {
                        final auth = context.read<AuthProvider>();
                        final ok = await auth.signInWithGoogle();
                        if (!context.mounted) return;
                        if (ok) {
                          context.go(AppRoutes.home);
                        } else if (auth.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
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
                      text: AppStrings.noAccount,
                      linkText: AppStrings.getStarted,
                      onTap: () => context.go(AppRoutes.signup),
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

class _ForgotPasswordDialog extends StatefulWidget {
  const _ForgotPasswordDialog();

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (Validators.email(_ctrl.text) != null) return;
    setState(() => _loading = true);
    await context.read<AuthProvider>().sendPasswordReset(_ctrl.text.trim());
    if (!mounted) return;
    setState(() {
      _loading = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        AppStrings.resetPassword,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
      ),
      content: _sent
          ? const Text(
              AppStrings.resetLinkSent,
              style: TextStyle(color: AppColors.green),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  AppStrings.resetPasswordSub,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _ctrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: AppStrings.emailAddress,
                  ),
                ),
              ],
            ),
      actions: [
        if (!_sent)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        if (!_sent)
          AppButton(
            label: AppStrings.sendResetLink,
            onPressed: _send,
            loading: _loading,
          )
        else
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
      ],
    );
  }
}

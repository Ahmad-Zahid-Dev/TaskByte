import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/ui_feedback.dart';
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
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
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
      fullName: _nameCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      context.go(AppRoutes.home);
    } else {
      UiFeedback.showSnackBar(
        context,
        title: 'Sign Up Failed',
        message: auth.error ?? AppStrings.genericError,
        isError: true,
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.signInWithGoogle();
    if (!mounted) return;
    if (ok) {
      context.go(AppRoutes.home);
    } else if (auth.error != null) {
      UiFeedback.showSnackBar(
        context,
        title: 'Google Sign In',
        message: auth.error!,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select((AuthProvider p) => p.loading);
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.width < 500;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const ConfettiDots(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 20 : 32,
                  vertical: 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFFE9EBF5),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.textPrimary.withValues(
                              alpha: 0.05,
                            ),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 22 : 32,
                        vertical: isCompact ? 28 : 36,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child:
                                  const Hero(
                                    tag: 'logo_tile',
                                    child: LogoTile(size: 76),
                                  ).animate().scale(
                                    duration: 400.ms,
                                    curve: Curves.easeOutBack,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                                  AppStrings.letsGetStarted,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                        letterSpacing: -0.5,
                                      ),
                                )
                                .animate()
                                .fadeIn(duration: 300.ms)
                                .slideY(begin: 0.2, end: 0),
                            const SizedBox(height: 6),
                            const Text(
                              'Create an account to start managing gig projects',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ).animate().fadeIn(delay: 50.ms, duration: 300.ms),
                            const SizedBox(height: 28),
                            AppTextField(
                              controller: _nameCtrl,
                              label: 'Full Name',
                              hint: 'e.g. Ahmad Zahid',
                              prefixIcon: const Icon(
                                Icons.person_outline_rounded,
                              ),
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter your full name';
                                }
                                if (val.trim().length < 2) {
                                  return 'Name must be at least 2 characters';
                                }
                                return null;
                              },
                            ).animate().fadeIn(delay: 50.ms, duration: 300.ms),
                            const SizedBox(height: 18),
                            AppTextField(
                              controller: _emailCtrl,
                              label: AppStrings.emailAddress,
                              hint: 'name@example.com',
                              prefixIcon: const Icon(
                                Icons.alternate_email_rounded,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: Validators.email,
                              showValidTick: true,
                              onChanged: (_) => setState(() {}),
                            ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                            const SizedBox(height: 18),
                            AppTextField(
                              controller: _passCtrl,
                              label: AppStrings.password,
                              hint: 'At least 6 characters',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
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
                            const SizedBox(height: 22),
                            _Divider(label: AppStrings.orSignUpWith),
                            const SizedBox(height: 20),
                            SocialButton(
                              label: AppStrings.continueWithGoogle,
                              logoAsset: const GoogleLogo(),
                              onPressed: _handleGoogleSignIn,
                            ).animate().fadeIn(delay: 250.ms, duration: 300.ms),
                            const SizedBox(height: 28),
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
        const Expanded(child: Divider(color: Color(0xFFE4E6F0), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE4E6F0), thickness: 1)),
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
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    );
  }
}

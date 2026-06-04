import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:level_bot/core/extensions/context_extensions.dart';
import 'package:level_bot/core/router/app_router.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/core/utils/validators.dart';
import 'package:level_bot/presentation/providers/auth_provider.dart';
import 'package:level_bot/presentation/widgets/common/app_button.dart';
import 'package:level_bot/presentation/widgets/common/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final error = await ref.read(authNotifierProvider.notifier).signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      context.showErrorSnackBar(error);
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    final error =
        await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      context.showErrorSnackBar(error);
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    final error =
        await ref.read(authNotifierProvider.notifier).signInWithApple();
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      context.showErrorSnackBar(error);
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildForm(),
              const SizedBox(height: 24),
              _buildSocialDivider(),
              const SizedBox(height: 24),
              _buildSocialButtons(),
              const SizedBox(height: 32),
              _buildSignUpLink(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.fitness_center_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.welcomeBack,
          style: context.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.signInSubtitle,
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            controller: _emailController,
            label: l10n.emailLabel,
            hint: l10n.emailPlaceholder,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: Validators.validateEmail,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _passwordController,
            label: l10n.passwordLabel,
            hint: l10n.passwordPlaceholder,
            obscureText: _obscurePassword,
            prefixIcon: Icons.lock_outline_rounded,
            suffixIcon: _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            onSuffixTap: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            validator: (v) => v == null || v.isEmpty ? l10n.passwordRequired : null,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _signInWithEmail(),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push(AppRoutes.forgotPassword),
              child: Text(l10n.forgotPasswordQuestion),
            ),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: l10n.signIn,
            onPressed: _signInWithEmail,
            isLoading: _isLoading,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialDivider() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.orContinueWith,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            label: 'Google',
            icon: Icons.g_mobiledata_rounded,
            onPressed: _signInWithGoogle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SocialButton(
            label: 'Apple',
            icon: Icons.apple,
            onPressed: _signInWithApple,
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpLink() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${l10n.dontHaveAccount} ',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        GestureDetector(
          onTap: () => context.push(AppRoutes.register),
          child: Text(
            l10n.signUp,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

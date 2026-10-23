import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../shared/models/user_profile.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../gym/data/gym_controller.dart';
import '../../../core/routing/app_router.dart' show myGymProvider;

class AcceptInvitePage extends ConsumerStatefulWidget {
  const AcceptInvitePage({super.key});

  @override
  ConsumerState<AcceptInvitePage> createState() => _AcceptInvitePageState();
}

class _AcceptInvitePageState extends ConsumerState<AcceptInvitePage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    final profile = UserProfile(
      uid: user.uid,
      displayName: user.displayName ?? 'Usuário',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await ref.read(inviteControllerProvider.notifier).acceptInvite(
        code: _codeController.text.trim(),
        user: profile,
      );
      
      if (mounted) {
        ref.invalidate(myGymProvider);
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) context.go(Routes.studentHome); // O router vai corrigir se for professor
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inviteControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Aceitar Convite')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.mark_email_read, size: 48, color: AppColors.primary),
                    const SizedBox(height: 8),
                    const Text('Junte-se à sua academia', style: AppTextStyles.headline2, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    const Text('Digite o código de 6 caracteres fornecido pelo administrador.', style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    AppTextField(
                      controller: _codeController,
                      label: 'Código do Convite',
                      hint: 'Ex.: A1B2C3',
                      validator: (v) {
                        if (v == null || v.trim().length != 6) return 'O código deve ter 6 caracteres.';
                        return null;
                      },
                      prefixIcon: const Icon(Icons.vpn_key),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Entrar na academia'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}



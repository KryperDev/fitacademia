import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'auth_controller.dart';

class NoGymPage extends ConsumerWidget {
  const NoGymPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitAcademia'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.hourglass_top, size: 40, color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  const Text('Aguardando vínculo com academia', style: AppTextStyles.headline2, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  const Text('Sua conta está criada. Peça um convite ao administrador ou crie sua própria academia.', style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => context.go(Routes.createGym),
                    icon: const Icon(Icons.add_business),
                    label: const Text('Criar minha academia'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.go(Routes.acceptInvite),
                    icon: const Icon(Icons.vpn_key),
                    label: const Text('Tenho um convite'),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () async {
                      await ref.read(authControllerProvider.notifier).signOut();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sair'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

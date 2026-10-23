import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'admin_scaffold.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    

    return AdminScaffold(
      title: 'Painel da Academia',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.dashboard, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text('Bem-vindo, Administrador!', style: AppTextStyles.headline2),
            const SizedBox(height: 8),
            const Text('Use o menu lateral para gerenciar os membros.', style: AppTextStyles.bodySecondary),
          ],
        ),
      ),
    );
  }
}


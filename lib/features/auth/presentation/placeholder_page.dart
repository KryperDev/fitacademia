import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/empty_state.dart';

class PlaceholderPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<Widget> actions;

  const PlaceholderPage({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.construction,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: EmptyState(
              icon: icon,
              title: title,
              description: description,
            ),
          ),
        ),
      ),
    );
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: EmptyState(
          icon: Icons.explore_off_outlined,
          title: 'Página não encontrada',
          description: 'A rota que você tentou acessar não existe.',
          actionLabel: 'Voltar ao início',
          onAction: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

/// Pequeno container usado nas páginas placeholder para indicar o papel previsto.
class RoleBadge extends StatelessWidget {
  final String label;
  final Color color;

  const RoleBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Widget auxiliar para exibir a rota atual (útil durante o desenvolvimento).
class RouteDebugChip extends StatelessWidget {
  final String route;

  const RouteDebugChip({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        route,
        style: AppTextStyles.caption.copyWith(
          fontFamily: 'monospace',
          color: AppColors.primaryLight,
        ),
      ),
    );
  }
}

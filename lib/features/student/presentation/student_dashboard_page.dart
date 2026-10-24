import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/routing/app_router.dart' show sessionProvider;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/student_controller.dart';
import 'workout_execution_page.dart';
import 'history_page.dart';

class StudentDashboardPage extends ConsumerWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final gymId = session.gymId ?? '';
    final studentUid = session.user?.uid ?? '';

    final activePlanAsync = ref.watch(activePlanProvider((gymId: gymId, studentUid: studentUid)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Treino'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Histórico',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: activePlanAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro: $e')),
            data: (plan) {
              if (plan == null) {
                return const Center(
                  child: Text('Você ainda não tem uma ficha de treino publicada.\nFale com seu professor.'),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Treino Atual', style: AppTextStyles.headline2),
                  const SizedBox(height: 16),
                  Card(
                    color: AppColors.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plan.name, style: AppTextStyles.headline3),
                          const SizedBox(height: 8),
                          Text('${plan.exercises.length} exercícios', style: AppTextStyles.caption),
                          const SizedBox(height: 16),
                          ...plan.exercises.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.fitness_center, size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(child: Text(e.name, style: AppTextStyles.body)),
                                Text('${e.sets}x${e.repsMin}-${e.repsMax}', style: AppTextStyles.caption),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkoutExecutionPage(plan: plan),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar Treino'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}


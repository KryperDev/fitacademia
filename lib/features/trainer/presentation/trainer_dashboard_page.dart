import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/routing/app_router.dart' show sessionProvider;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../gym/data/gym_controller.dart';
import '../data/workout_controller.dart';
import 'plan_editor_page.dart';

class TrainerDashboardPage extends ConsumerWidget {
  const TrainerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final gymId = session.gymId ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Área do professor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Meus alunos', style: AppTextStyles.headline2),
              const SizedBox(height: 8),
              const Text(
                'Selecione um aluno para criar ou editar a ficha de treino.',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ref.watch(membersStreamProvider(gymId)).when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Erro: $e')),
                  data: (members) {
                    final students = members
                        .where((m) => m.role.firestoreValue == 'student')
                        .toList();
                    if (students.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhum aluno vinculado ainda.\n'
                          'Peça ao administrador para convidar alunos.',
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: students.length,
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                            child: Text(
                              student.displayName.isNotEmpty
                                  ? student.displayName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(student.displayName),
                          subtitle: const Text('Ver fichas'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _StudentPlansPage(
                                  studentUid: student.uid,
                                  studentName: student.displayName,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentPlansPage extends ConsumerWidget {
  final String studentUid;
  final String studentName;

  const _StudentPlansPage({required this.studentUid, required this.studentName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final gymId = session.gymId ?? '';
    final plansAsync = ref.watch(
      studentPlansProvider((gymId: gymId, studentUid: studentUid)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Fichas de $studentName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlanEditorPage(
                    studentUid: studentUid,
                    studentName: studentName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (plans) {
          if (plans.isEmpty) {
            return const Center(
              child: Text('Nenhuma ficha criada para este aluno.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final plan = plans[index];
              return Card(
                child: ListTile(
                  title: Text(plan.name),
                  subtitle: Text(
                    'Versão ${plan.version} • ${plan.status} • '
                    '${plan.exercises.length} exercícios',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlanEditorPage(existingPlan: plan),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

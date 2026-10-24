import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/routing/app_router.dart' show sessionProvider;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/workout_session.dart';
import '../data/student_controller.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final gymId = session.gymId ?? '';
    final studentUid = session.user?.uid ?? '';

    final historyAsync = ref.watch(sessionHistoryProvider((gymId: gymId, studentUid: studentUid)));

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Histórico')),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(child: Text('Você ainda não concluiu nenhum treino.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final s = sessions[index];
              final dateStr = s.completedAt != null 
                  ? DateFormat('dd/MM/yyyy HH:mm').format(s.completedAt!) 
                  : 'Data desconhecida';
              
              final totalSets = s.exercises.fold<int>(0, (sum, ex) => sum + ex.loggedSets.length);
              final durationMin = (s.durationSeconds ?? 0) ~/ 60;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text('Treino: ${s.planId.substring(0, 5)}...'), // Simplificado
                  subtitle: Text('$dateStr\nDuração: $durationMin min • $totalSets séries'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showSessionDetails(context, s);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showSessionDetails(BuildContext context, WorkoutSession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Detalhes do Treino', style: AppTextStyles.headline2),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: session.exercises.length,
                      itemBuilder: (context, index) {
                        final ex = session.exercises[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ex.name, style: AppTextStyles.headline3),
                              const SizedBox(height: 4),
                              ...ex.loggedSets.map((s) => Text(
                                'Série ${s.setNumber}: ${s.weight} kg × ${s.reps} reps',
                                style: AppTextStyles.bodySecondary,
                              )),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

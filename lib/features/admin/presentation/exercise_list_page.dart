import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/routing/app_router.dart' show sessionProvider;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/exercise.dart';
import '../../gym/data/exercise_controller.dart';
import 'exercise_form_page.dart';

class ExerciseListPage extends ConsumerStatefulWidget {
  const ExerciseListPage({super.key});

  @override
  ConsumerState<ExerciseListPage> createState() => _ExerciseListPageState();
}

class _ExerciseListPageState extends ConsumerState<ExerciseListPage> {
  String _search = '';
  String? _muscleFilter;
  bool _seeding = false;

  Future<void> _seedDefaultExercises(String gymId) async {
    setState(() => _seeding = true);
    final repo = ref.read(exerciseRepositoryProvider);
    
    final defaults = [
      {'name': 'Supino Reto com Barra', 'muscleGroups': ['Peito', 'Tríceps'], 'equipment': 'Barra'},
      {'name': 'Supino Inclinado com Halteres', 'muscleGroups': ['Peito', 'Ombro'], 'equipment': 'Halteres'},
      {'name': 'Crucifixo na Máquina', 'muscleGroups': ['Peito'], 'equipment': 'Máquina'},
      {'name': 'Flexão de Braço', 'muscleGroups': ['Peito', 'Tríceps'], 'equipment': 'Peso Corporal'},
      {'name': 'Puxada Frontal', 'muscleGroups': ['Costas', 'Bíceps'], 'equipment': 'Polia'},
      {'name': 'Remada Baixa', 'muscleGroups': ['Costas'], 'equipment': 'Polia'},
      {'name': 'Remada Curvada', 'muscleGroups': ['Costas', 'Bíceps'], 'equipment': 'Barra'},
      {'name': 'Barra Fixa', 'muscleGroups': ['Costas', 'Bíceps'], 'equipment': 'Peso Corporal'},
      {'name': 'Levantamento Terra', 'muscleGroups': ['Costas', 'Pernas'], 'equipment': 'Barra'},
      {'name': 'Agachamento Livre', 'muscleGroups': ['Quadríceps', 'Glúteos'], 'equipment': 'Barra'},
      {'name': 'Leg Press 45°', 'muscleGroups': ['Quadríceps', 'Glúteos'], 'equipment': 'Máquina'},
      {'name': 'Cadeira Extensora', 'muscleGroups': ['Quadríceps'], 'equipment': 'Máquina'},
      {'name': 'Cadeira Flexora', 'muscleGroups': ['Posterior de Coxa'], 'equipment': 'Máquina'},
      {'name': 'Stiff', 'muscleGroups': ['Posterior de Coxa', 'Glúteos'], 'equipment': 'Barra'},
      {'name': 'Panturrilha em Pé', 'muscleGroups': ['Panturrilha'], 'equipment': 'Máquina'},
      {'name': 'Desenvolvimento Militar', 'muscleGroups': ['Ombro', 'Tríceps'], 'equipment': 'Barra'},
      {'name': 'Elevação Lateral', 'muscleGroups': ['Ombro'], 'equipment': 'Halteres'},
      {'name': 'Elevação Frontal', 'muscleGroups': ['Ombro'], 'equipment': 'Halteres'},
      {'name': 'Remada Alta', 'muscleGroups': ['Ombro', 'Trapézio'], 'equipment': 'Barra'},
      {'name': 'Rosca Direta', 'muscleGroups': ['Bíceps'], 'equipment': 'Barra'},
      {'name': 'Rosca Alternada', 'muscleGroups': ['Bíceps'], 'equipment': 'Halteres'},
      {'name': 'Rosca Martelo', 'muscleGroups': ['Bíceps', 'Antebraço'], 'equipment': 'Halteres'},
      {'name': 'Tríceps Testa', 'muscleGroups': ['Tríceps'], 'equipment': 'Barra'},
      {'name': 'Tríceps Corda', 'muscleGroups': ['Tríceps'], 'equipment': 'Polia'},
      {'name': 'Mergulho em Paralelas', 'muscleGroups': ['Tríceps', 'Peito'], 'equipment': 'Peso Corporal'},
      {'name': 'Abdominal Crunch', 'muscleGroups': ['Abdômen'], 'equipment': 'Peso Corporal'},
      {'name': 'Prancha Isométrica', 'muscleGroups': ['Abdômen'], 'equipment': 'Peso Corporal'},
      {'name': 'Elevação de Pernas', 'muscleGroups': ['Abdômen'], 'equipment': 'Peso Corporal'},
      {'name': 'Esteira', 'muscleGroups': ['Cardio'], 'equipment': 'Máquina'},
      {'name': 'Bicicleta Ergométrica', 'muscleGroups': ['Cardio'], 'equipment': 'Máquina'},
    ];

    try {
      for (final ex in defaults) {
        final exercise = Exercise(
          id: '',
          name: ex['name'] as String,
          muscleGroups: (ex['muscleGroups'] as List).cast<String>(),
          equipment: ex['equipment'] as String,
          description: 'Exercício padrão de academia.',
          instructions: 'Execute com boa postura.',
          active: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repo.createExercise(gymId: gymId, exercise: exercise);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('30 exercícios padrão criados!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _seeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final gymId = session.gymId ?? '';
    final exercisesAsync = ref.watch(exercisesStreamProvider(gymId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercícios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Novo exercício',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExerciseFormPage(gymId: gymId),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar exercício...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
                const SizedBox(height: 12),
                if (exercisesAsync.value?.isEmpty ?? false)
                  ElevatedButton.icon(
                    onPressed: _seeding ? null : () => _seedDefaultExercises(gymId),
                    icon: _seeding 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.download),
                    label: Text(_seeding ? 'Criando exercícios...' : 'Gerar 30 exercícios padrão'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
          if (_muscleFilter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text(_muscleFilter!),
                  onDeleted: () => setState(() => _muscleFilter = null),
                ),
              ),
            ),
          Expanded(
            child: exercisesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (exercises) {
                final filtered = exercises.where((e) {
                  final matchSearch = _search.isEmpty ||
                      e.name.toLowerCase().contains(_search.toLowerCase());
                  final matchMuscle = _muscleFilter == null ||
                      e.muscleGroups.contains(_muscleFilter);
                  return matchSearch && matchMuscle;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('Nenhum exercício encontrado.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final exercise = filtered[index];
                    return Card(
                      child: ListTile(
                        title: Text(exercise.name, style: AppTextStyles.body),
                        subtitle: Text(
                          exercise.muscleGroups.isNotEmpty
                              ? exercise.muscleGroups.join(', ')
                              : exercise.equipment,
                          style: AppTextStyles.caption,
                        ),
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.surfaceElevated,
                          child: Icon(Icons.fitness_center, color: AppColors.primary),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExerciseFormPage(
                                gymId: gymId,
                                exercise: exercise,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
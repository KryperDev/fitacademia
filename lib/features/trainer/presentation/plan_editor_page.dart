import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/routing/app_router.dart' show sessionProvider;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/exercise.dart';
import '../../../shared/models/workout_plan.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../gym/data/exercise_controller.dart';
import '../data/workout_controller.dart';

class PlanEditorPage extends ConsumerStatefulWidget {
  final WorkoutPlan? existingPlan;
  final String? studentUid;
  final String? studentName;

  const PlanEditorPage({
    super.key,
    this.existingPlan,
    this.studentUid,
    this.studentName,
  });

  @override
  ConsumerState<PlanEditorPage> createState() => _PlanEditorPageState();
}

class _PlanEditorPageState extends ConsumerState<PlanEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final List<WorkoutExercise> _exercises = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingPlan?.name ?? 'Treino A',
    );
    if (widget.existingPlan != null) {
      _exercises.addAll(widget.existingPlan!.exercises);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addExercise() async {
    final session = ref.read(sessionProvider);
    final gymId = session.gymId!;

    final exercise = await showDialog<Exercise>(
      context: context,
      builder: (_) => _ExercisePickerDialog(gymId: gymId),
    );

    if (exercise != null) {
      setState(() {
        _exercises.add(WorkoutExercise(
          exerciseId: exercise.id,
          name: exercise.name,
          sets: 3,
          repsMin: 8,
          repsMax: 12,
          restSeconds: 60,
        ));
      });
    }
  }

  Future<void> _save({required bool publish}) async {
    if (!_formKey.currentState!.validate()) return;
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos 1 exercício.')),
      );
      return;
    }

    setState(() => _loading = true);

    final session = ref.read(sessionProvider);
    final gymId = session.gymId!;
    final user = session.user;
    if (user == null) return;

    final repo = ref.read(workoutRepositoryProvider);

    final plan = WorkoutPlan(
      id: widget.existingPlan?.id ?? '',
      name: _nameController.text.trim(),
      studentUid: widget.existingPlan?.studentUid ?? widget.studentUid!,
      createdBy: widget.existingPlan?.createdBy ?? user.uid,
      version: widget.existingPlan?.version ?? 1,
      status: publish ? 'published' : 'draft',
      exercises: _exercises,
      createdAt: widget.existingPlan?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      publishedAt: publish ? DateTime.now() : widget.existingPlan?.publishedAt,
    );

    try {
      if (widget.existingPlan != null) {
        await repo.updatePlan(gymId: gymId, planId: plan.id, plan: plan);
      } else {
        await repo.savePlan(gymId: gymId, plan: plan);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingPlan == null ? 'Nova ficha' : 'Editar ficha'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Nome da ficha',
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 16),
            const Text('Exercícios', style: AppTextStyles.headline3),
            const SizedBox(height: 8),
            if (_exercises.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Nenhum exercício adicionado ainda.'),
              ),
            ..._exercises.asMap().entries.map((entry) {
              final i = entry.key;
              final ex = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(ex.name, style: AppTextStyles.body),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _editExercise(i),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: AppColors.error),
                            onPressed: () => setState(() => _exercises.removeAt(i)),
                          ),
                        ],
                      ),
                      Text(
                        '${ex.sets} séries • ${ex.repsMin}-${ex.repsMax} reps • ${ex.restSeconds}s descanso',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _addExercise,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar exercício'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _loading ? null : () => _save(publish: false),
                    child: const Text('Salvar rascunho'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : () => _save(publish: true),
                    child: _loading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Publicar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editExercise(int index) async {
    final ex = _exercises[index];
    final result = await showDialog<WorkoutExercise>(
      context: context,
      builder: (_) => _EditExerciseDialog(exercise: ex),
    );
    if (result != null) {
      setState(() => _exercises[index] = result);
    }
  }
}

class _ExercisePickerDialog extends ConsumerWidget {
  final String gymId;
  const _ExercisePickerDialog({required this.gymId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(exercisesStreamProvider(gymId));
    return AlertDialog(
      title: const Text('Escolher exercício'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: exercisesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Erro: $e'),
          data: (exercises) {
            if (exercises.isEmpty) {
              return const Center(
                child: Text('Nenhum exercício cadastrado.\nCrie um na biblioteca.'),
              );
            }
            return ListView(
              children: exercises
                  .map((e) => ListTile(
                        title: Text(e.name),
                        subtitle: Text(e.muscleGroups.join(', ')),
                        onTap: () => Navigator.pop(context, e),
                      ))
                  .toList(),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

class _EditExerciseDialog extends StatefulWidget {
  final WorkoutExercise exercise;
  const _EditExerciseDialog({required this.exercise});

  @override
  State<_EditExerciseDialog> createState() => _EditExerciseDialogState();
}

class _EditExerciseDialogState extends State<_EditExerciseDialog> {
  late int _sets;
  late int _repsMin;
  late int _repsMax;
  late int _rest;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _sets = widget.exercise.sets;
    _repsMin = widget.exercise.repsMin;
    _repsMax = widget.exercise.repsMax;
    _rest = widget.exercise.restSeconds;
    _notesController = TextEditingController(text: widget.exercise.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.exercise.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _numberRow('Séries', _sets, (v) => setState(() => _sets = v)),
            _numberRow('Reps mín.', _repsMin, (v) => setState(() => _repsMin = v)),
            _numberRow('Reps máx.', _repsMax, (v) => setState(() => _repsMax = v)),
            _numberRow('Descanso (s)', _rest, (v) => setState(() => _rest = v)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Observações'),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              widget.exercise.copyWith(
                sets: _sets,
                repsMin: _repsMin,
                repsMax: _repsMax,
                restSeconds: _rest,
                notes: _notesController.text.trim(),
              ),
            );
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  Widget _numberRow(String label, int value, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
          ),
          Text('$value',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/routing/app_router.dart' show sessionProvider;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/workout_plan.dart';
import '../../../shared/models/workout_session.dart';
import '../data/student_controller.dart';

class WorkoutExecutionPage extends ConsumerStatefulWidget {
  final WorkoutPlan plan;

  const WorkoutExecutionPage({super.key, required this.plan});

  @override
  ConsumerState<WorkoutExecutionPage> createState() => _WorkoutExecutionPageState();
}

class _WorkoutExecutionPageState extends ConsumerState<WorkoutExecutionPage> {
  late DateTime _startedAt;
  final List<ExerciseSession> _exercises = [];
  
  // Timer state
  Timer? _timer;
  int _restSecondsLeft = 0;
  bool _isResting = false;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    // Copia a ficha para a sessão
    for (final ex in widget.plan.exercises) {
      _exercises.add(ExerciseSession(
        exerciseId: ex.exerciseId,
        name: ex.name,
        targetSets: ex.sets,
        targetRepsMin: ex.repsMin,
        targetRepsMax: ex.repsMax,
        restSeconds: ex.restSeconds,
        notes: ex.notes,
      ));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRestTimer(int seconds) {
    _timer?.cancel();
    setState(() {
      _restSecondsLeft = seconds;
      _isResting = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsLeft > 1) {
        setState(() => _restSecondsLeft--);
      } else {
        timer.cancel();
        setState(() => _isResting = false);
      }
    });
  }

  void _addSet(int exerciseIndex, double weight, int reps) {
    final ex = _exercises[exerciseIndex];
    final newSet = LoggedSet(
      setNumber: ex.loggedSets.length + 1,
      weight: weight,
      reps: reps,
    );
    setState(() {
      _exercises[exerciseIndex] = ExerciseSession(
        exerciseId: ex.exerciseId,
        name: ex.name,
        targetSets: ex.targetSets,
        targetRepsMin: ex.targetRepsMin,
        targetRepsMax: ex.targetRepsMax,
        restSeconds: ex.restSeconds,
        notes: ex.notes,
        loggedSets: [...ex.loggedSets, newSet],
      );
    });
    if (ex.loggedSets.length + 1 < ex.targetSets) {
      _startRestTimer(ex.restSeconds);
    }
  }

  Future<void> _finishWorkout() async {
    if (_exercises.every((e) => e.loggedSets.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registre pelo menos uma série antes de finalizar.')),
      );
      return;
    }

    final session = ref.read(sessionProvider);
    final gymId = session.gymId ?? '';
    final user = session.user;
    if (user == null) return;

    final duration = DateTime.now().difference(_startedAt);

    final workoutSession = WorkoutSession(
      id: '',
      studentUid: user.uid,
      assignmentId: '', // Não temos assignment ainda, mas mantemos o campo
      planId: widget.plan.id,
      planVersion: widget.plan.version,
      status: 'completed',
      startedAt: _startedAt,
      completedAt: DateTime.now(),
      durationSeconds: duration.inSeconds,
      exercises: _exercises,
    );

    try {
      await ref.read(studentRepositoryProvider).saveSession(gymId, workoutSession);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treino concluído! Bom trabalho.'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan.name),
      ),
      body: Column(
        children: [
          if (_isResting)
            Container(
              color: AppColors.primary.withValues(alpha: 0.2),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Descanso: $_restSecondsLeft s',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      _timer?.cancel();
                      setState(() => _isResting = false);
                    },
                    child: const Text('Pular'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                final ex = _exercises[index];
                final isDone = ex.loggedSets.length >= ex.targetSets;
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: isDone ? AppColors.surfaceElevated : AppColors.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(ex.name, style: AppTextStyles.headline3)),
                            if (isDone) const Icon(Icons.check_circle, color: AppColors.success),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${ex.targetSets} séries • ${ex.targetRepsMin}-${ex.targetRepsMax} reps', style: AppTextStyles.caption),
                        const SizedBox(height: 12),
                        ...ex.loggedSets.map((s) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.check, size: 16, color: AppColors.success),
                              const SizedBox(width: 8),
                              Text('Série ${s.setNumber}: ', style: AppTextStyles.body),
                              Text('${s.weight} kg × ${s.reps} reps', style: AppTextStyles.body),
                            ],
                          ),
                        )),
                        const SizedBox(height: 8),
                        if (!isDone)
                          OutlinedButton.icon(
                            onPressed: () => _showSetDialog(index),
                            icon: const Icon(Icons.add),
                            label: Text('Registrar Série ${ex.loggedSets.length + 1}'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(40),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: ElevatedButton(
              onPressed: _finishWorkout,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: AppColors.success,
              ),
              child: const Text('Finalizar Treino'),
            ),
          ),
        ],
      ),
    );
  }

  void _showSetDialog(int exerciseIndex) {
    final weightController = TextEditingController();
    final repsController = TextEditingController();
    final ex = _exercises[exerciseIndex];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Série ${ex.loggedSets.length + 1}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Peso (kg)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Repetições'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text.replaceAll(',', '.')) ?? 0.0;
              final reps = int.tryParse(repsController.text) ?? 0;
              if (weight > 0 && reps > 0) {
                Navigator.pop(context);
                _addSet(exerciseIndex, weight, reps);
              }
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }
}


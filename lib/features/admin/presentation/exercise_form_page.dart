import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/exercise.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../gym/data/exercise_controller.dart';

class ExerciseFormPage extends ConsumerStatefulWidget {
  final String gymId;
  final Exercise? exercise; // null = criar, não-nulo = editar

  const ExerciseFormPage({super.key, required this.gymId, this.exercise});

  @override
  ConsumerState<ExerciseFormPage> createState() => _ExerciseFormPageState();
}

class _ExerciseFormPageState extends ConsumerState<ExerciseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _musclesController = TextEditingController();
  final _equipmentController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _mediaUrlController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.exercise != null) {
      final e = widget.exercise!;
      _nameController.text = e.name;
      _descriptionController.text = e.description;
      _musclesController.text = e.muscleGroups.join(', ');
      _equipmentController.text = e.equipment;
      _instructionsController.text = e.instructions;
      _mediaUrlController.text = e.mediaUrl ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _musclesController.dispose();
    _equipmentController.dispose();
    _instructionsController.dispose();
    _mediaUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final muscles = _musclesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final exercise = Exercise(
      id: widget.exercise?.id ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      muscleGroups: muscles,
      equipment: _equipmentController.text.trim(),
      instructions: _instructionsController.text.trim(),
      mediaProvider: _mediaUrlController.text.isEmpty ? null : 'external',
      mediaUrl: _mediaUrlController.text.trim().isEmpty ? null : _mediaUrlController.text.trim(),
      createdAt: widget.exercise?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final repo = ref.read(exerciseRepositoryProvider);
      if (widget.exercise == null) {
        await repo.createExercise(gymId: widget.gymId, exercise: exercise);
      } else {
        await repo.updateExercise(
          gymId: widget.gymId,
          exerciseId: widget.exercise!.id,
          exercise: exercise,
        );
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
    final isEditing = widget.exercise != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar exercício' : 'Novo exercício'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _nameController,
                  label: 'Nome do exercício',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _musclesController,
                  label: 'Grupos musculares (separados por vírgula)',
                  hint: 'Ex.: Peito, Tríceps',
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _equipmentController,
                  label: 'Equipamento',
                  hint: 'Ex.: Halteres, Barra',
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Descrição',
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _instructionsController,
                  label: 'Instruções de execução',
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _mediaUrlController,
                  label: 'URL do vídeo (opcional)',
                  hint: 'https://youtube.com/...',
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(isEditing ? 'Salvar alterações' : 'Criar exercício'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/gym_invite.dart';
import '../../gym/data/gym_controller.dart';

class InviteMemberDialog extends ConsumerStatefulWidget {
  final String gymId;

  const InviteMemberDialog({super.key, required this.gymId});

  @override
  ConsumerState<InviteMemberDialog> createState() => _InviteMemberDialogState();
}

class _InviteMemberDialogState extends ConsumerState<InviteMemberDialog> {
  final _emailController = TextEditingController();
  String _role = 'student'; // 'student' ou 'trainer'
  GymInvite? _generatedInvite;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    try {
      final invite = await ref.read(inviteControllerProvider.notifier).createInvite(
        gymId: widget.gymId,
        email: _emailController.text.trim(),
        role: _role,
      );
      if (mounted) setState(() => _generatedInvite = invite);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inviteControllerProvider);
    final isLoading = state.isLoading;

    return AlertDialog(
      title: Text(_generatedInvite == null ? 'Convidar Membro' : 'Convite Gerado'),
      content: _generatedInvite == null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'E-mail (opcional)'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _role,
                  decoration: const InputDecoration(labelText: 'Função'),
                  items: const [
                    DropdownMenuItem(value: 'student', child: Text('Aluno')),
                    DropdownMenuItem(value: 'trainer', child: Text('Professor')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _role = v);
                  },
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Copie o código abaixo e envie para o membro:', style: AppTextStyles.bodySecondary),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _generatedInvite!.code,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: AppColors.primary),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _generatedInvite!.code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Código copiado!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
        if (_generatedInvite == null)
          ElevatedButton(
            onPressed: isLoading ? null : _generate,
            child: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Gerar'),
          ),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../gym/data/gym_controller.dart';
import 'invite_member_dialog.dart';

class MembersPage extends ConsumerWidget {
  final String gymId;

  const MembersPage({super.key, required this.gymId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersStreamProvider(gymId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Membros da Academia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Convidar Membro',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => InviteMemberDialog(gymId: gymId),
              );
            },
          ),
        ],
      ),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (members) {
          if (members.isEmpty) {
            return const Center(child: Text('Nenhum membro encontrado.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final member = members[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Text(
                    member.displayName.isNotEmpty
                        ? member.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(member.displayName, style: AppTextStyles.body),
                subtitle: Text(member.role.labelPt, style: AppTextStyles.caption),
                trailing: member.role.firestoreValue == 'admin'
                    ? const Icon(Icons.star, color: Colors.amber, size: 20)
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}



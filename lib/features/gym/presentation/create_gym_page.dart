import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/gym_controller.dart';
import '../../../core/routing/app_router.dart' show myGymProvider;

class CreateGymPage extends ConsumerStatefulWidget {
  const CreateGymPage({super.key});

  @override
  ConsumerState<CreateGymPage> createState() => _CreateGymPageState();
}

class _CreateGymPageState extends ConsumerState<CreateGymPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final user = ref.read(authStateChangesProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessão expirada. Faça login novamente.')),
      );
      return;
    }

    final owner = UserProfile(
      uid: user.uid,
      displayName: user.displayName ?? 'Administrador',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final gym = await ref.read(createGymControllerProvider.notifier).createGym(
        owner: owner,
        name: _nameController.text,
        city: _cityController.text,
        uf: _stateController.text,
      );

      if (gym != null && mounted) {
        // Invalida o myGymProvider para forçar a releitura do vínculo
        ref.invalidate(myGymProvider);
        
        // Aguarda a propagação no Firestore
        await Future.delayed(const Duration(milliseconds: 800));
        
        if (mounted) {
          context.go(Routes.gymAdminHome);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error,
            ),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(createGymControllerProvider);
    final isLoading = asyncState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Criar academia')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.storefront, size: 48, color: AppColors.primary),
                    const SizedBox(height: 8),
                    const Text('Sua academia', style: AppTextStyles.headline2, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    const Text('Esses dados podem ser alterados depois.', style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    AppTextField(
                      controller: _nameController,
                      label: 'Nome da academia',
                      hint: 'Ex.: FitAcademia Centro',
                      validator: (v) => Validators.requiredText(v, fieldName: 'nome'),
                      prefixIcon: const Icon(Icons.business),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _cityController,
                      label: 'Cidade',
                      hint: 'Ex.: São Paulo',
                      validator: (v) => Validators.requiredText(v, fieldName: 'cidade'),
                      prefixIcon: const Icon(Icons.location_city),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _stateController,
                      label: 'Estado (UF)',
                      hint: 'Ex.: SP',
                      validator: (v) {
                        if (v == null || v.trim().length != 2) {
                          return 'Informe a UF (2 letras).';
                        }
                        return null;
                      },
                      prefixIcon: const Icon(Icons.place_outlined),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Criar academia'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/admin_dashboard_page.dart';
import '../../features/admin/presentation/members_page.dart';
import '../../features/auth/presentation/accept_invite_page.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/no_gym_page.dart';
import '../../features/auth/presentation/placeholder_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/gym/data/gym_controller.dart';
import '../../features/gym/data/gym_repository.dart';
import '../../features/gym/presentation/create_gym_page.dart';
import '../theme/app_colors.dart';
import 'routes.dart';

enum SessionStatus { unknown, unauthenticated, authenticated }

class SessionState {
  final SessionStatus status;
  final User? user;
  final String? role;
  final String? gymId;
  final String? gymName;

  const SessionState({
    required this.status,
    this.user,
    this.role,
    this.gymId,
    this.gymName,
  });

  bool get isAuthenticated => status == SessionStatus.authenticated;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionState &&
        other.status == status &&
        other.user?.uid == user?.uid &&
        other.role == role &&
        other.gymId == gymId &&
        other.gymName == gymName;
  }

  @override
  int get hashCode => Object.hash(status, user?.uid, role, gymId, gymName);
}

/// Provider que busca o vínculo do usuário na coleção `user_memberships`.
/// Substitui a busca antiga via collectionGroup, eliminando a necessidade de índices complexos.
final myGymProvider = FutureProvider<MyGymMembershipData?>((ref) async {
  final authAsync = ref.watch(authStateChangesProvider);
  final user = authAsync.value;
  if (user == null) return null;

  final repo = ref.watch(gymRepositoryProvider);
  return await repo.getMembershipDirect(user.uid);
});

final sessionProvider = Provider<SessionState>((ref) {
  final authAsync = ref.watch(authStateChangesProvider);
  final user = authAsync.value;

  if (authAsync.isLoading && user == null) {
    return const SessionState(status: SessionStatus.unknown);
  }
  if (user == null) {
    return const SessionState(status: SessionStatus.unauthenticated);
  }

  final gymAsync = ref.watch(myGymProvider);

  return gymAsync.when(
    data: (gym) {
      if (gym == null) {
        return SessionState(status: SessionStatus.authenticated, user: user);
      }
      return SessionState(
        status: SessionStatus.authenticated,
        user: user,
        role: gym.role,
        gymId: gym.gymId,
        gymName: gym.gymName,
      );
    },
    loading: () => SessionState(status: SessionStatus.authenticated, user: user),
    error: (e, _) {
      debugPrint('[session] erro ao carregar gyms: $e');
      return SessionState(status: SessionStatus.authenticated, user: user);
    },
  );
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionProvider);

  final initialLocation = switch (session.status) {
    SessionStatus.unknown => Routes.splash,
    SessionStatus.unauthenticated => Routes.login,
    SessionStatus.authenticated =>
      session.role == null ? Routes.noGym : _homeForRole(session.role),
  };

  return GoRouter(
    initialLocation: initialLocation,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final location = state.matchedLocation;

      final isAuthRoute = location == Routes.login ||
          location == Routes.register ||
          location == Routes.forgotPassword;
      final isSplash = location == Routes.splash;
      final isNoGymArea = location == Routes.noGym || 
                          location == Routes.createGym ||
                          location == Routes.acceptInvite;

      if (session.status == SessionStatus.unknown) {
        return isSplash ? null : Routes.splash;
      }

      if (!session.isAuthenticated) {
        if (isSplash || isAuthRoute) return null;
        return Routes.login;
      }

      if (session.role == null) {
        if (isNoGymArea) return null;
        return Routes.noGym;
      }

      if (isSplash || isAuthRoute || isNoGymArea) {
        return _homeForRole(session.role);
      }

      if (location.startsWith('/student') && session.role != 'student') return _homeForRole(session.role);
      if (location.startsWith('/trainer') && session.role != 'trainer') return _homeForRole(session.role);
      if (location.startsWith('/gym-admin') && session.role != 'admin') return _homeForRole(session.role);

      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (context, state) => const _SplashPage()),
      GoRoute(path: Routes.login, builder: (context, state) => const LoginPage()),
      GoRoute(path: Routes.register, builder: (context, state) => const RegisterPage()),
      GoRoute(path: Routes.forgotPassword, builder: (context, state) => const ForgotPasswordPage()),
      GoRoute(path: Routes.noGym, builder: (context, state) => const NoGymPage()),
      GoRoute(path: Routes.createGym, builder: (context, state) => const CreateGymPage()),
      GoRoute(path: Routes.acceptInvite, builder: (context, state) => const AcceptInvitePage()),
      
      // ROTAS DO ADMIN
      GoRoute(path: Routes.gymAdminHome, builder: (context, state) => const AdminDashboardPage()),
      GoRoute(
        path: Routes.gymAdminMembers, 
        builder: (context, state) {
          final gymId = ref.read(sessionProvider).gymId ?? '';
          return MembersPage(gymId: gymId);
        }
      ),

      // OUTROS PLACEHOLDERS
      GoRoute(path: Routes.studentHome, builder: (context, state) => const PlaceholderPage(title: 'Área do aluno', description: 'ETAPA 7', icon: Icons.fitness_center)),
      GoRoute(path: Routes.trainerHome, builder: (context, state) => const PlaceholderPage(title: 'Área do professor', description: 'ETAPA 8', icon: Icons.school)),
      GoRoute(path: Routes.platformAdminHome, builder: (context, state) => const PlaceholderPage(title: 'Admin SaaS', description: 'ETAPA 10', icon: Icons.admin_panel_settings)),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
});

String _homeForRole(String? role) {
  switch (role) {
    case 'student': return Routes.studentHome;
    case 'trainer': return Routes.trainerHome;
    case 'admin': return Routes.gymAdminHome;
    case 'platform_admin': return Routes.platformAdminHome;
    default: return Routes.login;
  }
}

class _SplashPage extends StatelessWidget {
  const _SplashPage();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 80, height: 80, child: DecoratedBox(decoration: BoxDecoration(color: AppColors.surfaceElevated, shape: BoxShape.circle), child: Icon(Icons.fitness_center, size: 40, color: AppColors.primary))),
              SizedBox(height: 24),
              Text('FitAcademia', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
              SizedBox(height: 32),
              SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary))),
            ],
          ),
        ),
      ),
    );
  }
}
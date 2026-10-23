import 'package:flutter/foundation.dart';

/// Notifica o GoRouter para re-avaliar seus redirects quando o estado
/// de autenticação mudar. Na ETAPA 3 este será conectado ao
/// `FirebaseAuth.authStateChanges()`.
class RouterRefresh extends ChangeNotifier {
  void notify() => notifyListeners();
}

abstract final class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe seu e-mail.';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'E-mail inválido.';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Informe sua senha.';
    if (value.length < 8) return 'A senha deve ter pelo menos 8 caracteres.';
    return null;
  }

  static String? requiredText(String? value, {String fieldName = 'campo'}) {
    if (value == null || value.trim().isEmpty) return 'O $fieldName é obrigatório.';
    if (value.trim().length < 2) return 'O $fieldName deve ter pelo menos 2 caracteres.';
    return null;
  }

  static String? displayName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe seu nome.';
    if (value.trim().length < 2) return 'Nome muito curto.';
    if (value.trim().length > 80) return 'Nome muito longo (máx. 80 caracteres).';
    return null;
  }
}

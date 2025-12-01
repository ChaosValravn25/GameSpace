/// Clase de utilidades para validación de datos
class Validators {
  Validators._();

  /// Validar que un campo no esté vacío
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    return null;
  }

  /// Validar email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }

    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un email válido';
    }

    return null;
  }

  /// Validar longitud mínima
  static String? minLength(String? value, int length, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }

    if (value.length < length) {
      return '${fieldName ?? 'Este campo'} debe tener al menos $length caracteres';
    }

    return null;
  }

  /// Validar longitud máxima
  static String? maxLength(String? value, int length, {String? fieldName}) {
    if (value != null && value.length > length) {
      return '${fieldName ?? 'Este campo'} no debe exceder $length caracteres';
    }

    return null;
  }

  /// Validar rango de longitud
  static String? lengthRange(
    String? value,
    int min,
    int max, {
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }

    if (value.length < min || value.length > max) {
      return '${fieldName ?? 'Este campo'} debe tener entre $min y $max caracteres';
    }

    return null;
  }

  /// Validar número
  static String? number(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }

    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'Este campo'} debe ser un número válido';
    }

    return null;
  }

  /// Validar número entero
  static String? integer(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }

    if (int.tryParse(value) == null) {
      return '${fieldName ?? 'Este campo'} debe ser un número entero';
    }

    return null;
  }

  /// Validar rango numérico
  static String? numberRange(
    String? value,
    num min,
    num max, {
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return '${fieldName ?? 'Este campo'} debe ser un número';
    }

    if (number < min || number > max) {
      return '${fieldName ?? 'Este campo'} debe estar entre $min y $max';
    }

    return null;
  }

  /// Validar URL
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return 'La URL es requerida';
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Ingresa una URL válida';
    }

    return null;
  }

  /// Validar teléfono (formato flexible)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es requerido';
    }

    // Remover espacios, guiones y paréntesis
    final cleanedPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Validar que solo contenga números y tenga entre 7 y 15 dígitos
    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(cleanedPhone)) {
      return 'Ingresa un número de teléfono válido';
    }

    return null;
  }

  /// Validar contraseña
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (value.length < minLength) {
      return 'La contraseña debe tener al menos $minLength caracteres';
    }

    return null;
  }

  /// Validar contraseña fuerte
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'La contraseña debe contener al menos una mayúscula';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'La contraseña debe contener al menos una minúscula';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'La contraseña debe contener al menos un número';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'La contraseña debe contener al menos un carácter especial';
    }

    return null;
  }

  /// Validar que las contraseñas coincidan
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }

    if (value != password) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  /// Validar fecha
  static String? date(String? value) {
    if (value == null || value.isEmpty) {
      return 'La fecha es requerida';
    }

    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Ingresa una fecha válida';
    }
  }

  /// Validar que la fecha sea futura
  static String? futureDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'La fecha es requerida';
    }

    try {
      final date = DateTime.parse(value);
      if (date.isBefore(DateTime.now())) {
        return 'La fecha debe ser futura';
      }
      return null;
    } catch (e) {
      return 'Ingresa una fecha válida';
    }
  }

  /// Validar que la fecha sea pasada
  static String? pastDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'La fecha es requerida';
    }

    try {
      final date = DateTime.parse(value);
      if (date.isAfter(DateTime.now())) {
        return 'La fecha debe ser pasada';
      }
      return null;
    } catch (e) {
      return 'Ingresa una fecha válida';
    }
  }

  /// Validar solo letras
  static String? alphabetic(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }

    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
      return '${fieldName ?? 'Este campo'} solo debe contener letras';
    }

    return null;
  }

  /// Validar solo números
  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return '${fieldName ?? 'Este campo'} solo debe contener números';
    }

    return null;
  }

  /// Validar alfanumérico
  static String? alphanumeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }

    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return '${fieldName ?? 'Este campo'} solo debe contener letras y números';
    }

    return null;
  }

  /// Validar rating (1-5)
  static String? rating(double? value) {
    if (value == null) {
      return 'La calificación es requerida';
    }

    if (value < 1 || value > 5) {
      return 'La calificación debe estar entre 1 y 5';
    }

    return null;
  }

  /// Combinar múltiples validadores
  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  /// Validador personalizado con expresión regular
  static String? Function(String?) pattern(
    RegExp regex,
    String errorMessage,
  ) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Este campo es requerido';
      }

      if (!regex.hasMatch(value)) {
        return errorMessage;
      }

      return null;
    };
  }
}

/// Extension para facilitar validación en TextFormField
extension ValidatorExtension on String? {
  /// Validar como requerido
  String? get required => Validators.required(this);

  /// Validar como email
  String? get email => Validators.email(this);

  /// Validar como número
  String? get number => Validators.number(this);

  /// Validar como URL
  String? get url => Validators.url(this);

  /// Validar como teléfono
  String? get phone => Validators.phone(this);
}
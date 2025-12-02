import 'package:intl/intl.dart';

/// Utilidad para formatear fechas en la aplicación
class DateFormatter {
  DateFormatter._();

  /// Formato: 15 Ene 2024
  static String formatShort(DateTime date) {
    return DateFormat('d MMM yyyy', 'es').format(date);
  }

  /// Formato: 15 de Enero de 2024
  static String formatLong(DateTime date) {
    return DateFormat('d \'de\' MMMM \'de\' yyyy', 'es').format(date);
  }

  /// Formato: Lun, 15 Ene 2024
  static String formatWithDay(DateTime date) {
    return DateFormat('EEE, d MMM yyyy', 'es').format(date);
  }

  /// Formato: 15/01/2024
  static String formatNumeric(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formato: 15:30
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Formato: 15 Ene 2024, 15:30
  static String formatDateTime(DateTime date) {
    return DateFormat('d MMM yyyy, HH:mm', 'es').format(date);
  }

  /// Formato relativo: "Hace 2 días", "Hace 3 horas", etc.
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'Hace $years ${years == 1 ? 'año' : 'años'}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'Hace $months ${months == 1 ? 'mes' : 'meses'}';
    } else if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} ${difference.inDays == 1 ? 'día' : 'días'}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'}';
    } else {
      return 'Hace un momento';
    }
  }

  /// Parsear string de fecha en formato ISO 8601
  static DateTime? parseIso8601(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parsear string de fecha en formato yyyy-MM-dd
  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    
    try {
      return DateFormat('yyyy-MM-dd').parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Verificar si una fecha es hoy
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Verificar si una fecha es ayer
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Verificar si una fecha está en esta semana
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek);
  }

  /// Obtener nombre del mes
  static String getMonthName(int month, {bool abbreviated = false}) {
    final months = abbreviated
        ? ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic']
        : ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    
    return months[month - 1];
  }

  /// Obtener nombre del día
  static String getDayName(int weekday, {bool abbreviated = false}) {
    final days = abbreviated
        ? ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom']
        : ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    
    return days[weekday - 1];
  }

  /// Calcular edad a partir de fecha de nacimiento
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }

  /// Formatear duración en formato legible
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours h $minutes min';
    } else if (minutes > 0) {
      return '$minutes min $seconds s';
    } else {
      return '$seconds s';
    }
  }

  /// Formatear rango de fechas
  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${start.day}-${end.day} ${getMonthName(start.month, abbreviated: true)} ${start.year}';
    } else if (start.year == end.year) {
      return '${start.day} ${getMonthName(start.month, abbreviated: true)} - ${end.day} ${getMonthName(end.month, abbreviated: true)} ${start.year}';
    } else {
      return '${formatShort(start)} - ${formatShort(end)}';
    }
  }

  /// Formatear para API (ISO 8601)
  static String formatForApi(DateTime date) {
    return date.toIso8601String();
  }

  /// Formatear solo fecha para API (yyyy-MM-dd)
  static String formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}

/// Extension de DateTime para facilitar formateo
extension DateTimeFormatting on DateTime {
  /// Formato corto: 15 Ene 2024
  String toShortString() => DateFormatter.formatShort(this);

  /// Formato largo: 15 de Enero de 2024
  String toLongString() => DateFormatter.formatLong(this);

  /// Formato con día: Lun, 15 Ene 2024
  String toStringWithDay() => DateFormatter.formatWithDay(this);

  /// Formato numérico: 15/01/2024
  String toNumericString() => DateFormatter.formatNumeric(this);

  /// Formato relativo: "Hace 2 días"
  String toRelativeString() => DateFormatter.formatRelative(this);

  /// Verificar si es hoy
  bool get isToday => DateFormatter.isToday(this);

  /// Verificar si es ayer
  bool get isYesterday => DateFormatter.isYesterday(this);

  /// Verificar si es esta semana
  bool get isThisWeek => DateFormatter.isThisWeek(this);
}
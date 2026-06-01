class Validators {
  Validators._();

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.length > 20) {
      return 'Username must be at most 20 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_\.]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, _ and .';
    }
    return null;
  }

  static String? validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Display name is required';
    }
    if (value.length > 30) {
      return 'Display name must be at most 30 characters';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) return null;
    final weight = double.tryParse(value);
    if (weight == null) return 'Enter a valid weight';
    if (weight < 0) return 'Weight cannot be negative';
    if (weight > 1000) return 'Weight seems too high';
    return null;
  }

  static String? validateReps(String? value) {
    if (value == null || value.isEmpty) return null;
    final reps = int.tryParse(value);
    if (reps == null) return 'Enter a valid number';
    if (reps < 0) return 'Reps cannot be negative';
    if (reps > 9999) return 'Reps seems too high';
    return null;
  }
}

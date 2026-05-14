library;

class AppValidators {
  static String? requiredField(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required.';
    }

    return null;
  }

  static String? email(String? value) {
    final required = requiredField(value, field: 'Email');
    if (required != null) {
      return required;
    }

    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pattern.hasMatch(value!.trim())) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  static String? password(String? value) {
    final required = requiredField(value, field: 'Password');
    if (required != null) {
      return required;
    }

    if (value!.length < 8) {
      return 'Password must contain at least 8 characters.';
    }

    return null;
  }
}

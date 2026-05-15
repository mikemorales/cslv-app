/// App Constants
///
/// Global constants for the application
library;

class AppConstants {
  // App metadata
  static const String appName = 'CSLV Manager';
  static const String appVersion = '1.0.0';
  static const String appBuild = '1';

  // Storage keys
  static const String storageKeyToken = 'auth_token';
  static const String storageKeyUser = 'auth_user';
  static const String storageKeyEmail = 'user_email';
  static const String storageKeyRefreshToken = 'refresh_token';
  static const String storageKeyLastLogin = 'last_login';

  // Cache keys
  static const String cacheKeyVillas = 'cache_villas';
  static const String cacheKeyPosts = 'cache_posts';
  static const String cacheKeyAdministrators = 'cache_administrators';
  static const String cacheKeyPayments = 'cache_payments';
  static const String cacheKeyCategories = 'cache_categories';
  static const String cacheKeyTags = 'cache_tags';

  // Validation
  static const int passwordMinLength = 8;
  static const int nameMinLength = 2;
  static const int nameMaxLength = 100;
  static const int titleMinLength = 3;
  static const int titleMaxLength = 255;

  // File upload
  static const int maxFileSizeMB = 10;
  static const int maxFileSizeBytes = maxFileSizeMB * 1024 * 1024;
  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];

  // Pagination
  static const int defaultPageSize = 15;
  static const int maxPageSize = 100;

  // Status values
  static const List<String> villaStatuses = [
    'draft',
    'publish',
    'unlisted',
    'private',
  ];
  static const List<String> postStatuses = ['draft', 'published', 'archived'];
  static const List<String> roles = ['administrador', 'editor'];
  static const List<String> paymentStatuses = [
    'pending_payment',
    'confirmed',
    'expired',
    'cancelled',
  ];

  // Seasonal rates seasons
  static const List<String> seasons = ['winter', 'spring', 'summer', 'fall'];

  // Payment environments
  static const String paymentEnvProduction = 'PRODUCTION';
  static const String paymentEnvSandbox = 'SANDBOX';

  // Date formats
  static const String dateFormatDisplay = 'MMM d, yyyy';
  static const String dateTimeFormatDisplay = 'MMM d, yyyy - HH:mm';
  static const String dateFormatAPI = 'yyyy-MM-dd';
  static const String dateTimeFormatAPI = 'yyyy-MM-ddTHH:mm:ss';

  // UI constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double largerBorderRadius = 12.0;
  static const double largestBorderRadius = 16.0;

  // Animation durations (milliseconds)
  static const int animationDurationSlow = 600;
  static const int animationDurationNormal = 300;
  static const int animationDurationFast = 150;

  // Error messages
  static const String errorNetworkConnection =
      'No internet connection. Please check your connection.';
  static const String errorUnauthorized = 'Unauthorized. Please login again.';
  static const String errorForbidden =
      'You do not have permission to perform this action.';
  static const String errorNotFound = 'Resource not found.';
  static const String errorValidation =
      'Please check your input and try again.';
  static const String errorServer = 'Server error. Please try again later.';
  static const String errorUnknown = 'An unexpected error occurred.';
  static const String errorTimeout = 'Request timed out. Please try again.';

  // Success messages
  static const String successCreated = 'Created successfully';
  static const String successUpdated = 'Updated successfully';
  static const String successDeleted = 'Deleted successfully';
  static const String successSaved = 'Saved successfully';
  static const String successCaptured = 'Payment captured successfully';
  static const String successCancelled = 'Cancelled successfully';
}

/// Transaction types for audit
class TransactionTypes {
  static const String create = 'create';
  static const String update = 'update';
  static const String delete = 'delete';
  static const String read = 'read';
  static const String export = 'export';
}

/// Entity types
class EntityTypes {
  static const String villa = 'villa';
  static const String post = 'post';
  static const String administrator = 'administrator';
  static const String payment = 'payment';
  static const String category = 'category';
  static const String tag = 'tag';
}

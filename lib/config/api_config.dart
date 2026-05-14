library;

class ApiConfig {
  static const String prodBaseUrl = 'https://cslvillas.com';
  static const String devBaseUrl = 'http://localhost:8000';
  static const String sandboxBaseUrl = 'https://staging.cslvillas.com';

  static Environment _environment = Environment.production;
  static String _baseUrl = prodBaseUrl;

  static void setEnvironment(Environment env) {
    _environment = env;
    switch (env) {
      case Environment.production:
        _baseUrl = prodBaseUrl;
        break;
      case Environment.development:
        _baseUrl = devBaseUrl;
        break;
      case Environment.sandbox:
        _baseUrl = sandboxBaseUrl;
        break;
    }
  }

  static Environment get environment => _environment;
  static String get baseUrl => _baseUrl;

  static const String login = '/app/login';
  static const String legacyLogin = '/app/login-app';
  static const String logout = '/app/logout';

  static const String categories = '/app/categories';
  static const String categoriesFlatHierarchy = '/app/categories-flat-hierarchy';
  static const String tags = '/app/tags';
  static const String dropbox = '/app/dropbox';
  static const String dropboxFetchImages = '$dropbox/fetch-images';
  static const String dropboxSaveAccessToken = '$dropbox/save-access-token';
  static const String dropboxCheckAccessToken = '$dropbox/check-access-token';

  static const String villas = '/app/villas';
  static String villaById(int id) => '$villas/$id';
  static const String villaGeneratePermalink = '$villas/generate-permalink';
  static const String villaCheckPermalink = '$villas/check-permalink';
  static String villaDropboxGallery(int id) => '$villas/$id/dropbox-gallery';
  static String villaSeasonalRates(int id) => '$villas/$id/seasonal-rates';
  static String villaSetFeaturedImage(int id) => '$villas/$id/set-featured-image';

  static const String posts = '/app/posts';
  static String postById(int id) => '$posts/$id';
  static const String postUploadImage = '$posts/upload-image';
  static String postGalleryUpload(int id) => '$posts/$id/gallery/upload';
  static String postGalleryDelete(int postId, int imageId) =>
      '$posts/$postId/gallery/$imageId';
  static String postGalleryReorder(int id) => '$posts/$id/gallery/reorder';

  static const String administrators = '/app/administrators';
  static String administratorById(int id) => '$administrators/$id';

  static const String payments = '/app/payments';
  static const String pendingPayments = '$payments/pending';
  static String capturePayment(int id) => '$payments/capture/$id';
  static String cancelPayment(int id) => '$payments/cancel/$id';
  static String recapturePayment(int id) => '$payments/recapture/$id';

  static const int defaultPerPage = 15;
  static const int paymentsPerPage = 20;
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
  static const int paymentAutoRefreshInterval = 30000;
}

enum Environment { production, development, sandbox }

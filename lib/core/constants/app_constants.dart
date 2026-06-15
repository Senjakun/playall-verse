class AppConstants {
  static const String baseUrl = 'https://playall.dev/api';
  static const String appName = 'PlayAll Verse';
  static const String appVersion = '1.0.0';

  // API Endpoints
  static const String contentEndpoint = '/content.php';
  static const String authEndpoint = '/auth.php';
  static const String episodesEndpoint = '/episodes.php';
  static const String bookmarksEndpoint = '/bookmarks.php';
  static const String historyEndpoint = '/history.php';
  static const String searchEndpoint = '/search.php';
  static const String commentsEndpoint = '/comments.php';

  // Content Types
  static const String typeAnime = 'anime';
  static const String typeManga = 'manga';
  static const String typeNovel = 'novel';
  static const String typeDonghua = 'donghua';

  // Pagination
  static const int pageSize = 20;
}

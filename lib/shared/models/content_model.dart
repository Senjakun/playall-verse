class ContentModel {
  final int id;
  final String type;
  final String slug;
  final String title;
  final String? posterUrl;
  final String? description;
  final List<String> genres;
  final String status;
  final double? rating;
  final String? sourceUrl;
  final String? createdAt;

  const ContentModel({
    required this.id,
    required this.type,
    required this.slug,
    required this.title,
    this.posterUrl,
    this.description,
    required this.genres,
    required this.status,
    this.rating,
    this.sourceUrl,
    this.createdAt,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    List<String> parseGenres(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      if (raw is String) {
        try {
          final decoded = raw.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '').split(',');
          return decoded.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        } catch (_) {
          return [];
        }
      }
      return [];
    }

    return ContentModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      type: json['type']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      posterUrl: json['poster_url']?.toString(),
      description: json['description']?.toString(),
      genres: parseGenres(json['genres']),
      status: json['status']?.toString() ?? 'ongoing',
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
      sourceUrl: json['source_url']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  String get displayRating => rating != null && rating! > 0
      ? rating!.toStringAsFixed(1)
      : 'N/A';

  String get statusLabel => status == 'completed' ? 'Tamat' : 'Ongoing';

  String get proxyPosterUrl {
    if (posterUrl == null || posterUrl!.isEmpty) return '';
    // Hapus proxy, gunakan URL aslinya langsung agar tidak error di Android
    return posterUrl!;
  }
}

class EpisodeModel {
  final int id;
  final int contentId;
  final int episodeNumber;
  final String title;
  final String? videoUrl;

  const EpisodeModel({
    required this.id,
    required this.contentId,
    required this.episodeNumber,
    required this.title,
    this.videoUrl,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    return EpisodeModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      contentId: json['content_id'] is int ? json['content_id'] : int.tryParse(json['content_id'].toString()) ?? 0,
      episodeNumber: json['episode_number'] is int ? json['episode_number'] : int.tryParse(json['episode_number'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      videoUrl: json['video_url']?.toString() ?? json['source_url']?.toString(),
    );
  }
}

class PaginationModel {
  final int page;
  final int limit;
  final int total;
  final int pages;

  const PaginationModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'] is int ? json['page'] : int.tryParse(json['page'].toString()) ?? 1,
      limit: json['limit'] is int ? json['limit'] : int.tryParse(json['limit'].toString()) ?? 20,
      total: json['total'] is int ? json['total'] : int.tryParse(json['total'].toString()) ?? 0,
      pages: json['pages'] is int ? json['pages'] : int.tryParse(json['pages'].toString()) ?? 0,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:readmore/readmore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/network/api_service.dart';
import '../../shared/models/content_model.dart';
import '../../shared/widgets/common_widgets.dart';

class ContentDetailPage extends StatefulWidget {
  final ContentModel content;

  const ContentDetailPage({super.key, required this.content});

  @override
  State<ContentDetailPage> createState() => _ContentDetailPageState();
}

class _ContentDetailPageState extends State<ContentDetailPage> {
  final _api = ApiService();
  List<EpisodeModel> _episodes = [];
  bool _isLoadingEpisodes = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadEpisodes();
  }

  Future<void> _loadEpisodes() async {
    setState(() => _isLoadingEpisodes = true);
    try {
      final eps = await _api.getEpisodes(widget.content.id);
      if (mounted) setState(() { _episodes = eps; _isLoadingEpisodes = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoadingEpisodes = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildHeroAppBar(content),
          SliverToBoxAdapter(child: _buildInfo(content)),
          SliverToBoxAdapter(child: _buildEpisodeSection(content)),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  SliverAppBar _buildHeroAppBar(ContentModel content) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_rounded, size: 16, color: Colors.white),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () async {
            final bookmarked = await _api.toggleBookmark(content.id);
            if (mounted) setState(() => _isBookmarked = bookmarked);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _isBookmarked ? AppColors.primary : Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            content.proxyPosterUrl.isNotEmpty
                ? CachedNetworkImage(imageUrl: content.proxyPosterUrl, fit: BoxFit.cover)
                : Container(color: AppColors.surface),
            const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.gradientOverlay)),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [AppColors.background, Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(ContentModel content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type badge + status
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Text(content.type.toUpperCase(),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: content.status == 'completed'
                    ? const Color(0xFF22C55E).withOpacity(0.15)
                    : AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(content.statusLabel,
                style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: content.status == 'completed' ? const Color(0xFF22C55E) : AppColors.primary,
                )),
            ),
            if (content.rating != null && content.rating! > 0) ...[
              const SizedBox(width: 8),
              const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFBBF24)),
              const SizedBox(width: 2),
              Text(content.displayRating,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ],
          ]),
          const SizedBox(height: 10),
          // Title
          Text(content.title, style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 12),
          // Genres
          if (content.genres.isNotEmpty)
            Wrap(
              spacing: 6, runSpacing: 6,
              children: content.genres.map((g) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(g, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              )).toList(),
            ),
          const SizedBox(height: 16),
          // Action buttons
          Row(children: [
            Expanded(
              child: PrimaryButton(
                label: content.type == 'anime' || content.type == 'donghua'
                    ? 'Tonton Ep. 1' : content.type == 'manga' ? 'Baca Ch. 1' : 'Baca Novel',
                icon: content.type == 'anime' || content.type == 'donghua'
                    ? Icons.play_arrow_rounded : Icons.menu_book_rounded,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 10),
            GlassContainer(
              padding: const EdgeInsets.all(12),
              borderRadius: BorderRadius.circular(10),
              child: const Icon(Icons.share_outlined, color: AppColors.textPrimary, size: 20),
            ),
          ]),
          const SizedBox(height: 20),
          // Synopsis
          if (content.description != null && content.description!.isNotEmpty) ...[
            const Text('Sinopsis', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            ReadMoreText(
              content.description!,
              trimLines: 3,
              trimMode: TrimMode.Line,
              trimCollapsedText: ' Selengkapnya',
              trimExpandedText: ' Sembunyikan',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
              moreStyle: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
              lessStyle: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEpisodeSection(ContentModel content) {
    final isVideo = content.type == 'anime' || content.type == 'donghua';
    final label = isVideo ? 'Episode' : 'Chapter';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Daftar $label',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              if (!_isLoadingEpisodes)
                Text('${_episodes.length} $label',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingEpisodes)
            const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
          else if (_episodes.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text('Belum ada episode tersedia',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _episodes.length > 50 ? 50 : _episodes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, i) {
                final ep = _episodes[i];
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${ep.episodeNumber}',
                              style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(ep.title,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                        ),
                        const Icon(Icons.play_circle_outline_rounded, color: AppColors.textMuted, size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

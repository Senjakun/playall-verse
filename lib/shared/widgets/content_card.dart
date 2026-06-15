import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/content_model.dart';

class ContentCard extends StatelessWidget {
  final ContentModel content;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final bool showType;

  const ContentCard({
    super.key,
    required this.content,
    this.onTap,
    this.width = 130,
    this.height = 190,
    this.showType = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  SizedBox(
                    width: width,
                    height: height,
                    child: content.proxyPosterUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: content.proxyPosterUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _buildShimmer(),
                            errorWidget: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: height * 0.4,
                      decoration: const BoxDecoration(
                        gradient: AppColors.gradientOverlay,
                      ),
                    ),
                  ),
                  // Rating badge
                  if (content.rating != null && content.rating! > 0)
                    Positioned(
                      top: 6, right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 10, color: Color(0xFFFBBF24)),
                            const SizedBox(width: 2),
                            Text(
                              content.displayRating,
                              style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Type badge
                  if (showType)
                    Positioned(
                      top: 6, left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          content.type.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9, fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  // Status badge
                  Positioned(
                    bottom: 6, left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: content.status == 'completed'
                            ? const Color(0xFF22C55E).withOpacity(0.85)
                            : AppColors.primary.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        content.statusLabel,
                        style: const TextStyle(
                          fontSize: 9, fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // Title
            Text(
              content.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary, height: 1.3,
              ),
            ),
            if (content.genres.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                content.genres.take(2).join(' • '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10, color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceHover,
      child: Container(
        width: width, height: height,
        color: AppColors.surface,
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width, height: height,
      color: AppColors.surface,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_outlined, color: AppColors.textMuted, size: 32),
          SizedBox(height: 4),
          Text('No Image', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/network/api_service.dart';
import '../../shared/models/content_model.dart';
import '../../shared/widgets/content_card.dart';
import '../../shared/widgets/common_widgets.dart';
import '../search/presentation/pages/search_page.dart';
import '../anime/presentation/pages/content_list_page.dart';
import '../anime/presentation/pages/content_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _api = ApiService();
  List<ContentModel> _featured = [];
  List<ContentModel> _anime = [];
  List<ContentModel> _manga = [];
  List<ContentModel> _novel = [];
  bool _isLoading = true;
  int _bannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _api.getContent(type: 'anime', page: 1),
        _api.getContent(type: 'manga', page: 1),
        _api.getContent(type: 'novel', page: 1),
      ]);
      if (mounted) {
        setState(() {
          _anime = results[0].content;
          _manga = results[1].content;
          _novel = results[2].content;
          _featured = [..._anime.take(5)];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(child: _buildHeroBanner()),
              SliverToBoxAdapter(child: _buildCategoryChips()),
              if (_anime.isNotEmpty) ...[
                SliverToBoxAdapter(child: const SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Anime Populer',
                    subtitle: 'Top rated dari MyAnimeList',
                    onSeeAll: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const ContentListPage(type: 'anime', title: 'Anime'),
                    )),
                  ),
                ),
                SliverToBoxAdapter(child: _buildHorizontalList(_anime)),
              ],
              if (_manga.isNotEmpty) ...[
                SliverToBoxAdapter(child: const SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Manga Terpopuler',
                    subtitle: 'Top manga dari MangaDex',
                    onSeeAll: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const ContentListPage(type: 'manga', title: 'Manga'),
                    )),
                  ),
                ),
                SliverToBoxAdapter(child: _buildHorizontalList(_manga)),
              ],
              if (_novel.isNotEmpty) ...[
                SliverToBoxAdapter(child: const SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Novel Light',
                    subtitle: 'Koleksi novel terlengkap',
                    onSeeAll: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const ContentListPage(type: 'novel', title: 'Novel'),
                    )),
                  ),
                ),
                SliverToBoxAdapter(child: _buildHorizontalList(_novel)),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              gradient: AppColors.gradientBrand,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          ShaderMask(
            shaderCallback: (bounds) => AppColors.gradientBrand.createShader(bounds),
            child: const Text(
              'PlayAll Verse',
              style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage())),
          icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildHeroBanner() {
    if (_isLoading) {
      return Container(
        height: 240,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
        ),
      );
    }

    if (_featured.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: _featured.length,
          itemBuilder: (context, index, _) {
            final item = _featured[index];
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ContentDetailPage(content: item),
              )),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      item.proxyPosterUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: item.proxyPosterUrl,
                              fit: BoxFit.cover,
                            )
                          : Container(color: AppColors.surface),
                      // Dark gradient
                      const DecoratedBox(
                        decoration: BoxDecoration(gradient: AppColors.gradientOverlay),
                      ),
                      // Top gradient
                      Positioned(
                        top: 0, left: 0, right: 0,
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                      // Content info
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.genres.isNotEmpty)
                                Text(
                                  item.genres.take(3).join(' • '),
                                  style: const TextStyle(
                                    fontSize: 11, color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w800,
                                  color: Colors.white, shadows: [
                                    Shadow(blurRadius: 8, color: Colors.black),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  PrimaryButton(
                                    label: 'Tonton Sekarang',
                                    icon: Icons.play_arrow_rounded,
                                    onTap: () => Navigator.push(context, MaterialPageRoute(
                                      builder: (_) => ContentDetailPage(content: item),
                                    )),
                                  ),
                                  const SizedBox(width: 8),
                                  GlassContainer(
                                    padding: const EdgeInsets.all(10),
                                    borderRadius: BorderRadius.circular(10),
                                    child: const Icon(Icons.bookmark_border_rounded, color: Colors.white, size: 18),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 240,
            viewportFraction: 0.9,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            onPageChanged: (index, _) => setState(() => _bannerIndex = index),
          ),
        ),
        const SizedBox(height: 10),
        AnimatedSmoothIndicator(
          activeIndex: _bannerIndex,
          count: _featured.length,
          effect: ExpandingDotsEffect(
            dotHeight: 4, dotWidth: 4,
            activeDotColor: AppColors.primary,
            dotColor: AppColors.border,
            expansionFactor: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    final categories = [
      ('🎌 Anime', 'anime'),
      ('📚 Manga', 'manga'),
      ('📖 Novel', 'novel'),
      ('🐉 Donghua', 'donghua'),
    ];
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((cat) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ContentListPage(type: cat.$2, title: cat.$1.split(' ').last),
                )),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    cat.$1,
                    style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHorizontalList(List<ContentModel> items) {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => ContentCard(
          content: items[i],
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => ContentDetailPage(content: items[i]),
          )),
        ),
      ),
    );
  }
}

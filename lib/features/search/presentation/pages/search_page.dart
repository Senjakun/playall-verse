import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:playall_verse/core/theme/app_colors.dart';
import 'package:playall_verse/core/network/api_service.dart';
import 'package:playall_verse/shared/models/content_model.dart';
import 'package:playall_verse/shared/widgets/common_widgets.dart';
import 'package:playall_verse/features/anime/presentation/pages/content_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _api = ApiService();
  final _controller = TextEditingController();
  List<ContentModel> _results = [];
  bool _isLoading = false;
  String _selectedType = 'all';
  String _query = '';

  final _types = [
    ('Semua', 'all'),
    ('Anime', 'anime'),
    ('Manga', 'manga'),
    ('Novel', 'novel'),
    ('Donghua', 'donghua'),
  ];

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() { _results = []; _query = ''; });
      return;
    }
    setState(() { _isLoading = true; _query = q; });
    try {
      final all = <ContentModel>[];
      if (_selectedType == 'all') {
        final res = await Future.wait([
          _api.getContent(type: 'anime', search: q),
          _api.getContent(type: 'manga', search: q),
          _api.getContent(type: 'novel', search: q),
        ]);
        for (final r in res) all.addAll(r.content);
      } else {
        final res = await _api.getContent(type: _selectedType, search: q);
        all.addAll(res.content);
      }
      if (mounted) setState(() { _results = all; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          decoration: const InputDecoration(
            hintText: 'Cari anime, manga, novel...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintStyle: TextStyle(color: AppColors.textMuted),
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (v) {
            if (v.length >= 2) _search(v);
            else if (v.isEmpty) setState(() { _results = []; _query = ''; });
          },
          onSubmitted: _search,
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _controller.clear();
                setState(() { _results = []; _query = ''; });
              },
              icon: const Icon(Icons.close_rounded),
            ),
        ],
      ),
      body: Column(
        children: [
          // Type filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: _types.map((t) {
                final selected = _selectedType == t.$2;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedType = t.$2);
                      if (_query.isNotEmpty) _search(_query);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Text(
                        t.$1,
                        style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500,
                          color: selected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
                : _results.isEmpty && _query.isNotEmpty
                    ? _buildEmpty()
                    : _results.isEmpty
                        ? _buildInitial()
                        : _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildInitial() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_rounded, size: 56, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text('Cari anime, manga, atau novel favoritmu', 
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded, size: 56, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            'Tidak ada hasil untuk "$_query"',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = _results[i];
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => ContentDetailPage(content: item),
          )),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.proxyPosterUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.proxyPosterUrl,
                          width: 56, height: 76, fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 56, height: 76, color: AppColors.card,
                            child: const Icon(Icons.movie_outlined, color: AppColors.textMuted),
                          ),
                        )
                      : Container(
                          width: 56, height: 76, color: AppColors.card,
                          child: const Icon(Icons.movie_outlined, color: AppColors.textMuted),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.type.toUpperCase(),
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              item.statusLabel,
                              style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(item.title,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (item.genres.isNotEmpty)
                        Text(item.genres.take(3).join(' • '),
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      if (item.rating != null && item.rating! > 0) ...[
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFBBF24)),
                          const SizedBox(width: 3),
                          Text(item.displayRating, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ]),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ],
            ),
          ),
        );
      },
    );
  }
}

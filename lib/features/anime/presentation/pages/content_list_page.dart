import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/network/api_service.dart';
import '../../shared/models/content_model.dart';
import '../../shared/widgets/content_card.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../features/anime/presentation/pages/content_detail_page.dart';

class ContentListPage extends StatefulWidget {
  final String type;
  final String title;

  const ContentListPage({super.key, required this.type, required this.title});

  @override
  State<ContentListPage> createState() => _ContentListPageState();
}

class _ContentListPageState extends State<ContentListPage> {
  final _api = ApiService();
  final _scrollController = ScrollController();
  final List<ContentModel> _items = [];
  int _page = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _selectedGenre;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);
    try {
      final res = await _api.getContent(
        type: widget.type,
        page: _page,
        genre: _selectedGenre,
        status: _selectedStatus,
      );
      if (mounted) {
        setState(() {
          _items.addAll(res.content);
          _totalPages = res.pagination.pages;
          _hasMore = _page < _totalPages;
          _page++;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _reset() {
    setState(() {
      _items.clear();
      _page = 1;
      _hasMore = true;
    });
    _loadMore();
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
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _showFilterSheet,
            icon: Stack(
              children: [
                const Icon(Icons.tune_rounded),
                if (_selectedGenre != null || _selectedStatus != null)
                  Positioned(
                    right: 0, top: 0,
                    child: Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: _items.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
          : _items.isEmpty
              ? const Center(child: Text('Tidak ada konten', style: TextStyle(color: AppColors.textMuted)))
              : GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.52,
                  ),
                  itemCount: _items.length + (_isLoading ? 3 : 0),
                  itemBuilder: (context, i) {
                    if (i >= _items.length) {
                      return const ShimmerCard(width: 110, height: 160);
                    }
                    return ContentCard(
                      content: _items[i],
                      width: double.infinity,
                      height: 160,
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => ContentDetailPage(content: _items[i]),
                      )),
                    );
                  },
                ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  TextButton(
                    onPressed: () {
                      setState(() { _selectedGenre = null; _selectedStatus = null; });
                      Navigator.pop(context);
                      _reset();
                    },
                    child: const Text('Reset', style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Row(children: [
                _filterChip('Semua', null, _selectedStatus, (v) { setModalState(() => _selectedStatus = v); }),
                const SizedBox(width: 8),
                _filterChip('Ongoing', 'ongoing', _selectedStatus, (v) { setModalState(() => _selectedStatus = v); }),
                const SizedBox(width: 8),
                _filterChip('Tamat', 'completed', _selectedStatus, (v) { setModalState(() => _selectedStatus = v); }),
              ]),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Terapkan Filter',
                  onTap: () {
                    setState(() {});
                    Navigator.pop(context);
                    _reset();
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, String? value, String? selected, Function(String?) onTap) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

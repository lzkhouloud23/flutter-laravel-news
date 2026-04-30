import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/database_helper.dart';

class DetailScreen extends StatefulWidget {
  final Article article;
  const DetailScreen({super.key, required this.article});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> with SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isFavorite = false;
  late AnimationController _fabAnim;

  static const Map<String, Color> _categoryColors = {
    'All': Color(0xFF6C3CE1),
    'Sport': Color(0xFFFF3D5A),
    'Technology': Color(0xFF00C2FF),
    'Politics': Color(0xFFFF8C00),
    'Science': Color(0xFF00D68F),
    'Health': Color(0xFFFF4FCB),
  };

  static const Map<String, IconData> _categoryIcons = {
    'All': Icons.grid_view_rounded,
    'Sport': Icons.sports_soccer_rounded,
    'Technology': Icons.memory_rounded,
    'Politics': Icons.account_balance_rounded,
    'Science': Icons.science_rounded,
    'Health': Icons.favorite_rounded,
  };

  Color get _accentColor => _categoryColors[widget.article.category] ?? const Color(0xFF6C3CE1);
  IconData get _catIcon => _categoryIcons[widget.article.category] ?? Icons.label_rounded;

  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 400), value: 1);
    _checkFavorite();
  }

  @override
  void dispose() {
    _fabAnim.dispose();
    super.dispose();
  }

  Future<void> _checkFavorite() async {
    if (widget.article.id != null) {
      final result = await _dbHelper.isFavorite(widget.article.id!);
      if (mounted) setState(() => _isFavorite = result);
    }
  }

  Future<void> _toggleFavorite() async {
    if (widget.article.id == null) return;
    // Bounce animation
    await _fabAnim.reverse();
    if (_isFavorite) {
      await _dbHelper.deleteArticle(widget.article.id!);
      if (!mounted) return;
      setState(() => _isFavorite = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [Icon(Icons.bookmark_remove_rounded, color: Colors.white), SizedBox(width: 8), Text('Removed from favorites')]),
          backgroundColor: const Color(0xFFFF8C00),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      await _dbHelper.insertArticle(widget.article);
      if (!mounted) return;
      setState(() => _isFavorite = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [Icon(Icons.bookmark_added_rounded, color: Colors.white), SizedBox(width: 8), Text('Added to favorites!')]),
          backgroundColor: const Color(0xFF00D68F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
    _fabAnim.forward();
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FF),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(article),
          SliverToBoxAdapter(child: _buildBody(article)),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnim,
        child: FloatingActionButton.extended(
          onPressed: _toggleFavorite,
          backgroundColor: _isFavorite ? const Color(0xFFFF3D5A) : _accentColor,
          foregroundColor: Colors.white,
          icon: Icon(_isFavorite ? Icons.bookmark_remove_rounded : Icons.bookmark_add_rounded),
          label: Text(_isFavorite ? 'Unsave' : 'Save Article',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          elevation: 6,
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(Article article) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: _accentColor,
      foregroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          ),
        ),
      ),
      title: const Text('Article', style: TextStyle(fontWeight: FontWeight.bold)),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            article.imageUrl.isNotEmpty
                ? Image.network(
                    article.imageUrl, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_accentColor, _accentColor.withOpacity(0.6)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(_catIcon, size: 80, color: Colors.white.withOpacity(0.3)),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_accentColor, _accentColor.withOpacity(0.6)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(_catIcon, size: 80, color: Colors.white.withOpacity(0.3)),
                  ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(Article article) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F2FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _accentColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: _accentColor.withOpacity(0.4), blurRadius: 8)],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(_catIcon, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(article.category,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ]),
                ),
                const SizedBox(width: 10),
                Icon(Icons.access_time_rounded, size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(article.publishedAt, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              article.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, height: 1.3, letterSpacing: -0.3),
            ),
            const SizedBox(height: 16),

            // Colored divider
            Container(
              height: 4,
              width: 60,
              decoration: BoxDecoration(
                color: _accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _accentColor.withOpacity(0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _accentColor.withOpacity(0.2)),
              ),
              child: Text(
                article.description,
                style: TextStyle(
                  fontSize: 16, color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic, height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Content
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Text(
                article.content,
                style: const TextStyle(fontSize: 15, height: 1.8, letterSpacing: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
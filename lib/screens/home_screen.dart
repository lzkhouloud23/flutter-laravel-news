import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';
import 'detail_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Article> _articles = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Sport', 'Technology', 'Politics', 'Science', 'Health'];

  // Bold color palette per category
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

  late AnimationController _headerAnim;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerAnim.forward();
    _loadArticles();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    super.dispose();
  }

  Future<void> _loadArticles() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final articles = await _apiService.getArticles();
      setState(() { _articles = articles; _isLoading = false; });
    } catch (e) {
      setState(() {
        _errorMessage = 'Cannot connect to server.\nMake sure Laravel is running.';
        _isLoading = false;
      });
    }
  }

  Future<void> _addToFavorites(Article article) async {
    final already = await _dbHelper.isFavorite(article.id!);
    if (!mounted) return;
    if (already) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [Icon(Icons.info_rounded, color: Colors.white), SizedBox(width: 8), Text('Already in favorites!')]),
          backgroundColor: const Color(0xFFFF8C00),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      await _dbHelper.insertArticle(article);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [Icon(Icons.bookmark_added_rounded, color: Colors.white), SizedBox(width: 8), Text('Added to favorites!')]),
          backgroundColor: const Color(0xFF00D68F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Color get _accentColor => _categoryColors[_selectedCategory] ?? const Color(0xFF6C3CE1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FF),
      appBar: AppBar(
        title: const Text('NewsApp', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryBar(),
          Expanded(
            child: _isLoading
                ? _buildLoading()
                : _errorMessage.isNotEmpty
                    ? _buildError()
                    : _buildList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loadArticles,
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Refresh', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 6,
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _headerFade,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 20, right: 12, bottom: 20,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_accentColor, _accentColor.withOpacity(0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
          boxShadow: [
            BoxShadow(color: _accentColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            // Logo + Title
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('NewsFlash', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1)),
                Text(_selectedCategory == 'All' ? 'All Stories' : _selectedCategory,
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
            const Spacer(),
            // Favorites button
            GestureDetector(
              onTap: () => Navigator.push(context, _slideRoute(const FavoritesScreen())).then((_) => _loadArticles()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.bookmark_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 4),
                    Text('Saved', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBar() {
    return Container(
      height: 64,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final isSelected = cat == _selectedCategory;
          final color = _categoryColors[cat]!;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? color : Colors.grey.shade200, width: 2),
                boxShadow: isSelected
                    ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]
                    : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_categoryIcons[cat], color: isSelected ? Colors.white : color, size: 16),
                  const SizedBox(width: 6),
                  Text(cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _accentColor, strokeWidth: 3),
          const SizedBox(height: 16),
          Text('Loading stories...', style: TextStyle(color: _accentColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3D5A).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, size: 56, color: Color(0xFFFF3D5A)),
            ),
            const SizedBox(height: 20),
            Text(_errorMessage, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5)),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _loadArticles,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3D5A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    final filtered = _selectedCategory == 'All'
        ? _articles
        : _articles.where((a) => a.category == _selectedCategory).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: _accentColor.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('No stories in "$_selectedCategory"',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _accentColor,
      onRefresh: _loadArticles,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: filtered.length,
        itemBuilder: (_, i) => _AnimatedCard(
          delay: Duration(milliseconds: i * 60),
          child: _buildCard(filtered[i]),
        ),
      ),
    );
  }

  Widget _buildCard(Article article) {
    final catColor = _categoryColors[article.category] ?? _accentColor;
    return GestureDetector(
      onTap: () => Navigator.push(context, _slideRoute(DetailScreen(article: article))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl.isNotEmpty)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      article.imageUrl, height: 190, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          height: 190,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [catColor.withOpacity(0.2), catColor.withOpacity(0.05)]),
                          ),
                          child: Icon(Icons.newspaper_rounded, size: 64, color: catColor.withOpacity(0.4))),
                    ),
                  ),
                  // Category badge overlaid on image
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: catColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: catColor.withOpacity(0.5), blurRadius: 8)],
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(_categoryIcons[article.category] ?? Icons.label_rounded, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(article.category, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, height: 1.3),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(article.description,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(article.publishedAt, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _addToFavorites(article),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: catColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: catColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bookmark_add_rounded, size: 15, color: catColor),
                              const SizedBox(width: 4),
                              Text('Save', style: TextStyle(fontSize: 12, color: catColor, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Route _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) =>
          SlideTransition(position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)), child: child),
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}

// Staggered animation wrapper for list cards
class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _AnimatedCard({required this.child, required this.delay});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade, child: SlideTransition(position: _slide, child: widget.child));
}
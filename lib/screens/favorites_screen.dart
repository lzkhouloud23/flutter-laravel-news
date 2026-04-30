import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/database_helper.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Article> _favorites = [];
  bool _isLoading = true;

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

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // ✅ YOUR ORIGINAL - untouched
  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final favorites = await _dbHelper.getFavorites();
    setState(() {
      _favorites = favorites;
      _isLoading = false;
    });
  }

  // ✅ YOUR ORIGINAL logic - untouched
  Future<void> _editNote(Article article) async {
    final controller = TextEditingController(text: article.personalNote);
    final catColor = _categoryColors[article.category] ?? const Color(0xFF6C3CE1);

    await showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: catColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.edit_note_rounded, color: catColor, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Text('Add Personal Note',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Enter your thoughts...",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: catColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context), // ✅ original
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        // ✅ YOUR EXACT ORIGINAL SAVE LOGIC
                        final updatedArticle = Article(
                          id: article.id,
                          title: article.title,
                          description: article.description,
                          content: article.content,
                          category: article.category,
                          imageUrl: article.imageUrl,
                          publishedAt: article.publishedAt,
                          personalNote: controller.text,
                        );
                        await _dbHelper.updateArticle(updatedArticle);
                        Navigator.pop(context);
                        _loadFavorites(); // ✅ original refresh
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: catColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Save',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ YOUR ORIGINAL logic - untouched
  Future<void> _deleteArticle(Article article) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3D5A).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_rounded,
                    color: Color(0xFFFF3D5A), size: 36),
              ),
              const SizedBox(height: 16),
              const Text('Remove from favorites?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('"${article.title}"',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false), // ✅ original
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true), // ✅ original
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3D5A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Remove',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    // ✅ YOUR ORIGINAL confirm check
    if (confirm == true) {
      await _dbHelper.deleteArticle(article.id!);
      _loadFavorites();
    }
  }

  // ✅ SAME STRUCTURE AS YOUR ORIGINAL - Scaffold + AppBar + body ternary
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FF),
      appBar: AppBar(
        title: const Text('My Favorites',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6C3CE1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C3CE1)))
          : _favorites.isEmpty
              ? _buildEmpty()
              : _buildList(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF6C3CE1).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bookmark_border_rounded,
                size: 64, color: Color(0xFF6C3CE1)),
          ),
          const SizedBox(height: 20),
          const Text('No favorites yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6C3CE1))),
          const SizedBox(height: 8),
          Text('Tap the bookmark icon on any article\nto save it here',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  height: 1.5)),
        ],
      ),
    );
  }

  // ✅ YOUR ORIGINAL ListView.builder - NO SliverList, NO CustomScrollView
  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _favorites.length,
      itemBuilder: (_, i) => _buildCard(_favorites[i]),
    );
  }

  // ✅ YOUR ORIGINAL card Row: image | details | buttons - NO color strip
  Widget _buildCard(Article article) {
    final catColor =
        _categoryColors[article.category] ?? const Color(0xFF6C3CE1);
    final catIcon =
        _categoryIcons[article.category] ?? Icons.label_rounded;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image - same size as your original (80x80)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                article.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.newspaper_rounded,
                      size: 36, color: catColor.withOpacity(0.5)),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Article details - same Expanded as your original
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Colorful category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: catColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(catIcon, size: 10, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(article.category,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(article.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  // ✅ YOUR ORIGINAL personalNote display
                  if (article.personalNote.isNotEmpty)
                    Text(
                      "Note: ${article.personalNote}",
                      style: TextStyle(
                          fontSize: 12,
                          color: catColor,
                          fontStyle: FontStyle.italic),
                    ),
                ],
              ),
            ),

            // ✅ YOUR ORIGINAL two buttons - same icons, same onPressed
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.edit_note, color: catColor),
                  onPressed: () => _editNote(article),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Color(0xFFF44336)),
                  onPressed: () => _deleteArticle(article),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
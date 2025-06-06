import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/mahas/widget/mahas_tile.dart';
import '../../../../data/datasource/network/service/comic_service.dart';
import '../../../../data/models/chapter_model.dart';

/// Widget for displaying chapter list in bottom sheet
class ChapterListWidget extends StatefulWidget {
  final String comicId;
  final String currentChapterId;
  final Function(Chapter) onChapterSelected;

  const ChapterListWidget({
    super.key,
    required this.comicId,
    required this.currentChapterId,
    required this.onChapterSelected,
  });

  @override
  State<ChapterListWidget> createState() => _ChapterListWidgetState();
}

class _ChapterListWidgetState extends State<ChapterListWidget> {
  final ComicService _comicService = ComicService();
  final ScrollController _scrollController = ScrollController();

  List<Chapter> _chapters = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadChapters();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMoreChapters();
      }
    }
  }

  Future<void> _loadChapters() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _comicService.getComicChapters(
        comicId: widget.comicId,
        page: 1,
        limit: _limit,
        sort: 'chapter_number',
        order: 'desc',
      );

      setState(() {
        _chapters = response.chapters;
        _hasMore = response.meta.hasMore;
        _currentPage = 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreChapters() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _comicService.getComicChapters(
        comicId: widget.comicId,
        page: _currentPage + 1,
        limit: _limit,
        sort: 'chapter_number',
        order: 'desc',
      );

      setState(() {
        _chapters.addAll(response.chapters);
        _hasMore = response.meta.hasMore;
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _chapters.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _chapters.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final chapter = _chapters[index];
        final isCurrentChapter = chapter.id == widget.currentChapterId;

        return Column(
          children: [
            MahasTile(
              title: Container(
                height: 30,
                color: AppColors.darkBackgroundColor,
                child: Center(
                  child: Text(
                    chapter.title ?? 'Chapter ${chapter.chapterNumber}',
                    style: TextStyle(
                      fontWeight: isCurrentChapter
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isCurrentChapter ? AppColors.primaryColor : null,
                    ),
                  ),
                ),
              ),
              trailing: isCurrentChapter
                  ? const Icon(
                      Icons.play_arrow,
                      color: AppColors.primaryColor,
                    )
                  : null,
              onTap: () => widget.onChapterSelected(chapter),
              backgroundColor: isCurrentChapter
                  ? AppColors.primaryColor.withValues(alpha: 0.1)
                  : AppColors.darkBackgroundColor,
            ),
            const SizedBox(height: 5),
          ],
        );
      },
    );
  }
}

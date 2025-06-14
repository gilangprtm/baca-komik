import '../../../../data/models/local/bookmark_model.dart';
import '../../../../data/models/local/history_model.dart';
import '../../../../data/models/shinigami/shinigami_models.dart';

/// Converter to create ShinigamiManga from BookmarkModel
class BookmarkToShinigamiManga {
  static ShinigamiManga convert(BookmarkModel bookmark) {
    return ShinigamiManga(
      mangaId: bookmark.comicId,
      title: bookmark.title,
      alternativeTitle: null,
      status: 1, // Default to ongoing
      coverImageUrl: bookmark.urlCover,
      viewCount: 0,
      bookmarkCount: 0,
      rank: 0,
      countryId: bookmark.nation,
      isRecommended: false,
      userRate: null,
      taxonomy: ShinigamiTaxonomy(
        artist: [],
        author: [],
        format: [],
        genre: [],
        type: [],
      ),
      chapters: null,
    );
  }
}

/// Converter to create ShinigamiManga from HistoryModel
class HistoryToShinigamiManga {
  static ShinigamiManga convert(HistoryModel history) {
    return ShinigamiManga(
      mangaId: history.comicId,
      title: history.title,
      alternativeTitle: null,
      status: 1, // Default to ongoing
      coverImageUrl: history.urlCover,
      viewCount: 0,
      bookmarkCount: 0,
      rank: 0,
      countryId: history.nation,
      isRecommended: false,
      userRate: null,
      taxonomy: ShinigamiTaxonomy(
        artist: [],
        author: [],
        format: [],
        genre: [],
        type: [],
      ),
      chapters: [
        ShinigamiChapterListItem(
          chapterId: history.chapterId,
          chapterNumber: int.parse(history.chapter),
          createdAt: history.updatedAt,
        ),
      ],
    );
  }
}

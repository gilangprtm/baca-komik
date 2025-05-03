import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../presentation/riverpod/bookmark/bookmark_provider.dart';
import '../../../presentation/riverpod/bookmark/bookmark_state.dart';
import '../../../presentation/widgets/common/loading_indicator.dart';
import '../../../presentation/widgets/common/error_widget.dart';

class BookmarkPage extends ConsumerWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookmarkProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookmarks'),
      ),
      body: state.status == BookmarkStateStatus.loading
          ? const LoadingIndicator()
          : state.status == BookmarkStateStatus.error
              ? ErrorDisplayWidget(
                  message: state.errorMessage ?? 'Something went wrong',
                  onRetry: () {
                    // Dalam implementasi nyata, ini akan memanggil method di provider
                    // ref.read(bookmarkProvider.notifier).getBookmarks();
                  },
                )
              : state.bookmarks.isEmpty
                  ? const NoDataWidget(
                      message: 'You don\'t have any bookmarks yet.',
                      icon: Icons.bookmark_border,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.bookmarks.length,
                      itemBuilder: (context, index) {
                        final bookmark = state.bookmarks[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            leading: bookmark.comic.coverImageUrl != null
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(bookmark.comic.coverImageUrl!),
                                  )
                                : const CircleAvatar(
                                    child: Icon(Icons.book),
                                  ),
                            title: Text(bookmark.comic.title),
                            subtitle: Text('ID: ${bookmark.bookmarkId}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                // Dalam implementasi nyata, ini akan memanggil method di provider
                                // ref.read(bookmarkProvider.notifier).removeBookmark(bookmark.bookmarkId);
                              },
                            ),
                            onTap: () {
                              // Navigate to comic detail page
                              // TODO: Implement navigation
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../riverpod/comic/comic_provider.dart';

class ComicErrorWidget extends StatelessWidget {
  final String? errorMessage;

  const ComicErrorWidget({
    Key? key,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, _) {
              return ElevatedButton(
                onPressed: () {
                  // Retry loading comic details
                  ref.read(comicProvider.notifier).fetchComicDetails();
                },
                child: const Text('Retry'),
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../presentation/widgets/common/under_construction.dart';

class BookmarkPage extends StatelessWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookmarks'),
      ),
      body: const UnderConstruction(),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../riverpod/search/search_provider.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final searchQuery = ref.watch(searchQueryProvider);

        return Container(
          padding: const EdgeInsets.all(16.0),
          color: AppColors.getBackgroundColor(context),
          child: SearchTextField(
            initialValue: searchQuery,
            onSubmitted: (query) {
              ref.read(searchProvider.notifier).searchComics(query);
            },
            onChanged: (query) {
              ref.read(searchProvider.notifier).updateSearchQuery(query);
            },
            onClear: () {
              ref.read(searchProvider.notifier).clearSearch();
            },
          ),
        );
      },
    );
  }
}

class SearchTextField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const SearchTextField({
    Key? key,
    required this.initialValue,
    required this.onSubmitted,
    required this.onChanged,
    required this.onClear,
  }) : super(key: key);

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(SearchTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    widget.onChanged(query);

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new timer for search
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        widget.onSubmitted(query.trim());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Search ...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  widget.onClear();
                  setState(() {}); // Update suffixIcon visibility
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: AppColors.getCardColor(context),
      ),
      onSubmitted: widget.onSubmitted,
      onChanged: (query) {
        _onSearchChanged(query);
        setState(() {}); // Update suffixIcon visibility
      },
    );
  }
}

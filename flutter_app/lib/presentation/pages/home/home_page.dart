
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(HomeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Counter: ${state.counter}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => ref.read(HomeProvider.notifier).incrementCounter(),
              child: const Text('Increment'),
            ),
          ],
        ),
      ),
    );
  }
}
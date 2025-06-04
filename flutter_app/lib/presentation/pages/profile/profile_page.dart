import 'package:flutter/material.dart';
import 'package:flutter_project/presentation/widgets/common/under_construction.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const UnderConstruction(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/base/global_state.dart';
import '../../../core/mahas/widget/mahas_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/type_utils.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.getBackgroundColor(context),
        foregroundColor: AppColors.getTextPrimaryColor(context),
      ),
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomActionsSection(context),
            const SizedBox(height: 24),
            _buildUrlInformationSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Donate Button
        MahasButton(
          text: 'Donate',
          icon: const Icon(Icons.favorite, size: 20),
          type: ButtonType.primary,
          color: Colors.red,
          isFullWidth: true,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Donate functionality coming soon')),
            );
          },
        ),

        const SizedBox(height: 12),

        // Auto Scroll Button
        MahasButton(
          text: 'Auto Scroll',
          icon: const Icon(Icons.auto_mode, size: 20),
          type: ButtonType.outline,
          isFullWidth: true,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Auto scroll settings coming soon')),
            );
          },
        ),

        const SizedBox(height: 12),

        // Clear Cache Button
        MahasButton(
          text: 'Clear Cache',
          icon: const Icon(Icons.clear_all, size: 20),
          type: ButtonType.outline,
          color: Colors.orange,
          isFullWidth: true,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Clear cache functionality coming soon')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUrlInformationSection(BuildContext context) {
    final urlInformation = GlobalState.urlInformation;

    if (urlInformation == null || urlInformation.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.getTextPrimaryColor(context),
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),

        // Generate buttons from GlobalState.urlInformation
        ...urlInformation.map((urlInfo) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MahasButton(
              text: urlInfo.title ?? 'Unknown',
              icon: const Icon(Icons.open_in_new, size: 20),
              type: ButtonType.outline,
              isFullWidth: true,
              onPressed: () async {
                if (urlInfo.url != null && urlInfo.url!.isNotEmpty) {
                  try {
                    await launchUrl(
                      Uri.parse(urlInfo.url!),
                      mode: LaunchMode.externalApplication,
                    );
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Could not launch ${urlInfo.title}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
            ),
          );
        }).toList(),
      ],
    );
  }
}

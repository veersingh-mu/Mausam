import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/weather_card_model.dart';

class FamilyDetailsScreen extends StatelessWidget {
  final FamilyData familyData;

  const FamilyDetailsScreen({Key? key, required this.familyData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Family & School Weather'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // School Morning Status Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD81B60), Color(0xFFC2185B)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MORNING SCHOOL COMMUTE STATUS', style: AppTypography.labelCaps.copyWith(color: Colors.white70)),
                const SizedBox(height: 8),
                Text(
                  familyData.schoolCommuteStatus,
                  style: AppTypography.headlineSm.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Morning: ${familyData.morningTempC}°C', style: AppTypography.bodyMd.copyWith(color: Colors.white)),
                    Text('Afternoon: ${familyData.afternoonTempC}°C', style: AppTypography.bodyMd.copyWith(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('RAIN WINDOW & OUTDOOR PLAY ADVISORY', style: AppTypography.labelCaps),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      familyData.outdoorPlaySafe ? Icons.sentiment_very_satisfied_rounded : Icons.umbrella_rounded,
                      color: familyData.outdoorPlaySafe ? AppColors.alertSafe : AppColors.alertWarning,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      familyData.outdoorPlaySafe ? 'Outdoor playtime is safe today' : 'Keep children indoors during rain',
                      style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Clothing Recommendation:', style: AppTypography.labelCaps),
                const SizedBox(height: 4),
                Text(familyData.clothingAdvisory, style: AppTypography.bodyMd),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

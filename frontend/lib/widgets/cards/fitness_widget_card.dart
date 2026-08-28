import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/weather_card_model.dart';
import 'base_widget_card.dart';

class FitnessWidgetCard extends BaseWidgetCard {
  const FitnessWidgetCard({
    Key? key,
    required WidgetCard card,
    VoidCallback? onTap,
  }) : super(key: key, card: card, onTap: onTap);

  @override
  Widget buildCardContent(BuildContext context) {
    final fitness = FitnessData.fromMap(card.data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Workout Score + Golden Running Hours
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OUTDOOR WORKOUT SCORE', style: AppTypography.labelCaps),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${fitness.outdoorWorkoutScore}',
                      style: AppTypography.headlineMd.copyWith(
                        color: fitness.outdoorWorkoutScore > 75 ? AppColors.alertSafe : AppColors.alertWarning,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text('/100', style: AppTypography.bodyMd),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.fitnessBadge.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.fitnessBadge.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('GOLDEN HOURS', style: AppTypography.labelCaps.copyWith(color: AppColors.fitnessBadge)),
                  const SizedBox(height: 2),
                  Text(
                    fitness.goldenRunningHours.isNotEmpty ? fitness.goldenRunningHours.first : '05:30 AM',
                    style: AppTypography.dataMono.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Metrics Grid (Wind, Temp, Heat Stress)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _metricItem('Wind Speed', '${fitness.windSpeedKmh} km/h ${fitness.windDirection}'),
            _metricItem('Sunrise/Sunset', '${fitness.sunrise} / ${fitness.sunset}'),
            _metricItem('Heat Index', fitness.heatStressIndex, isWarning: fitness.heatAlertActive),
          ],
        ),
        if (fitness.recommendation.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.directions_run_rounded, size: 16, color: AppColors.fitnessBadge),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fitness.recommendation,
                    style: AppTypography.bodyMd.copyWith(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _metricItem(String title, String value, {bool isWarning = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.labelCaps.copyWith(fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.bodyMd.copyWith(
            fontWeight: FontWeight.w600,
            color: isWarning ? AppColors.alertSevere : AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

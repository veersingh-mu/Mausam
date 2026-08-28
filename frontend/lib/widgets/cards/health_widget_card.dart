import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/weather_card_model.dart';
import 'base_widget_card.dart';

class HealthWidgetCard extends BaseWidgetCard {
  const HealthWidgetCard({
    Key? key,
    required WidgetCard card,
    VoidCallback? onTap,
  }) : super(key: key, card: card, onTap: onTap);

  @override
  Widget buildCardContent(BuildContext context) {
    final health = HealthData.fromMap(card.data);

    Color getAqiColor(int aqi) {
      if (aqi <= 50) return AppColors.alertSafe;
      if (aqi <= 100) return const Color(0xFF8BC34A);
      if (aqi <= 200) return AppColors.alertWatch;
      if (aqi <= 300) return AppColors.alertWarning;
      return AppColors.alertSevere;
    }

    final aqiColor = getAqiColor(health.aqi);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main AQI Highlight Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: aqiColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: aqiColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    '${health.aqi}',
                    style: AppTypography.headlineMd.copyWith(
                      color: aqiColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    health.aqiCategory.toUpperCase(),
                    style: AppTypography.labelCaps.copyWith(
                      color: aqiColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('PM2.5: ${health.pm25} µg/m³', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                      Text('PM10: ${health.pm10}', style: AppTypography.bodyMd),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('UV Index: ${health.uvIndex} (${health.uvCategory})', style: AppTypography.bodyMd),
                      Text('Pollen: ${health.pollenCount}', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600, color: AppColors.secondary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (health.healthAdvice.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.outline),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    health.healthAdvice,
                    style: AppTypography.bodyMd.copyWith(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/weather_card_model.dart';
import 'base_widget_card.dart';

class MarineWidgetCard extends BaseWidgetCard {
  const MarineWidgetCard({
    Key? key,
    required WidgetCard card,
    VoidCallback? onTap,
  }) : super(key: key, card: card, onTap: onTap);

  @override
  Widget buildCardContent(BuildContext context) {
    final marine = MarineData.fromMap(card.data);

    Color getFlagColor(String flag) {
      switch (flag.toLowerCase()) {
        case 'green':
          return AppColors.alertSafe;
        case 'yellow':
          return AppColors.alertWatch;
        case 'red':
          return AppColors.alertSevere;
        default:
          return AppColors.alertSafe;
      }
    }

    final flagColor = getFlagColor(marine.flagColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tide Timing + Swim Safety Flag
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NEXT HIGH TIDE', style: AppTypography.labelCaps),
                const SizedBox(height: 2),
                Text(
                  marine.nextHighTide,
                  style: AppTypography.titleMd.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: flagColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: flagColor.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.flag_rounded, color: flagColor, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    marine.swimSafety.toUpperCase(),
                    style: AppTypography.labelCaps.copyWith(color: flagColor, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Marine metrics grid
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _metricItem('Wave Height', '${marine.waveHeightM} m'),
            _metricItem('Swell Period', '${marine.swellPeriodSec}s'),
            _metricItem('Sea Temp', '${marine.seaSurfaceTempC}°C'),
          ],
        ),
        if (marine.incoisBulletin != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.waves_rounded, size: 16, color: AppColors.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    marine.incoisBulletin!,
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

  Widget _metricItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.labelCaps.copyWith(fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/weather_card_model.dart';
import 'base_widget_card.dart';

class FamilyWidgetCard extends BaseWidgetCard {
  const FamilyWidgetCard({
    Key? key,
    required WidgetCard card,
    VoidCallback? onTap,
  }) : super(key: key, card: card, onTap: onTap);

  @override
  Widget buildCardContent(BuildContext context) {
    final family = FamilyData.fromMap(card.data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // School Morning Status
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SCHOOL COMMUTE', style: AppTypography.labelCaps),
                const SizedBox(height: 2),
                Text(
                  family.schoolCommuteStatus,
                  style: AppTypography.titleMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: family.schoolCommuteStatus.contains('Clear')
                        ? AppColors.alertSafe
                        : AppColors.alertWarning,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('MORNING / AFTERNOON', style: AppTypography.labelCaps),
                const SizedBox(height: 2),
                Text(
                  '${family.morningTempC}°C / ${family.afternoonTempC}°C',
                  style: AppTypography.dataMono.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Rain Window & Clothing Advisory
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (family.rainWindowStart != null) ...[
                Row(
                  children: [
                    const Icon(Icons.umbrella_rounded, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Text(
                      'Rain window expected: ${family.rainWindowStart} - ${family.rainWindowEnd}',
                      style: AppTypography.bodyMd.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
              Text(
                'Advisory: ${family.clothingAdvisory}',
                style: AppTypography.bodyMd.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

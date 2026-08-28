import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/weather_card_model.dart';
import 'base_widget_card.dart';

class AgriWidgetCard extends BaseWidgetCard {
  const AgriWidgetCard({
    Key? key,
    required WidgetCard card,
    VoidCallback? onTap,
  }) : super(key: key, card: card, onTap: onTap);

  @override
  Widget buildCardContent(BuildContext context) {
    final agri = AgriData.fromMap(card.data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Soil Moisture & 72h Rain Forecast
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SOIL MOISTURE (TOP / ROOT)', style: AppTypography.labelCaps),
                const SizedBox(height: 4),
                Text(
                  '${agri.soilMoistureSurfacePct}% / ${agri.soilMoistureRootzonePct}%',
                  style: AppTypography.titleMd.copyWith(color: AppColors.agriBadge, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('72H RAINFALL OUTLOOK', style: AppTypography.labelCaps),
                const SizedBox(height: 4),
                Text(
                  '${agri.rainfallPrediction72hMm} mm',
                  style: AppTypography.dataMono.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Irrigation Recommendation & Spray suitability
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    agri.pesticideSprayingSuitable ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
                    size: 16,
                    color: agri.pesticideSprayingSuitable ? AppColors.alertSafe : AppColors.alertSevere,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    agri.pesticideSprayingSuitable ? 'Pesticide spray suitable today' : 'Postpone pesticide spraying',
                    style: AppTypography.bodyMd.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                agri.irrigationRecommendation,
                style: AppTypography.bodyMd.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

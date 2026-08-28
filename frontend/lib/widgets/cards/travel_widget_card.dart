import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/weather_card_model.dart';
import 'base_widget_card.dart';

class TravelWidgetCard extends BaseWidgetCard {
  const TravelWidgetCard({
    Key? key,
    required WidgetCard card,
    VoidCallback? onTap,
  }) : super(key: key, card: card, onTap: onTap);

  @override
  Widget buildCardContent(BuildContext context) {
    final travel = TravelData.fromMap(card.data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Saved Destinations Horizontal Scroll
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: travel.savedDestinations.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final dest = travel.savedDestinations[index];
              return Container(
                width: 130,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: dest.severeWarning != null
                        ? AppColors.alertWarning
                        : AppColors.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dest.city,
                      style: AppTypography.labelCaps.copyWith(color: AppColors.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${dest.tempC}°',
                          style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          dest.condition.split(' ').first,
                          style: AppTypography.bodyMd.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Flight Disruption & Packing Tips
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.travelBadge.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Flight Risk: ${travel.flightDisruptionRisk}',
                style: AppTypography.labelCaps.copyWith(color: AppColors.travelBadge, fontSize: 10),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                travel.packingTips.isNotEmpty ? travel.packingTips.first : 'Weather is pleasant for travel',
                style: AppTypography.bodyMd.copyWith(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

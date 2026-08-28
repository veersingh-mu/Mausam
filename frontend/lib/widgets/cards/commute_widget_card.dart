import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/weather_card_model.dart';
import 'base_widget_card.dart';

class CommuteWidgetCard extends BaseWidgetCard {
  const CommuteWidgetCard({
    Key? key,
    required WidgetCard card,
    VoidCallback? onTap,
  }) : super(key: key, card: card, onTap: onTap);

  @override
  Widget buildCardContent(BuildContext context) {
    final commute = CommuteData.fromMap(card.data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Visibility status + Departure buffer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.visibility_rounded,
                  size: 18,
                  color: commute.dominantVisibilityM < 500
                      ? AppColors.alertSevere
                      : (commute.dominantVisibilityM < 1000 ? AppColors.alertWarning : AppColors.alertSafe),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('VISIBILITY: ${commute.dominantVisibilityM}m', style: AppTypography.labelCaps),
                    Text(
                      commute.visibilityStatus,
                      style: AppTypography.titleMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: commute.dominantVisibilityM < 500 ? AppColors.alertSevere : AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (commute.recommendedDepartureDeltaMins > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.alertWarning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.alertWarning.withOpacity(0.4)),
                ),
                child: Text(
                  'Leave +${commute.recommendedDepartureDeltaMins}m Early',
                  style: AppTypography.labelCaps.copyWith(color: AppColors.alertWarning),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        // Saved Routes List
        if (commute.routes.isNotEmpty) ...[
          Column(
            children: commute.routes.map((r) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.routeName, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600, fontSize: 12)),
                          Text('${r.origin} → ${r.destination}', style: AppTypography.bodyMd.copyWith(fontSize: 10, color: AppColors.outline)),
                        ],
                      ),
                    ),
                    Text(
                      '${r.travelTimeMins} min ${r.delayMins > 0 ? '(+${r.delayMins}m)' : ''}',
                      style: AppTypography.dataMono.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: r.delayMins > 10 ? AppColors.alertSevere : AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

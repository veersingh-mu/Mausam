import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/weather_card_model.dart';
import 'base_widget_card.dart';

class EventsWidgetCard extends BaseWidgetCard {
  const EventsWidgetCard({
    Key? key,
    required WidgetCard card,
    VoidCallback? onTap,
  }) : super(key: key, card: card, onTap: onTap);

  @override
  Widget buildCardContent(BuildContext context) {
    final events = EventsData.fromMap(card.data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comfort Index + Rain Probability
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OUTDOOR COMFORT', style: AppTypography.labelCaps),
                const SizedBox(height: 2),
                Text(
                  '${events.eventComfortIndex}/100 (${events.comfortCategory})',
                  style: AppTypography.titleMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: events.eventComfortIndex > 80 ? AppColors.alertSafe : AppColors.alertWarning,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('RAIN PROBABILITY', style: AppTypography.labelCaps),
                const SizedBox(height: 2),
                Text(
                  '${events.rainProbabilityPct}%',
                  style: AppTypography.dataMono.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Hourly rain timeline chips
        if (events.hourlyForecast.isNotEmpty) ...[
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: events.hourlyForecast.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final h = events.hourlyForecast[index];
                final rainP = h['rain_probability_pct'] ?? 0;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: rainP > 30 ? AppColors.secondary : AppColors.outlineVariant.withOpacity(0.4),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(h['time']?.toString().split(' ').first ?? '', style: AppTypography.labelCaps.copyWith(fontSize: 10)),
                      const SizedBox(height: 2),
                      Text('$rainP%', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600, fontSize: 11)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

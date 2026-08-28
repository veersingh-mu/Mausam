import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/weather_card_model.dart';

class EventPlannerDetailsScreen extends StatelessWidget {
  final EventsData eventsData;

  const EventPlannerDetailsScreen({Key? key, required this.eventsData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Event Planning & Comfort Forecast'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Event Comfort Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OUTDOOR EVENT COMFORT INDEX', style: AppTypography.labelCaps.copyWith(color: Colors.white70)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${eventsData.eventComfortIndex}/100',
                      style: AppTypography.displayTemp.copyWith(color: Colors.white, fontSize: 52),
                    ),
                    Text(
                      eventsData.comfortCategory.toUpperCase(),
                      style: AppTypography.titleMd.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('HOURLY PRECIPITATION TIMELINE', style: AppTypography.labelCaps),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              children: eventsData.hourlyForecast.map((h) {
                final rainP = h['rain_probability_pct'] ?? 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(h['time'] ?? '', style: AppTypography.titleMd.copyWith(fontSize: 14)),
                      Row(
                        children: [
                          Icon(Icons.water_drop_rounded, size: 16, color: rainP > 30 ? AppColors.secondary : AppColors.outline),
                          const SizedBox(width: 6),
                          Text('$rainP% Rain Prob', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Text('EXTENDED EVENT FORECAST', style: AppTypography.labelCaps),
          const SizedBox(height: 8),
          ...eventsData.extendedForecastDays.map((d) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d['day'] ?? '', style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700)),
                      Text(d['date'] ?? '', style: AppTypography.labelCaps),
                    ],
                  ),
                  Text(d['condition'] ?? '', style: AppTypography.bodyMd),
                  Text(
                    '${d['temp_max']}° / ${d['temp_min']}°',
                    style: AppTypography.dataMono.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

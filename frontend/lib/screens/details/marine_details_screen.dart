import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/weather_card_model.dart';

class MarineDetailsScreen extends StatelessWidget {
  final MarineData marineData;

  const MarineDetailsScreen({Key? key, required this.marineData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Marine & Coastal Forecast'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // INCOIS Ocean State Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00639A), Color(0xFF0288D1)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('INCOIS OCEAN STATE FORECAST', style: AppTypography.labelCaps.copyWith(color: Colors.white70)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('WAVE SWELL HEIGHT', style: AppTypography.labelCaps.copyWith(color: Colors.white60)),
                        Text('${marineData.waveHeightM} Meters', style: AppTypography.headlineSm.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        marineData.swimSafety.toUpperCase(),
                        style: AppTypography.labelCaps.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('24-HOUR TIDE SCHEDULE', style: AppTypography.labelCaps),
          const SizedBox(height: 8),
          ...marineData.tideSchedule.map((t) {
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
                  Row(
                    children: [
                      Icon(
                        t['type'] == 'High Tide' ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        color: t['type'] == 'High Tide' ? AppColors.secondary : AppColors.outline,
                      ),
                      const SizedBox(width: 12),
                      Text(t['type'] ?? '', style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(t['time'] ?? '', style: AppTypography.dataMono.copyWith(fontWeight: FontWeight.w700)),
                      Text('${t['height_m']}m tide height', style: AppTypography.bodyMd.copyWith(fontSize: 11)),
                    ],
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

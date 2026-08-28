import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/weather_card_model.dart';

class FitnessDetailsScreen extends StatelessWidget {
  final FitnessData fitnessData;

  const FitnessDetailsScreen({Key? key, required this.fitnessData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fitness & Running Forecast'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Workout Score Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE65100), Color(0xFFEF6C00)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OUTDOOR READINESS SCORE', style: AppTypography.labelCaps.copyWith(color: Colors.white70)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${fitnessData.outdoorWorkoutScore}/100',
                      style: AppTypography.displayTemp.copyWith(color: Colors.white, fontSize: 52),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('HEAT STRESS INDEX', style: AppTypography.labelCaps.copyWith(color: Colors.white60)),
                        Text(
                          fitnessData.heatStressIndex.toUpperCase(),
                          style: AppTypography.titleMd.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('GOLDEN WORKOUT WINDOWS', style: AppTypography.labelCaps),
          const SizedBox(height: 8),
          ...fitnessData.goldenRunningHours.map((g) {
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
                      const Icon(Icons.wb_sunny_outlined, color: AppColors.fitnessBadge),
                      const SizedBox(width: 12),
                      Text(g, style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Text('Optimal Window', style: AppTypography.labelCaps.copyWith(color: AppColors.alertSafe)),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
          Text('WIND & TEMPERATURE CONDITIONS', style: AppTypography.labelCaps),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Wind Velocity', style: AppTypography.labelCaps),
                      const SizedBox(height: 4),
                      Text('${fitnessData.windSpeedKmh} km/h ${fitnessData.windDirection}', style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Feels Like', style: AppTypography.labelCaps),
                      const SizedBox(height: 4),
                      Text('${fitnessData.feelsLikeC}°C', style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

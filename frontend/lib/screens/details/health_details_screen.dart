import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/weather_card_model.dart';

class HealthDetailsScreen extends StatelessWidget {
  final HealthData healthData;

  const HealthDetailsScreen({Key? key, required this.healthData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Health & Air Quality Index'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Large AQI Gauge Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF004D40), Color(0xFF00796B)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NATIONAL AIR QUALITY INDEX (NAQI)', style: AppTypography.labelCaps.copyWith(color: Colors.white70)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${healthData.aqi}',
                      style: AppTypography.displayTemp.copyWith(color: Colors.white, fontSize: 56),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        healthData.aqiCategory.toUpperCase(),
                        style: AppTypography.titleMd.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Particulate Pollutants Breakdown
          Text('PARTICULATE MATTER & ALLERGENS', style: AppTypography.labelCaps),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _metricCard('PM 2.5', '${healthData.pm25} µg/m³', 'Fine particulates')),
              const SizedBox(width: 12),
              Expanded(child: _metricCard('PM 10', '${healthData.pm10} µg/m³', 'Coarse dust')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _metricCard('UV Index', '${healthData.uvIndex} (${healthData.uvCategory})', 'Sun protection')),
              const SizedBox(width: 12),
              Expanded(child: _metricCard('Pollen Count', healthData.pollenCount, 'Grass & tree pollen')),
            ],
          ),
          const SizedBox(height: 16),
          // Health Advisory Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CPCB HEALTH RECOMMENDATION', style: AppTypography.labelCaps),
                const SizedBox(height: 8),
                Text(
                  healthData.healthAdvice,
                  style: AppTypography.bodyMd.copyWith(fontSize: 14, color: AppColors.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String value, String sub) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.labelCaps),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(sub, style: AppTypography.bodyMd.copyWith(fontSize: 11, color: AppColors.outline)),
        ],
      ),
    );
  }
}

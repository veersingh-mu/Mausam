import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/weather_card_model.dart';

class AgriDetailsScreen extends StatelessWidget {
  final AgriData agriData;

  const AgriDetailsScreen({Key? key, required this.agriData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Agromet & Soil Moisture Advisory'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Soil Moisture Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('IMD GRAMIN KRISHI MAUSAM SEWA', style: AppTypography.labelCaps.copyWith(color: Colors.white70)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SURFACE SOIL MOISTURE', style: AppTypography.labelCaps.copyWith(color: Colors.white60)),
                        Text('${agriData.soilMoistureSurfacePct}%', style: AppTypography.headlineSm.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('ROOT-ZONE MOISTURE', style: AppTypography.labelCaps.copyWith(color: Colors.white60)),
                        Text('${agriData.soilMoistureRootzonePct}%', style: AppTypography.headlineSm.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('72-HOUR RAIN & FROST FORECAST', style: AppTypography.labelCaps),
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
                      Text('72h Rainfall', style: AppTypography.labelCaps),
                      const SizedBox(height: 4),
                      Text('${agriData.rainfallPrediction72hMm} mm', style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700)),
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
                      Text('Frost Alert Risk', style: AppTypography.labelCaps),
                      const SizedBox(height: 4),
                      Text(
                        agriData.frostRiskLevel,
                        style: AppTypography.titleMd.copyWith(
                          fontWeight: FontWeight.w700,
                          color: agriData.frostAlertActive ? AppColors.alertSevere : AppColors.alertSafe,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('CROP & FIELD ADVISORIES', style: AppTypography.labelCaps),
          const SizedBox(height: 8),
          ...agriData.cropAdvisories.map((a) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.eco_rounded, color: AppColors.agriBadge, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(a, style: AppTypography.bodyMd.copyWith(fontSize: 13, color: AppColors.onSurface)),
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

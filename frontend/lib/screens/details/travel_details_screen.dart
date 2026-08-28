import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/weather_card_model.dart';

class TravelDetailsScreen extends StatelessWidget {
  final TravelData travelData;

  const TravelDetailsScreen({Key? key, required this.travelData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Travel & Destination Weather'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Flight Disruption Status
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.travelBadge.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.flight_takeoff_rounded, color: AppColors.travelBadge, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FLIGHT DISRUPTION RISK', style: AppTypography.labelCaps),
                    Text(
                      travelData.flightDisruptionRisk.toUpperCase(),
                      style: AppTypography.headlineSm.copyWith(
                        color: travelData.flightDisruptionRisk == 'Low' ? AppColors.alertSafe : AppColors.alertWarning,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('SAVED DESTINATIONS', style: AppTypography.labelCaps),
          const SizedBox(height: 8),
          ...travelData.savedDestinations.map((d) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: d.severeWarning != null ? AppColors.alertWarning : AppColors.outlineVariant,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.city, style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(d.condition, style: AppTypography.bodyMd.copyWith(fontSize: 12)),
                      if (d.severeWarning != null) ...[
                        const SizedBox(height: 4),
                        Text(d.severeWarning!, style: AppTypography.labelCaps.copyWith(color: AppColors.alertWarning, fontSize: 10)),
                      ],
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${d.tempC}°C', style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800)),
                      Text('Rain: ${d.rainProbabilityPct}%', style: AppTypography.labelCaps),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
          Text('PACKING & CLOTHING ADVICE', style: AppTypography.labelCaps),
          const SizedBox(height: 8),
          ...travelData.packingTips.map((tip) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.luggage_outlined, size: 18, color: AppColors.travelBadge),
                  const SizedBox(width: 10),
                  Expanded(child: Text(tip, style: AppTypography.bodyMd)),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/weather_card_model.dart';

class CommuteDetailsScreen extends StatelessWidget {
  final CommuteData commuteData;

  const CommuteDetailsScreen({Key? key, required this.commuteData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Commute & Route Visibility'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Visibility Card
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
                    color: AppColors.commuteBadge.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.visibility_rounded, color: AppColors.commuteBadge, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('RUNWAY / HIGHWAY VISIBILITY', style: AppTypography.labelCaps),
                    Text(
                      '${commuteData.dominantVisibilityM} Meters',
                      style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      commuteData.visibilityStatus,
                      style: AppTypography.bodyMd.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('SAVED COMMUTE CORRIDORS', style: AppTypography.labelCaps),
          const SizedBox(height: 8),
          ...commuteData.routes.map((r) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(r.routeName, style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700)),
                      Text(
                        '${r.travelTimeMins} mins',
                        style: AppTypography.headlineSm.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('${r.origin} → ${r.destination}', style: AppTypography.bodyMd),
                  if (r.delayMins > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.alertWarning.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Delay: +${r.delayMins} min (${r.hazardAlert ?? "Congestion"})',
                        style: AppTypography.labelCaps.copyWith(color: AppColors.alertWarning),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

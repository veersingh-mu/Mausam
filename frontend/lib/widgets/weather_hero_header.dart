import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/homepage_feed_response.dart';

class WeatherHeroHeader extends StatelessWidget {
  final WeatherLocation location;
  final CurrentConditions current;
  final VoidCallback? onLocationTap;
  final VoidCallback? onSearchTap;

  const WeatherHeroHeader({
    Key? key,
    required this.location,
    required this.current,
    this.onLocationTap,
    this.onSearchTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 360;
        final padding = isSmallScreen ? 14.0 : 20.0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryContainer,
                Color(0xFF283593),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location + Department Badge (Safely truncated, Accessible Min 44px Target)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: InkWell(
                        onTap: onSearchTap ?? onLocationTap,
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                location.name,
                                style: AppTypography.titleMd.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down_rounded, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'IMD OFFICIAL',
                      style: AppTypography.labelCaps.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Persistent Search Bar Pill (44px Minimum Touch Target)
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: InkWell(
                  onTap: onSearchTap ?? onLocationTap,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Search city in India...',
                            style: AppTypography.bodyMd.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '35+ CITIES',
                            style: AppTypography.labelCaps.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Large Temperature & Condition + Scaled Centered Icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${current.temperatureC.round()}°',
                      style: AppTypography.displayTemp.copyWith(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 48 : 64,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          current.condition,
                          style: AppTypography.headlineSm.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 16 : 18,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Feels like ${current.feelsLikeC.round()}°  •  H: ${current.tempMaxC.round()}° L: ${current.tempMinC.round()}°',
                          style: AppTypography.bodyMd.copyWith(
                            color: Colors.white70,
                            fontSize: isSmallScreen ? 11 : 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Dedicated Centered Weather Condition Icon Container
                  _buildConditionIcon(current, isSmallScreen),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Colors.white24),
              const SizedBox(height: 12),
              // Quick Stats Pill Row (Humidity, Wind, Air Quality) - Evenly Distributed 3-Col
              Row(
                children: [
                  Expanded(child: _statItem(Icons.water_drop_outlined, '${current.humidityPct}%', 'Humidity')),
                  Expanded(child: _statItem(Icons.air_rounded, '${current.windKph} km/h', 'Wind')),
                  Expanded(child: _statItem(Icons.shield_outlined, current.airQualitySummary.split(' ').first, 'Air Quality')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConditionIcon(CurrentConditions current, [bool isSmallScreen = false]) {
    final cond = current.condition.toLowerCase();
    final hour = DateTime.now().hour;
    final isNight = hour < 6 || hour >= 19;

    Widget iconWidget;

    if (cond.contains('thunder') || cond.contains('storm')) {
      iconWidget = Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.cloud_rounded, color: Colors.white70, size: 44),
          Positioned(
            bottom: 2,
            child: Icon(Icons.bolt_rounded, color: Colors.amber[300], size: 28),
          ),
        ],
      );
    } else if (cond.contains('rain') || cond.contains('shower') || cond.contains('drizzle')) {
      iconWidget = Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.cloud_rounded, color: Colors.white70, size: 44),
          Positioned(
            bottom: 0,
            child: Icon(Icons.water_drop_rounded, color: Colors.lightBlue[200], size: 22),
          ),
        ],
      );
    } else if (cond.contains('partly') || cond.contains('partial') || cond.contains('scattered') || cond.contains('few clouds')) {
      if (isNight) {
        // Partly Cloudy Night: Moon + Cloud
        iconWidget = Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 4,
              right: 6,
              child: Icon(Icons.nightlight_round, color: Colors.indigo[100], size: 28),
            ),
            const Positioned(
              bottom: 4,
              left: 2,
              child: Icon(Icons.cloud_rounded, color: Colors.white, size: 40),
            ),
          ],
        );
      } else {
        // Partly Cloudy Day: Sun + Cloud
        iconWidget = Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 2,
              right: 4,
              child: Icon(Icons.wb_sunny_rounded, color: Colors.amber[300], size: 30),
            ),
            const Positioned(
              bottom: 2,
              left: 2,
              child: Icon(Icons.cloud_rounded, color: Colors.white, size: 42),
            ),
          ],
        );
      }
    } else if (cond.contains('cloud') || cond.contains('overcast')) {
      iconWidget = Stack(
        alignment: Alignment.center,
        children: const [
          Positioned(
            top: 2,
            right: 4,
            child: Icon(Icons.cloud_rounded, color: Colors.white38, size: 34),
          ),
          Positioned(
            bottom: 2,
            left: 2,
            child: Icon(Icons.cloud_rounded, color: Colors.white, size: 42),
          ),
        ],
      );
    } else if (cond.contains('clear') || cond.contains('sunny')) {
      iconWidget = Icon(
        isNight ? Icons.nightlight_round : Icons.wb_sunny_rounded,
        color: isNight ? Colors.indigo[100] : Colors.amber[300],
        size: 46,
      );
    } else {
      iconWidget = Icon(
        Icons.wb_sunny_rounded,
        color: Colors.amber[300],
        size: 44,
      );
    }

    final containerSize = isSmallScreen ? 50.0 : 60.0;
    final innerSize = isSmallScreen ? 42.0 : 52.0;

    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Center(
        child: SizedBox(
          width: innerSize,
          height: innerSize,
          child: FittedBox(
            fit: BoxFit.contain,
            child: iconWidget,
          ),
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTypography.bodyMd.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
            Text(label, style: AppTypography.labelCaps.copyWith(color: Colors.white60, fontSize: 9)),
          ],
        ),
      ],
    );
  }
}

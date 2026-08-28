import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/weather_card_model.dart';
import '../../models/persona_type.dart';

// Card implementations
import 'health_widget_card.dart';
import 'fitness_widget_card.dart';
import 'marine_widget_card.dart';
import 'travel_widget_card.dart';
import 'family_widget_card.dart';
import 'agri_widget_card.dart';
import 'commute_widget_card.dart';
import 'events_widget_card.dart';

/// Abstract Base class for all persona weather widget cards.
/// Provides standardized IMD container styling, header, badge, and interaction.
abstract class BaseWidgetCard extends StatelessWidget {
  final WidgetCard card;
  final VoidCallback? onTap;

  const BaseWidgetCard({
    Key? key,
    required this.card,
    this.onTap,
  }) : super(key: key);

  /// Subclasses implement the specific content body for their persona metrics.
  Widget buildCardContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final persona = card.persona;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.6), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Persona Icon + Badge + Title + Subtitle
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: persona.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        persona.icon,
                        color: persona.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.title,
                            style: AppTypography.titleMd.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          if (card.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              card.subtitle!,
                              style: AppTypography.bodyMd.copyWith(
                                fontSize: 12,
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.outline.withOpacity(0.7),
                      size: 22,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 1, color: AppColors.surfaceContainerHigh),
                const SizedBox(height: 16),
                // Specialized Card Body
                buildCardContent(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dynamic Widget Card Factory that creates the appropriate persona card
/// without modifying core feed/layout code.
class WidgetCardFactory {
  static Widget createCard(WidgetCard card, {VoidCallback? onTap}) {
    switch (card.persona) {
      case PersonaType.health:
        return HealthWidgetCard(card: card, onTap: onTap);
      case PersonaType.fitness:
        return FitnessWidgetCard(card: card, onTap: onTap);
      case PersonaType.beach:
        return MarineWidgetCard(card: card, onTap: onTap);
      case PersonaType.travel:
        return TravelWidgetCard(card: card, onTap: onTap);
      case PersonaType.family:
        return FamilyWidgetCard(card: card, onTap: onTap);
      case PersonaType.agriculture:
        return AgriWidgetCard(card: card, onTap: onTap);
      case PersonaType.commute:
        return CommuteWidgetCard(card: card, onTap: onTap);
      case PersonaType.events:
        return EventsWidgetCard(card: card, onTap: onTap);
    }
  }
}

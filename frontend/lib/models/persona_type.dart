import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum PersonaType {
  health,
  fitness,
  beach,
  travel,
  family,
  agriculture,
  commute,
  events,
}

extension PersonaTypeExtension on PersonaType {
  String get value {
    switch (this) {
      case PersonaType.health:
        return 'health';
      case PersonaType.fitness:
        return 'fitness';
      case PersonaType.beach:
        return 'beach';
      case PersonaType.travel:
        return 'travel';
      case PersonaType.family:
        return 'family';
      case PersonaType.agriculture:
        return 'agriculture';
      case PersonaType.commute:
        return 'commute';
      case PersonaType.events:
        return 'events';
    }
  }

  String get displayName {
    switch (this) {
      case PersonaType.health:
        return 'Health-Conscious';
      case PersonaType.fitness:
        return 'Fitness Enthusiast';
      case PersonaType.beach:
        return 'Beachgoer / Surfer';
      case PersonaType.travel:
        return 'Traveler';
      case PersonaType.family:
        return 'Parent / Family';
      case PersonaType.agriculture:
        return 'Farmer / Gardener';
      case PersonaType.commute:
        return 'Daily Commuter';
      case PersonaType.events:
        return 'Event Planner';
    }
  }

  String get description {
    switch (this) {
      case PersonaType.health:
        return 'AQI, pollen, UV & humidity alerts';
      case PersonaType.fitness:
        return 'Best running hours, wind & heat alerts';
      case PersonaType.beach:
        return 'Tide times, wave height, sea temp';
      case PersonaType.travel:
        return 'Destination weather & packing tips';
      case PersonaType.family:
        return 'School commute & rain alerts';
      case PersonaType.agriculture:
        return 'Soil moisture, rainfall, frost alerts';
      case PersonaType.commute:
        return 'Traffic, visibility, fog/storm alerts';
      case PersonaType.events:
        return 'Extended forecast & comfort index';
    }
  }

  IconData get icon {
    switch (this) {
      case PersonaType.health:
        return Icons.favorite_rounded;
      case PersonaType.fitness:
        return Icons.directions_run_rounded;
      case PersonaType.beach:
        return Icons.waves_rounded;
      case PersonaType.travel:
        return Icons.flight_takeoff_rounded;
      case PersonaType.family:
        return Icons.family_restroom_rounded;
      case PersonaType.agriculture:
        return Icons.eco_rounded;
      case PersonaType.commute:
        return Icons.directions_car_filled_rounded;
      case PersonaType.events:
        return Icons.calendar_month_rounded;
    }
  }

  Color get color {
    switch (this) {
      case PersonaType.health:
        return AppColors.healthBadge;
      case PersonaType.fitness:
        return AppColors.fitnessBadge;
      case PersonaType.beach:
        return AppColors.beachBadge;
      case PersonaType.travel:
        return AppColors.travelBadge;
      case PersonaType.family:
        return AppColors.familyBadge;
      case PersonaType.agriculture:
        return AppColors.agriBadge;
      case PersonaType.commute:
        return AppColors.commuteBadge;
      case PersonaType.events:
        return AppColors.eventsBadge;
    }
  }

  static PersonaType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'health':
        return PersonaType.health;
      case 'fitness':
        return PersonaType.fitness;
      case 'beach':
      case 'marine':
        return PersonaType.beach;
      case 'travel':
      case 'traveler':
        return PersonaType.travel;
      case 'family':
      case 'parent':
        return PersonaType.family;
      case 'agriculture':
      case 'agri':
      case 'farmer':
        return PersonaType.agriculture;
      case 'commute':
      case 'traffic':
      case 'commuter':
        return PersonaType.commute;
      case 'events':
      case 'event':
      case 'event_planner':
        return PersonaType.events;
      default:
        return PersonaType.health;
    }
  }
}

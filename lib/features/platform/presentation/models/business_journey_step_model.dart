import 'package:flutter/material.dart';

class BusinessJourneyStepModel {
  final String id;
  final String title;
  final String description;
  final String businessValue;
  final String platformModule;
  final String industryModule;
  final String route;
  final IconData icon;

  const BusinessJourneyStepModel({
    required this.id,
    required this.title,
    required this.description,
    required this.businessValue,
    required this.platformModule,
    required this.industryModule,
    required this.route,
    required this.icon,
  });
}

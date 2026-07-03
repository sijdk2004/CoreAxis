import 'package:flutter/material.dart';

class AiDemoScenarioModel {
  final String id;
  final String title;
  final String description;
  final String prompt;
  final String mockResponse;
  final IconData icon;

  const AiDemoScenarioModel({
    required this.id,
    required this.title,
    required this.description,
    required this.prompt,
    required this.mockResponse,
    required this.icon,
  });
}

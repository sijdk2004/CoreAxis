import 'package:flutter/material.dart';

enum RoadmapPhase {
  completed,
  current,
  next,
  future,
}

enum RoadmapTrack {
  platform,
  furniture,
  steel,
  garment,
  ai,
  mobile,
  integrations,
}

class RoadmapItemModel {
  final String id;
  final String title;
  final String description;
  final RoadmapPhase phase;
  final RoadmapTrack track;
  final String? date;
  final IconData icon;

  const RoadmapItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.phase,
    required this.track,
    this.date,
    required this.icon,
  });
}

import 'package:flutter/material.dart';

enum HelpCategory { gettingStarted, account, billing, troubleshooting, api, releases }

class HelpArticleModel {
  final String id;
  final String title;
  final String summary;
  final HelpCategory category;
  final IconData icon;
  final String readTime;
  final DateTime updatedAt;
  final bool isVideo;

  const HelpArticleModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.icon,
    required this.readTime,
    required this.updatedAt,
    this.isVideo = false,
  });
}

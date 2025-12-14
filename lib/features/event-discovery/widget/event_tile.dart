import 'package:flutter/material.dart';
import 'package:bond_up_mobile/app/app_theme.dart';
import 'package:bond_up_mobile/features/event-discovery/data/models/event_model.dart';

// Helper simpel untuk format tanggal (Contoh output: 14 - JAN - 2025)
// Tanpa package intl agar bisa langsung jalan
String _formatDate(DateTime date) {
  const List<String> months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
  ];

  String day = date.day.toString().padLeft(2, '0');
  String month = months[date.month - 1];
  String year = date.year.toString();

  return "$day - $month - $year";
}
}
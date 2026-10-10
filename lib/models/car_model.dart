import 'package:flutter/material.dart';

enum CarBodyType {
  buggy,
  supercar,
  retro,
  cyber,
  f1,
  truck,
}

class CarModel {
  final String id;
  final String name;
  final String tagline;
  final CarBodyType bodyType;
  final double topSpeed;
  final double acceleration;
  final double nitroRating;
  final double handling;

  const CarModel({
    required this.id,
    required this.name,
    required this.tagline,
    required this.bodyType,
    required this.topSpeed,
    required this.acceleration,
    required this.nitroRating,
    required this.handling,
  });

  static const List<CarModel> availableCars = [
    CarModel(
      id: 'sun_dazer',
      name: 'Sun Dazer',
      tagline: 'Classic beach runner with heavy-duty dunes tires',
      bodyType: CarBodyType.buggy,
      topSpeed: 4.2,
      acceleration: 4.8,
      nitroRating: 4.5,
      handling: 4.0,
    ),
    CarModel(
      id: 'cyber_racer',
      name: 'Cyber Neon',
      tagline: 'High-downforce aero coupe with neon underglow',
      bodyType: CarBodyType.supercar,
      topSpeed: 5.0,
      acceleration: 4.6,
      nitroRating: 4.8,
      handling: 4.9,
    ),
    CarModel(
      id: 'lightning_f1',
      name: 'Lightning F1',
      tagline: 'Apex open-wheel racer built for raw straight-line speed',
      bodyType: CarBodyType.f1,
      topSpeed: 5.0,
      acceleration: 5.0,
      nitroRating: 4.0,
      handling: 4.7,
    ),
    CarModel(
      id: 'retro_cruiser',
      name: 'Old Timer V8',
      tagline: 'Vintage muscle with roaring custom twin exhausts',
      bodyType: CarBodyType.retro,
      topSpeed: 4.4,
      acceleration: 4.2,
      nitroRating: 4.3,
      handling: 3.8,
    ),
    CarModel(
      id: 'skull_truck',
      name: 'Skull Crusher',
      tagline: 'Armored monster rover built for rugged offroad supremacy',
      bodyType: CarBodyType.truck,
      topSpeed: 3.9,
      acceleration: 4.5,
      nitroRating: 5.0,
      handling: 3.6,
    ),
    CarModel(
      id: 'cyber_blade',
      name: 'Phantom Hyper',
      tagline: 'Futuristic hypercar with electric vectoring boost',
      bodyType: CarBodyType.cyber,
      topSpeed: 4.8,
      acceleration: 4.9,
      nitroRating: 4.7,
      handling: 4.8,
    ),
  ];

  static CarModel getById(String id) {
    return availableCars.firstWhere(
      (c) => c.id == id,
      orElse: () => availableCars.first,
    );
  }

  static const List<Color> palette = [
    Color(0xFF00E5FF), // Cyan
    Color(0xFF00E676), // Neon Green
    Color(0xFFFF9100), // Solar Orange
    Color(0xFFFF1744), // Crimson
    Color(0xFFD500F9), // Neon Purple
    Color(0xFFFFEA00), // Lightning Yellow
    Color(0xFF3B82F6), // Azure Blue
    Color(0xFFF43F5E), // Rose Pink
  ];
}

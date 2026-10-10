import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/car_model.dart';
import 'custom_car_painter.dart';

class CarPreviewCard extends StatelessWidget {
  final CarModel car;
  final Color selectedColor;
  final ValueChanged<Color>? onColorChanged;
  final bool isSelected;
  final VoidCallback? onSelect;

  const CarPreviewCard({
    super.key,
    required this.car,
    required this.selectedColor,
    this.onColorChanged,
    this.isSelected = false,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF162035), Color(0xFF0C1322)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? AppColors.electricCyan : AppColors.surfaceBorder,
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.electricCyan.withValues(alpha: 0.35),
                  blurRadius: 22,
                  spreadRadius: 2,
                )
              ]
            : [
                const BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.name.toUpperCase(),
                      style: AppTypography.headingMedium.copyWith(
                        fontSize: 20,
                        letterSpacing: 1.5,
                        color: selectedColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      car.tagline,
                      style: AppTypography.bodyMedium.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.electricCyan, AppColors.electricBlue],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.electricCyan.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    'EQUIPPED',
                    style: AppTypography.buttonText.copyWith(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          // --- 3D GLOWING PODIUM STAGE ---
          Center(
            child: SizedBox(
              height: 140,
              width: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Multi-layer Glowing Neon Turntable Platform
                  Positioned(
                    bottom: 12,
                    child: Container(
                      width: 240,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.elliptical(240, 54)),
                        gradient: RadialGradient(
                          colors: [
                            selectedColor.withValues(alpha: 0.6),
                            selectedColor.withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                          stops: const [0.2, 0.65, 1.0],
                        ),
                        border: Border.all(
                          color: selectedColor.withValues(alpha: 0.8),
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: selectedColor.withValues(alpha: 0.4),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Inner platform disk
                  Positioned(
                    bottom: 22,
                    child: Container(
                      width: 170,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.elliptical(170, 32)),
                        color: const Color(0xFF0F172A),
                        border: Border.all(color: Colors.white24, width: 1.0),
                      ),
                    ),
                  ),
                  // Prominent High-Detail Car Drawing
                  CustomPaint(
                    size: const Size(140, 70),
                    painter: CustomCarPainter(
                      carColor: selectedColor,
                      bodyType: car.bodyType,
                      nitroActive: true,
                      showHeadlightBeams: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // --- STAT RATINGS WITH GRADIENTS ---
          _buildStatBar('TOP SPEED', car.topSpeed / 5.0, AppColors.electricCyan, Icons.speed_rounded),
          const SizedBox(height: 8),
          _buildStatBar('ACCELERATION', car.acceleration / 5.0, AppColors.electricGreen, Icons.flash_on_rounded),
          const SizedBox(height: 8),
          _buildStatBar('NITRO BOOST', car.nitroRating / 5.0, AppColors.neonOrange, Icons.local_fire_department_rounded),
          const SizedBox(height: 8),
          _buildStatBar('HANDLING', car.handling / 5.0, AppColors.neonPurple, Icons.alt_route_rounded),
          if (onColorChanged != null) ...[
            const SizedBox(height: 20),
            Text('CUSTOM PAINT SHOP', style: AppTypography.hudLabel.copyWith(fontSize: 11)),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: CarModel.palette.map((color) {
                  final isColorSelected = color.toARGB32() == selectedColor.toARGB32();
                  return GestureDetector(
                    onTap: () => onColorChanged!(color),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isColorSelected ? Colors.white : Colors.white24,
                          width: isColorSelected ? 3.0 : 1.5,
                        ),
                        boxShadow: isColorSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.9),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                )
                              ]
                            : [],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, double fillPercent, Color barColor, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: barColor),
        const SizedBox(width: 6),
        SizedBox(
          width: 95,
          child: Text(
            label,
            style: AppTypography.hudLabel.copyWith(fontSize: 10, color: Colors.white70),
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fillPercent.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [barColor.withValues(alpha: 0.6), barColor],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: barColor.withValues(alpha: 0.8),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(fillPercent * 100).toInt()}%',
          style: TextStyle(
            color: barColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

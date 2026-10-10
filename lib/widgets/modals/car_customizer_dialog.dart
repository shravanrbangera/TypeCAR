import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/car_model.dart';
import '../../services/storage_service.dart';
import '../car/car_preview_card.dart';
import '../common/arcade_button.dart';
import '../common/glowing_avatar.dart';

class CarCustomizerDialog extends StatefulWidget {
  final StorageService storageService;
  final VoidCallback onSaved;

  const CarCustomizerDialog({
    super.key,
    required this.storageService,
    required this.onSaved,
  });

  @override
  State<CarCustomizerDialog> createState() => _CarCustomizerDialogState();
}

class _CarCustomizerDialogState extends State<CarCustomizerDialog> {
  late TextEditingController _nicknameController;
  late String _selectedCarId;
  late Color _selectedColor;
  late int _selectedAvatarIndex;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.storageService.getNickname());
    _selectedCarId = widget.storageService.getCarId();
    _selectedColor = Color(widget.storageService.getCarColor());
    _selectedAvatarIndex = widget.storageService.getAvatarIndex();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final name = _nicknameController.text.trim();
    if (name.isNotEmpty) {
      await widget.storageService.setNickname(name);
    }
    await widget.storageService.setCarId(_selectedCarId);
    await widget.storageService.setCarColor(_selectedColor.toARGB32());
    await widget.storageService.setAvatarIndex(_selectedAvatarIndex);
    widget.onSaved();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCar = CarModel.getById(_selectedCarId);

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune_rounded, color: AppColors.electricCyan),
                      const SizedBox(width: 8),
                      Text('GARAGE & DRIVER', style: AppTypography.headingMedium),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Divider(color: AppColors.surfaceBorder, height: 24),
              // Nickname Input
              Text('DRIVER NICKNAME', style: AppTypography.hudLabel),
              const SizedBox(height: 8),
              TextField(
                controller: _nicknameController,
                maxLength: 16,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.badge_rounded, color: AppColors.electricCyan),
                  hintText: 'Enter your racer nickname',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),
              // Avatar Selection
              Text('AVATAR ICON', style: AppTypography.hudLabel),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(6, (index) {
                  final isSelected = _selectedAvatarIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAvatarIndex = index;
                      });
                    },
                    child: GlowingAvatar(
                      avatarIndex: index,
                      size: 44,
                      glowColor: isSelected ? AppColors.electricCyan : Colors.transparent,
                      isReady: isSelected,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              // Car Selection Grid/Carousel
              Text('SELECT RACE CAR', style: AppTypography.hudLabel),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: CarModel.availableCars.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final car = CarModel.availableCars[index];
                    final isSelected = car.id == _selectedCarId;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCarId = car.id;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.electricCyan : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.white : AppColors.surfaceBorder,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            car.name,
                            style: AppTypography.buttonText.copyWith(
                              fontSize: 12,
                              color: isSelected ? Colors.black : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Car Preview Card with Stat bars and Paint colors
              CarPreviewCard(
                car: currentCar,
                selectedColor: _selectedColor,
                isSelected: true,
                onColorChanged: (color) {
                  setState(() {
                    _selectedColor = color;
                  });
                },
              ),
              const SizedBox(height: 20),
              ArcadeButton(
                text: 'SAVE & EQUIP',
                onPressed: _saveChanges,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

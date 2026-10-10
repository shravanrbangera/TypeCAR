import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/car_model.dart';
import '../services/auth_service.dart';
import '../services/mock_room_service.dart';
import '../services/room_service.dart';
import '../services/room_service_interface.dart';
import '../services/storage_service.dart';
import '../widgets/car/car_preview_card.dart';
import '../widgets/common/arcade_button.dart';
import '../widgets/common/glowing_avatar.dart';
import 'lobby_screen.dart';

class CreateRoomScreen extends StatefulWidget {
  final bool isMockMode;

  const CreateRoomScreen({super.key, this.isMockMode = false});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  late StorageService _storageService;
  late TextEditingController _nicknameController;

  String _selectedCarId = 'sun_dazer';
  Color _selectedColor = const Color(0xFF00E5FF);
  int _selectedAvatarIndex = 0;
  int _maxPlayers = 4;
  TextDifficulty _difficulty = TextDifficulty.medium;
  TextCategory _category = TextCategory.funFacts;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _storageService = Provider.of<StorageService>(context, listen: false);
    _nicknameController = TextEditingController(text: _storageService.getNickname());
    _selectedCarId = _storageService.getCarId();
    _selectedColor = Color(_storageService.getCarColor());
    _selectedAvatarIndex = _storageService.getAvatarIndex();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateRoom() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a driver nickname')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final IRoomService roomService = widget.isMockMode
          ? Provider.of<MockRoomService>(context, listen: false)
          : Provider.of<RoomService>(context, listen: false);

      // Save local preferences
      await _storageService.setNickname(nickname);
      await _storageService.setCarId(_selectedCarId);
      await _storageService.setCarColor(_selectedColor.toARGB32());
      await _storageService.setAvatarIndex(_selectedAvatarIndex);

      final roomCode = await roomService.createRoom(
        hostId: authService.currentUserId,
        hostNickname: nickname,
        carId: _selectedCarId,
        carColorValue: _selectedColor.toARGB32(),
        avatarIndex: _selectedAvatarIndex,
        maxPlayers: _maxPlayers,
        difficulty: _difficulty,
        category: _category,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LobbyScreen(
            roomCode: roomCode,
            isHost: true,
            isMockMode: widget.isMockMode,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating room: $e'), backgroundColor: AppColors.neonPink),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCar = CarModel.getById(_selectedCarId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('CREATE RACE ROOM', style: AppTypography.headingMedium),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Driver Profile Customizer
            Text('DRIVER DETAILS', style: AppTypography.hudLabel),
            const SizedBox(height: 8),
            TextField(
              controller: _nicknameController,
              maxLength: 16,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.badge_rounded, color: AppColors.electricCyan),
                hintText: 'Enter your driver nickname',
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            // Avatar Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(6, (index) {
                final isSelected = _selectedAvatarIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAvatarIndex = index),
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
            // Car Customizer Card
            Text('SELECTED VEHICLE', style: AppTypography.hudLabel),
            const SizedBox(height: 8),
            CarPreviewCard(
              car: selectedCar,
              selectedColor: _selectedColor,
              isSelected: true,
              onColorChanged: (c) => setState(() => _selectedColor = c),
            ),
            const SizedBox(height: 10),
            // Car Horizontal Chips
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: CarModel.availableCars.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final c = CarModel.availableCars[index];
                  final isCur = c.id == _selectedCarId;
                  return ChoiceChip(
                    label: Text(c.name),
                    selected: isCur,
                    selectedColor: AppColors.electricCyan,
                    backgroundColor: AppColors.surfaceElevated,
                    labelStyle: TextStyle(
                      color: isCur ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedCarId = c.id);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Room Settings (Max Players)
            Text('MAX RACERS ($minPlayers TO $maxPlayers)', style: AppTypography.hudLabel),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [2, 3, 4, 6, 8].map((count) {
                final isCur = _maxPlayers == count;
                return GestureDetector(
                  onTap: () => setState(() => _maxPlayers = count),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isCur ? AppColors.electricCyan : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCur ? Colors.white : AppColors.surfaceBorder,
                      ),
                    ),
                    child: Text(
                      '$count',
                      style: AppTypography.buttonText.copyWith(
                        color: isCur ? Colors.black : AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Text Difficulty
            Text('RACE TEXT DIFFICULTY', style: AppTypography.hudLabel),
            const SizedBox(height: 8),
            Row(
              children: TextDifficulty.values.map((diff) {
                final isCur = _difficulty == diff;
                Color chipColor = AppColors.electricGreen;
                if (diff == TextDifficulty.medium) chipColor = AppColors.electricYellow;
                if (diff == TextDifficulty.hard) chipColor = AppColors.neonPink;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _difficulty = diff),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isCur ? chipColor : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCur ? Colors.white : AppColors.surfaceBorder,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            diff.label.toUpperCase(),
                            style: AppTypography.buttonText.copyWith(
                              color: isCur ? Colors.black : AppColors.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Text Category
            Text('TEXT CATEGORY', style: AppTypography.hudLabel),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<TextCategory>(
                  value: _category,
                  isExpanded: true,
                  dropdownColor: AppColors.surfaceElevated,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.electricCyan),
                  items: TextCategory.values.map((cat) {
                    return DropdownMenuItem<TextCategory>(
                      value: cat,
                      child: Text(cat.label, style: AppTypography.bodyLarge),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _category = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 28),
            ArcadeButton(
              text: 'CREATE ROOM & ENTER LOBBY',
              icon: Icons.rocket_launch_rounded,
              isLoading: _isLoading,
              onPressed: _handleCreateRoom,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  int get minPlayers => AppConstants.minPlayers;
  int get maxPlayers => AppConstants.maxPlayers;
}

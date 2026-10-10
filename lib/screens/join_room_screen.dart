import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/room_code_generator.dart';
import '../models/car_model.dart';
import '../models/player_model.dart';
import '../services/auth_service.dart';
import '../services/mock_room_service.dart';
import '../services/room_service.dart';
import '../services/room_service_interface.dart';
import '../services/storage_service.dart';
import '../widgets/car/car_preview_card.dart';
import '../widgets/common/arcade_button.dart';
import '../widgets/common/glowing_avatar.dart';
import 'lobby_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  final bool isMockMode;
  const JoinRoomScreen({super.key, this.isMockMode = false});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  late StorageService _storageService;
  late TextEditingController _roomCodeController;
  late TextEditingController _nicknameController;

  String _selectedCarId = 'sun_dazer';
  Color _selectedColor = const Color(0xFF00E5FF);
  int _selectedAvatarIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _storageService = Provider.of<StorageService>(context, listen: false);
    _roomCodeController = TextEditingController();
    _nicknameController = TextEditingController(text: _storageService.getNickname());
    _selectedCarId = _storageService.getCarId();
    _selectedColor = Color(_storageService.getCarColor());
    _selectedAvatarIndex = _storageService.getAvatarIndex();
  }

  @override
  void dispose() {
    _roomCodeController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _handleJoinRoom() async {
    final rawCode = _roomCodeController.text.trim();
    if (!RoomCodeGenerator.isValid(rawCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-character room code.'),
          backgroundColor: AppColors.neonPink,
        ),
      );
      return;
    }

    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a driver nickname.'),
          backgroundColor: AppColors.neonPink,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final IRoomService roomService = widget.isMockMode
          ? Provider.of<MockRoomService>(context, listen: false)
          : Provider.of<RoomService>(context, listen: false);

      final normalizedCode = RoomCodeGenerator.normalize(rawCode);

      // Persist chosen profile
      await _storageService.setNickname(nickname);
      await _storageService.setCarId(_selectedCarId);
      await _storageService.setCarColor(_selectedColor.toARGB32());
      await _storageService.setAvatarIndex(_selectedAvatarIndex);

      final room = await roomService.getRoom(normalizedCode);
      if (room == null) {
        throw Exception('Room $normalizedCode not found. Please check the code.');
      }

      final player = PlayerModel(
        id: authService.currentUserId,
        nickname: nickname,
        carId: _selectedCarId,
        carColorValue: _selectedColor.toARGB32(),
        avatarIndex: _selectedAvatarIndex,
        isHost: false,
        isReady: false,
        connected: true,
        lastActive: DateTime.now().millisecondsSinceEpoch,
      );

      await roomService.joinRoom(normalizedCode, player);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LobbyScreen(
            roomCode: normalizedCode,
            isHost: false,
            isMockMode: widget.isMockMode,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.neonPink,
        ),
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
        title: Text('JOIN RACE ROOM', style: AppTypography.headingMedium),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Big Room Code Input
            Text('ENTER 6-LETTER ROOM CODE', style: AppTypography.hudLabel),
            const SizedBox(height: 8),
            TextField(
              controller: _roomCodeController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: AppTypography.gameTitle.copyWith(
                letterSpacing: 8.0,
                fontSize: 28,
                color: AppColors.electricCyan,
              ),
              decoration: const InputDecoration(
                hintText: 'e.g. KV7R8M',
                counterText: '',
                prefixIcon: Icon(Icons.pin_rounded, color: AppColors.electricCyan),
              ),
            ),
            const SizedBox(height: 20),
            // Driver Profile
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
            const SizedBox(height: 28),
            ArcadeButton(
              text: 'ENTER RACE LOBBY',
              icon: Icons.login_rounded,
              primaryColor: AppColors.electricGreen,
              isLoading: _isLoading,
              onPressed: _handleJoinRoom,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

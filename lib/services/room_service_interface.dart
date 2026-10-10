import '../core/constants/app_constants.dart';
import '../models/player_model.dart';
import '../models/room_model.dart';

abstract class IRoomService {
  Future<String> createRoom({
    required String hostId,
    required String hostNickname,
    required String carId,
    required int carColorValue,
    required int avatarIndex,
    required int maxPlayers,
    required TextDifficulty difficulty,
    required TextCategory category,
  });

  Future<RoomModel?> getRoom(String roomCode);

  Future<void> joinRoom(String roomCode, PlayerModel player);

  Future<void> toggleReady(String roomCode, String playerId, bool isReady);

  Future<void> startRace(String roomCode, {String? targetText});

  Future<void> updateProgress({
    required String roomCode,
    required String playerId,
    required double progress,
    required double wpm,
    required double accuracy,
    required bool finished,
    required bool nitroActive,
  });

  Future<void> requestRematch(String roomCode, TextCategory category, TextDifficulty difficulty);

  Future<void> kickPlayer(String roomCode, String playerId);

  Future<void> leaveRoom(String roomCode, String playerId);

  Stream<RoomModel?> roomStream(String roomCode);
  
  void dispose();
}

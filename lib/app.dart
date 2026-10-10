import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/mock_room_service.dart';
import 'services/room_service.dart';
import 'services/storage_service.dart';

class TypeRacerApp extends StatelessWidget {
  final StorageService storageService;

  const TypeRacerApp({
    super.key,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        Provider<RoomService>(create: (_) => RoomService()),
        Provider<MockRoomService>(create: (_) => MockRoomService()),
      ],
      child: MaterialApp(
        title: 'TypeRacer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}

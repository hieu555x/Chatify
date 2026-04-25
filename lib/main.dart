import 'package:chattify/constant.dart';
import 'package:chattify/cubit/language/local_cubit.dart';
import 'package:chattify/cubit/profile/profiles_cubit.dart';
import 'package:chattify/cubit/rooms/rooms_cubit.dart';
import 'package:chattify/cubit/theme/theme_cubit.dart';
import 'package:chattify/env.dart';
import 'package:chattify/services/navigation_handler.dart';
import 'package:chattify/services/notification_service.dart';
import 'package:chattify/view/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final navigationHandler = NavigationHandler();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // Initialize notification service
  await NotificationService().initialize(
    onNotificationTap: (roomId, otherUserId) {
      // Navigate to the chat room when notification is tapped
      navigationHandler.handleNotificationTap(
        roomId: roomId,
        otherUserId: otherUserId,
      );
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
        BlocProvider<LocaleCubit>(create: (context) => LocaleCubit()),
        BlocProvider<ProfilesCubit>(create: (context) => ProfilesCubit()),
        BlocProvider<RoomCubit>(
          create: (context) => RoomCubit(
            profilesCubit: context.read<ProfilesCubit>(),
          ),
        ),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp(
                title: 'Chatify',
                debugShowCheckedModeBanner: false,
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: themeMode,
                navigatorKey: navigationHandler.navigatorKey,
                locale: locale,
                localizationsDelegates: [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: [Locale('en'), Locale('vi')],
                home: SplashPage(),
              );
            },
          );
        },
      ),
    );
  }
}

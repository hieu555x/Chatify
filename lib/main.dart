import 'package:chattify/constant.dart';
import 'package:chattify/cubit/language/local_cubit.dart';
import 'package:chattify/cubit/theme/theme_cubit.dart';
import 'package:chattify/env.dart';
import 'package:chattify/services/notification_service.dart';
import 'package:chattify/view/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  await NotificationService().initialize();

  NotificationService.setNavigatorKey(navigatorKey);

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
                navigatorKey: navigatorKey,
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

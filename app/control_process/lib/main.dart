import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'provider/connection_provider.dart';
import 'services/mqtt_service.dart';
import 'provider/permission_provider.dart';
import 'provider/devices_provider.dart';
import 'screen/menu_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static String title = "Controle de Processos";

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => PermissionProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (context) => MqttService(),
          lazy: false,
        ),
        ChangeNotifierProxyProvider2<MqttService, PermissionProvider,
            DevicesProvider>(
          create: (context) => DevicesProvider(),
          update: (context, mqttProvider, permissionProvider, devicesProvider) {
            if (devicesProvider != null) {
              return devicesProvider..update(mqttProvider, permissionProvider);
            } else {
              return DevicesProvider()
                ..update(mqttProvider, permissionProvider);
            }
          },
        ),
        ChangeNotifierProxyProvider<PermissionProvider, ConnectionProvider>(
          create: (context) => ConnectionProvider(),
          update: (context, permissionProvider, connectionProvider) {
            if (connectionProvider != null) {
              return connectionProvider..updatePermissions(permissionProvider);
            } else {
              return ConnectionProvider()
                ..updatePermissions(permissionProvider);
            }
          },
          lazy: false,
        ),
      ],
      child: MaterialApp(
        title: title,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('pt', 'BR')],
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          cupertinoOverrideTheme: const CupertinoThemeData(
            primaryColor: Color.fromRGBO(26, 26, 26, 1),
            primaryContrastingColor: Color.fromRGBO(26, 26, 26, 1),
            barBackgroundColor: Color.fromRGBO(26, 26, 26, 0.75),
            scaffoldBackgroundColor: Color.fromRGBO(26, 26, 26, 1),
            textTheme: CupertinoTextThemeData(
              primaryColor: Color.fromRGBO(26, 26, 26, 1),
            ),
            applyThemeToAll: true,
          ),
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromRGBO(26, 26, 26, 1)),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color.fromRGBO(26, 26, 26, 1),
          appBarTheme: const AppBarTheme(
            color: Color.fromRGBO(26, 26, 26, 1),
            titleTextStyle: TextStyle(
              fontSize: 26,
              fontStyle: FontStyle.normal,
              fontFamily: "Roboto",
              color: Color.fromRGBO(246, 246, 246, 1),
            ),
            surfaceTintColor: Color.fromRGBO(26, 26, 26, 1),
            foregroundColor: Color.fromRGBO(246, 246, 246, 1),
            shadowColor: Color.fromRGBO(246, 246, 246, 1),
            elevation: 0,
          ),
          textTheme: const TextTheme(
            titleSmall: TextStyle(
              fontFamily: "Roboto",
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(26, 26, 26, 1),
              fontSize: 48,
            ),
            headlineSmall: TextStyle(
              fontSize: 24,
              fontStyle: FontStyle.normal,
              fontFamily: "Roboto",
              color: Color.fromRGBO(26, 26, 26, 1),
            ),
            bodyLarge: TextStyle(
              fontFamily: "Roboto",
              color: Color.fromRGBO(26, 26, 26, 1),
              fontSize: 20,
            ),
            bodyMedium: TextStyle(
              fontSize: 20,
              fontFamily: "Roboto",
              color: Color.fromRGBO(26, 26, 26, 1),
            ),
            labelSmall: TextStyle(
              fontFamily: "Roboto",
              color: Color.fromRGBO(26, 26, 26, 1),
              fontSize: 14,
            ),
          ),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Color.fromRGBO(26, 26, 26, 1),
            selectionColor: Color.fromRGBO(26, 26, 26, 0.25),
            selectionHandleColor: Color.fromRGBO(26, 26, 26, 1),
          ),
          dividerTheme: const DividerThemeData(
            color: Color.fromRGBO(166, 60, 60, 1),
            thickness: 1,
          ),
          cardTheme: const CardTheme(
            elevation: 8,
            color: Colors.white70,
            surfaceTintColor: Color.fromRGBO(246, 246, 246, 1),
            shadowColor: Color.fromRGBO(246, 246, 246, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            hintStyle: TextStyle(
              fontSize: 16,
              fontFamily: "Roboto",
              color: Color.fromRGBO(26, 26, 26, 1),
            ),
            prefixIconColor: Color.fromRGBO(26, 26, 26, 1),
            prefixStyle: TextStyle(
              fontFamily: "Roboto",
              color: Color.fromRGBO(26, 26, 26, 1),
              fontSize: 20,
            ),
            labelStyle: TextStyle(
              fontFamily: "Roboto",
              color: Color.fromRGBO(26, 26, 26, 1),
              fontSize: 20,
            ),
            suffixIconColor: Color.fromRGBO(26, 26, 26, 1),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(),
            focusColor: Color.fromRGBO(246, 246, 246, 1),
            fillColor: Color.fromRGBO(246, 246, 246, 1),
            isDense: true,
            hoverColor: Color.fromRGBO(246, 246, 246, 1),
          ),
          iconTheme: const IconThemeData(
            size: 32,
            color: Color.fromRGBO(166, 60, 60, 1),
          ),
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            linearMinHeight: 1,
            color: Color.fromRGBO(166, 60, 60, 1),
            circularTrackColor: Color.fromRGBO(26, 26, 26, 1),
          ),
          textButtonTheme: const TextButtonThemeData(
            style: ButtonStyle(
              alignment: Alignment.center,
              textStyle: WidgetStatePropertyAll(
                TextStyle(
                  fontFamily: "Roboto",
                  color: Color.fromRGBO(26, 26, 26, 1),
                  fontSize: 22,
                ),
              ),
              foregroundColor:
                  WidgetStatePropertyAll(Color.fromRGBO(26, 26, 26, 1)),
            ),
          ),
          filledButtonTheme: const FilledButtonThemeData(
            style: ButtonStyle(
              textStyle: WidgetStatePropertyAll(
                TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 22,
                ),
              ),
              iconColor: WidgetStatePropertyAll(
                Color.fromRGBO(26, 26, 26, 1),
              ),
              foregroundColor: WidgetStatePropertyAll(
                Color.fromRGBO(26, 26, 26, 1),
              ),
              backgroundColor:
                  WidgetStatePropertyAll(Color.fromRGBO(246, 246, 246, 1)),
              surfaceTintColor:
                  WidgetStatePropertyAll(Color.fromRGBO(246, 246, 246, 1)),
              overlayColor:
                  WidgetStatePropertyAll(Color.fromRGBO(103, 58, 183, 0.25)),
              splashFactory: InkRipple.splashFactory,
            ),
          ),
          elevatedButtonTheme: const ElevatedButtonThemeData(
            style: ButtonStyle(
              elevation: WidgetStatePropertyAll(4),
              textStyle: WidgetStatePropertyAll(
                TextStyle(
                  fontFamily: "Roboto",
                  color: Color.fromRGBO(246, 246, 246, 1),
                  fontSize: 22,
                ),
              ),
              foregroundColor:
                  WidgetStatePropertyAll(Color.fromRGBO(246, 246, 246, 1)),
              backgroundColor:
                  WidgetStatePropertyAll(Color.fromRGBO(26, 26, 26, 1)),
              surfaceTintColor:
                  WidgetStatePropertyAll(Color.fromRGBO(26, 26, 26, 1)),
              shadowColor:
                  WidgetStatePropertyAll(Color.fromRGBO(246, 246, 246, 1)),
              overlayColor:
                  WidgetStatePropertyAll(Color.fromRGBO(103, 58, 183, 0.25)),
              splashFactory: InkRipple.splashFactory,
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          switchTheme: SwitchThemeData(
            trackColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.deepPurple;
                } else {
                  return Colors.white;
                }
              },
            ),
          ),
          sliderTheme: const SliderThemeData(
            valueIndicatorColor: Colors.deepPurple,
            activeTrackColor: Colors.deepPurple,
            thumbColor: Colors.deepPurple,
          ),
          tabBarTheme: const TabBarTheme(
            overlayColor:
                WidgetStatePropertyAll(Color.fromRGBO(0xb3, 0x88, 0xff, 0.5)),
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            labelStyle: TextStyle(
              fontFamily: "Roboto",
              fontSize: 26,
            ),
            unselectedLabelColor: Colors.deepPurple,
            unselectedLabelStyle: TextStyle(
              fontFamily: "Roboto",
              fontSize: 26,
            ),
          ),
        ),
        home: const MenuScreen(),
      ),
    );
  }
}

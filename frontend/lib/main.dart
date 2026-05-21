import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app_keys.dart';
import 'env_parse.dart';
import 'screens/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final raw = normalizeEnvText(await rootBundle.loadString('.env'));
    final parsed = parseDotEnvManual(raw);
    final envBody = parsed.entries.map((e) => '${e.key}=${e.value}').join('\n');
    dotenv.testLoad(fileInput: envBody);
    assert(() {
      final t = dotenv.env['MICROSOFT_TENANT_ID']?.trim() ?? '';
      final c = dotenv.env['MICROSOFT_CLIENT_ID']?.trim() ?? '';
      debugPrint(
        'Loaded .env from assets (${dotenv.env.length} keys: ${dotenv.env.keys.join(", ")}). '
        'Microsoft: tenantId set=${t.isNotEmpty}, clientId set=${c.isNotEmpty}',
      );
      return true;
    }());
  } catch (e, stackTrace) {
    debugPrint('Could not load .env from assets: $e');
    debugPrint('$stackTrace');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: appScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'CampusPark',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      home: const LoginPage(),
    );
  }
}
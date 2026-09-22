import 'package:flutter/material.dart';

import 'screens/areas_page.dart';
import 'services/api_service.dart';
import 'theme/rotary_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RooterApp());
}

class RooterApp extends StatelessWidget {
  const RooterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiService();

    return MaterialApp(
      title: 'Rooter — Mato Grosso',
      debugShowCheckedModeBanner: false,
      theme: RotaryTheme.light(),
      home: AreasPage(api: api),
    );
  }
}

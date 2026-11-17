import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      title: 'Distrito 4440',
      debugShowCheckedModeBanner: false,
      theme: RotaryTheme.dark(),
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: RotaryTheme.overlayStyle,
          child: ColoredBox(
            color: RotaryTheme.background,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
      home: AreasPage(api: api),
    );
  }
}

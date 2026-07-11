import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Uygulamanın tema tercihi. Varsayılan dark: Move Beyond kimliğinin doğal hali.
/// Sprint 5'te Settings sayfasındaki anahtara bağlanacak.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

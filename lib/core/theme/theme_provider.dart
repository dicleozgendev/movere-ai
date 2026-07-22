import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The app's theme preference. Default dark: the natural state of the Move Beyond identity.
/// Will be wired to the switch on the Settings page in Sprint 5.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

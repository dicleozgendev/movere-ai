import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The app's current language — defaults explicitly to English rather
/// than following the device's system language, so a Turkish phone
/// doesn't silently open the app in Turkish before the user has chosen
/// anything. Sign In in Settings switches this.
///
/// Kept in memory for now — the same pattern the theme toggle used before
/// SQLite existed; persisting the choice is a small follow-up (a single
/// row in the existing local database, same shape as the user profile).
final localeProvider = StateProvider<Locale?>((ref) => const Locale('en'));

const supportedLocales = [Locale('en'), Locale('tr')];

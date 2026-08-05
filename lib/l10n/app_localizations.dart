import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @onboardingFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get onboardingFocusTitle;

  /// No description provided for @onboardingFocusDescription.
  ///
  /// In en, this message translates to:
  /// **'Silence distractions, start focus sessions and discover the power of deep work.'**
  String get onboardingFocusDescription;

  /// No description provided for @onboardingProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get onboardingProgressTitle;

  /// No description provided for @onboardingProgressDescription.
  ///
  /// In en, this message translates to:
  /// **'Track your digital habits with your Reality Score and see exactly where you stand every day.'**
  String get onboardingProgressDescription;

  /// No description provided for @onboardingBreakFreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Break Free'**
  String get onboardingBreakFreeTitle;

  /// No description provided for @onboardingBreakFreeDescription.
  ///
  /// In en, this message translates to:
  /// **'With Academy content and personal insights, take control of your life — not just your screen.'**
  String get onboardingBreakFreeDescription;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcomeBack;

  /// No description provided for @loginTagline.
  ///
  /// In en, this message translates to:
  /// **'Focus, progress, break free.'**
  String get loginTagline;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginSignIn;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account yet?'**
  String get loginNoAccount;

  /// No description provided for @loginSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get loginSignUp;

  /// No description provided for @dashboardWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get dashboardWelcomeBack;

  /// No description provided for @dashboardTagline.
  ///
  /// In en, this message translates to:
  /// **'Focus, progress, break free.'**
  String get dashboardTagline;

  /// No description provided for @dashboardFocusTimeToday.
  ///
  /// In en, this message translates to:
  /// **'Focus time today'**
  String get dashboardFocusTimeToday;

  /// No description provided for @dashboardRealityScore.
  ///
  /// In en, this message translates to:
  /// **'Reality Score'**
  String get dashboardRealityScore;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSupport;

  /// No description provided for @settingsEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get settingsEditProfile;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsHelpFeedback.
  ///
  /// In en, this message translates to:
  /// **'Help & Feedback'**
  String get settingsHelpFeedback;

  /// No description provided for @settingsAboutMovere.
  ///
  /// In en, this message translates to:
  /// **'About Movere'**
  String get settingsAboutMovere;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settingsSignOut;

  /// No description provided for @settingsSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get settingsSignedInAs;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get languageTurkish;

  /// No description provided for @dashboardStartFirstSession.
  ///
  /// In en, this message translates to:
  /// **'Start your first session'**
  String get dashboardStartFirstSession;

  /// No description provided for @dashboardGoalPrefix.
  ///
  /// In en, this message translates to:
  /// **'Goal: '**
  String get dashboardGoalPrefix;

  /// No description provided for @dashboardDailyGoals.
  ///
  /// In en, this message translates to:
  /// **'Daily Goals'**
  String get dashboardDailyGoals;

  /// No description provided for @dashboardMyProgress.
  ///
  /// In en, this message translates to:
  /// **'My Progress'**
  String get dashboardMyProgress;

  /// No description provided for @dashboardWeeklyView.
  ///
  /// In en, this message translates to:
  /// **'Weekly view'**
  String get dashboardWeeklyView;

  /// No description provided for @dashboardDeepFocus.
  ///
  /// In en, this message translates to:
  /// **'Deep Focus'**
  String get dashboardDeepFocus;

  /// No description provided for @dashboardStartNow.
  ///
  /// In en, this message translates to:
  /// **'Start now'**
  String get dashboardStartNow;

  /// No description provided for @dashboardDistractionsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Distractions blocked today'**
  String get dashboardDistractionsBlocked;

  /// No description provided for @dashboardFocusStreak.
  ///
  /// In en, this message translates to:
  /// **'Focus streak'**
  String get dashboardFocusStreak;

  /// No description provided for @dashboardQuote.
  ///
  /// In en, this message translates to:
  /// **'\"What you focus on, expands.\"'**
  String get dashboardQuote;

  /// No description provided for @focusHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Deep Focus'**
  String get focusHeaderTitle;

  /// No description provided for @focusHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your mode. Silence the noise.'**
  String get focusHeaderSubtitle;

  /// No description provided for @focusModeQuick.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get focusModeQuick;

  /// No description provided for @focusModeQuickDesc.
  ///
  /// In en, this message translates to:
  /// **'Short and sharp'**
  String get focusModeQuickDesc;

  /// No description provided for @focusModeClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get focusModeClassic;

  /// No description provided for @focusModeClassicDesc.
  ///
  /// In en, this message translates to:
  /// **'The proven rhythm'**
  String get focusModeClassicDesc;

  /// No description provided for @focusModeDeep.
  ///
  /// In en, this message translates to:
  /// **'Deep'**
  String get focusModeDeep;

  /// No description provided for @focusModeDeepDesc.
  ///
  /// In en, this message translates to:
  /// **'Real deep work'**
  String get focusModeDeepDesc;

  /// No description provided for @focusModeMarathon.
  ///
  /// In en, this message translates to:
  /// **'Marathon'**
  String get focusModeMarathon;

  /// No description provided for @focusModeMarathonDesc.
  ///
  /// In en, this message translates to:
  /// **'For the big things'**
  String get focusModeMarathonDesc;

  /// No description provided for @focusStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start Focus'**
  String get focusStartButton;

  /// No description provided for @focusInterruptionNote.
  ///
  /// In en, this message translates to:
  /// **'Leaving the app during a session counts as an interruption.'**
  String get focusInterruptionNote;

  /// No description provided for @focusEndSession.
  ///
  /// In en, this message translates to:
  /// **'End Session'**
  String get focusEndSession;

  /// No description provided for @focusStartAnother.
  ///
  /// In en, this message translates to:
  /// **'Start Another Session'**
  String get focusStartAnother;

  /// No description provided for @focusFocusedLabel.
  ///
  /// In en, this message translates to:
  /// **'Focused'**
  String get focusFocusedLabel;

  /// No description provided for @focusPlannedLabel.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get focusPlannedLabel;

  /// No description provided for @focusInterruptionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Interruptions'**
  String get focusInterruptionsLabel;

  /// No description provided for @academyHeader.
  ///
  /// In en, this message translates to:
  /// **'MOVERE ACADEMY'**
  String get academyHeader;

  /// No description provided for @academyTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore. Understand. Transform.'**
  String get academyTitle;

  /// No description provided for @academySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Understanding the digital world is the first step to reclaiming your attention.'**
  String get academySubtitle;

  /// No description provided for @academyAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get academyAll;

  /// No description provided for @academyListenToLesson.
  ///
  /// In en, this message translates to:
  /// **'Listen to this lesson'**
  String get academyListenToLesson;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get registerFullName;

  /// No description provided for @registerConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerConfirmPassword;

  /// No description provided for @settingsPrivacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get settingsPrivacySecurity;

  /// No description provided for @settingsMovereAccount.
  ///
  /// In en, this message translates to:
  /// **'Movere account'**
  String get settingsMovereAccount;

  /// No description provided for @dashboardProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get dashboardProgress;

  /// No description provided for @dashboardAcademy.
  ///
  /// In en, this message translates to:
  /// **'Academy'**
  String get dashboardAcademy;

  /// No description provided for @dashboardBlockedApp.
  ///
  /// In en, this message translates to:
  /// **'Blocked App'**
  String get dashboardBlockedApp;

  /// No description provided for @dashboardAppBlockingSoon.
  ///
  /// In en, this message translates to:
  /// **'App blocking arrives with Focus Mode.'**
  String get dashboardAppBlockingSoon;

  /// No description provided for @dashboardHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get dashboardHome;

  /// No description provided for @dashboardUsageInsights.
  ///
  /// In en, this message translates to:
  /// **'Usage Insights'**
  String get dashboardUsageInsights;

  /// No description provided for @dashboardLightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get dashboardLightMode;

  /// No description provided for @dashboardDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get dashboardDarkMode;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @dashboardSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get dashboardSettings;

  /// No description provided for @realityScoreStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong day. Your digital balance is paying off.'**
  String get realityScoreStrong;

  /// No description provided for @realityScoreGood.
  ///
  /// In en, this message translates to:
  /// **'Good progress. Keep today\'s momentum going.'**
  String get realityScoreGood;

  /// No description provided for @realityScoreSlow.
  ///
  /// In en, this message translates to:
  /// **'A slow start today — one focus session changes this fast.'**
  String get realityScoreSlow;

  /// No description provided for @realityScoreNone.
  ///
  /// In en, this message translates to:
  /// **'No signal yet today. Start a focus session to begin.'**
  String get realityScoreNone;

  /// No description provided for @dashboardScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get dashboardScoreLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

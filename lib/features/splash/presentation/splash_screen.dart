import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

/// Açılış ekranı: marka kimliği + 2.5 sn sonra Onboarding'e otomatik geçiş.
/// (İleride: kullanıcı daha önce onboarding'i gördüyse direkt login'e,
/// oturum açıksa dashboard'a yönlenecek — Sprint 4'te session ile gelecek.)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Logo ve sloganın yumuşak belirmesi için opaklık animasyonu.
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Ekran 2.5 sn görünür, sonra kendini Onboarding ile DEĞİŞTİRİR.
    // pushReplacement: geri tuşu splash'e dönemesin diye push yerine bunu
    // kullanıyoruz — splash yığından (stack) tamamen çıkar.
    _timer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // ekran erken kapanırsa timer boşa çalışmasın
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark, // splash her zaman koyu
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Geçici tipografik logo — 3D logo PNG'si gelince
              // buraya Image.asset(...) konulacak.
              ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  colors: AppColors.brandGradient,
                ).createShader(rect),
                child: Text(
                  'MOVERE',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white, // ShaderMask bunun üstüne gradient basar
                        letterSpacing: 10,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                'MOVE BEYOND',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 6,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

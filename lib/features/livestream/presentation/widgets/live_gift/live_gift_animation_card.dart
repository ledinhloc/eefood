import 'package:eefood/features/livestream/data/model/send_gift_response.dart';
import 'package:eefood/features/livestream/presentation/widgets/live_gift/live_gift_card/live_gift_card.dart';
import 'package:flutter/material.dart';

class LiveGiftAnimationCard extends StatefulWidget {
  final SendGiftResponse gift;
  final VoidCallback onComplete;

  final Duration displayDuration;
  const LiveGiftAnimationCard({
    super.key,
    required this.gift,
    required this.onComplete,
    this.displayDuration = const Duration(seconds: 4),
  });

  @override
  State<LiveGiftAnimationCard> createState() => _LiveGiftAnimationCardState();
}

class _LiveGiftAnimationCardState extends State<LiveGiftAnimationCard>
    with TickerProviderStateMixin {
  // Slide + fade vào
  late final AnimationController _enterCtrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  // Shimmer chạy ngang
  late final AnimationController _shimmerCtrl;

  // Scale bounce khi card vào
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;

  // Particles
  late final AnimationController _particleCtrl;

  // Slide-out khi dismiss
  late final AnimationController _exitCtrl;
  late final Animation<Offset> _exitSlide;
  late final Animation<double> _exitFade;

  bool _dismissed = false;

  @override
  void initState() {
    super.initState();

    // --- Enter ---
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(-1.4, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _enterCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // --- Bounce scale ---
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnim = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut));

    // --- Shimmer ---
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    // --- Particles ---
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // --- Exit ---
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _exitSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.4, 0),
    ).animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeInCubic));
    _exitFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _exitCtrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    // Bắt đầu sequence
    _startSequence();
  }

  Future<void> _startSequence() async {
    _enterCtrl.forward();
    _bounceCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _particleCtrl.forward();
    await Future.delayed(widget.displayDuration);
    if (!mounted || _dismissed) return;
    _dismissed = true;
    await _exitCtrl.forward();
    if (mounted) widget.onComplete();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _shimmerCtrl.dispose();
    _bounceCtrl.dispose();
    _particleCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 420,
      left: 0,
      child: SlideTransition(
        position: _exitCtrl.isAnimating ? _exitSlide : _slideAnim,
        child: FadeTransition(
          opacity: _exitCtrl.isAnimating ? _exitFade : _fadeAnim,
          child: ScaleTransition(
            scale: _bounceAnim,
            child: LiveGiftCard(
              gift: widget.gift,
              shimmerCtrl: _shimmerCtrl,
              particleCtrl: _particleCtrl,
            ),
          ),
        ),
      ),
    );
  }
}

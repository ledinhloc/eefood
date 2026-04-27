import 'package:flutter/material.dart';

class StepImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  const StepImageCarousel({super.key, required this.imageUrls});

  @override
  State<StepImageCarousel> createState() => _StepImageCarouselState();
}

class _StepImageCarouselState extends State<StepImageCarousel> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (p) => setState(() => _page = p),
              itemCount: widget.imageUrls.length,
              itemBuilder: (_, i) => Image.network(
                widget.imageUrls[i],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF1E1E1E),
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.white30,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (widget.imageUrls.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.imageUrls.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: _page == i ? 20 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: _page == i
                      ? const Color(0xFFFF6B35)
                      : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

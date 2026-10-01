import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class ProfileImageViewer extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final String heroTag;

  const ProfileImageViewer({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.heroTag,
  });

  static void show({
    required String? imageUrl,
    required String name,
    required String heroTag,
  }) {
    Get.to(
      () =>
          ProfileImageViewer(imageUrl: imageUrl, name: name, heroTag: heroTag),
      opaque: false,
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 320),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.82),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background dismissal tap
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Get.back(),
              child: const SizedBox.expand(),
            ),

            // Center Modal Content
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                constraints: const BoxConstraints(maxWidth: 340),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x40000000),
                      blurRadius: 30,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Smooth Morphing Hero Image
                    Hero(
                      tag: heroTag,
                      flightShuttleBuilder:
                          (
                            flightContext,
                            animation,
                            flightDirection,
                            fromHeroContext,
                            toHeroContext,
                          ) {
                            final borderRadiusTween = BorderRadiusTween(
                              begin: BorderRadius.circular(
                                100,
                              ), // Circular source avatar
                              end: const BorderRadius.vertical(
                                top: Radius.circular(24),
                              ), // Top rounded destination
                            );

                            return AnimatedBuilder(
                              animation: animation,
                              builder: (context, child) {
                                return ClipRRect(
                                  borderRadius: borderRadiusTween.evaluate(
                                    animation,
                                  )!,
                                  child: Material(
                                    color: KazinColors.primaryNavy,
                                    child:
                                        imageUrl != null && imageUrl!.isNotEmpty
                                        ? Image.network(
                                            imageUrl!,
                                            height: 320,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _buildFallback(),
                                          )
                                        : _buildFallback(),
                                  ),
                                );
                              },
                            );
                          },
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        child: Material(
                          color: KazinColors.primaryNavy,
                          child: imageUrl != null && imageUrl!.isNotEmpty
                              ? Image.network(
                                  imageUrl!,
                                  height: 320,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _buildFallback(),
                                )
                              : _buildFallback(),
                        ),
                      ),
                    ),

                    // Guide Details Banner
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 18,
                      ),
                      child: Column(
                        children: [
                          Text(
                            name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: KazinColors.primaryNavy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Certified DMC Guide",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: KazinColors.secondaryTeal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Close Icon
            Positioned(
              top: 16,
              right: 20,
              child: Material(
                color: Colors.white24,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Get.back(),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallback() {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "G";
    return Container(
      height: 320,
      width: double.infinity,
      color: KazinColors.primaryNavy,
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

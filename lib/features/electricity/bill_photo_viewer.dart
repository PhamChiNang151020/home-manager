import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/app_loading.dart";

Future<void> showBillPhotoViewer({
  required BuildContext context,
  required String photoPath,
  required BillPhotoService photos,
}) async {
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: S.photo,
    barrierColor: Colors.black.withValues(alpha: 0.92),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _BillPhotoFullscreen(photoPath: photoPath, photos: photos);
    },
  );
}

class _BillPhotoFullscreen extends StatefulWidget {
  const _BillPhotoFullscreen({required this.photoPath, required this.photos});

  final String photoPath;
  final BillPhotoService photos;

  @override
  State<_BillPhotoFullscreen> createState() => _BillPhotoFullscreenState();
}

class _BillPhotoFullscreenState extends State<_BillPhotoFullscreen> {
  String? _url;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final url = await widget.photos.signedUrl(widget.photoPath);
      if (mounted) {
        setState(() {
          _url = url;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "$e";
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child:
                    _loading
                        ? const AppLoader(size: 72)
                        : _error != null
                        ? Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Text(
                            _error!,
                            style: TextStyle(color: colors.error),
                            textAlign: TextAlign.center,
                          ),
                        )
                        : _url == null
                        ? const SizedBox.shrink()
                        : InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 4,
                          child: Image.network(
                            _url!,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const SizedBox(
                                width: 120,
                                height: 120,
                                child: Center(child: AppLoader()),
                              );
                            },
                            errorBuilder:
                                (_, __, ___) => Text(
                                  S.noPhoto,
                                  style: TextStyle(color: colors.textMuted),
                                ),
                          ),
                        ),
              ),
            ),
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                color: Colors.white,
                tooltip: S.cancel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

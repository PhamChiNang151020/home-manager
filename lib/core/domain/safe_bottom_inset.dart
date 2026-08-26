/// Bottom inset for bars that must clear the iOS home indicator.
///
/// Flutter 3.29 on newer iPhone simulators can report a Dynamic Island top
/// inset but `padding.bottom == 0`, so SafeArea does nothing and the nav sits
/// on the home indicator. Pass window insets from `MediaQueryData.fromView`,
/// not `MediaQuery.of` — Scaffold zeros top padding on bottomNavigationBar.
double safeBottomInset({
  required double paddingBottom,
  required double viewPaddingBottom,
  required double paddingTop,
  required bool isCupertino,
}) {
  final reported =
      paddingBottom > viewPaddingBottom ? paddingBottom : viewPaddingBottom;
  if (reported > 0) return reported;
  if (isCupertino && paddingTop >= 44) return 34;
  return 0;
}

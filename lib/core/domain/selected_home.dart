import "package:home_manager/core/models/home.dart";

/// Picks the home to show after a list refresh.
///
/// Preference: in-memory selection still in [homes], then [persistedId],
/// then the first home. Never jumps to `homes.first` while the saved id
/// is still a member of the list.
Home? resolveSelectedHome({
  required List<Home> homes,
  Home? current,
  String? persistedId,
}) {
  if (homes.isEmpty) {
    return null;
  }
  if (current != null) {
    for (final home in homes) {
      if (home.id == current.id) {
        return home;
      }
    }
  }
  if (persistedId != null && persistedId.isNotEmpty) {
    for (final home in homes) {
      if (home.id == persistedId) {
        return home;
      }
    }
  }
  return homes.first;
}

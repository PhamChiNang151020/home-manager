import "package:home_manager/core/models/home.dart";

/// Picks the home to show after a list refresh.
///
/// Preference: [preferId] (just-joined home), then in-memory selection still
/// in [homes], then [persistedId], then the first home. Never jumps to
/// `homes.first` while the saved id is still a member of the list.
Home? resolveSelectedHome({
  required List<Home> homes,
  Home? current,
  String? persistedId,
  String? preferId,
}) {
  if (homes.isEmpty) {
    return null;
  }
  final preferred = _byId(homes, preferId);
  if (preferred != null) return preferred;
  if (current != null) {
    final stillThere = _byId(homes, current.id);
    if (stillThere != null) return stillThere;
  }
  final persisted = _byId(homes, persistedId);
  if (persisted != null) return persisted;
  return homes.first;
}

Home? _byId(List<Home> homes, String? id) {
  if (id == null || id.isEmpty) return null;
  for (final home in homes) {
    if (home.id == id) return home;
  }
  return null;
}

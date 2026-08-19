import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:mocktail/mocktail.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late BillPhotoService photos;

  setUp(() {
    photos = BillPhotoService(MockSupabaseClient());
  });

  test("pathFor uses homes/id/yyyy-mm.jpg", () {
    expect(
      photos.pathFor(homeId: "abc", month: DateTime(2026, 3)),
      "homes/abc/2026-03.jpg",
    );
  });
}

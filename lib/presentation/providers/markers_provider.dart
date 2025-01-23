import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/marker_model.dart';

final markersProvider = StateNotifierProvider<MarkersNotifier, List<CustomMarker>>((ref) {
  return MarkersNotifier();
});

class MarkersNotifier extends StateNotifier<List<CustomMarker>> {
  MarkersNotifier() : super([]);

  Future<void> addMarker(CustomMarker marker) async {
    state = [...state, marker];
  }
  void refreshMarkers() {
    state = [...state];
  }

  void removeMarker(String id) {
    state = state.where((marker) => marker.id != id).toList();
  }

  void updateMarker(CustomMarker updatedMarker) {
    state = state.map((marker) =>
    marker.id == updatedMarker.id ? updatedMarker : marker
    ).toList();
  }
}
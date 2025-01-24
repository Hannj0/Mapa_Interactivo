import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/marker_model.dart';
import '../providers/markers_provider.dart';
import 'delete_marker.dart';
import 'edit_marker.dart';

void showMarkersListBottomSheet({
  required BuildContext context,
  required Function(CustomMarker) onMarkerSelected,
}) {
  showModalBottomSheet(
    context: context,
    builder: (context) => MarkersListView(
      onMarkerSelected: (marker) {
        onMarkerSelected(marker);
        Navigator.pop(context);
      },
    ),
  );
}

class MarkersListView extends ConsumerWidget {
  final Function(CustomMarker) onMarkerSelected;

  const MarkersListView({
    Key? key,
    required this.onMarkerSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final markers = ref.watch(markersProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Marcadores Guardados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: markers.length,
              itemBuilder: (context, index) {
                final marker = markers[index];
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(marker.name),
                  subtitle: Text(
                    'Lat: ${marker.latitude.toStringAsFixed(4)}, '
                        'Lng: ${marker.longitude.toStringAsFixed(4)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showEditMarkerDialog(context, marker);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDeleteMarkerDialog(context, marker);
                        },
                      ),
                    ],
                  ),
                  onTap: () => onMarkerSelected(marker),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
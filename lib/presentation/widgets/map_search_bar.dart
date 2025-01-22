import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/mapbox_service.dart';
import '../../data/models/search_result.dart';
import '../providers/markers_provider.dart';
import '../../data/models/marker_model.dart';
import 'package:uuid/uuid.dart';

final mapboxServiceProvider = Provider((ref) => MapboxService());

class MapSearchBar extends ConsumerStatefulWidget {
  final Function(double latitude, double longitude)? onLocationSelected;

  const MapSearchBar({
    Key? key,
    this.onLocationSelected,
  }) : super(key: key);

  @override
  ConsumerState<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends ConsumerState<MapSearchBar> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<SearchResult> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounceTimer;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      // Dar tiempo para que se procese el tap en los resultados
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() => _searchResults = []);
        }
      });
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await ref.read(mapboxServiceProvider).searchPlaces(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Error al buscar ubicaciones');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _onLocationSelected(SearchResult result) async {
    try {
      // Crear un nuevo marcador
      final marker = CustomMarker(
        id: const Uuid().v4(),
        name: result.name,
        latitude: result.latitude,
        longitude: result.longitude,
      );

      // Agregar el marcador
      await ref.read(markersProvider.notifier).addMarker(marker);

      // Centrar el mapa en la ubicación seleccionada
      widget.onLocationSelected?.call(result.latitude, result.longitude);

      // Limpiar la búsqueda y quitar el foco
      if (mounted) {
        setState(() {
          _searchResults = [];
          _searchController.clear();
        });
        _focusNode.unfocus();
      }
    } catch (e) {
      _showError('Error al seleccionar la ubicación');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSearchBar(),
        if (_searchResults.isNotEmpty) _buildSearchResults(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Buscar ubicación...',
          border: InputBorder.none,
          icon: const Icon(Icons.search),
          suffixIcon: _buildSuffixIcon(),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (_isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (_searchController.text.isNotEmpty) {
      return IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          _searchController.clear();
          setState(() => _searchResults = []);
        },
      );
    }
    return null;
  }

  Widget _buildSearchResults() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final result = _searchResults[index];
          return ListTile(
            title: Text(
              result.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              result.address ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _onLocationSelected(result),
          );
        },
      ),
    );
  }
}

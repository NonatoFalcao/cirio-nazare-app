import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../data/routes_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedRoute = 0; // 0 = nenhuma, 1 = Círio, 2 = Trasladação, 3 = Rota até início
  List<LatLng> _userToStart = [];
  LatLng? _userLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Círio de Nazaré'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildButtonBar(),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: RoutesData.pontoInicial,
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                MarkerLayer(
                  markers: _buildMarkers(),
                ),
                if (_selectedRoute == 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: RoutesData.rotaCirio,
                        color: Colors.blue,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                if (_selectedRoute == 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: RoutesData.rotaTrasladacao,
                        color: Colors.green,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                if (_selectedRoute == 3 && _userToStart.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _userToStart,
                        color: Colors.orange,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonBar() {
    return Container(
      color: Colors.blue[900],
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButton('Círio', 1, Colors.blue),
          _buildButton('Trasladação', 2, Colors.green),
          _buildButton('Ir ao início', 3, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildButton(String label, int index, Color color) {
    final isSelected = _selectedRoute == index;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.white,
        foregroundColor: isSelected ? Colors.white : color,
      ),
      onPressed: () => _onButtonPressed(index),
      child: Text(label),
    );
  }

  List<Marker> _buildMarkers() {
    final pinPoint = _selectedRoute == 2
        ? RoutesData.pontoFinal
        : RoutesData.pontoInicial;
    List<Marker> markers = [
      Marker(
        point: pinPoint,
        child: const Icon(Icons.location_pin, color: Colors.red, size: 36),
      ),
    ];

    if (_userLocation != null) {
      markers.add(
        Marker(
          point: _userLocation!,
          child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
        ),
      );
    }

    return markers;
  }

  void _onButtonPressed(int index) async {
    if (index == 3) {
      await _loadUserLocation();
    }
    setState(() => _selectedRoute = index);
  }

  Future<void> _loadUserLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    Position pos = await Geolocator.getCurrentPosition();
    setState(() {
      _userLocation = LatLng(pos.latitude, pos.longitude);
      _userToStart = [
        _userLocation!,
        RoutesData.pontoInicial,
      ];
    });
  }
}
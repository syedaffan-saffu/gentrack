import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:testing_app/loc/loc_one.dart';

class LocPage extends StatefulWidget {
  final LatLng? latlng;
  const LocPage({super.key, this.latlng});

  @override
  State<LocPage> createState() => _LocPageState();
}

class _LocPageState extends State<LocPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BS Tracking Map"),
      ),
      body: FlutterMap(
        options: MapOptions(center: widget.latlng, zoom: 9.4),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: widget.latlng!,
                builder: (ctx) => Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

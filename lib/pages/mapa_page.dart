

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapasPage extends StatefulWidget{
  final double latitude;
  final double longitude;

  const MapasPage({ Key? key, required this.latitude, required this.longitude}) :
        super(key: key);

  @override
  _MapasPageState createState() => _MapasPageState();
}

class _MapasPageState extends State<MapasPage>{

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa Interno'),),
      body: GoogleMap(
        mapType: MapType.normal,
        markers: {
          Marker(
            markerId: MarkerId('1'),
            position: LatLng(widget.latitude, widget.longitude),
            infoWindow: const InfoWindow(
              title: 'Utfpr',
            )
          )
        },
      ),
    );
  }

}
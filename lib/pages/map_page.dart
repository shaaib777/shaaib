import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;

  // إحداثيات المدن
  final LatLng sanaa = const LatLng(15.354726, 44.206667); // صنعاء
  final LatLng aden = const LatLng(12.777319, 45.038975); // عدن
  final LatLng taiz = const LatLng(13.582750, 44.014827); // تعز

  // مجموعة العلامات
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    // إضافة العلامات
    markers.add(
      Marker(
        markerId: const MarkerId('sanaa'),
        position: sanaa,
        infoWindow: const InfoWindow(title: 'صنعاء', snippet: 'ارضية اربع لين حارة الجيش'),
      ),
    );
    markers.add(
      Marker(
        markerId: const MarkerId('aden'),
        position: aden,
        infoWindow: const InfoWindow(title: 'عدن', snippet: 'ارضية على شارعين'),
      ),
    );
    markers.add(
      Marker(
        markerId: const MarkerId('taiz'),
        position: taiz,
        infoWindow: const InfoWindow(title: 'تعز', snippet: 'مدينة الثقافة والفن'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('موقعنا'),
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
          // تحريك الكاميرا لتغطية جميع العلامات
          _moveCameraToIncludeAllMarkers();
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(14.5, 44.5), // مركز اليمن تقريبًا
          zoom: 7.0, // مستوى التكبير
        ),
        markers: markers, // عرض العلامات
      ),
    );
  }

  // دالة لتحريك الكاميرا لتغطية جميع العلامات
  void _moveCameraToIncludeAllMarkers() {
    if (markers.isEmpty) return;

    // تحديد حدود الخريطة
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        markers.map((m) => m.position.latitude).reduce((a, b) => a < b ? a : b),
        markers.map((m) => m.position.longitude).reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        markers.map((m) => m.position.latitude).reduce((a, b) => a > b ? a : b),
        markers.map((m) => m.position.longitude).reduce((a, b) => a > b ? a : b),
      ),
    );

    // تحريك الكاميرا
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../core/utils/theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late YandexMapController mapController;
  Point? myCurrentLocation;
  Position? _currentLocation;
  LocationPermission? permission;
  final YandexSearch yandexSearch = YandexSearch();
  final TextEditingController _searchTextController = TextEditingController();
  double searchHeight = 250;
  String? _selectedStreet;
  Point? _selectedPoint;

  List<SuggestItem> _suggestionList = [];
  final Point najotTalim = const Point(
    latitude: 41.2856806,
    longitude: 69.2034646,
  );

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
  }

  Future<SuggestSessionResult> _suggest() async {
    final resultWithSession = await YandexSuggest.getSuggestions(
      text: _searchTextController.text,
      boundingBox: const BoundingBox(
        northEast: Point(latitude: 56.0421, longitude: 38.0284),
        southWest: Point(latitude: 55.5143, longitude: 37.24841),
      ),
      suggestOptions: const SuggestOptions(
        suggestType: SuggestType.geo,
        suggestWords: true,
        userPosition: Point(latitude: 56.0321, longitude: 38),
      ),
    );

    return await resultWithSession.$2;
  }

  void _zoomToLocation(Point point) {
    mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: point,
          zoom: 17,
        ),
      ),
      animation: const MapAnimation(
        type: MapAnimationType.smooth,
        duration: 1.5,
      ),
    );
  }

  void _onSearchItemSelected(SuggestItem item) {
    setState(() {
      searchHeight = 0;
      myCurrentLocation = item.center;
    });
    _zoomToLocation(myCurrentLocation!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: (controller) {
              mapController = controller;
              mapController.moveCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: najotTalim,
                    zoom: 17,
                  ),
                ),
              );
            },
            onMapTap: (point) async {
              print(point);
              // List<Placemark> placemarks = await placemarkFromCoordinates(
              //   point.latitude,
              //   point.longitude,
              // );
              // if (placemarks.isNotEmpty) {
              //   print("${placemarks.first.street}");
              // }

              List<Placemark> placemarks = await placemarkFromCoordinates(
                point.latitude,
                point.longitude,
              );
              if (placemarks.isNotEmpty) {
                setState(() {
                  _selectedStreet = placemarks.first.street;
                  _selectedPoint = point;
                });
                _showLocationBottomSheet(context);
              }
            },
            mapType: MapType.vector,
            mapObjects: [
              PlacemarkMapObject(
                mapId: const MapObjectId("najotTalim"),
                point: najotTalim,
                opacity: 1,
                icon: PlacemarkIcon.single(
                  PlacemarkIconStyle(
                    scale: 0.2,
                    image: BitmapDescriptor.fromAssetImage(
                      "assets/marker1.png",
                    ),
                  ),
                ),
              ),
              if (myCurrentLocation != null)
                PlacemarkMapObject(
                  opacity: 1,
                  mapId: const MapObjectId("myCurrentLocation"),
                  point: myCurrentLocation!,
                  icon: PlacemarkIcon.single(
                    PlacemarkIconStyle(
                      scale: 0.15,
                      image:
                          BitmapDescriptor.fromAssetImage("assets/marker1.png"),
                    ),
                  ),
                ),
            ],
          ),
          Positioned(
            top: 70,
            left: 10,
            right: 10,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _suggestionList.isNotEmpty ? searchHeight : 0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: ListView.builder(
                itemCount: _suggestionList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () => _onSearchItemSelected(_suggestionList[index]),
                    title: Text(
                      _suggestionList[index].title,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      _suggestionList[index].subtitle!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 10,
            right: 10,
            child: Column(
              children: [
                TextField(
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    suffixIcon: _suggestionList.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                _searchTextController.text = "";
                                myCurrentLocation = null;
                                _suggestionList = [];
                              });
                            },
                            child: const Icon(CupertinoIcons.clear_fill,
                                color: Colors.grey),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.location_on_rounded,
                        color: Colors.teal),
                    hintText: "Search",
                    hintStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.teal),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  controller: _searchTextController,
                  onChanged: (value) async {
                    final res = await _suggest();
                    if (res.items != null) {
                      setState(() {
                        _suggestionList = res.items!.toSet().toList();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          Positioned(
            right: 10,
            top: MediaQuery.of(context).size.height / 2,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    mapController.moveCamera(CameraUpdate.zoomIn());
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.teal.withOpacity(.8),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
                const Gap(10),
                GestureDetector(
                  onTap: () {
                    mapController.moveCamera(CameraUpdate.zoomOut());
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.teal.withOpacity(.8),
                    ),
                    child: const Icon(Icons.remove, color: Colors.white),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.teal,
        onPressed: () async {
          _currentLocation = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          final Point currentPoint = Point(
            latitude: _currentLocation!.latitude,
            longitude: _currentLocation!.longitude,
          );
          _zoomToLocation(currentPoint);
        },
        child: const Icon(CupertinoIcons.location_fill, color: Colors.white),
      ),
    );
  }

  void _showLocationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Selected Location',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    "Tanlangan joy: ",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    _selectedStreet ?? 'Unknown street',
                    style: TextStyle(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, {
                    'street': _selectedStreet,
                    'latitude': _selectedPoint?.latitude,
                    'longitude': _selectedPoint?.longitude,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Select location',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart';
import 'package:cc_core/components/loading.dart';

import 'package:cc_core/models/core/ccApp.dart';
import 'package:cc_core/models/core/ccData.dart';
// import 'package:cc_core/screens/mapScreen/mapOverlay.dart';
// import 'package:permission_handler/permission_handler.dart';

/// ## MapScreen
/// A standard map widget with auto caching courtesy of [fileCache.dart]
class MapScreen extends StatefulWidget {
  MapScreen({
    this.mbTilesUrl,
    // this.mapOverlay,
    // this.locationDot,
    this.loadFromOSM = true,
    this.centre,
    this.onTap,
    this.mapController,
  });

  /// the url for the MBTiles file
  final String? mbTilesUrl;
  // final MapOverlay mapOverlay;
  // final LocationDot locationDot;
  final bool loadFromOSM;
  final LatLng? centre;
  final MapController? mapController;
  final void Function(LatLng)? onTap;
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Polygon> polygons = [];
  List<CircleMarker> circles = [];
  bool gotFile = false;
  File? mapFile;
  LatLng? centre;
  CircleLayerOptions? cirLayer;
  PolygonLayerOptions? polyLayer;
  OverlayImageLayerOptions? imageLayer;
  MapController? mapController;
  List<LayerOptions?> mapLayers = [];
  bool loading = true;
  TileLayerOptions? tileLayerOptions;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      // cirLayer = widget.mapOverlay.circleLayer;
      // polyLayer = widget.mapOverlay.polygonLayer;
      // imageLayer = widget.mapOverlay.imageLayer;
      if (widget.centre != null) centre = widget.centre;
      if (widget.mapController != null) {
        mapController = widget.mapController;
      } else {
        mapController = MapController();
      }
      loading = false;
    }

    if (!gotFile && !widget.loadFromOSM && widget.mbTilesUrl != null) {
      // time to load files
      CcData data = CcData(CcApp.of(context)!.database);
      // get map file
      data.getFile(widget.mbTilesUrl, "maps").then((val) {
        setState(() {
          mapFile = val;
          gotFile = true;
          tileLayerOptions = TileLayerOptions(
            // tileProvider: MBTilesImageProvider.fromFile(mapFile),
            keepBuffer: 6,
            tms: true,
          );
        });
      });

      return Loading("Loading map file");
    }

    if (widget.loadFromOSM) {
      tileLayerOptions = TileLayerOptions(
        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
        subdomains: ['a', 'b', 'c'],
      );
    }

    // the FlutterMap can't be given a null value as a layer,
    // so we need to make sure this exist before we draw it

    if (mapLayers.isEmpty) {
      if (tileLayerOptions != null) mapLayers.add(tileLayerOptions);
      if (imageLayer != null) mapLayers.add(imageLayer);
      if (cirLayer != null) mapLayers.add(cirLayer);
      if (polyLayer != null) mapLayers.add(polyLayer);
      // if (widget.locationDot != null) mapLayers.add(widget.locationDot.showMarker());
    }

    centre ??= LatLng(0, 0);

    return FlutterMap(
      options: MapOptions(
        onTap: (latlng) => widget.onTap!(latlng),
        center: centre,
        zoom: 18.0,
      ),
      layers: mapLayers as List<LayerOptions>,
      mapController: mapController,
    );
  }
}

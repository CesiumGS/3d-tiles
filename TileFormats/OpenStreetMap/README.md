# OpenStreetMap

## Notes

**Use cases**: OSM buildings

The [Cesium OSM NYC demo](http://cesiumjs.org/NewYork) uses `Batched 3D Model` tiles.  It _could_ be a net win to use a more concise tile representation based on OSM constructs (for example, their [roofs](http://wiki.openstreetmap.org/wiki/Simple_3D_Buildings#Roof)) and then quickly generate batched geometry at runtime, in a web worker if needed.  The OSM constructs may not map well&mdash;or efficiently&mdash;to Cesium geometries, in which case, we could convert them to something Cesium-friendly and use that as the tile format.  This may be the `Vector Data` format, but we want to avoid creating a kitchen sink.
# Vector Data

## Notes

**Use cases**: Traditional geospatial features: points, polylines, and polygons.  Replacing KML.

**Format**
* Combination of binary (for positions, normals, etc.) and JSON (for labels, other metadata, etc.).
* Concise representations for Cesium's [set of geometries](http://cesiumjs.org/2013/11/04/Geometry-and-Appearances/), including extrusions, and billboards and labels.
   * Need to carefully select the representation for the best trade-off between conciseness and runtime processing.  For example, polygons will likely be pre-triangulated since it only adds indices to the payload, but will be subdivided at runtime since subdivision is fast and increases the vertex payload significantly.
   * RTC positions for high precision-rendering.
   * Context-aware compression.
   * Bounding volume may need to be adjusted at runtime for terrain clamping.
* Metadata for cracking, morphing, and perhaps label declutter.

Could also name this a `Geometry` tile.

**Implementation work-in-progress**
* Polygons: https://github.com/AnalyticalGraphicsInc/cesium/pull/4186
* Polylines: https://github.com/AnalyticalGraphicsInc/cesium/pull/4208

# Vector Data

## Contributors

* Dan Bagnell, [@bagnell](https://github.com/bagnell)
* Rob Taglang, [@lasalvavida](https://github.com/lasalvavida)
* Patrick Cozzi, [@pjcozzi](https://twitter.com/pjcozzi)

## Overview

The _Vector_ tile format allows streaming of vector graphics data like polygons and polylines. 

Each vector graphics element is a _feature_ in the core 3D Tiles spec language. 

## Layout

A tile is composed of a header section immediately followed by a body section.

**Figure 1**: Vector layout (dashes indicate optional fields). 

![header layout](figures/header-layout.png)

## Header

The -byte header contains the following fields:

| Field name | Data type | Description |
| --- | --- | --- |
| `magic` | 4-byte ANSI string | `"vctr"`. This can be used to identify the arraybuffer as a Vector tile. |
| `version` | `uint32` | The version of the Instanced 3D Model format. It is currently `1`. |
| `byteLength` | `uint32` | The length of the entire tile, including the header, in bytes. |
| `featureTableJSONByteLength` | `uint32` | The length of the feature table JSON section in bytes. |
| `featureTableBinaryByteLength` | `uint32` | The length of the feature table binary section in bytes. If `featureTableJSONByteLength` is zero, this will also be zero. |
| `batchTableJSONByteLength` | `uint32` | The length of the batch table JSON section in bytes. Zero indicates that there is no batch table. |
| `batchTableBinaryByteLength` | `uint32` | The length of the batch table binary section in bytes. If `batchTableJSONByteLength` is zero, this will also be zero. | 

## Feature Table

Contains values for `vctr` semantics used to create vector elements.
More information is available in the [Feature Table specification](../FeatureTable).

The `vctr` Feature Table JSON schema is defined in [vctr.featureTable.schema.json](../../schema/vctr.featureTable.schema.json).

### Semantics

#### Vector Semantics

| Semantic | Data Type | Description | Required |
| --- | --- | --- | --- |
| `POLYGON_INDICES` | `uint32` | An index into the `POLYGON_POSITION` array. | :red_circle: No. |
| `POLYGON_POSITION` | `float32[3]` | A 3-component array of numbers containing `x`, `y`, and `z` Cartesian coordinates for the polygon positions. If `POLYGON_INDICES` is not defined, these values are used to create the polygon in order. | :white_check_mark: Yes, unless `POLYGON_POSITION_QUANTIZED` is defined. |
| `POLYGON_POSITION_QUANTIZED` | `uint16[3]` | A 3-component array of numbers containing `x`, `y`, and `z` in quantized Cartesian coordinates for the polygon positions. If `POLYGON_INDICES` is not defined, these values are used to create the polygon in order. | :white_check_mark: Yes, unless `POLYGON_POSITION` is defined. |


#### Global Semantics

The semantics define global properties for all vector elements.

| Semantic | Data Type | Description | Required |
| --- | --- | --- | --- |
| `POLYGONS_LENGTH` | `uint32` | The number of polygons to generate. The length of each array value for a `POLYGON` semantic should be equal to this. | :white_check_mark: Yes, unless `POLYLINES_LENGTH` is defined. |
| `POLYLINES_LENGTH` | `uint32` | The number of polylines to generate. The length of each array value for a `POLYLINE` semantic should be equal to this. | :white_check_mark: Yes, unless `POLYGONS_LENGTH` is defined. |

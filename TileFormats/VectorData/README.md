# Vector Data

## Contributors

* Dan Bagnell, [@bagnell](https://github.com/bagnell)
* Rob Taglang, [@lasalvavida](https://github.com/lasalvavida)
* Patrick Cozzi, [@pjcozzi](https://twitter.com/pjcozzi)

## Overview

The _Vector_ tile format allows streaming of vector datasets including points, polylines, and polygons.  Points can be represented with a combination of billboard, label, and point graphics primitives.

Each point, poyline, and polygon is a _feature_ in the 3D Tiles specification language. 

## Layout

A tile is composed of two sections: a header immediately followed by a body.

**Figure1**: Vector tile layout.
![](figures/layout.jpg)

## Header

The 44-byte header contains the following fields:

| Field name | Data type | Description |
| --- | --- | --- |
| `magic` | 4-byte ANSI string | `"vctr"`. This can be used to identify the arraybuffer as a Vector tile. |
| `version` | `uint32` | The version of the Vector Data format. It is currently `1`. |
| `byteLength` | `uint32` | The length of the entire tile, including the header, in bytes. |
| `featureTableJSONByteLength` | `uint32` | The length of the feature table JSON section in bytes. |
| `featureTableBinaryByteLength` | `uint32` | The length of the feature table binary section in bytes. If `featureTableJSONByteLength` is zero, this will also be zero. |
| `batchTableJSONByteLength` | `uint32` | The length of the batch table JSON section in bytes. Zero indicates that there is no batch table. |
| `batchTableBinaryByteLength` | `uint32` | The length of the batch table binary section in bytes. If `batchTableJSONByteLength` is zero, this will also be zero. | 
| `polygonIndicesByteLength` | `uint32` | The length of the polygon indices buffer. |
| `polygonPositionsByteLength` | `uint32` | The length of the polygon positions buffer. |
| `polylinePositionsByteLength` | `uint32` | The length of the polyline positions buffer. |
| `pointPositionsByteLength` | `uint32` | The length of the point positions buffer. |

If `featureTableJSONByteLength` equals zero, the tile does not need to be rendered.

The body section immediately follows the header section, and is composed, in order, of four fields: `Feature Table`, `Batch Table`, `Indices`, `Positions`, and `Meshes`.

Code for reading the header can be found in
[Vector3DModelTileContent.js](https://github.com/AnalyticalGraphicsInc/cesium/blob/vector-tiles/Source/Scene/Vector3DTileContent.js)
in the Cesium implementation of 3D Tiles.

## Feature Table

Contains values for `vctr` semantics used to render features.  The general layout of a Feature Table is described in the [Feature Table specification](../FeatureTable).

The `vctr` Feature Table JSON schema is defined in [vctr.featureTable.schema.json](../../schema/vctr.featureTable.schema.json).

### Semantics

Per-feature semantics specific to a feature type are prefixed with the name of the feature type. e.g. `POLYGON` for pre-triangulated polygons, `POLYLINE` for polylines and `POINT` for points.

At least one global `LENGTH` semantic must be defined. 
If `POLYGONS_LENGTH` is not defined, or zero, no polygons will be rendered. 
If `POLYLINES_LENGTH` is not defined, or zero, no polylines will be rendered.
If `POINTS_LENGTH` is not defined, or zero, no points will be rendered.
If `MESHES_LENGTH` in not defined, or zero, no meshes will be rendered.
If `BOXES_LENGTH` in not defined, or zero, no boxes will be rendered.
If `CYLINDERS_LENGTH` in not defined, or zero, no cylinders will be rendered.
If `ELLIPSOIDS_LENGTH` in not defined, or zero, no ellipsoids will be rendered.
If `SPHERES_LENGTH` in not defined, or zero, no spheres will be rendered.
Multiple feature types may be defined in a single Vector tile using multiple `LENGTH` semantics, and in that case, all specified feature types will be rendered.

If a semantic has a dependency on another semantic, that semantic must be defined as well.

#### Global Semantics

The semantics define global properties for all vector elements.

| Semantic | Data Type | Description | Required |
| --- | --- | --- | --- |
| `POLYGONS_LENGTH` | `uint32` | The number of pre-triangulated polygons in the tile. | :red_circle: No. |
| `POLYLINES_LENGTH` | `uint32` | The number of polylines in the tile. | :red_circle: No. |
| `POINTS_LENGTH` | `uint32` | The number of points in the tile. | :red_circle: No. |
| `MESHES_LENGTH` | `uint32` | The number of meshes in the tile. | :red_circle: No. |
| `BOXES_LENGTH` | `uint32` | The number of boxes in the tile. | :red_circle: No. |
| `CYLINDERS_LENGTH` | `uint32` | The number of cylinders in the tile. | :red_circle: No. |
| `ELLIPSOIDS_LENGTH` | `uint32` | The number of ellipsoids in the tile. | :red_circle: No. |
| `SPHERES_LENGTH` | `uint32` | The number of spheres in the tile. | :red_circle: No. |
| `MINIMUM_HEIGHT` | `float32` | The minimum height for this tiles' region in meters above the WGS84 ellipsoid. | :white_check_mark: Yes. |
| `MAXIMUM_HEIGHT` | `float32` | The maximum height for this tiles' region in meters above the WGS84 ellipsoid. | :white_check_mark: Yes. |
| `RECTANGLE` | `float32[]` | The rectangle containing the geometry in the tile. It is an array with the four elements west, south, east, and north (in that order). | :white_check_mark: Yes. |
| `RTC_CENTER` | `float32[]` | The center used for RTC rendering. | :red_circle: No. If no center is supplied, the center of the global `RECTANGLE` will be used. |

#### Vector Semantics

| Semantic | Data Type | Description | Required |
| --- | --- | --- | --- |
| `POLYGON_COUNTS` | `uint32[]` | The number of vertices that belong to each polygon. This refers to the polygon section of the positions buffer in the body. Each polygon count refers to a contiguous number of vertices in the position buffer that represents the polygon.  | :white_check_mark: Yes, when the global `POLYGONS_LENGTH` is greater than zero. |
| `POLYGON_INDEX_COUNTS` | `uint32[]` | The number of indices that belong to each polygon. This refers to the indices buffer of the body. Each index count refers to a contiguous number of indices that represent the triangulated polygon. | :white_check_mark: Yes, when the global `POLYGONS_LENGTH` is greater than zero. |
| `POLYGON_MINIMUM_HEIGHTS` | `float32[]` | The minimum height of each polygon in meters above the WGS84 ellipsoid. | :red_circle: No. If the minimum height for each polygon is not specified, the global `MINIMUM_HEIGHT` will be used. |
| `POLYGON_MAXIMUM_HEIGHTS` | `float32[]` | The maximum height of each polygon in meters above the WGS84 ellipsoid. | :red_circle: No. If the maximum height for each polygon is not specified, the global `MAXIMUM_HEIGHT` will be used. |
| `POLYGON_BATCH_IDS` | `uint16[]` | The `batchId` of the polygon that can be used to retrieve metadata from the `Batch Table`. | :red_circle: No. |
| `POLYLINE_COUNTS` | `uint32[]` | The number of vertices that belong to each polyline. This refers to the polyline section of the positions buffer in the body. Each polyline count refers to a contiguous number of vertices in the position buffer that represents the polyline. Each vertex is the start of a segment of the polyline with the next being the end of the segment. | :white_check_mark: Yes, when the global `POLYLINES_LENGTH` is greater than zero. |
| `POLYLINE_WIDTHS` | `uint16[]` | The width of each polyline in pixels. | :red_circle: No. The default width for every polyline is `2.0`. |
| `POLYLINE_BATCH_IDS` | `uint16[]` | The `batchId` of the polyline that can be used to retrieve metadata from the `Batch Table`. | :red_circle: No. |
| `POINT_BATCH_IDS` | `uint16[]` | The `batchId` of the point that can be used to retrieve metadata from the `Batch Table`. | :red_circle: No. |
| `MESH_INDEX_OFFSETS` | `uint32[]` | The offset of the first index in the indices buffer of each mesh. | :white_check_mark: Yes, when the global `MESHES_LENGTH` is greater than zero. |
| `MESH_INDEX_COUNTS` | `uint32[]` | The number of indices for each mesh. | :white_check_mark: Yes, when the global `MESHES_LENGTH` is greater than zero. |
| `MESH_POSITION_COUNT` | `uint32` | The number of positions of all meshes. | :white_check_mark: Yes, when the global `MESHES_LENGTH` is greater than zero. |
| `MESH_BATCH_IDS` | `uint16[]` | The `batchId` of the mesh that can be used to retrieve metadata from the `Batch Table`. | :red_circle: No. |
| `BOXES` | `float32[]` | The boxes in the tile. The length of the array will be `19 * BOXES_LENGTH`. The first three elements of each box are the x, y, and z dimensions. The following 16 elements are the model matrix of the box. | :white_check_mark: Yes, when the global `BOXES_LENGTH` is greater than zero. |
| `BOX_BATCH_IDS` | `uint16[]` | The `batchId` of the box that can be used to retrieve metadata from the `Batch Table`. | :red_circle: No. |
| `CYLINDERS` | `float32[]` | The cylinders in the tile. The length of the array will be `18 * CYLINDERS_LENGTH`. The first element is the radius of the cylinder. The second element is the length along the z axis. The following 16 elements are the model matrix. | :white_check_mark: Yes, when the global `CYLINDERS_LENGTH` is greater than zero. |
| `CYLINDER_BATCH_IDS` | `uint16[]` | The `batchId` of the cylinder that can be used to retrieve metadata from the `Batch Table`. | :red_circle: No. |
| `ELLIPSOIDS` | `float32[]` | The ellipsoids in the tile. The length of the array will be `19 * ELLIPSOIDS_LENGTH`. The first three elements are the radii in the x, y, and z axes. The following 16 elements are the model matrix. | :white_check_mark: Yes, when the global `ELLIPSOIDS_LENGTH` is greater than zero. |
| `ELLIPSOID_BATCH_IDS` | `uint16[]` | The `batchId` of the ellipsoid that can be used to retrieve metadata from the `Batch Table`. | :red_circle: No. |
| `SPHERES` | `float32[]` | The spheres in the tile. The length of the array will be `17 * SPHERES_LENGTH`. The first element is the radius. The following 16 elements are the model matrix. | :white_check_mark: Yes, when the global `SPHERES_LENGTH` is greater than zero. |
| `SPHERE_BATCH_IDS` | `uint16[]` | The `batchId` of the sphere that can be used to retrieve metadata from the `Batch Table`. | :red_circle: No. |

## Batch Table

The _Batch Table_ contains application-specific metadata, indexable by `batchId`, that can be used for declarative styling and application-specific use cases such as populating a UI or issuing a REST API request.

See the [Batch Table](../BatchTable/README.md) reference for more information.

### Polygon Indices

TODO: `uint16` indices?

The indices are a buffer of `uint32` values. The byte length is given by `polygonIndicesByteLength` in the header. Each count in `POLYGON_INDEX_COUNT` represents a contiguous section of the array that represents a triangulated polygon. 
For example, let the first two polygons have 6 and 12 for their index counts. The first polygon has 6 indices starting at byte offset `0` and ending at byte offset `6 * byteSize - 1`.
The second polygon has 12 indices starting at byte offset `6 * byteSize` and ending at `6 * byteSize + 12 * byteSize`.

**Figure 2**: Example index buffer.

![](figures/indices.jpg)

The number of indices must be a multiple of three. Each consecutive list of three indices is a triangle that must be ordered counter-clockwise. Each index is from the start of the buffer, **NOT** from the offset of the first position of the polygon.

### Positions

The positions buffer contains up to three sub-buffers for the polygons, polylines, and points.

The bounding volume for the tile must be a tile bounding region containing the west, south, east, north bounds of the tile. The positions are represented by u, v, and height values that are quantized and delta encoded.

| Field | Meaning |
| --- | --- |
| u | The horizontal coordinate of the vertex in the tile. When the u value is 0, the vertex is on the western edge of the tile. Then the value is 32767, the vertex is on the eastern edge of the tile. For other values, the vertex's longitude is a linear interpolation between the longitudes of the western and eastern edges of the tile. |
| v | The vertical coordinate of the vertex in the tile. When the v value is 0, the vertex is on the southern edge of the tile. When the value is 32767, the vertex is on the northern edge of the tile. For other values, the vertex's latitude is a linear interpolation between the latitudes of the southern and northern edges of the tile. |
| height | The height of the vertex of the tile. When the height value is 0, the vertex's height is equal to `MINIMUM_HEIGHT` from the feature table. When the value is 32767, the vertex's height is equal to `MAXIMUM_HEIGHT` from the feature table. For other values, the vertex's height is a linear interpolation of the minimum and maximum heights. |

The values are then delta and ZigZag encoded. The delta encoding ensures the values are small integers. The ZigZag encoding ensure the values are positive integers. Example encoding code is listed below:
```javascript
function zigZag(value) {
    return ((value << 1) ^ (value >> 15)) & 0xFFFF;
}

var lastU = 0;
var lastV = 0;
var lastHeight = 0;

for (var i = 0; i < length; ++i) {
    var u = uBuffer[i];
    var v = vBuffer[i];
    var height = heightBuffer[i];
    
    uBuffer[i] = zigZag(u - lastU);
    vBuffer[i] = zigZag(v - lastV);
    heightBuffer = zigZag(height - lastHeight);

    lastU = u;
    lastV = v;
    lastHeight = height;
}
```

Example decoding code is listed below:
```javascript
function zigZagDecode(value) {
    return (value >> 1) ^ (-(value & 1));
}

var u = 0;
var v = 0;
var height = 0;

for (var i = 0; i < length; ++i) {
    u += zigZagDecode(uBuffer[i]);
    v += zigZagDecode(vBuffer[i]);
    height += zigZagDecode(heightBuffer[i]);
    
    uBuffer[i] = u;
    vBuffer[i] = v;
    heightBuffer[i] = height;
}
```

#### Polygon positions

**Figure 3**: Polygon layout.

![](figures/polygon.jpg)

The number of positions for each polygon is determined by the value of its `POLYGON_COUNT`. For example, let the first polygon count be 5. The first polygons u values start at offset `0` and end at `5 * byteSize`. Its v values start at `polygonPositionsByteLength / 2` and end at `polygonPositionsByteLength / 2 + 5 * byteSize`.

The positions of the polygons must be the outer ring positions listed in counter-clockwise order.

#### Polyline positions

**Figure 4**: Polyline layout.

![](figures/polyline.jpg)

The number of positions for each polyline is determined by the value of its `POLYLINE_COUNT`. From the first point on the polyline, each successive point creates a segment connected to the previous.

#### Point positions

**Figure 5**: Point layout.

![](figures/point.jpg)

Each `u, v, height` triple is a single point.

### Meshes

The indices are a buffer of `uint32` values. The indices for each mesh must be contiguous in the buffer. For example, the first mesh would have indices starting at the byte offset given by the first element in `MESH_INDEX_OFFSETS` and end after the first element in `MESH_INDEX_COUNTS`. After the indices is a `float32[]` containing positions of tall of the meshes. The number of positions in the buffer is given by `MESH_POSITION_COUNT`. Unlike polygons, there are no restrictions on where a mesh can index into the position buffer.

## File Extension

`.vctr`

The file extension is optional. Valid implementations ignore it and identify a content's format by the `magic` field in its header.

## MIME Type

_TODO, [#60](https://github.com/AnalyticalGraphicsInc/3d-tiles/issues/60)_

`application/octet-stream`

## Implementation Notes

In JavaScript, a `TypedArray` cannot be created on data unless it is byte-aligned to the data type.
For example, a `Float32Array` must be stored in memory such that its data begins on a byte multiple of four since each `float` contains four bytes.

The string generated from the JSON and each array should be padded is necessary to ensure byte alignment.
 
## Resources
1. [quantized-mesh-1.0 terrain format](https://cesiumjs.org/data-and-assets/terrain/formats/quantized-mesh-1.0.html)

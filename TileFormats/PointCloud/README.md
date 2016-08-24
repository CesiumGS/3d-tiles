# Point Cloud

## Contributors

* Sean Lilley, [@lilleyse](https://github.com/lilleyse)
* Tom Fili, [@CesiumFili](https://twitter.com/CesiumFili)
* Patrick Cozzi, [@pjcozzi](https://twitter.com/pjcozzi)
* Dan Bagnell, [@bagnell](https://github.com/bagnell)

## Overview

The _Point Cloud_ tile format enables efficient streaming of massive point clouds for 3D visualization. Each point is defined by a position and optional properties used to define its appearance, such as color and normal, and optional properties that define application-specific metadata.

Using 3D Tiles terminology, each point is a _feature_.

## Layout

A tile is composed of a header section immediately followed by a body section.

**Figure 1**: Point Cloud layout (dashes indicate optional fields).

![](figures/layout.png)

## Header

The 20-byte header contains the following fields:

| Field name | Data type | Description |
| --- | --- | --- |
| `magic` | 4-byte ANSI string | `"pnts"`.  This can be used to identify the arraybuffer as a Point Cloud tile. |
| `version` | `uint32` | The version of the Point Cloud format. It is currently `1`. |
| `byteLength` | `uint32` | The length of the entire tile, including the header, in bytes. |
| `featureTableJSONByteLength` | `uint32` | The length of the feature table JSON section in bytes. |
| `featureTableBinaryByteLength` | `uint32` | The length of the feature table binary section in bytes. If `featureTableJSONByteLength` is zero, this will also be zero. |

If `featureTableJSONByteLength` equals zero, the tile does not need to be rendered.

The body section immediately follows the header section, and is composed of a `Feature Table`.

Code for reading the header can be found in [Points3DModelTileContent.js](https://github.com/AnalyticalGraphicsInc/cesium/blob/3d-tiles/Source/Scene/Points3DTileContent.js) in the Cesium implementation of 3D Tiles.

## Feature Table

Contains per-tile and per-point values that define where and how to render points.
More information is available in the [Feature Table specification](../FeatureTable).

The `pnts` Feature Table JSON Schema is defined in [pnts.featureTable.schema.json](../../schema/pnts.featureTable.schema.json)

### Semantics

#### Point Semantics

These semantics map to an array of feature values that are define each point. The length of these arrays must be the same for all semantics and is equal to the number of points.

If a semantic has a dependency on another semantic, that semantic must be defined.
If both `POSITION` and `POSITION_QUANTIZED` are defined for a point, the higher precision `POSITION` will be used.
If both `NORMAL` and `NORMAL_OCT16P` are defined for a point, the higher precision `NORMAL` will be used.

| Semantic | Data Type  | Description | Required |
| --- | --- | --- | --- | --- |
| `POSITION` | `float32[3]` | A 3-component array of numbers containing `x`, `y`, and `z` Cartesian coordinates for the position of the point. | :white_check_mark: Yes, unless `POSITION_QUANTIZED` is defined. |
| `POSITION_QUANTIZED` | `uint16[3]` | A 3-component array of numbers containing `x`, `y`, and `z` in quantized Cartesian coordinates for the position of the point. | :white_check_mark: Yes, unless `POSITION` is defined. |
| `RGBA` | `uint8[4]` | A 4-component array of values containing the `RGBA` color of the point. | :red_circle: No. |
| `RGB` | `uint8[3]` | A 3-component array of values containing the `RGB` color of the point. | :red_circle: No. |
| `NORMAL` | `float32[3]`| A unit vector defining the normal of the point. | :red_circle: No. |
| `NORMAL_OCT16P` | `uint8[2]` | An oct-encoded unit vector with 16-bits of precision defining the normal of the point. | :red_circle: No. |

#### Global Semantics

These semantics define global properties for all points.

| Semantic | Data Type | Description | Required |
| --- | --- | --- | --- |
| `POINTS_LENGTH`| `uint32` | The number of points to render. The length of each array value for a point semantic should be equal to this. | :white_check_mark: Yes. |
| `RTC_CENTER` | `float32[3]` | A 3-component array of numbers defining the center position when point positions are defined relative-to-center. | :red_circle: No. |
| `QUANTIZED_VOLUME_OFFSET` | `float32[3]` | A 3-component array of numbers defining the offset for the quantized volume. | :red_circle: No, unless `POSITION_QUANTIZED` is defined. |
| `QUANTIZED_VOLUME_SCALE` | `float32[3]` | A 3-component array of numbers defining the scale for the quantized volume. | :red_circle: No, unless `POSITION_QUANTIZED` is defined. |
| `CONSTANT_RGBA` | `uint8[4]` | A 4-component array of values defining a constant `RGBA` color for all points in the tile. | :red_circle: No. |

Examples using these semantics can be found in the [examples section](#examples) below.

### Point Positions

`POSITION` defines the position for a point before any tileset transforms are applied. Positions may be defined relative-to-center for high-precision rendering [4]. `RTC_CENTER` defines the center position.

#### Quantized Positions

If `POSITION` is not defined, positions may be stored in `POSITION_QUANTIZED` which defines point positions relative to the quantized volume.
If neither `POSITION` or `POSITION_QUANTIZED` are defined, the tile does not need to be rendered.

A quantized volume is defined by `offset` and `scale` to map quantized positions into model space.

**Figure 2**: A quantized volume based on `offset` and `scale`.

![quantized volume](figures/quantized-volume.png)

`offset` is stored in the global semantic `QUANTIZED_VOLUME_OFFSET`, and `scale` is stored in the global semantic `QUANTIZED_VOLUME_SCALE`.
If those global semantics are not defined, `POSITION_QUANTIZED` cannot be used.

Quantized positions can be mapped to model space using the formula:

`POSITION = POSITION_QUANTIZED * QUANTIZED_VOLUME_SCALE + QUANTIZED_VOLUME_OFFSET`

### Point Colors

If more than one color semantic is defined, the precedence order is `RGBA`, `RGB`, then `CONSTANT_RGBA`. For example, if a tile's feature table contains both `RGBA` and `CONSTANT_RGBA` properties, the runtime would render with per-point colors using `RGBA`.

If no color semantics are defined, the runtime is free to color points using an application-specific default color.

In any case, [3D Tiles Styling](../../Styling/README.md) may be used to change the final rendered color and other visual properties at runtime.

### Point Normals

Per-point normals are an optional property that can help improve the visual quality of points by enabling lighting, hidden surface removal, and other rendering techniques.
The normals will be transformed using the inverse transpose of the tileset transform.

#### Oct-encoded Normal Vectors
Oct-encoding is described in [*A Survey of Efficient Representations of Independent Unit Vectors* by Cigolle et al.](http://jcgt.org/published/0003/02/01/). An implementation for encoding and decoding these unit vectors can be found in Cesium's
[AttributeCompression](https://github.com/AnalyticalGraphicsInc/cesium/blob/master/Source/Core/AttributeCompression.js)
module.

### Examples

These examples show how to generate JSON and binary buffers for the feature table.

#### Positions Only

This minimal example has four points on the corners of a unit length square.

```javascript
var featureTableJSON = {
    POINTS_LENGTH : 4,
    POSITION : {
        byteOffset : 0
    }
};

var featureTableBinary = new Buffer(new Float32Array([
    0.0, 0.0, 0.0, 
    1.0, 0.0, 0.0,
    0.0, 0.0, 1.0,
    1.0, 0.0, 1.0
]).buffer);
```

#### Positions and Colors

The following example has four points (red, green, blue, and yellow) above the globe. Their positions are defined relative-to-center.

```javascript
var featureTableJSON = {
    POINTS_LENGTH : 4,
    RTC_CENTER : [1215013.8, -4736316.7, 4081608.4],
    POSITION : {
        byteOffset : 0
    },
    RGB : {
        byteOffset : 48
    }
};

var positionBinary = new Buffer(new Float32Array([
    0.0, 0.0, 0.0, 
    1.0, 0.0, 0.0, 
    0.0, 0.0, 1.0, 
    1.0, 0.0, 1.0
]).buffer);

var colorBinary = new Buffer(new Uint8Array([
    255, 0, 0,
    0, 255, 0,
    0, 0, 255,
    255, 255, 0,
]).buffer);

var featureTableBinary = Buffer.concat([positionBinary, colorBinary]);
```
#### Quantized Positions and Oct-Encoded Normals

In this example, the 4 points will have normals pointing up `[0.0, 1.0, 0.0]` in oct-encoded format and they will be placed on the corners of a quantized volme that spans from `-250.0` to `250.0` units in the `x` and `z` directions.

```javascript
var featureTableJSON = {
    POINTS_LENGTH : 4,
    QUANTIZED_VOLUME_OFFSET : [-250.0, 0.0, -250.0],
    QUANTIZED_VOLUME_SCALE : [500.0, 0.0, 500.0],
    POSITION_QUANTIZED : {
        byteOffset : 0
    },
    NORMAL_OCT16P : {
        byteOffset : 24
    }
};

var positionQuantizedBinary = new Buffer(new Uint16Array([
    0, 0, 0,
    65535, 0, 0,
    0, 0, 65535,
    65535, 0, 65535
]).buffer);

var normalOct16PBinary = new Buffer(new Uint8Array([
    128, 255,
    128, 255,
    128, 255,
    128, 255
]).buffer);

var featureTableBinary = Buffer.concat([positionQuantizedBinary, normalOct16PBinary]);
```
## File Extension

`.pnts`

## MIME Type

_TODO, [#60](https://github.com/AnalyticalGraphicsInc/3d-tiles/issues/60)_

`application/octet-stream`

## Resources

1. [*A Survey of Efficient Representations of Independent Unit Vectors* by Cigolle et al.](http://jcgt.org/published/0003/02/01/)
2. [*Mesh Geometry Compression for Mobile Graphics* by Jongseok Lee et al.](http://cg.postech.ac.kr/research/mesh_comp_mobile/mesh_comp_mobile_conference.pdf)
3. Cesium [AttributeCompression](https://github.com/AnalyticalGraphicsInc/cesium/blob/master/Source/Core/AttributeCompression.js) module for oct-encoding
4. [Precisions, Precisions](http://blogs.agi.com/insight3d/index.php/2008/09/03/precisions-precisions/)

# Point Cloud

## Contents

* [Overview](#overview)
* [Layout](#layout)
    * [Padding](#padding)
* [Header](#header)
* [Feature Table](#feature-table)
    * [Semantics](#semantics)
        * [Point semantics](#point-semantics)
        * [Global semantics](#global-semantics)
    * [Point positions](#point-positions)
        * [Coordinate reference system (CRS)](#coordinate-reference-system-crs)
        * [RTC_CENTER](#rtc_center)
        * [Quantized positions](#quantized-positions) 
    * [Point colors](#point-colors) 
    * [Point normals](#point-normals)     
        * [Oct-encoded normal vectors](#oct-encoded-normal-vectors)
    * [Batched points](#batched-points)
    * [Examples](#examples)
        * [Positions only](#positions-only)
        * [Positions and colors](#positions-and-colors)
        * [Quantized positions and oct-encoded normals](#quantized-positions-and-oct-encoded-normals)
        * [Batched points](#batched-points)
        * [Per-point properties](#per-point-properties)
* [Batch Table](#batch-table)
* [File extension and MIME type](#file-extension-and-mime-type)
* [Implementation example](#implementation-example)
* [Property reference](#property-reference)

## Overview

The _Point Cloud_ tile format enables efficient streaming of massive point clouds for 3D visualization. Each point is defined by a position and by optional properties used to define its appearance, such as color and normal, as well as optional properties that define application-specific metadata.

Using 3D Tiles terminology, each point is a _feature_.

A Point Cloud tile is a binary blob in little endian.

## Layout

A tile is composed of a header section immediately followed by a body section. The following figure shows the Point Cloud layout (dashes indicate optional fields):

![](figures/layout.png)

### Padding

A tile's `byteLength` must be aligned to an 8-byte boundary. The contained [Feature Table](../FeatureTable/README.md#padding) and [Batch Table](../BatchTable/README.md#padding) must conform to their respective padding requirement.

## Header

The 28-byte header contains the following fields:

| Field name | Data type | Description |
| --- | --- | --- |
| `magic` | 4-byte ANSI string | `"pnts"`.  This can be used to identify the content as a Point Cloud tile. |
| `version` | `uint32` | The version of the Point Cloud format. It is currently `1`. |
| `byteLength` | `uint32` | The length of the entire tile, including the header, in bytes. |
| `featureTableJSONByteLength` | `uint32` | The length of the Feature Table JSON section in bytes. |
| `featureTableBinaryByteLength` | `uint32` | The length of the Feature Table binary section in bytes. |
| `batchTableJSONByteLength` | `uint32` | The length of the Batch Table JSON section in bytes. Zero indicates that there is no Batch Table. |
| `batchTableBinaryByteLength` | `uint32` | The length of the Batch Table binary section in bytes. If `batchTableJSONByteLength` is zero, this will also be zero. |

The body section immediately follows the header section, and is composed of a `Feature Table` and `Batch Table`.

## Feature Table

Contains per-tile and per-point values that define where and how to render points.
More information is available in the [Feature Table specification](../FeatureTable/README.md).

See [Property reference](#property-reference) for the `pnts` feature table schema reference. The full JSON schema can be found in [pnts.featureTable.schema.json](../../schema/pnts.featureTable.schema.json).

### Semantics

#### Point semantics

These semantics map to an array of feature values that define each point. The length of these arrays must be the same for all semantics and is equal to the number of points.
The value for each point semantic must be a reference to the Feature Table binary body; they cannot be embedded in the Feature Table JSON header.

If a semantic has a dependency on another semantic, that semantic must be defined.
If both `POSITION` and `POSITION_QUANTIZED` are defined for a point, the higher precision `POSITION` will be used.
If both `NORMAL` and `NORMAL_OCT16P` are defined for a point, the higher precision `NORMAL` will be used.

| Semantic | Data Type | Description | Required |
| --- | --- | --- | --- |
| `POSITION` | `float32[3]` | A 3-component array of numbers containing `x`, `y`, and `z` Cartesian coordinates for the position of the point. | :white_check_mark: Yes, unless `POSITION_QUANTIZED` is defined. |
| `POSITION_QUANTIZED` | `uint16[3]` | A 3-component array of numbers containing `x`, `y`, and `z` in quantized Cartesian coordinates for the position of the point. | :white_check_mark: Yes, unless `POSITION` is defined. |
| `RGBA` | `uint8[4]` | A 4-component array of values containing the `RGBA` color of the point. | :red_circle: No. |
| `RGB` | `uint8[3]` | A 3-component array of values containing the `RGB` color of the point. | :red_circle: No. |
| `RGB565` | `uint16` | A lossy compressed color format that packs the `RGB` color into 16 bits, providing 5 bits for red, 6 bits for green, and 5 bits for blue. | :red_circle: No. |
| `NORMAL` | `float32[3]`| A unit vector defining the normal of the point. | :red_circle: No. |
| `NORMAL_OCT16P` | `uint8[2]` | An oct-encoded unit vector with 16 bits of precision defining the normal of the point. | :red_circle: No. |
| `BATCH_ID` | `uint8`, `uint16` (default), or `uint32` | The `batchId` of the point that can be used to retrieve metadata from the `Batch Table`. | :red_circle: No. |

#### Global semantics

These semantics define global properties for all points.

| Semantic | Data Type | Description | Required |
| --- | --- | --- | --- |
| `POINTS_LENGTH`| `uint32` | The number of points to render. The length of each array value for a point semantic should be equal to this. | :white_check_mark: Yes. |
| `RTC_CENTER` | `float32[3]` | A 3-component array of numbers defining the center position when point positions are defined relative-to-center. | :red_circle: No. |
| `QUANTIZED_VOLUME_OFFSET` | `float32[3]` | A 3-component array of numbers defining the offset for the quantized volume. | :red_circle: No, unless `POSITION_QUANTIZED` is defined. |
| `QUANTIZED_VOLUME_SCALE` | `float32[3]` | A 3-component array of numbers defining the scale for the quantized volume. | :red_circle: No, unless `POSITION_QUANTIZED` is defined. |
| `CONSTANT_RGBA` | `uint8[4]` | A 4-component array of values defining a constant `RGBA` color for all points in the tile. | :red_circle: No. |
| `BATCH_LENGTH` | `uint32` | The number of unique `BATCH_ID` values. | :red_circle: No, unless `BATCH_ID` is defined. |

Examples using these semantics can be found in the [examples section](#examples) below.

### Point positions

`POSITION` defines the position for a point before any tileset transforms are applied.

#### Coordinate reference system (CRS)

3D Tiles local coordinate systems use a right-handed 3-axis (x, y, z) Cartesian coordinate system; that is, the cross product of _x_ and _y_ yields _z_. 3D Tiles defines the _z_ axis as up for local Cartesian coordinate systems (also see [coordinate reference system](../../README.md#coordinate-reference-system-crs)).

#### RTC_CENTER

Positions may be defined relative-to-center for high-precision rendering, see [Precisions, Precisions](http://help.agi.com/AGIComponents/html/BlogPrecisionsPrecisions.htm). If defined, `RTC_CENTER` specifies the center position and all point positions are treated as relative to this value.

#### Quantized positions

If `POSITION` is not defined, positions may be stored in `POSITION_QUANTIZED`, which defines point positions relative to the quantized volume.
If neither `POSITION` nor `POSITION_QUANTIZED` is defined, the tile does not need to be rendered.

A quantized volume is defined by `offset` and `scale` to map quantized positions to a position in local space. The following figure shows a quantized volume based on `offset` and `scale`:

![quantized volume](figures/quantized-volume.png)

`offset` is stored in the global semantic `QUANTIZED_VOLUME_OFFSET`, and `scale` is stored in the global semantic `QUANTIZED_VOLUME_SCALE`.
If those global semantics are not defined, `POSITION_QUANTIZED` cannot be used.

Quantized positions can be mapped to local space using the following formula:

`POSITION = POSITION_QUANTIZED * QUANTIZED_VOLUME_SCALE / 65535.0 + QUANTIZED_VOLUME_OFFSET`

### Point colors

If more than one color semantic is defined, the precedence order is `RGBA`, `RGB`, `RGB565`, then `CONSTANT_RGBA`. For example, if a tile's Feature Table contains both `RGBA` and `CONSTANT_RGBA` properties, the runtime would render with per-point colors using `RGBA`.

If no color semantics are defined, the runtime is free to color points using an application-specific default color.

In any case, [3D Tiles Styling](../../Styling/README.md) may be used to change the final rendered color and other visual properties at runtime.

### Point normals

Per-point normals are an optional property that can help improve the visual quality of points by enabling lighting, hidden surface removal, and other rendering techniques.
The normals will be transformed using the inverse transpose of the tileset transform.

#### Oct-encoded normal vectors

Oct-encoding is described in [*A Survey of Efficient Representations of Independent Unit Vectors*](http://jcgt.org/published/0003/02/01/). Oct-encoded values are stored in unsigned, unnormalized range (`[0, 255]`) and then mapped to a signed normalized range (`[-1.0, 1.0]`) at runtime.

> An implementation for encoding and decoding these unit vectors can be found in Cesium's [AttributeCompression](https://github.com/AnalyticalGraphicsInc/cesium/blob/master/Source/Core/AttributeCompression.js)
module.

### Batched points

Points that make up distinct features of the Point Cloud may be batched together using the `BATCH_ID` semantic. For example, the points that make up a door in a house would all be assigned the same `BATCH_ID`, whereas points that make up a window would be assigned a different `BATCH_ID`.
This is useful for per-object picking and storing application-specific metadata for declarative styling and application-specific use cases such as populating a UI or issuing a REST API request on a per-object instead of per-point basis.

The `BATCH_ID` semantic may have a `componentType` of `UNSIGNED_BYTE`, `UNSIGNED_SHORT`, or `UNSIGNED_INT`. When `componentType` is not present, `UNSIGNED_SHORT` is used.
The global semantic `BATCH_LENGTH` defines the number of unique `batchId` values, similar to the `batchLength` field in the [Batched 3D Model](../Batched3DModel/README.md) header.

### Examples

_This section is non-normative_

These examples show how to generate JSON and binary buffers for the Feature Table.

#### Positions only

This minimal example has four points on the corners of a unit length square:

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

#### Positions and colors

The following example has four points (red, green, blue, and yellow) above the globe. Their positions are defined relative to center:

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
#### Quantized positions and oct-encoded normals

In this example, the four points will have normals pointing up `[0.0, 1.0, 0.0]` in oct-encoded format, and they will be placed on the corners of a quantized volume that spans from `-250.0` to `250.0` units in the `x` and `z` directions:

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

#### Batched points

In this example, the first two points have a `batchId` of 0, and the next two points have a `batchId` of 1. Note that the Batch Table only has two names:

```javascript
var featureTableJSON = {
    POINTS_LENGTH : 4,
    BATCH_LENGTH : 2,
    POSITION : {
        byteOffset : 0
    },
    BATCH_ID : {
        byteOffset : 48,
        componentType : "UNSIGNED_BYTE"
    }
};

var positionBinary = new Buffer(new Float32Array([
    0.0, 0.0, 0.0,
    1.0, 0.0, 0.0,
    0.0, 0.0, 1.0,
    1.0, 0.0, 1.0
]).buffer);

var batchIdBinary = new Buffer(new Uint8Array([
    0,
    0,
    1,
    1
]).buffer);

var featureTableBinary = Buffer.concat([positionBinary, batchIdBinary]);

var batchTableJSON = {
    names : ['object1', 'object2']
};
```

#### Per-point properties

In this example, each of the 4 points will have metadata stored in the Batch Table JSON and binary.

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

var batchTableJSON = {
    names : ['point1', 'point2', 'point3', 'point4']
};
```

## Batch Table

The _Batch Table_ contains application-specific metadata, indexable by `batchId`, that can be used for declarative styling and application-specific use cases such as populating a UI or issuing a REST API request.

* If the `BATCH_ID` semantic is defined, the Batch Table stores metadata for each `batchId`, and the length of the Batch Table arrays will equal `BATCH_LENGTH`.
* If the `BATCH_ID` semantic is not defined, then the Batch Table stores per-point metadata, and the length of the Batch Table arrays will equal `POINTS_LENGTH`.

See the [Batch Table](../BatchTable/README.md) reference for more information.

## File extension and MIME type

Point cloud tiles use the `.pnts` extension and `application/octet-stream` MIME type.

An explicit file extension is optional. Valid implementations may ignore it and identify a content's format by the `magic` field in its header.

## Implementation example

_This section is non-normative_

Code for reading the header can be found in [`PointCloud3DModelTileContent.js`](https://github.com/AnalyticalGraphicsInc/cesium/blob/master/Source/Scene/PointCloud3DTileContent.js) in the Cesium implementation of 3D Tiles.

## Property reference

* [`Point Cloud Feature Table`](#reference-point-cloud-feature-table)
    * [`BinaryBodyReference`](#reference-binarybodyreference)
    * [`GlobalPropertyCartesian3`](#reference-globalpropertycartesian3)
    * [`GlobalPropertyCartesian4`](#reference-globalpropertycartesian4)
    * [`GlobalPropertyScalar`](#reference-globalpropertyscalar)
    * [`Property`](#reference-property)


---------------------------------------
<a name="reference-point-cloud-feature-table"></a>
### Point Cloud Feature Table

A set of Point Cloud semantics that contains values defining the position and appearance properties for points in a tile.

**Properties**

|   |Type|Description|Required|
|---|----|-----------|--------|
|**extensions**|`object`|Dictionary object with extension-specific objects.|No|
|**extras**|`any`|Application-specific data.|No|
|**POSITION**|`object`|A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).|No|
|**POSITION_QUANTIZED**|`object`|A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).|No|
|**RGBA**|`object`|A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).|No|
|**RGB**|`object`|A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).|No|
|**RGB565**|`object`|A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).|No|
|**NORMAL**|`object`|A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).|No|
|**NORMAL_OCT16P**|`object`|A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).|No|
|**BATCH_ID**|`object`|A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).|No|
|**POINTS_LENGTH**|`object`, `number` `[1]`, `number`|A [`GlobalPropertyScalar`](#reference-globalpropertyscalar) object defining a numeric property for all points. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).| :white_check_mark: Yes|
|**RTC_CENTER**|`object`, `number` `[3]`|A [`GlobalPropertyCartesian3`](#reference-globalpropertycartesian3) object defining a 3-component numeric property for all points. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).|No|
|**QUANTIZED_VOLUME_OFFSET**|`object`, `number` `[3]`|A [`GlobalPropertyCartesian3`](#reference-globalpropertycartesian3) object defining a 3-component numeric property for all points. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).|No|
|**QUANTIZED_VOLUME_SCALE**|`object`, `number` `[3]`|A [`GlobalPropertyCartesian3`](#reference-globalpropertycartesian3) object defining a 3-component numeric property for all points. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).|No|
|**CONSTANT_RGBA**|`object`, `number` `[4]`|A [`GlobalPropertyCartesian4`](#reference-globalpropertycartesian4) object defining a 4-component numeric property for all points. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).|No|
|**BATCH_LENGTH**|`object`, `number` `[1]`, `number`|A [`GlobalPropertyScalar`](#reference-globalpropertyscalar) object defining a numeric property for all points. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).|No|

Additional properties are allowed.

* **Type of each property**: [`Property`](#reference-property)
#### PointCloudFeatureTable.extensions

Dictionary object with extension-specific objects.

* **Type**: `object`
* **Required**: No
* **Type of each property**: Extension

#### PointCloudFeatureTable.extras

Application-specific data.

* **Type**: `any`
* **Required**: No

#### PointCloudFeatureTable.POSITION

A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).

* **Type**: `object`
* **Required**: No

#### PointCloudFeatureTable.POSITION_QUANTIZED

A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).

* **Type**: `object`
* **Required**: No

#### PointCloudFeatureTable.RGBA

A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).

* **Type**: `object`
* **Required**: No

#### PointCloudFeatureTable.RGB

A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).

* **Type**: `object`
* **Required**: No

#### PointCloudFeatureTable.RGB565

A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).

* **Type**: `object`
* **Required**: No

#### PointCloudFeatureTable.NORMAL

A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).

* **Type**: `object`
* **Required**: No

#### PointCloudFeatureTable.NORMAL_OCT16P

A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).

* **Type**: `object`
* **Required**: No

#### PointCloudFeatureTable.BATCH_ID

A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).

* **Type**: `object`
* **Required**: No

#### PointCloudFeatureTable.POINTS_LENGTH :white_check_mark:

A [`GlobalPropertyScalar`](#reference-globalpropertyscalar) object defining a numeric property for all points. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).

* **Type**: `object`, `number` `[1]`, `number`
* **Required**: Yes

#### PointCloudFeatureTable.RTC_CENTER

A [`GlobalPropertyCartesian3`](#reference-globalpropertycartesian3) object defining a 3-component numeric property for all points. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).

* **Type**: `object`, `number` `[3]`
* **Required**: No

#### PointCloudFeatureTable.QUANTIZED_VOLUME_OFFSET

A [`GlobalPropertyCartesian3`](#reference-globalpropertycartesian3) object defining a 3-component numeric property for all points. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).

* **Type**: `object`, `number` `[3]`
* **Required**: No

#### PointCloudFeatureTable.QUANTIZED_VOLUME_SCALE

A [`GlobalPropertyCartesian3`](#reference-globalpropertycartesian3) object defining a 3-component numeric property for all points. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).

* **Type**: `object`, `number` `[3]`
* **Required**: No

#### PointCloudFeatureTable.CONSTANT_RGBA

A [`GlobalPropertyCartesian4`](#reference-globalpropertycartesian4) object defining a 4-component numeric property for all points. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).

* **Type**: `object`, `number` `[4]`
* **Required**: No

#### PointCloudFeatureTable.BATCH_LENGTH

A [`GlobalPropertyScalar`](#reference-globalpropertyscalar) object defining a numeric property for all points. See the corresponding property semantic in [Semantics](/specification/TileFormats/PointCloud/README.md#semantics).

* **Type**: `object`, `number` `[1]`, `number`
* **Required**: No


---------------------------------------
<a name="reference-binarybodyreference"></a>
### BinaryBodyReference

An object defining the reference to a section of the binary body of the features table where the property values are stored if not defined directly in the JSON.

**Properties**

|   |Type|Description|Required|
|---|----|-----------|--------|
|**byteOffset**|`number`|The offset into the buffer in bytes.| :white_check_mark: Yes|

Additional properties are allowed.

#### BinaryBodyReference.byteOffset :white_check_mark:

The offset into the buffer in bytes.

* **Type**: `number`
* **Required**: Yes
* **Minimum**: ` >= 0`



---------------------------------------
<a name="reference-globalpropertycartesian3"></a>
### GlobalPropertyCartesian3

An object defining a global 3-component numeric property values for all features.

* **JSON schema**: [`featureTable.schema.json`](../../schema/featureTable.schema.json)



---------------------------------------
<a name="reference-globalpropertycartesian4"></a>
### GlobalPropertyCartesian4

An object defining a global 4-component numeric property values for all features.

* **JSON schema**: [`featureTable.schema.json`](../../schema/featureTable.schema.json)



---------------------------------------
<a name="reference-globalpropertyscalar"></a>
### GlobalPropertyScalar

An object defining a global numeric property values for all features.

* **JSON schema**: [`featureTable.schema.json`](../../schema/featureTable.schema.json)


---------------------------------------
<a name="reference-property"></a>
### Property

A user-defined property which specifies per-feature application-specific metadata in a tile. Values either can be defined directly in the JSON as an array, or can refer to sections in the binary body with a [`BinaryBodyReference`](#reference-binarybodyreference) object.

* **JSON schema**: [`featureTable.schema.json`](../../schema/featureTable.schema.json)

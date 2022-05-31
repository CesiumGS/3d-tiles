# Instanced 3D Model

## Contents

* [Overview](#overview)
* [Layout](#layout)
    * [Padding](#padding)
* [Header](#header)
* [Feature Table](#feature-table)
    * [Semantics](#semantics)
        * [Instance semantics](#instance-semantics)
        * [Global semantics](#global-semantics)
    * [Instance orientation](#instance-orientation)
        * [Oct-encoded normal vectors](#oct-encoded-normal-vectors)
        * [Default orientation](#default-orientation)
    * [Instance position](#instance-position)
        * [RTC_CENTER](#rtc_center)
        * [Quantized positions](#quantized-positions)
    * [Instance scaling](#instance-scaling)
    * [Examples](#examples)
        * [Positions only](#positions-only)
        * [Quantized positions and oct-encoded normals](#quantized-positions-and-oct-encoded-normals)
* [Batch Table](#batch-table)
* [glTF](#gltf)
    * [Coordinate system](#coordinate-system)
* [File extension and media type](#file-extension-and-media-type)
* [Property reference](#property-reference)

## Overview

_Instanced 3D Model_ is a tile format for efficient streaming and rendering of a large number of models, called _instances_, with slight variations.  In the simplest case, the same tree model, for example, may be located&mdash;or _instanced_&mdash;in several places.  Each instance references the same model and has per-instance properties, such as position.  Using the core 3D Tiles spec language, each instance is a _feature_.

In addition to trees, Instanced 3D Model is useful for exterior features such as fire hydrants, sewer caps, lamps, and traffic lights, and for interior CAD features such as bolts, valves, and electrical outlets.

An Instanced 3D Model tile is a binary blob in little endian.

> **Implementation Note:** A [Composite](../Composite/README.md) tile can be used to create tiles with different types of instanced models, e.g., trees and traffic lights by combing two Instanced 3D Model tiles.

> **Implementation Note:** Instanced 3D Model maps well to the [ANGLE_instanced_arrays](https://www.khronos.org/registry/webgl/extensions/ANGLE_instanced_arrays/) extension for efficient rendering with WebGL.

## Layout

A tile is composed of a header section immediately followed by a binary body. The following figure shows the Instanced 3D Model layout (dashes indicate optional fields):

![header layout](figures/header-layout.png)

### Padding

A tile's `byteLength` must be aligned to an 8-byte boundary. The contained [Feature Table](../FeatureTable/README.md#padding) and [Batch Table](../BatchTable/README.md#padding) must conform to their respective padding requirement.

The [binary glTF](#gltf) (if present) must start and end on an 8-byte boundary so that glTF's byte-alignment guarantees are met. This can be done by padding the Feature Table or Batch Table if they are present.

Otherwise, if the glTF field is a UTF-8 string, it must be padded with trailing Space characters (`0x20`) to satisfy alignment requirements of the tile, which must be removed at runtime before requesting the glTF asset.

## Header

The 32-byte header contains the following fields:

| Field name | Data type | Description |
| --- | --- | --- |
| `magic` | 4-byte ANSI string | `"i3dm"`.  This can be used to identify the content as an Instanced 3D Model tile. |
| `version` | `uint32` | The version of the Instanced 3D Model format. It is currently `1`. |
| `byteLength` | `uint32` | The length of the entire tile, including the header, in bytes. |
| `featureTableJSONByteLength` | `uint32` | The length of the Feature Table JSON section in bytes. |
| `featureTableBinaryByteLength` | `uint32` | The length of the Feature Table binary section in bytes. |
| `batchTableJSONByteLength` | `uint32` | The length of the Batch Table JSON section in bytes. Zero indicates that there is no Batch Table. |
| `batchTableBinaryByteLength` | `uint32` | The length of the Batch Table binary section in bytes. If `batchTableJSONByteLength` is zero, this will also be zero. |
| `gltfFormat` | `uint32` | Indicates the format of the glTF field of the body.  `0` indicates it is a URI, `1` indicates it is embedded binary glTF.  See the [glTF](#gltf) section below. |

The body section immediately follows the header section and is composed of three fields: `Feature Table`, `Batch Table`, and `glTF`.

## Feature Table

The Feature Table contains values for `i3dm` semantics used to create instanced models.
More information is available in the [Feature Table specification](../FeatureTable/README.md).

See [Property reference](#property-reference) for the `i3dm` feature table schema reference. The full JSON schema can be found in [i3dm.featureTable.schema.json](../../schema/i3dm.featureTable.schema.json).

### Semantics

#### Instance semantics

These semantics map to an array of feature values that are used to create instances. The length of these arrays must be the same for all semantics and is equal to the number of instances.
The value for each instance semantic must be a reference to the Feature Table binary body; they cannot be embedded in the Feature Table JSON header.

If a semantic has a dependency on another semantic, that semantic must be defined.
If both `SCALE` and `SCALE_NON_UNIFORM` are defined for an instance, both scaling operations will be applied.
If both `POSITION` and `POSITION_QUANTIZED` are defined for an instance, the higher precision `POSITION` will be used.
If `NORMAL_UP`, `NORMAL_RIGHT`, `NORMAL_UP_OCT32P`, and `NORMAL_RIGHT_OCT32P` are defined for an instance, the higher precision `NORMAL_UP` and `NORMAL_RIGHT` will be used.

| Semantic | Data Type | Description | Required |
| --- | --- | --- | --- |
| `POSITION` | `float32[3]` | A 3-component array of numbers containing `x`, `y`, and `z` Cartesian coordinates for the position of the instance. | :white_check_mark: Yes, unless `POSITION_QUANTIZED` is defined. |
| `POSITION_QUANTIZED` | `uint16[3]` | A 3-component array of numbers containing `x`, `y`, and `z` in quantized Cartesian coordinates for the position of the instance. | :white_check_mark: Yes, unless `POSITION` is defined. |
| `NORMAL_UP` | `float32[3]`| A unit vector defining the `up` direction for the orientation of the instance. | :red_circle: No, unless `NORMAL_RIGHT` is defined. |
| `NORMAL_RIGHT` | `float32[3]` | A unit vector defining the `right` direction for the orientation of the instance. Must be orthogonal to `up`. | :red_circle: No, unless `NORMAL_UP` is defined. |
| `NORMAL_UP_OCT32P` | `uint16[2]` | An oct-encoded unit vector with 32-bits of precision defining the `up` direction for the orientation of the instance. | :red_circle: No, unless `NORMAL_RIGHT_OCT32P` is defined. |
| `NORMAL_RIGHT_OCT32P` | `uint16[2]` | An oct-encoded unit vector with 32-bits of precision defining the `right` direction for the orientation of the instance. Must be orthogonal to `up`. | :red_circle: No, unless `NORMAL_UP_OCT32P` is defined. |
| `SCALE` | `float32` | A number defining a scale to apply to all axes of the instance. | :red_circle: No. |
| `SCALE_NON_UNIFORM` | `float32[3]` | A 3-component array of numbers defining the scale to apply to the `x`, `y`, and `z` axes of the instance. | :red_circle: No. |
| `BATCH_ID` | `uint8`, `uint16` (default), or `uint32` | The `batchId` of the instance that can be used to retrieve metadata from the `Batch Table`. | :red_circle: No. |

#### Global semantics

These semantics define global properties for all instances.

| Semantic | Data Type | Description | Required |
| --- | --- | --- | --- |
| `INSTANCES_LENGTH` | `uint32` | The number of instances to generate. The length of each array value for an instance semantic should be equal to this. | :white_check_mark: Yes. |
| `RTC_CENTER` | `float32[3]` | A 3-component array of numbers defining the center position when instance positions are defined relative-to-center. | :red_circle: No. |
| `QUANTIZED_VOLUME_OFFSET` | `float32[3]` | A 3-component array of numbers defining the offset for the quantized volume. | :red_circle: No, unless `POSITION_QUANTIZED` is defined. |
| `QUANTIZED_VOLUME_SCALE` | `float32[3]` | A 3-component array of numbers defining the scale for the quantized volume. |:red_circle: No, unless `POSITION_QUANTIZED` is defined. |
| `EAST_NORTH_UP` | `boolean` | When `true` and per-instance orientation is not defined, each instance will default to the `east/north/up` reference frame's orientation on the `WGS84` ellipsoid. | :red_circle: No. |

Examples using these semantics can be found in the [examples section](#examples).

### Instance orientation

An instance's orientation is defined by an orthonormal basis created by an `up` and `right` vector. The orientation will be transformed by the [tile transform](../../README.md#tile-transforms).

The `x` vector in the standard basis maps to the `right` vector in the transformed basis, and the `y` vector maps to the `up` vector.
The `z` vector would map to a `forward` vector, but it is omitted because it will always be the cross product of `right` and `up`.

A box in the standard basis:
![box standard basis](figures/box-standard-basis.png)

A box transformed into a rotated basis
![box rotated basis](figures/box-rotated-basis.png)

#### Oct-encoded normal vectors

If `NORMAL_UP` and `NORMAL_RIGHT` are not defined for an instance, its orientation may be stored as oct-encoded normals in `NORMAL_UP_OCT32P` and `NORMAL_RIGHT_OCT32P`.
These define `up` and `right` using the oct-encoding described in [*A Survey of Efficient Representations of Independent Unit Vectors*](http://jcgt.org/published/0003/02/01/). Oct-encoded values are stored in unsigned, unnormalized range (`[0, 65535]`) and then mapped to a signed normalized range (`[-1.0, 1.0]`) at runtime.

> An implementation for encoding and decoding these unit vectors can be found in CesiumJS's [AttributeCompression](https://github.com/CesiumGS/cesium/blob/main/Source/Core/AttributeCompression.js)
module.

#### Default orientation

If `NORMAL_UP` and `NORMAL_RIGHT` or `NORMAL_UP_OCT32P` and `NORMAL_RIGHT_OCT32P` are not present, the instance will not have a custom orientation. If `EAST_NORTH_UP` is `true`, the instance is assumed to be on the `WGS84` ellipsoid and its orientation will default to the `east/north/up` reference frame at its cartographic position.
This is suitable for instanced models such as trees whose orientation is always facing up from their position on the ellipsoid's surface.

### Instance position

`POSITION` defines the location for an instance before any tile transforms are applied.

#### RTC_CENTER

Positions may be defined relative-to-center for high-precision rendering, see [Precisions, Precisions](http://help.agi.com/AGIComponents/html/BlogPrecisionsPrecisions.htm). If defined, `RTC_CENTER` specifies the center position and all instance positions are treated as relative to this value.

#### Quantized positions

If `POSITION` is not defined for an instance, its position may be stored in `POSITION_QUANTIZED`, which defines the instance position relative to the quantized volume.
If neither `POSITION` or `POSITION_QUANTIZED` are defined, the instance will not be created.

A quantized volume is defined by `offset` and `scale` to map quantized positions into local space, as shown in the following figure:

![quantized volume](figures/quantized-volume.png)

`offset` is stored in the global semantic `QUANTIZED_VOLUME_OFFSET`, and `scale` is stored in the global semantic `QUANTIZED_VOLUME_SCALE`.
If those global semantics are not defined, `POSITION_QUANTIZED` cannot be used.

Quantized positions can be mapped to local space using the following formula:

`POSITION = POSITION_QUANTIZED * QUANTIZED_VOLUME_SCALE / 65535.0 + QUANTIZED_VOLUME_OFFSET`

### Instance scaling

Scaling can be applied to instances using the `SCALE` and `SCALE_NON_UNIFORM` semantics.
`SCALE` applies a uniform scale along all axes, and `SCALE_NON_UNIFORM` applies scaling to the `x`, `y`, and `z` axes independently.

### Examples

These examples show how to generate JSON and binary buffers for the Feature Table.

#### Positions only

In this minimal example, we place four instances on the corners of a unit length square with the default orientation:

```javascript
var featureTableJSON = {
    INSTANCES_LENGTH : 4,
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

#### Quantized positions and oct-encoded normals

In this example, the four instances will be placed with an orientation `up` of `[0.0, 1.0, 0.0]` and `right` of `[1.0, 0.0, 0.0]` in oct-encoded format
and they will be placed on the corners of a quantized volume that spans from `-250.0` to `250.0` units in the `x` and `z` directions:

```javascript
var featureTableJSON = {
    INSTANCES_LENGTH : 4,
    QUANTIZED_VOLUME_OFFSET : [-250.0, 0.0, -250.0],
    QUANTIZED_VOLUME_SCALE : [500.0, 0.0, 500.0],
    POSITION_QUANTIZED : {
        byteOffset : 0
    },
    NORMAL_UP_OCT32P : {
        byteOffset : 24
    },
    NORMAL_RIGHT_OCT32P : {
        byteOffset : 40
    }
};

var positionQuantizedBinary = new Buffer(new Uint16Array([
    0, 0, 0,
    65535, 0, 0,
    0, 0, 65535,
    65535, 0, 65535
]).buffer);

var normalUpOct32PBinary = new Buffer(new Uint16Array([
    32768, 65535,
    32768, 65535,
    32768, 65535,
    32768, 65535
]).buffer);

var normalRightOct32PBinary = new Buffer(new Uint16Array([
    65535, 32768,
    65535, 32768,
    65535, 32768,
    65535, 32768
]).buffer);

var featureTableBinary = Buffer.concat([positionQuantizedBinary, normalUpOct32PBinary, normalRightOct32PBinary]);
```

## Batch Table

Contains metadata organized by `batchId` that can be used for declarative styling. See the [Batch Table](../BatchTable/README.md) reference for more information.

## glTF

Instanced 3D Model embeds [glTF 2.0](https://github.com/KhronosGroup/glTF/tree/master/specification/2.0) containing model geometry and texture information.

The glTF asset to be instanced is stored after the Feature Table and Batch Table. It may embed all of its geometry, texture, and animations, or it may refer to external sources for some or all of these data.

`header.gltfFormat` determines the format of the glTF field

* When the value of `header.gltfFormat` is `0`, the glTF field is a UTF-8 string, which contains a URI of the glTF or binary glTF model content.
* When the value of `header.gltfFormat` is `1`, the glTF field is a binary blob containing [binary glTF](https://github.com/KhronosGroup/glTF/tree/master/specification/2.0#binary-gltf-layout).

When the glTF field contains a URI, then this URI may point to a [relative external reference (RFC3986)](https://tools.ietf.org/html/rfc3986#section-4.2). When the URI is relative, its base is always relative to the referring `.i3dm` file. Client implementations are required to support relative external references. Optionally, client implementations may support other schemes (such as `http://`). All URIs must be valid and resolvable.


### Coordinate system

By default glTFs use a right handed coordinate system where the _y_-axis is up. For consistency with the _z_-up coordinate system of 3D Tiles, glTFs must be transformed at runtime. See [glTF transforms
](../../README.md#gltf-transforms) for more details.

## File extension and media type

Instanced 3D models tiles use the `.i3dm` extension and `application/octet-stream` media type.

An explicit file extension is optional. Valid implementations may ignore it and identify a content's format by the `magic` field in its header.

## Property reference

* [`Instanced 3D Model Feature Table`](#reference-instanced-3d-model-feature-table)
    * [`BinaryBodyReference`](#reference-binarybodyreference)
    * [`GlobalPropertyCartesian3`](#reference-globalpropertycartesian3)
    * [`GlobalPropertyInteger`](#reference-globalpropertyinteger)
    * [`GlobalPropertyBoolean`](#reference-globalpropertyboolean)
    * [`Property`](#reference-property)


---------------------------------------
<a name="reference-instanced-3d-model-feature-table"></a>
### Instanced 3D Model Feature Table

A set of Instanced 3D Model semantics that contains values defining the position and appearance properties for instanced models in a tile.

**Properties**

|   |Type|Description|Required|
|---|----|-----------|--------|
|**extensions**|`object`|Dictionary object with extension-specific objects.|No|
|**extras**|`any`|Application-specific data.|No|
|**POSITION**|`object`|A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).|No|
|**POSITION_QUANTIZED**|`object`|A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).|No|
|**NORMAL_UP**|`object`|A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).|No|
|**NORMAL_RIGHT**|`object`|A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).|No|
|**NORMAL_UP_OCT32P**|`object`|A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).|No|
|**NORMAL_RIGHT_OCT32P**|`object`|A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).|No|
|**SCALE**|`object`|A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).|No|
|**SCALE_NON_UNIFORM**|`object`|A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).|No|
|**BATCH_ID**|`object`|A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).|No|
|**INSTANCES_LENGTH**|`object`, `number` `[1]`, `number`|A [`GlobalPropertyInteger`](#reference-globalpropertyinteger) object defining an integer property for all features. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).| :white_check_mark: Yes|
|**RTC_CENTER**|`object`, `number` `[3]`|A [`GlobalPropertyCartesian3`](#reference-globalpropertycartesian3) object defining a 3-component numeric property for all features. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).|No|
|**QUANTIZED_VOLUME_OFFSET**|`object`, `number` `[3]`|A [`GlobalPropertyCartesian3`](#reference-globalpropertycartesian3) object defining a 3-component numeric property for all features. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).|No|
|**QUANTIZED_VOLUME_SCALE**|`object`, `number` `[3]`|A [`GlobalPropertyCartesian3`](#reference-globalpropertycartesian3) object defining a 3-component numeric property for all features. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).|No|
|**EAST_NORTH_UP**|`boolean`|A [`GlobalPropertyBoolean`](#reference-globalpropertyboolean) object defining a boolean property for all features. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).|No|

Additional properties are allowed.

* **Type of each property**: [`Property`](#reference-property)
#### Instanced3DModelFeatureTable.extensions

Dictionary object with extension-specific objects.

* **Type**: `object`
* **Required**: No
* **Type of each property**: Extension

#### Instanced3DModelFeatureTable.extras

Application-specific data.

* **Type**: `any`
* **Required**: No

#### Instanced3DModelFeatureTable.POSITION

A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).

* **Type**: `object`
* **Required**: No

#### Instanced3DModelFeatureTable.POSITION_QUANTIZED

A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).

* **Type**: `object`
* **Required**: No

#### Instanced3DModelFeatureTable.NORMAL_UP

A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).

* **Type**: `object`
* **Required**: No

#### Instanced3DModelFeatureTable.NORMAL_RIGHT

A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).

* **Type**: `object`
* **Required**: No

#### Instanced3DModelFeatureTable.NORMAL_UP_OCT32P

A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).

* **Type**: `object`
* **Required**: No

#### Instanced3DModelFeatureTable.NORMAL_RIGHT_OCT32P

A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).

* **Type**: `object`
* **Required**: No

#### Instanced3DModelFeatureTable.SCALE

A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).

* **Type**: `object`
* **Required**: No

#### Instanced3DModelFeatureTable.SCALE_NON_UNIFORM

A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).

* **Type**: `object`
* **Required**: No

#### Instanced3DModelFeatureTable.BATCH_ID

A [`BinaryBodyReference`](#reference-binarybodyreference) object defining the reference to a section of the binary body where the property values are stored. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).

* **Type**: `object`
* **Required**: No

#### Instanced3DModelFeatureTable.INSTANCES_LENGTH :white_check_mark:

A [`GlobalPropertyInteger`](#reference-globalpropertyinteger) object defining an integer property for all features. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).

* **Type**: `object`, `number` `[1]`, `number`
* **Required**: Yes

#### Instanced3DModelFeatureTable.RTC_CENTER

A [`GlobalPropertyCartesian3`](#reference-globalpropertycartesian3) object defining a 3-component numeric property for all features. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).

* **Type**: `object`, `number` `[3]`
* **Required**: No

#### Instanced3DModelFeatureTable.QUANTIZED_VOLUME_OFFSET

A [`GlobalPropertyCartesian3`](#reference-globalpropertycartesian3) object defining a 3-component numeric property for all features. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).

* **Type**: `object`, `number` `[3]`
* **Required**: No

#### Instanced3DModelFeatureTable.QUANTIZED_VOLUME_SCALE

A [`GlobalPropertyCartesian3`](#reference-globalpropertycartesian3) object defining a 3-component numeric property for all features. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).

* **Type**: `object`, `number` `[3]`
* **Required**: No

#### Instanced3DModelFeatureTable.EAST_NORTH_UP

A [`GlobalPropertyBoolean`](#reference-globalpropertyboolean) object defining a boolean property for all features. See the corresponding property semantic in [Semantics](/specification/TileFormats/Instanced3DModel/README.md#semantics).

* **Type**: `boolean`
* **Required**: No

---------------------------------------
<a name="reference-binarybodyreference"></a>
### BinaryBodyReference

An object defining the reference to a section of the binary body of the features table where the property values are stored if not defined directly in the JSON.

**Properties**

|   |Type|Description|Required|
|---|----|-----------|--------|
|**byteOffset**|`number`|The offset into the buffer in bytes.| :white_check_mark: Yes|
|**componentType**|`string`|The datatype of components in the property. The implicit component type of some semantics may be overridden using this property.| No|

Additional properties are allowed.

#### BinaryBodyReference.byteOffset :white_check_mark:

The offset into the buffer in bytes.

* **Type**: `number`
* **Required**: Yes
* **Minimum**: ` >= 0`

#### BinaryBodyReference.componentType

The datatype of components in the property.

* **Type**: `string`
* **Required**: Yes
* **Allowed values**:
   * `"BYTE"`
   * `"UNSIGNED_BYTE"`
   * `"SHORT"`
   * `"UNSIGNED_SHORT"`
   * `"INT"`
   * `"UNSIGNED_INT"`
   * `"FLOAT"`
   * `"DOUBLE"`


---------------------------------------
<a name="reference-globalpropertycartesian3"></a>
### GlobalPropertyCartesian3

An object defining a global 3-component numeric property value for all features.

* **JSON schema**: [`featureTable.schema.json`](../../schema/featureTable.schema.json)

---------------------------------------
<a name="reference-globalpropertyinteger"></a>
### GlobalPropertyInteger

An object defining a global integer property value for all features.

* **JSON schema**: [`featureTable.schema.json`](../../schema/featureTable.schema.json)

---------------------------------------
<a name="reference-globalpropertyboolean"></a>
### GlobalPropertyBoolean

An object defining a global boolean property value for all features.

* **JSON schema**: [`featureTable.schema.json`](../../schema/featureTable.schema.json)

---------------------------------------
<a name="reference-property"></a>
### Property

A user-defined property which specifies per-feature application-specific metadata in a tile. Values either can be defined directly in the JSON as an array, or can refer to sections in the binary body with a [`BinaryBodyReference`](#reference-binarybodyreference) object.

* **JSON schema**: [`featureTable.schema.json`](../../schema/featureTable.schema.json)


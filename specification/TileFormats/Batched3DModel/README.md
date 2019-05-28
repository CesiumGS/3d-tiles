# Batched 3D Model

## Contents

* [Overview](#overview)
* [Layout](#layout)
    * [Padding](#padding)
* [Header](#header)
* [Feature Table](#feature-table)
	* [Semantics](#semantics)
		* [Feature semantics](#feature-semantics)
		* [Global semantics](#global-semantics)
* [Batch Table](#batch-table)
* [Binary glTF](#binary-gltf)
   * [Coordinate system](#coordinate-system)
* [File extension and MIME type](#file-extension-and-mime-type)
* [Implementation example](#implementation-example)
* [Property reference](#property-reference)

## Overview

_Batched 3D Model_ allows offline batching of heterogeneous 3D models, such as different buildings in a city, for efficient streaming to a web client for rendering and interaction.  Efficiency comes from transferring multiple models in a single request and rendering them in the least number of WebGL draw calls necessary.  Using the core 3D Tiles spec language, each model is a _feature_.

Per-model properties, such as IDs, enable individual models to be identified and updated at runtime, e.g., show/hide, highlight color, etc. Properties may be used, for example, to query a web service to access metadata, such as passing a building's ID to get its address. Or a property might be referenced on the fly for changing a model's appearance, e.g., changing highlight color based on a property value.

A Batched 3D Model tile is a binary blob in little endian.

## Layout

A tile is composed of two sections: a header immediately followed by a body. The following figure shows the Batched 3D Model layout (dashes indicate optional fields):

![](figures/layout.png)

### Padding

A tile's `byteLength` must be aligned to an 8-byte boundary. The contained [Feature Table](../FeatureTable/README.md#padding) and [Batch Table](../BatchTable/README.md#padding) must conform to their respective padding requirement.

The [binary glTF](#binary-gltf) must start and end on an 8-byte boundary so that glTF's byte-alignment guarantees are met. This can be done by padding the Feature Table or Batch Table if they are present.

## Header

The 28-byte header contains the following fields:

|Field name|Data type|Description|
|----------|---------|-----------|
| `magic` | 4-byte ANSI string | `"b3dm"`.  This can be used to identify the content as a Batched 3D Model tile. |
| `version` | `uint32` | The version of the Batched 3D Model format. It is currently `1`. |
| `byteLength` | `uint32` | The length of the entire tile, including the header, in bytes. |
| `featureTableJSONByteLength` | `uint32` | The length of the Feature Table JSON section in bytes. |
| `featureTableBinaryByteLength` | `uint32` | The length of the Feature Table binary section in bytes. |
| `batchTableJSONByteLength` | `uint32` | The length of the Batch Table JSON section in bytes. Zero indicates there is no Batch Table. |
| `batchTableBinaryByteLength` | `uint32` | The length of the Batch Table binary section in bytes. If `batchTableJSONByteLength` is zero, this will also be zero. |

The body section immediately follows the header section, and is composed of three fields: `Feature Table`, `Batch Table`, and `Binary glTF`.

## Feature Table

Contains values for `b3dm` semantics.

More information is available in the [Feature Table specification](../FeatureTable/README.md).

See [Property reference](#property-reference) for the `b3dm` feature table schema reference. The full JSON schema can be found in [b3dm.featureTable.schema.json](../../schema/b3dm.featureTable.schema.json).

### Semantics

#### Feature semantics

There are currently no per-feature semantics.

#### Global semantics

These semantics define global properties for all features.

| Semantic | Data Type | Description | Required |
| --- | --- | --- | --- |
| `BATCH_LENGTH` | `uint32` | The number of distinguishable models, also called features, in the batch. If the Binary glTF does not have a `batchId` attribute, this field _must_ be `0`. | :white_check_mark: Yes. |
| `RTC_CENTER` | `float32[3]` | A 3-component array of numbers defining the center position when positions are defined relative-to-center, (see [Coordinate system](#coordinate-system)). | :red_circle: No. |

## Batch Table

The _Batch Table_ contains per-model application-specific properties, indexable by `batchId`, that can be used for [declarative styling](../../Styling/README.md) and application-specific use cases such as populating a UI or issuing a REST API request.  In the binary glTF section, each vertex has a numeric `batchId` attribute in the integer range `[0, number of models in the batch - 1]`.  The `batchId` indicates the model to which the vertex belongs.  This allows models to be batched together and still be identifiable.

See the [Batch Table](../BatchTable/README.md) reference for more information.

## Binary glTF

Batched 3D Model embeds [glTF 2.0](https://github.com/KhronosGroup/glTF/tree/master/specification/2.0) containing model geometry and texture information.

The [binary glTF](https://github.com/KhronosGroup/glTF/tree/master/specification/2.0#binary-gltf-layout) immediately follows the Feature Table and Batch Table.  It may embed all of its geometry, texture, and animations, or it may refer to external sources for some or all of these data.

As described above, each vertex has a `batchId` attribute indicating the model to which it belongs.  For example, vertices for a batch with three models may look like this:
```
batchId:  [0,   0,   0,   ..., 1,   1,   1,   ..., 2,   2,   2,   ...]
position: [xyz, xyz, xyz, ..., xyz, xyz, xyz, ..., xyz, xyz, xyz, ...]
normal:   [xyz, xyz, xyz, ..., xyz, xyz, xyz, ..., xyz, xyz, xyz, ...]
```
Vertices do not need to be ordered by `batchId`, so the following is also OK:
```
batchId:  [0,   1,   2,   ..., 2,   1,   0,   ..., 1,   2,   0,   ...]
position: [xyz, xyz, xyz, ..., xyz, xyz, xyz, ..., xyz, xyz, xyz, ...]
normal:   [xyz, xyz, xyz, ..., xyz, xyz, xyz, ..., xyz, xyz, xyz, ...]
```
Note that a vertex can't belong to more than one model; in that case, the vertex needs to be duplicated so the `batchId`s can be assigned.

The `batchId` parameter is specified in a glTF mesh [primitive](https://github.com/KhronosGroup/glTF/tree/master/specification/2.0#reference-primitive) by providing the `_BATCHID` attribute semantic, along with the index of the `batchId` [accessor](https://github.com/KhronosGroup/glTF/tree/master/specification/2.0#accessors). For example,

```JSON
"primitives": [
    {
        "attributes": {
            "_BATCHID": 0
        }
    }
]
```

```JSON
{
    "accessors": [
        {
            "bufferView": 1,
            "byteOffset": 0,
            "componentType": 5126,
            "count": 4860,
            "max": [2],
            "min": [0],
            "type": "SCALAR"
        }
    ]
}
```

The `accessor.type` must be a value of `"SCALAR"`. All other properties must conform to the glTF schema, but have no additional requirements.

When a Batch Table is present or the `BATCH_LENGTH` property is greater than `0`, the `_BATCHID` attribute is required; otherwise, it is not.

### Coordinate system

By default embedded glTFs use a right handed coordinate system where the _y_-axis is up. For consistency with the _z_-up coordinate system of 3D Tiles, glTFs must be transformed at runtime. See [glTF transforms](../../README.md#gltf-transforms) for more details.

Vertex positions may be defined relative-to-center for high-precision rendering, see [Precisions, Precisions](http://help.agi.com/AGIComponents/html/BlogPrecisionsPrecisions.htm). If defined, `RTC_CENTER` specifies the center position that all vertex positions are relative to after the coordinate system transform and glTF node hierarchy transforms have been applied.

## File extension and MIME type

Batched 3D Model tiles use the `.b3dm` extension and `application/octet-stream` MIME type.

An explicit file extension is optional. Valid implementations may ignore it and identify a content's format by the `magic` field in its header.

## Implementation example

_This section is non-normative_

Code for reading the header can be found in
[`Batched3DModelTileContent.js`](https://github.com/AnalyticalGraphicsInc/cesium/blob/master/Source/Scene/Batched3DModel3DTileContent.js)
in the Cesium implementation of 3D Tiles.


### Property reference

* [`Batched 3D Model Feature Table`](#reference-batched-3d-model-feature-table)
    * [`BinaryBodyReference`](#reference-binarybodyreference)
    * [`GlobalPropertyCartesian3`](#reference-globalpropertycartesian3)
    * [`GlobalPropertyScalar`](#reference-globalpropertyscalar)
    * [`Property`](#reference-property)


---------------------------------------
<a name="reference-batched-3d-model-feature-table"></a>
### Batched 3D Model Feature Table

A set of Batched 3D Model semantics that contain additional information about features in a tile.

**Properties**

|   |Type|Description|Required|
|---|----|-----------|--------|
|**extensions**|`object`|Dictionary object with extension-specific objects.|No|
|**extras**|`any`|Application-specific data.|No|
|**BATCH_LENGTH**|`object`, `number` `[1]`, `number`|A [`GlobalPropertyScalar`](#reference-globalpropertyscalar) object defining a numeric property for all features. See the corresponding property semantic in [Semantics](/specification/TileFormats/Batched3DModel/README.md#semantics).| :white_check_mark: Yes|
|**RTC_CENTER**|`object`, `number` `[3]`|A [`GlobalPropertyCartesian3`](#reference-globalpropertycartesian3) object defining a 3-component numeric property for all features. See the corresponding property semantic in [Semantics](/specification/TileFormats/Batched3DModel/README.md#semantics).|No|

Additional properties are allowed.

* **Type of each property**: [`Property`](#reference-property)
#### Batched3DModelFeatureTable.extensions

Dictionary object with extension-specific objects.

* **Type**: `object`
* **Required**: No
* **Type of each property**: Extension

#### Batched3DModelFeatureTable.extras

Application-specific data.

* **Type**: `any`
* **Required**: No

#### Batched3DModelFeatureTable.BATCH_LENGTH :white_check_mark:

A [`GlobalPropertyScalar`](#reference-globalpropertyscalar) object defining a numeric property for all features. See the corresponding property semantic in [Semantics](/specification/TileFormats/Batched3DModel/README.md#semantics).

* **Type**: `object`, `number` `[1]`, `number`
* **Required**: Yes

#### Batched3DModelFeatureTable.RTC_CENTER

A [`GlobalPropertyCartesian3`](#reference-globalpropertycartesian3) object defining a 3-component numeric property for all features. See the corresponding property semantic in [Semantics](/specification/TileFormats/Batched3DModel/README.md#semantics).

* **Type**: `object`, `number` `[3]`
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

An object defining a global 3-component numeric property value for all features.

* **JSON schema**: [`featureTable.schema.json`](../../schema/featureTable.schema.json)



---------------------------------------
<a name="reference-globalpropertyscalar"></a>
### GlobalPropertyScalar

An object defining a global numeric property value for all features.

* **JSON schema**: [`featureTable.schema.json`](../../schema/featureTable.schema.json)



---------------------------------------
<a name="reference-property"></a>
### Property

A user-defined property which specifies per-feature application-specific metadata in a tile. Values either can be defined directly in the JSON as an array, or can refer to sections in the binary body with a [`BinaryBodyReference`](#reference-binarybodyreference) object.

* **JSON schema**: [`featureTable.schema.json`](../../schema/featureTable.schema.json)


# Batched 3D Model

## Contributors

* Patrick Cozzi, [@pjcozzi](https://twitter.com/pjcozzi)
* Tom Fili, [@CesiumFili](https://twitter.com/CesiumFili)
* Sean Lilley, [@lilleyse](https://github.com/lilleyse)

## Contents

* [Overview](#overview)
* [Layout](#layout)
* [Header](#header)
* [Feature Table](#feature-table)
	* [Semantics](#semantics)
		* [Feature semantics](#feature-semantics)
		* [Global semantics](#global-semantics)
* [Batch Table](#batch-table)
* [Binary glTF](#binary-gltf)
   * [Coordinate reference system (CRS)](#coordinate-reference-system-crs)
* [File extension and MIME type](#file-extension-and-mime-type)

## Overview

_Batched 3D Model_ allows offline batching of heterogeneous 3D models, such as different buildings in a city, for efficient streaming to a web client for rendering and interaction.  Efficiency comes from transferring multiple models in a single request and rendering them in the least number of WebGL draw calls necessary.  Using the core 3D Tiles spec language, each model is a _feature_.

Per-model properties, such as IDs, enable individual models to be identified and updated at runtime, e.g., show/hide, highlight color, etc. Properties may be used, for example, to query a web service to access metadata, such as passing a building's ID to get its address. Or a property might be referenced on the fly for changing a model's appearance, e.g., changing highlight color based on a property value.

Batched 3D Model, or just the _batch_, is a binary blob in little endian accessed in JavaScript as an `ArrayBuffer`.

## Layout

A tile is composed of two sections: a header immediately followed by a body. The following figure shows the Batched 3D Model layout (dashes indicate optional fields):

![](figures/layout.png)

## Header

The 28-byte header contains the following fields:

|Field name|Data type|Description|
|----------|---------|-----------|
| `magic` | 4-byte ANSI string | `"b3dm"`.  This can be used to identify the arraybuffer as a Batched 3D Model tile. |
| `version` | `uint32` | The version of the Batched 3D Model format. It is currently `1`. |
| `byteLength` | `uint32` | The length of the entire tile, including the header, in bytes. |
| `featureTableJSONByteLength` | `uint32` | The length of the Feature Table JSON section in bytes. Zero indicates there is no Feature Table. |
| `featureTableBinaryByteLength` | `uint32` | The length of the Feature Table binary section in bytes. If `featureTableJSONByteLength` is zero, this will also be zero. |
| `batchTableJSONByteLength` | `uint32` | The length of the Batch Table JSON section in bytes. Zero indicates there is no Batch Table. |
| `batchTableBinaryByteLength` | `uint32` | The length of the Batch Table binary section in bytes. If `batchTableJSONByteLength` is zero, this will also be zero. |

If `featureTableJSONByteLength` equals zero, the tile does not need to be rendered.

The body section immediately follows the header section, and is composed of three fields: `Feature Table`, `Batch Table`, and `Binary glTF`.

> Implementation Note: Code for reading the header can be found in
[Batched3DModelTileContent](https://github.com/AnalyticalGraphicsInc/cesium/blob/master/Source/Scene/Batched3DModel3DTileContent.js)
in the Cesium implementation of 3D Tiles.

## Feature Table

Contains values for `b3dm` semantics.
More information is available in the [Feature Table specification](../FeatureTable/README.md).

The `b3dm` Feature Table JSON schema is defined in [b3dm.featureTable.schema.json](../../schema/b3dm.featureTable.schema.json).

### Semantics

#### Feature semantics

There are currently no per-feature semantics.

#### Global semantics

These semantics define global properties for all features.

| Semantic | Data Type | Description | Required |
| --- | --- | --- | --- |
| `BATCH_LENGTH` | `uint32` | The number of distinguishable models, also called features, in the batch. If the Binary glTF does not have a `batchId` attribute, this field _must_ be `0`. | :white_check_mark: Yes. |
| `RTC_CENTER` | `float32[3]` | A 3-component array of numbers defining the center position when positions are defined relative-to-center. | :red_circle: No. |

## Batch Table

The _Batch Table_ contains per-model application-specific metadata, indexable by `batchId`, that can be used for [declarative styling](../../Styling/README.md) and application-specific use cases such as populating a UI or issuing a REST API request.  In the binary glTF section, each vertex has an numeric `batchId` attribute in the integer range `[0, number of models in the batch - 1]`.  The `batchId` indicates the model to which the vertex belongs.  This allows models to be batched together and still be identifiable.

See the [Batch Table](../BatchTable/README.md) reference for more information.

## Binary glTF

Batched 3D Model uses [glTF 2.0](https://github.com/KhronosGroup/glTF/tree/master/specification/2.0) to embed model data.

The [binary glTF](https://github.com/KhronosGroup/glTF/tree/master/specification/2.0#binary-gltf-layout) immediately follows the Feature Table and Batch Table.  It may embed all of its geometry, texture, and animations, or it may refer to external sources for some or all of these data.

The glTF asset must be 8-byte aligned so that glTF's byte-alignment guarantees are met. This can be done by padding the Feature Table or Batch Table if they are present.

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

The `batchId` is identified by the glTF technique parameter semantic `_BATCHID`.  For example:

```JSON
"technique": {
    "attributes": {
        "a_batchId": "batchId"
    },
    "parameters": {
        "batchId": {
            "semantic": "_BATCHID",
            "type": 5126
        }
    }
}
```

For this example the attribute is named `a_batchId`, and is declared in the vertex shader as:

```glsl
attribute float a_batchId;
```

The vertex shader can be modified at runtime to use `a_batchId` to access individual models in the batch, e.g., to change their color.

When a Batch Table is present or the `BATCH_LENGTH` property is greater than `0`, the `batchId` attribute (with the parameter semantic `_BATCHID`) is required; otherwise, it is not.

### Coordinate reference system (CRS)

Vertex positions are defined according to a right-handed coordinate system where the _y_-axis is up [2].

Vertex positions may be defined relative-to-center for high-precision rendering [1]. If defined, `RTC_CENTER` specifies the center position and all vertex positions are treated as relative to this value. When `RTC_CENTER` is used, vertex positions are defined according to a coordinate system where the _z_-axis is up.

## File extension and MIME type

Batched 3D Model tiles use the `.b3dm` extension and `application/octet-stream` MIME type.

An explicit file extension is optional. Valid implementations may ignore it and identify a content's format by the `magic` field in its header.

## Resources

1. [Precisions, Precisions](http://blogs.agi.com/insight3d/index.php/2008/09/03/precisions-precisions/)
2. [glTF Coordinate System and Units](https://github.com/KhronosGroup/glTF/tree/master/specification/2.0#coordinate-system-and-units)
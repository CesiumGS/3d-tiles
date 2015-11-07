# Batched 3D Model

## Contributors

* Patrick Cozzi, [@pjcozzi](https://twitter.com/pjcozzi)
* Tom Fili, [@CesiumFili](https://twitter.com/CesiumFili)

## Overview

_Batched 3D Model_ allows offline batching of heterogeneous 3D models, such as different buildings in a city, for efficient streaming to a web client for rendering and interaction.  Efficiency comes from transferring multiple models in a single request and rendering them in the least number of WebGL draw calls necessary.

Per-model properties, such as IDs, enable individual models to be identified and updated at runtime, e.g., show/hide, highlight color, etc. Properties may be used, for example, to query a web service to access metadata, such as passing a building's ID to get its address. Or a property might be referenced on-the-fly for changing a model's appearance, e.g., changing highlight color based on a property value.

Batched 3D Model, or just the _batch_, is a binary blob in little endian accessed in JavaScript as an `ArrayBuffer`.

## Layout

A tile is composed of a header immediately followed by a body.

**Figure 1**: Batched 3D Model layout (dashes indicate optional sections).

![](figures/layout.png)

## Header

The 16-byte header contains:

|Field name|Data type|Description|
|----------|---------|-----------|
| `magic` | 4-byte ANSI string | `"b3dm"`.  This can be used to identify the arraybuffer as a Batched 3D Model tile. |
| `version` | `uint32` | The version of the Batched 3D Model format. It is currently `1`. |
| `byteLength` | `uint32` | The length of the entire tile, including the header, in bytes. |
| `batchLength` | `unit32` | The number of models in the batch.  This must be greater than or equal to zero. |
| `batchTableByteLength` | `uint32` | The length of the batch table in bytes.  This must be greater than or equal to zero.  Zero indicates there is not a batch table. |

_TODO: code example reading header_

The body immediately follows the header, and is composed of two fields: `Batch Table` and `Binary glTF`.

## Batch Table

In the Binary glTF section, each vertex has an unsigned short `batchId` attribute in the range `[0, number of models in the batch - 1]`.  The `batchId` indicates the model to which the vertex belongs.  This allows models to be batched together and still be identifiable.

The batch table maps each `batchId` to per-model properties.  If present, the batch table immediately follows the header and is `batchTableByteLength` bytes long.

The batch table is a `UTF-8` string containing JSON.  It immediately follows the header.  It can be extracted from the arraybuffer using the `TextDecoder` JavaScript API and transformed to a JavaScript object with `JSON.parse`.

Each property in the object is an array with its length equal to `header.batchLength`.  Each array is a homogeneous collection of `String`, `Number`, or `Boolean` elements.  Elements may be `null`.

A vertex's `batchId` is used to access elements in each array and extract the corresponding properties.  For example, the following batch table has properties for a batch of two models.
```json
{
    "id" : ["unique id", "another unique id"],
    "displayName" : ["Building name", "Another building name"],
    "yearBuilt" : [1999, 2015]
}
```

The properties for the model with `batchId = 0` are
```javascript
id[0] = 'unique id';
displayName[0] = 'Building name';
yearBuilt[0] = 1999;
```

The properties for `batchId = 1` are
```javascript
id[1] = 'another unique id';
displayName[1] = 'Another building name';
yearBuilt[1] = 2015;
```

## Binary glTF

[glTF](https://www.khronos.org/gltf) is the runtime asset format for WebGL.  [Binary glTF](https://github.com/KhronosGroup/glTF/tree/master/extensions/Khronos/KHR_binary_glTF) is an extension defining a binary container for glTF.  Batched 3D Model uses glTF 1.0 with the [KHR_binary_glTF](https://github.com/KhronosGroup/glTF/tree/master/extensions/Khronos/KHR_binary_glTF) extension.

Binary glTF immediately follows the batch table.  It begins `12 + batchTableByteLength` bytes from the start of the arraybuffer and continues for the rest of arraybuffer.  It may embed all of its geometry, texture, and animations, or it may refer to external sources for some or all of these data.

As described above, each vertex has a `batchId` attribute indicating the model to which it belongs.  For example, vertices for a batch with three models may look like this:
```
batchId:  [0,   0,   0,   ..., 1,   1,   1,   ..., 2,   2,   2,   ...]
position: [xyz, xyz, xyz, ..., xyz, xyz, xyz, ..., xyz, xyz, xyz, ...]
normal:   [xyz, xyz, xyz, ..., xyz, xyz, xyz, ..., xyz, xyz, xyz, ...]
```
Vertices do not need to be ordered by `batchId` so the following is also OK:
```
batchId:  [0,   1,   2,   ..., 2,   1,   0,   ..., 1,   2,   0,   ...]
position: [xyz, xyz, xyz, ..., xyz, xyz, xyz, ..., xyz, xyz, xyz, ...]
normal:   [xyz, xyz, xyz, ..., xyz, xyz, xyz, ..., xyz, xyz, xyz, ...]
```
Note that a vertex can't belong to more than one model; in that case, the vertex needs to be duplicated so the `batchId`s can be assigned.

The `batchId` is identified by the glTF technique parameter semantic `BATCHID`.  In the vertex shader, the attribute is named `a_batchId` and is declared as:
```glsl
attribute float a_batchId;
```
The vertex shader can be modified at runtime to use `a_batchId` to access individual models in the batch, e.g., to change their color.

Although not strictly required, clients may find the glTF [CESIUM_RTC](https://github.com/KhronosGroup/glTF/blob/new-extensions/extensions/CESIUM_RTC/README.md) extension useful for high-precision rendering.

## File Extension

`.b3dm`

## MIME Type

_TODO_

`application/octet-stream`

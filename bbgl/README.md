_TODO: change name to something like "Batched 3D Model"_

# Batched Binary glTF

## Contributors

* Patrick Cozzi, [@pjcozzi](https://twitter.com/pjcozzi)
* Tom Fili, [@CesiumFili](https://twitter.com/CesiumFili)

## Overview

Batched Binary glTF allows offline batching of heterogeneous 3D models, such as different buildings in a city, for efficient streaming to a web client for rendering and interaction.  Efficiency comes from transfering multiple models in a single request and rendering them in the least number of WebGL draw calls necessary.

Per-model IDs and metadata enable individual models to be identified and updated at runtime, e.g., show/hide, hightlight color, etc., and enable individual models to reference properties, for example, to query REST services, for display, or for updating, e.g., changing highlight color based on a property value.

Batched Binary glTF is a binary blob in little endian accessed in JavaScript as an `ArrayBuffer`.

## Layout

_TODO: extensions?_

**Figure 1**: Batched Binary glTF layout (dashes indicate optional sections).

![](figures/layout.png)

### Header

The 12-byte header contains:

* `magic` - 4-byte ANSI string `bbgl`.  This can be used to identify the arraybuffer as Batched Binary glTF.
* `version` - `uint32` that contains the version of the Batched Binary glTF format, which is currently `1`.
* `batchTableLength` - `uint32` that contains the length of the batch table.  It may be zero indicating there is not a batch table.

### Batch Table

In the Binary glTF section, each vertex has a `batchId` attribute (_TODO: type_) in the range `[0, number of models in the batch - 1]`.  The `batchId` indicates the model to which the vertex belongs.  This allows models to be batched together and still be identifiable.

The batch table maps each `batchId` to per-model properties.  If present, the batch table immediately follows the header and is `batchTableLength` bytes long.

The batch table is a `UTF-8` string containing JSON.  It can be extracted from the arraybuffer using the `TextDecoder` JavaScript API and transformed to a JavaScript object with `JSON.parse`.

Each property in the object is an array with its length equal to the number of models in the batch.  Each array is a homogeneous collection of `String`, `Number`, or `Boolean` elements.  Elements may be `null`.

_TODO: schema._

A vertex's `batchId` is used to access elements in each array, and extract the corresponding properties.  For example, the following batch table has properties for a batch of two models.
```json
{
    "id" : ["unique id", "another unique id"],
    "displayName" : ["Building name", "Another building name"],
    "yearBuilt" : [1999, 2015]
}
```

The properties for the model with `batchId = 0` are:
```javascript
id[0] = 'unique id';
displayName[0] = 'Building name';
yearBuilt[0] = 1999;
```

The properties for `batchId = 1` are:
```javascript
id[1] = 'another unique id';
displayName[1] = 'Another building name';
yearBuilt[1] = 2015;
```

### Binary glTF

[glTF](https://www.khronos.org/gltf) is the runtime asset format for WebGL.  [Binary glTF](https://github.com/KhronosGroup/glTF/blob/new-extensions/extensions/CESIUM_binary_glTF/README.md) is an extension defining a binary container for glTF.

Binary glTF immediately follows the batch table.  It begins `12 + batchTableLength` bytes from the start of the arraybuffer and continues for the rest of arraybuffer.  It may embed all of its geometry, texture, and animations or may refer to external sources for some or all of these data.

As described above, each vertex has a `batchId` attribute indicating the model to which it belongs.  For example, vertices for a batch with three models may look like:
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

_TODO: WGS84 coordnates - or that really belongs elsewhere so this can be used in different scenarios._

The `batchId` is identified by the glTF technique parameter semantic `BATCHID`.  In the vertex shader, the attribute is named `a_batchId` and is declared as:
```glsl
attribute float a_batchId;
```
The vertex shader can be modified at runtime to use `a_batchId` to access individual models in the batch, e.g., to change their color.

Although not strictly required, clients may find the glTF [CESIUM_RTC](https://github.com/KhronosGroup/glTF/blob/new-extensions/extensions/CESIUM_RTC/README.md) extension useful for high-precision rendering.

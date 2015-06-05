_TODO: change name to something like "Batched Model"_

# Batched Binary glTF

## Contributors

* Patrick Cozzi, [@pjcozzi](https://twitter.com/pjcozzi)
* Tom Fili, [@CesiumFili](https://twitter.com/CesiumFili)

## Overview

Batched Binary glTF allows offline batching of heterogeneous 3D models, such as different buildings in a city, for efficient streaming to a web client for rendering.  The efficiency comes from transfering multiple models in a single request and rendering them in the least number of WebGL draw calls necessary.

IDs and metadata are supported so individual models can be identified and updated at runtime, e.g., show/hide, hightlight color, etc., and individual models can carry properties used to query REST services, for display, or for updating, e.g., changing highlight color based on a property value.

Batched Binary glTF is little endian.

## Layout

Batched Binary glTF is a binary blob accessed in JavaScript as an `ArrayBuffer`.

**Figure 1**: Batched Binary glTF layout.

![](figures/layout.png)

### Header

The 12-byte header contains:

* `magic` - 4-byte ANSI string `bbgl`.  This can be used to identify the arraybuffer as Batched Binary glTF.
* `version` - `uint32` that indicates the version of the Batched Binary glTF format, which is currently `1`.
* `batchTableLength` - `uint32` that indicates the length of the batch table.  It may be zero indicating there is not a batch table.

### Batch Table

If present, the batch table immediately follows the header and is `batchTableLength` bytes long.

The batch table is a `UTF-8` string containing JSON.  It can be extracted from the arraybuffer using the `TextDecoder` JavaScript API and transformed to a JavaScript object with `JSON.parse`.

Each property in the object is an array with its length equal to the number of models in the batch.  Each array is a homogeneous collection of `String`, `Number`, or `Boolean` elements.  Array elements may be `null`.

_TODO: schema._

A model's zero-based `batchId` is used to lookup into each array, and extract the model's properties.

For example, the following example batch table has properties for two models.
```json
{
    "id" : ["unique id", "another unique id"]
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

Binary glTF immediately follows the batch table.  It begins `12 + batchTableLength` bytes from the start of the arraybuffer and continues for the rest of arraybuffer.

It may embed all of its geometry, texture, and animations or may refer to external sources for some or all of these data.  See the [Binary glTF extension](https://github.com/KhronosGroup/glTF/blob/new-extensions/extensions/CESIUM_binary_glTF/README.md) for complete details.

_TODO: we we want to include a length in the header so we can combine multiple bbgls into one?_

_TODO_
   * CESIUM_RTC extension
   * New attribute semantic: `BATCHID`
   * New well-known vertex shader attribute: `a_batchId`

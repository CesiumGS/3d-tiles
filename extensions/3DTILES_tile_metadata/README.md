# 3DTILES_tile_metadata

## Overview

This extension to 3D Tiles allows for storage of per-tile metadata in external binary buffers.

## Indexing

When using 3D Tiles 1.0, the tile metadata is indexed using the Depth First Traversal of the `tileset.json`.

When using the `3DTILES_implicit_tiling` extension, the tile metadata is indexed using the metadata bitstream.

## Dependencies

This extension depends on [3DTILES_binary_buffers](https://github.com/CesiumGS/3d-tiles/blob/3DTILES_binary_buffers/extensions/3DTILES_binary_buffers/README.md) for storage of the binary data.

## Properties Reference

---------------------------------------
### 3DTILES_tile_metadata Tileset JSON extension

**Properties**

|   |Type|Description|Required|
|---|----|-----------|--------|
|**properties**|`object`|An object containing one or more metadata properties associated with each tile.|No|

---------------------------------------
### 3DTILES_tile_metadata.properties

This property of the 3DTILES_tile_metadata object enumerates the different metadata properties associated with each tile in the tileset.

**Properties**

|   |Type|Description|Required|
|---|----|-----------|--------|
|**semantic**|`string`|The name of the property. Semantic names must be unique.|No|
|**bufferView**|`integer`|The index of the bufferView in the the bufferViews array of `3DTILES_binary_buffers`.|☑️ Yes|

Application-specific semantics may also be defined, with the caveat that they must begin with an underscore, e.g. _CLASSIFICATION.

## Example

```json
{
  "extensions": {
    "3DTILES_tile_metadata": {
      "properties": {
        "revisionDate": {
          "semantic": "_REVISION_DATE",
          "bufferView": 0
        },
        "id": {
          "semantic": "_TILE_ID",
          "bufferView": 2
        },
        "center": {
          "semantic": "_TILE_CENTER",
          "bufferView": 3
        }
      },
    },
    "3DTILES_binary_buffers": {
      "bufferViews": [
        {
          "buffer": 0,
          "byteOffset": 0,
          "byteLength": 3,
          "componentType": "INT",
        },
        {
          "buffer": 2,
          "byteOffset": 0,
          "byteLength": 3,
          "componentType": "UNSIGNED_BYTE"
        }
        {
          "buffer": 1,
          "byteOffset": 0,
          "byteLength": 18,
          "elementByteOffsetsBufferView": 1,
          "componentType": "STRING"
        },
        {
          "buffer": 3,
          "byteOffset": 0,
          "byteLength": 36,
          "type": "VEC3",
          "componentType": "FLOAT"
        }
      ],
      "buffers": [
        {
          "uri": "revision_dates.bin",
          "byteLength": 3
        },
        {
          "uri": "tile_names.bin",
          "byteLength": 18
        },
        {
          "uri": "offsets.bin",
          "byteLength": 3
        },
        {
          "uri": "tile_centers.bin",
          "byteLength": 36
        }
      ]
    }
  }
}
```
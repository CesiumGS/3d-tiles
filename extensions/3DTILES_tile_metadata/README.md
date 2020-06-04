# 3DTILES_tile_metadata

## Overview

This extension to 3D Tiles allows for storage of per-tile metadata in external binary buffers.

## Indexing

When using 3D Tiles 1.0, the tile metadata is indexed using the Depth First Traversal of the `tileset.json`.

When using the `3DTILES_implicit_tiling` extension, the tile metadata is indexed using the metadata bitstream.

## Properties Reference

---------------------------------------
### 3DTILES_tile_metadata Tileset JSON extension

**Properties**

|   |Type|Description|Required|
|---|----|-----------|--------|
|**properties**|`object`|An object containing one or more metadata properties associated with each tile.|No|
|**bufferViews**|`array`|An array containing typed views into buffers|No|
|**buffers**|`array`|An array of buffers.|No|

---------------------------------------
### 3DTILES_tile_metadata.properties

This property of the 3DTILES_tile_metadata object enumerates the different metadata properties associated with each tile in the tileset.

**Properties**

|   |Type|Description|Required|
|---|----|-----------|--------|
|**semantic**|`string`|The name of the feature. Semantic names must be unique.|No|
|**bufferView**|`integer`|The index of the bufferView.|☑️ Yes|


Application-specific semantics may also be defined, with the caveat that they must begin with an underscore, e.g. _CLASSIFICATION.

---------------------------------------
### 3DTILES_tile_metadata.bufferViews

`bufferViews` provide a typed view into a `buffer`.

**Properties**

|   |Type|Description|Required|
|---|----|-----------|--------|
|**buffer**|`integer`|The index of the buffer.|☑️ Yes|
|**byteOffset**|`integer`|The offset relative to the start of the buffer in bytes.|☑️ Yes|
|**byteLength**|`integer`|The length of the bufferView in bytes.| ☑️ Yes|
|**elementByteOffsetsBufferView**|`integer`|The index of the bufferView containing byte offsets for each element. Must be defined for the STRING type.|No|
|**type**|`string`|Specifies if the attribute is a scalar, vector, matrix or string.|No, default is one element.|
|**componentType**|`string`|The datatype of components in the attribute.|☑️ Yes|

Allowed `componentType`s:

- `"BYTE"`
- `"UNSIGNED_BYTE"`
- `"SHORT"`
- `"UNSIGNED_SHORT"`
- `"INT"`
- `"UNSIGNED_INT"`
- `"FLOAT"`
- `"DOUBLE"`

Allowed `type`s:

| `type` | Number of components |
|:------:|:--------------------:|
| `"SCALAR"` | 1 |
| `"STRING"` | 1 |
| `"VEC2"` | 2 |
| `"VEC3"` | 3 |
| `"VEC4"` | 4 |
| `"MAT2"` | 4 |
| `"MAT3"` | 9 |
| `"MAT4"` | 16 |

---------------------------------------
### 3DTILES_tile_metadata.buffers
A buffer points to binary data.

**Properties**

|   |Type|Description|Required|
|---|----|-----------|--------|
|**uri**|`string`|The uri of the buffer.|No|
|**byteLength**|`integer`|The total byte length of the buffer view.| ☑️ Yes|

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
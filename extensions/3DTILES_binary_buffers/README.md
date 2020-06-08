# 3DTILES_binary_buffers

## Overview

This extension to 3D Tiles enables storage of binary data in external buffers.

## Properties Reference

---------------------------------------
### 3DTILES_binary_buffers.bufferViews

`bufferViews` provide a typed view into a `buffer`.

**Properties**

|   |Type|Description|Required|
|---|----|-----------|--------|
|**buffer**|`integer`|The index of the buffer.|☑️ Yes|
|**byteOffset**|`integer`|The offset relative to the start of the buffer in bytes.|☑️ Yes|
|**byteLength**|`integer`|The length of the bufferView in bytes.| ☑️ Yes|
|**elementCount**|`integer`|The number of elements in the buffer view.| ☑️ Yes|
|**elementByteOffsetsBufferView**|`integer`|The index of the bufferView containing byte offsets for each element. Must be defined for the STRING type.|No|
|**elementType**|`string`|Specifies if the attribute is a scalar, vector, matrix or string.|No, default is `SCALAR`.|
|**componentType**|`string`|The datatype of components in the attribute.|☑️ Yes|


#### Element Types

| Element Type | No. of components |
|:------------:|:-----------------:|
| SCALAR | 1 |
| STRING | 1 |
| VEC2 | 2 |
| VEC3 | 3 | 
| VEC4 | 4 |
| MAT2 | 4 |
| MAT3 | 9 |
| MAT4 | 16 |

*Note: The `STRING` element type only stores UTF-8 encoded strings.*

#### Component Types

| Component | Size (bits) |
|:---------:|:------------:|
| BIT | 1 |
| BYTE | 8 |
| UNSIGNED_BYTE | 8 |
| SHORT | 16 |
| UNSIGNED_SHORT | 16 |
| HALF_FLOAT | 16 |
| INT | 32 |
| UNSIGNED_INT | 32 |
| FLOAT | 32 |
| DOUBLE | 64 |


---------------------------------------
### 3DTILES_binary_buffers.buffers
A buffer points to a blob data.

**Properties**

|   |Type|Description|Required|
|---|----|-----------|--------|
|**uri**|`string`|The uri of the buffer.| ☑️ Yes|
|**byteLength**|`integer`|The total byte length of the buffer view.| ☑️ Yes|

## Examples

### 3DTILES_implicit_tiling and 3DTILES_tile_metadata

```json
{
    "asset": {
        "version": "2.0.0-alpha.0"
    },
    "extensions": {
        "3DTILES_implicit_tiling": {
            "tilingScheme": "quadtree",
            "subdivision": {
                "completeLevels": 2,
                "bufferView": 0
            },
            "content": {
                "levelOffset": 2,
                "levelOffsetFill": 0,
                "bufferView": 1
            },
            "metadata": {
                "levelOffset": 2,
                "levelOffsetFill": 0,
                "bufferView": 1
            }
        },
        "3DTILES_tile_metadata": {
            "properties": {
                "surfaceArea": {
                    "semantic": "_SURFACE_AREA",
                    "bufferView": 2
                },
                "tileId": {
                    "semantic": "_TILE_ID",
                    "bufferView": 3
                }
            }
        },
        "3DTILES_binary_buffers": {
            "bufferViews": [
                {
                    "elementType": "VEC2",
                    "componentType": "BIT",
                    "byteOffset": 0,
                    "byteLength": 2,
                    "buffer": 0
                },
                {
                    "elementType": "SCALAR",
                    "componentType": "BIT",
                    "byteOffset": 2,
                    "byteLength": 4,
                    "buffer": 0
                },
                {
                    "elementType": "SCALAR",
                    "componentType": "FLOAT",
                    "byteOffset": 0,
                    "byteLength": 32,
                    "buffer": 1
                },
                {
                    "elementType": "STRING",
                    "byteOffset": 32,
                    "byteLength": 64,
                    "elementByteOffsetsBufferView": 5,
                    "buffer": 2
                },
                {
                    "elementType": "SCALAR",
                    "componentType": "UNSIGNED_INT",
                    "byteOffset": 0,
                    "byteLength": 32,
                    "buffer": 2
                }
            ],
            "buffer": [
                {
                    "uri": "implicit.bin",
                    "byteLength": 6
                },
                {
                    "uri": "metadata_surface_area.bin",
                    "byteLength": 32
                },
                {
                    "uri": "metadata_tile_id.bin",
                    "byteLength": 96
                }
            ]
        }
    }
}

```
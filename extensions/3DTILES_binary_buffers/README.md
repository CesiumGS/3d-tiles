# 3DTILES_binary_buffers

## Overview

This extension to 3D Tiles enables storage of binary data in external buffers.

## Data Alignment

The byte offset of a buffer view into a buffer must be a multiple of the size of the buffer view's component type. For a buffer view that uses the `BIT` element type, the data must be padded with `0`s to meet the nearest byte boundary.

Buffer views of matrix type have data stored in column-major order; start of each column must be aligned to 4-byte boundaries. To achieve this, three `elementType`/`componentType` combinations require special layout:

**MAT2, 1-byte components**
```
| 00| 01| 02| 03| 04| 05| 06| 07| 
|===|===|===|===|===|===|===|===|
|m00|m10|---|---|m01|m11|---|---|
```

**MAT3, 1-byte components**
```
| 00| 01| 02| 03| 04| 05| 06| 07| 08| 09| 0A| 0B|
|===|===|===|===|===|===|===|===|===|===|===|===|
|m00|m10|m20|---|m01|m11|m21|---|m02|m12|m22|---|
```

**MAT3, 2-byte components**
```
| 00| 01| 02| 03| 04| 05| 06| 07| 08| 09| 0A| 0B| 0C| 0D| 0E| 0F| 10| 11| 12| 13| 14| 15| 16| 17|
|===|===|===|===|===|===|===|===|===|===|===|===|===|===|===|===|===|===|===|===|===|===|===|===|
|m00|m00|m10|m10|m20|m20|---|---|m01|m01|m11|m11|m21|m21|---|---|m02|m02|m12|m12|m22|m22|---|---|
```

Alignment requirements apply only to start of each column, so trailing bytes could be omitted if there's no further data. 

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
|**elementByteOffsetsBufferView**|`integer`|The index of the bufferView containing byte offsets for each element. Must be defined for the STRING and NONUNIFORM element types.|No|
|**elementType**|`string`|Specifies if the attribute is a scalar, vector, matrix or string.|No, default is `SCALAR`.|
|**componentType**|`string`|The datatype of components in the attribute. Must be defined for every other element type, except STRING and NONUNIFORM (in which case it will be ignored).|No|


#### Element Types

| Element Type | No. of components |
|:------------:|:-----------------:|
| SCALAR | 1 |
| STRING | 1 |
| NONUNIFORM | 1 |
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
|**byteLength**|`integer`|The total byte length of the buffer.| ☑️ Yes|

## Examples

### 3DTILES_implicit_tiling and 3DTILES_tile_metadata

```json
{
    "asset": {
        "version": "1.0"
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
                    "elementByteOffsetsBufferView": 4,
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
            "buffers": [
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

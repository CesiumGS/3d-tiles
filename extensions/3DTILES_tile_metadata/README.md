# 3DTILES_tile_metadata

## Contributors

* Sam Suhag, Cesium
* Sean Lilley, Cesium

## Status

Draft

## Dependencies

Written against the 3D Tiles 1.0 spec. This extension depends on [`3DTILES_binary_buffers`](https://github.com/CesiumGS/3d-tiles/blob/3DTILES_binary_buffers/extensions/3DTILES_binary_buffers/README.md) for storage of the binary data.

## Contents

  - [Overview](#overview)
  - [Optional vs. Required](#optional-vs-required)
  - [Schema Updates](#schema-updates)
  - [Examples](#examples)

## Overview

This extension enables storage of per-tile metadata in external binary buffers.

Tile metadata is indexed based on a pre-order depth-first traversal starting at `root`.

When using the [`3DTILES_implicit_tiling`](https://github.com/CesiumGS/3d-tiles/blob/3DTILES_implicit_tiling/extensions/3DTILES_implicit_tiling/README.md) extension, the tile metadata is indexed according to the implicit tree traversal.

## Optional vs. Required

This extension is optional, meaning it should be placed in the tileset JSON top-level `extensionsUsed` list, but not in the `extensionsRequired` list.

## Schema Updates

`3DTILES_tile_metadata` is a property of the top-level `extensions` object that defines property types and property arrays for tile metadata. Property arrays are stored in [Apache Arrow Columnar Format 1.0](https://arrow.apache.org/docs/format/Columnar.html).

There are currently no built-in semantics for property types.

The full JSON schema can be found in [tileset.3DTILES_tile_metadata.schema.json](schema/tileset.3DTILES_tile_metadata.schema.json).

## Examples

```json
{
  "asset": {
    "version": "1.0"
  },
  "extensionsUsed": ["3DTILES_tile_metadata", "3DTILES_binary_buffers"],
  "extensions": {
    "3DTILES_tile_metadata": {
      "properties": [
        {
          "name": "Revision date",
          "semantic": "_REVISION_DATE",
          "valueType": "STRING"
        },
        {
          "name": "Horizon occlusion point",
          "semantic": "_HORIZON_OCCLUSION_POINT",
          "valueType": "FLOAT64",
          "elementType": "ARRAY",
          "valuesPerElement": 3
        }
      ],
      "arrayLengths": 5,
      "propertyArrays": [
        {
          "bufferView": 0,
          "offsetBufferView": 1
        },
        {
          "bufferView": 2
        }
      ]
    },
    "3DTILES_binary_buffers": {
      "bufferViews": [
        {
          "buffer": 0,
          "byteOffset": 0,
          "byteLength": 40
        },
        {
          "buffer": 0,
          "byteOffset": 40,
          "byteLength": 24
        }
        {
          "buffer": 0,
          "byteOffset": 64,
          "byteLength": 120
        }
      ],
      "buffers": [
        {
          "uri": "external.bin",
          "byteLength": 184
        }
      ],
      "extras": {
        "draftVersion": "0.0.0"
      }
    }
  },
  "geometricError": 240,
  "root": {
    "boundingVolume": {
      "region": [
        -1.3197209591796106,
        0.6988424218,
        -1.3196390408203893,
        0.6989055782,
        0,
        88
      ]
    },
    "geometricError": 70,
    "refine": "ADD",
    "content": {
      "uri": "parent.b3dm",
      "boundingVolume": {
        "region": [
          -1.3197004795898053,
          0.6988582109,
          -1.3196595204101946,
          0.6988897891,
          0,
          88
        ]
      }
    },
    "children": [
      {
        "boundingVolume": {
          "region": [
            -1.3197209591796106,
            0.6988424218,
            -1.31968,
            0.698874,
            0,
            20
          ]
        },
        "geometricError": 0,
        "content": {
          "uri": "ll.b3dm"
        }
      },
      {
        "boundingVolume": {
          "region": [
            -1.31968,
            0.6988424218,
            -1.3196390408203893,
            0.698874,
            0,
            20
          ]
        },
        "geometricError": 0,
        "content": {
          "uri": "lr.b3dm"
        }
      },
      {
        "boundingVolume": {
          "region": [
            -1.31968,
            0.698874,
            -1.3196390408203893,
            0.6989055782,
            0,
            20
          ]
        },
        "geometricError": 0,
        "content": {
          "uri": "ur.b3dm"
        }
      },
      {
        "boundingVolume": {
          "region": [
            -1.3197209591796106,
            0.698874,
            -1.31968,
            0.6989055782,
            0,
            20
          ]
        },
        "geometricError": 0,
        "content": {
          "uri": "ul.b3dm"
        }
      }
    ]
  }
}
```
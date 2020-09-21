# 3DTILES_binary_buffers

## Contributors

* Sam Suhag, Cesium
* Sean Lilley, Cesium

## Status

Draft

## Dependencies

Written against the 3D Tiles 1.0 spec.

## Contents

  - [Overview](#overview)
  - [Optional vs. Required](#optional-vs-required)
  - [Schema Updates](#schema-updates)
  - [Examples](#examples)

## Overview

This extension enables storage of binary data in external buffers.

## Optional vs. Required

This extension is required if extensions that depend on it are required. Otherwise it is optional. If required it should be placed in the tileset JSON top-level `extensionsRequired` list.

## Schema Updates

`3DTILES_binary_buffers` is a property of the top-level `extensions` object and contains two properties:

* `bufferViews`: an array of buffer views, generally representing subsets of buffers
* `buffers`: an array of buffers pointing to binary data

The full JSON schema can be found in [tileset.3DTILES_binary_buffers.schema.json](schema/tileset.3DTILES_binary_buffers.schema.json).

## Examples

```json
{
  "asset": {
    "version": "1.0"
  },
  "extensionsUsed": ["3DTILES_binary_buffers"],
  "extensionsRequired": ["3DTILES_binary_buffers"],
  "extensions": {
    "3DTILES_binary_buffers": {
      "bufferViews": [
        {
          "buffer": 0,
          "byteOffset": 0,
          "byteLength": 98
        },
        {
          "buffer": 0,
          "byteOffset": 100,
          "byteLength": 250
        }
      ],
      "buffers": [
        {
          "uri": "external.bin",
          "byteLength": 350
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
      "region": [-1.31972, 0.69884, -1.31964, 0.6989, 0, 88]
    },
    "geometricError": 70,
    "refine": "ADD",
    "content": {
      "uri": "tile.b3dm",
      "extras": {
        "editHistory": {
          "year": "2020",
          "bufferView": 0
        },
        "author": {
          "name": "Cesium",
          "bufferView": 1
        }
      }
    }
  }
}
```
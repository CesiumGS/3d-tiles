# MAXAR_layer_content_3tz 

## Contributors

Erik Dahlström, Maxar, [@erikdahlstrom](https://twitter.com/erikdahlstrom)

## Status

Draft

## Dependencies

This extension depends on 3DTILES_layers.

## Contents

  - [Overview](#overview)
  - [Optional vs. Required](#optional-vs-required)
  - [Schema Updates](#schema-updates)
  - [Examples](#examples)

## Overview

This extension allows a 3DTILES_layers layer content to use a 3tz container as content.

When referencing a 3tz container as content directly, the root tileset of the 3tz, as defined by the [3D Tiles Archive Format 1.0 specification](https://github.com/CesiumGS/3d-tiles/issues/422), must be used.

The internet media type to use for 3tz archives is `application/vnd.maxar.archive.3tz+zip`.

## Optional vs Required

This extension is required, meaning it should be placed in the tileset JSON top-level `extensionsRequired` and `extensionsUsed` lists.

## Examples

```json
{
  "asset": {
    "version": "1.0"
  },
  "extensionsUsed": [
    "3DTILES_layers",
    "3DTILES_metadata",
    "MAXAR_layer_content_3tz"
  ],
  "extensionsRequired": [
    "3DTILES_layers",
    "3DTILES_metadata",
    "MAXAR_layer_content_3tz"
  ],
  "extensions": {
    "3DTILES_metadata": {
      "extras": {
        "draftVersion": "0.0.0"
      },
      "tileset": {
        "name": "Dataset with layers",
        "class": "dataset",
        "properties": {
          "revision": "0.3"
        }
      },
      "classes": {
        "dataset": {
          "properties": {
            "revision": {
              "elementType": "STRING"
            }
          }
        }
      }
    },
    "3DTILES_layers": {
      "extras": {
        "draftVersion": "0.0.0"
      },
      "layers": {
        "3D_Terrain": {
          "name": "Terrain",
          "class": "dataset",
          "properties": {
             "revision": "0.4"
          }
        },
        "3D_Buildings": {
          "name": "Buildings",
          "class": "dataset",
          "properties": {
             "revision": "0.2"
          }
        }
      }
    }
  },
  "geometricError": 500,
  "root": {
    "boundingVolume": {
      "region": [
        -1.2419,
        0.7395,
        -1.2415,
        0.7396,
        0,
        20.4
      ]
    },
    "geometricError": 500,
    "refine": "REPLACE",
    "extensions": {
      "3DTILES_layers": {
        "contents": [
          {
            "layer": "3D_Terrain",
             "uri": "terrain.3tz",
             "mimeType": "application/vnd.maxar.archive.3tz+zip"
          },
          {
            "layer": "3D_Buildings",
            "uri": "buildings.3tz",
            "mimeType": "application/vnd.maxar.archive.3tz+zip"
          }
        ]
      }
    }
  }
}
```
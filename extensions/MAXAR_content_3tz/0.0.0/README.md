# MAXAR_content_3tz 

**Version 0.0.0**, June 11, 2021

## Contributors

Erik Dahlström, Maxar, [@erikdahlstrom](https://twitter.com/erikdahlstrom)

## Status

Draft

## Dependencies

Written against the [3D Tiles 1.0](https://github.com/CesiumGS/3d-tiles/tree/1.0/specification) spec.

## Contents

  - [Overview](#overview)
  - [Optional vs. Required](#optional-vs-required)
  - [Examples](#examples)

## Overview

This extension allows a tileset to use a [3tz container](https://github.com/CesiumGS/3d-tiles/issues/422) directly as tile content.

When a 3tz container is referenced it must be handled as if the entire 3tz was decompressed, and as if the decompressed root tileset of the 3tz was referenced instead of the 3tz file itself. For details, see the [3D Tiles Archive Format 1.1 specification](https://github.com/CesiumGS/3d-tiles/issues/422).

Only the ['root'](https://github.com/CesiumGS/3d-tiles/blob/afa1fa3815c3e3bb97fe26a5e5665186702743ba/specification/schema/tileset.schema.json#L23) tile's direct children of the top-level tileset may reference 3tz containers.

## Optional vs Required

This extension is required, meaning it should be placed in the tileset JSON top-level `extensionsRequired` and `extensionsUsed` lists.

## Examples

```json
{
  "asset": {
    "version": "1.0"
  },
  "extensionsUsed": [
    "3DTILES_metadata",
    "MAXAR_content_3tz"
  ],
  "extensionsRequired": [
    "3DTILES_metadata",
    "MAXAR_content_3tz"
  ],
  "extensions": {
    "MAXAR_content_3tz" : {
      "extras": {
        "draftVersion": "0.0.0"
      }
    },
    "3DTILES_metadata": {
      "extras": {
        "draftVersion": "1.0.0"
      },
      "tileset": {
        "name": "Dataset with layers",
        "class": "dataset",
        "properties": {
          "revision": "0.3"
        }
      },
      "schema": {
        "classes": {
          "dataset": {
            "properties": {
              "revision": {
                "elementType": "STRING"
              }
            }
          }
        },
        "groups": {
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
    "children": [
      {
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
        "content": {
          "uri": "terrain.3tz",
          "extensions": {
            "3DTILES_metadata": {
              "group": "3D_Terrain"
            }
          }
        }
      },
      {
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
        "content": {
          "uri": "buildings.3tz",
          "extensions": {
            "3DTILES_metadata": {
              "group": "3D_Buildings"
            }
          }
        }
      }
    ]
  }
}
```
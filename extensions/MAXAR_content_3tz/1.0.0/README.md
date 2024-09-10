# MAXAR_content_3tz 

**Version 1.0.0**, November 18, 2021

## Contributors

Erik Dahlström, Maxar, [@erikdahlstrom](https://twitter.com/erikdahlstrom)

## Status

Draft

## Dependencies

Written against the [3D Tiles 1.0](https://github.com/CesiumGS/3d-tiles/tree/1.0/specification) spec.

Referenced 3tz files must follow the [3D Tiles Archive Format 1.3](https://github.com/erikdahlstrom/3tz-specification/blob/master/3D%20Tiles%20Archive%20Format%20v1.3.pdf) spec.

## Contents

  - [Overview](#overview)
  - [Path Resolver Algorithm](#path-resolver-algorithm)
  - [Optional vs. Required](#optional-vs-required)
  - [Examples](#examples)

## Overview

This extension allows a tileset to use a [3tz container](https://github.com/erikdahlstrom/3tz-specification/blob/master/3D%20Tiles%20Archive%20Format%20v1.3.pdf) directly as tile content.

When this extension is required by a tileset, then all URIs referenced by the tileset, both directly and indirectly, must be resolved using the 3tz [Path Resolver algorithm](#path-resolver-algorithm). Note that this requirement includes any URIs inside of tile contents, e.g resources referenced by glTF.

The URI path syntax must be used when referring to a specific file inside a 3tz container, thus treating the 3tz container as if it was a plain directory, e.g `../../resources.3tz/tiles/0/0/0.glb`.

Implementations may block any resolved URI that the tileset that required this
extension is not the base URI to.

Note that in the URIs any reserved characters (as defined by RFC 3986, Section 2.2. and RFC 3987, Section 2.2.) must be percent-encoded.

Note that if this extension is used to tie the datasets to some underlying storage 
or particular URI scheme, the data may become less portable as a result.

### Path Resolver Algorithm ###

1. If the URI is not a data URI and if the path of the URI matches the regular expression `(.+\.3tz)[\/]?(.*)` then let `resolved 3tz container path` be the first match group. The regular expression uses the grammar defined in [ECMAScript-262](https://262.ecma-international.org/5.1/#sec-15.10).

2. If the second match group is empty, the let the `resolved inner file path` be `tileset.json`, otherwise let the `resolved inner file path` be the second match group.

3. Return the file contents of the `resolved inner file path` from the 3tz file that can be read from the `resolved 3tz container path`.

    Implementations are allowed to return the file contents data in a form that suits the consumer of the data, e.g raw compressed data as long as the consumer itself can itself decompress the data if needed.

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
        "draftVersion": "1.0.0"
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
          "uri": "terrain.3tz/buildings.json",
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

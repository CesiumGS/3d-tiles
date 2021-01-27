<!-- omit in toc -->
# 3DTILES_multiple_contents

**Version 0.0.0**, [TODO: date]

<!-- omit in toc -->
## Contributors

* Sean Lilley, Cesium
* Sam Suhag, Cesium

<!-- omit in toc -->
## Status

Draft

<!-- omit in toc -->
## Dependencies

Written against the 3D Tiles 1.0 specification.

<!-- omit in toc -->
## Contents

- [Overview](#overview)
- [Concepts](#concepts)
  - [Metadata](#metadata)
  - [Implicit Tiling](#implicit-tiling)
- [Schema Updates](#schema-updates)


## Overview

This extension adds support for multiple contents per tile.

This is useful for datasets that have multiple content layers. Normally layering is achieved by combining contents into a [Composite](../../../specification/TileFormats/Composite/README.md) content, or by placing contents into sibling tiles, or by creating separate tilesets. With this extension content layers can exist cleanly in the same tileset, while allowing contents to be requested independently from each other.

## Concepts

A `tile` may be extended with the `3DTILES_multiple_contents` extension.

```jsonc
{
  "root": {
    "refine": "ADD",
    "geometricError": 0.0,
    "boundingVolume": {
      "region": [-1.707, 0.543, -1.706, 0.544, 203.895, 253.113]
    },
    "extensions": {
      "3DTILES_multiple_contents": {
        "content": [
          {
            "uri": "buildings.b3dm"
          },
          {
            "uri": "trees.i3dm"
          }
        ]
      }
    }
  }
}
```

When this extension is used the tile's `content` property must be omitted.

### Metadata

This extension may be paired with the [3DTILES_metadata](../../3DTILES_metadata/README.md) extension to assign metadata to each content layer.

```jsonc
{
  "extensions": {
    "3DTILES_metadata": {
      "classes": {
        "layer": {
          "properties": {
            "color": {
              "type": "ARRAY",
              "componentType": "UINT8",
              "componentCount": 3
            },
            "order": {
              "type": "INT32"
            }
          }
        }
      },
      "groups": {
        "buildings": {
          "class": "layer",
          "properties": {
            "color": [128, 128, 128],
            "order": 0
          }
        },
        "trees": {
          "class": "layer",
          "properties": {
            "color": [10, 240, 30],
            "order": 1
          }
        }
      }
    }
  },
  "root": {
    "refine": "ADD",
    "geometricError": 32768.0,
    "boundingVolume": {
      "region": [-1.707, 0.543, -1.706, 0.544, -10.3, 253.113]
    },
    "extensions": {
      "3DTILES_multiple_contents": {
        "content": [
          {
            "uri": "buildings.b3dm"
            "extensions": {
              "3DTILES_metadata": {
                "group": "buildings"
              }
            }
          },
          {
            "uri": "trees.i3dm"
            "extensions": {
              "3DTILES_metadata": {
                "group": "trees"
              }
            }
          }
        ]
      }
    }
  }
}
```

### Implicit Tiling

When using the [3DTILES_implicit_tiling](../../3DTILES_implicit_tiling) extension `contentAvailability` is provided for each element in the content array. The subtree's top-level `contentAvailability` must be omitted.

Example tileset JSON:

```jsonc
{
  "root": {
    "refine": "ADD",
    "geometricError": 16384.0,
    "boundingVolume": {
      "region": [-1.707, 0.543, -1.706, 0.544, 203.895, 253.113]
    },
    "extensions": {
      "3DTILES_multiple_contents": {
        "content": [
          {
            "uri": "buildings/{level}/{x}/{y}.b3dm",
          },
          {
            "uri": "trees/{level}/{x}/{y}.i3dm",
          }
        ]    
      },
      "3DTILES_implicit_tiling": {
        "subdivisionScheme": "QUADTREE",
        "subtreeLevels": 10,
        "maximumLevel": 16,
        "subtrees": {
          "uri": "subtrees/{level}/{x}/{y}.subtree"
        }
      }
    }
  }
}
```

Example subtree JSON:

```jsonc
{
  "bufferViews": [
    {
      "buffer": 0,
      "byteLength": 0,
      "byteOffset": 0
    },
    {
      "buffer": 0,
      "byteLength": 0,
      "byteOffset": 0
    },
    {
      "buffer": 0,
      "byteLength": 0,
      "byteOffset": 0
    },
    {
      "buffer": 0,
      "byteLength": 0,
      "byteOffset": 0
    },
    {
      "buffer": 0,
      "byteLength": 0,
      "byteOffset": 0
    }
  ],
  "buffers": [
    {
      "byteLength": 0
    }
  ],
  "tileAvailability": {
    "bufferView": 0
  },
  "childSubtreeAvailability": {
    "bufferView": 1
  },
  "extensions": {
    "3DTILES_multiple_contents": {
      "contentAvailability": [
        {
          "bufferView": 2
        },
        {
          "bufferView": 3
        }
      ]
    }
  }
}
```

## Schema Updates

The full JSON schema can be found [here](schema).

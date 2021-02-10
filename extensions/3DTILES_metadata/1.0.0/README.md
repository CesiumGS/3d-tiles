<!-- omit in toc -->
# 3DTILES_metadata Extension

**Version 1.0.0**, [TODO: Date]

<!-- omit in toc -->
## Contributors

* Sam Suhag, Cesium
* Sean Lilley, Cesium
* Peter Gagliardi, Cesium
* Bao Tran, Cesium

<!-- omit in toc -->
## Status

Draft

<!-- omit in toc -->
## Dependencies

Written against the 3D Tiles 1.0 specification.

<!-- omit in toc -->
## Optional vs. Required

This extension is optional, meaning it should be placed in the tileset JSON top-level `extensionsUsed` list, but not in the `extensionsRequired` list.

<!-- omit in toc -->
## Contents

- [Overview](#overview)
- [Concepts](#concepts)
  - [Schemas](#schemas)
  - [Classes](#classes)
  - [Tileset Metadata](#tileset-metadata)
  - [Tile Metadata](#tile-metadata)
  - [Group Metadata](#group-metadata)
  - [Feature Metadata](#feature-metadata)
  - [Statistics](#statistics)
  - [Semantics](#semantics)
- [Schema Updates](#schema-updates)

## Overview

This extension provides a formal mechanism for attaching application-specific metadata to various components of 3D Tiles. This includes

* Tileset metadata: metadata about the tileset as a whole
* Tile metadata: metadata about individual tiles
* Content metadata: metadata about groups of content (or "layers")
* Feature metadata: metadata about features. See the companion glTF extension [EXT_feature_metadata](https://github.com/CesiumGS/glTF/pull/3).


At the top-level this extension defines a **schema**. A schema defines a set of **classes** and **enums**. A class contains a set of **properties**, which may be numeric, string, enum, or array types.

**Entities** (such as tiles, features, etc.) conform to classes and contain **property values**. Depending on the context, property values may be stored in JSON or binary.

**Statistics** provide metadata about the metadata. For example, statistics may include the min/max values of a numeric property for mapping property values to gradients in the [declarative styling language](../../../specification/Styling/README.md) or the number of enum occurrences for color coding features.

By default properties are application-specific and do not have any inherent meaning. A **semantic** may be provided to give a property meaning. This extension lists the available built-in semantics for 3D Tiles. Tileset authors may define their own additional semantics.

There are many use cases for metadata including

* Picking features and querying their properties
* Styling, including generating complex styles that synthesize tileset, tile, content, and feature metadata together
* Optimizing traversal algorithms with tile metadata
* Grouping content into layers and providing per-layer visibility and color controls 
* Selectively loading content based on properties

## Concepts

### Schemas

A schema defines a set of classes and enums used in a tileset. A schema may be embedded in the extension object or referenced externally.

### Classes

Classes serve as the templates for entities - they provide a list of properties and the type information for those properties. For example, a tileset containing buildings and trees might define classes for each type:

```jsonc
{
  "extensions": {
    "3DTILES_metadata": {
      "schema": {
        "classes": {
          "building": {
            "properties": {
              "height": {
                "type": "FLOAT32"
              },
              "owners": {
                "type": "ARRAY",
                "componentType": "STRING"
              },
              "buildingType": {
                "type": "STRING"
              }
            }
          },
          "tree": {
            "properties": {
              "height": {
                "type": "FLOAT32"
              },
              "species": {
                "type": "STRING",
              }
            }
          }
        }
      }
    }
  }
}
```

For the full list of property types see the [Cesium 3D Metadata specification](../../../specification/Metadata/README.md).

### Tileset Metadata

Metadata may be assigned to the tileset as a whole with the `tileset` object.

The tileset metadata object may specify a `name` and `description`. The tileset metadata object may also specify a `class` and assign values to the `properties` defined by the selected class.

```jsonc
{
  "extensions": {
    "3DTILES_metadata": {
      "schema": {
        "classes": {
          "city": {
            "properties": {
              "dateFounded": {
                "type": "STRING"
              },
              "population": {
                "type": "UINT32"
              },
              "country": {
                "type": "STRING",
                "optional": true,
                "default": "United States"
              }
            }
          }
        }
      },
      "tileset": {
        "name": "Philadelphia",
        "description": "Point cloud of Philadelphia captured by drone survey",
        "class": "city",
        "properties": {
          "dateFounded": "October 27, 1682",
          "population": 1579000
        }
      }
    }
  }
}
```

### Tile Metadata

Metadata may be assigned to individual tiles. Tile metadata is often spatial in nature and can be used to aid traversal algorithms.

```jsonc
{
  "extensions": {
    "3DTILES_metadata": {
      "schema": {
        "classes": {
          "tile": {
            "properties": {
              "horizonOcclusionPoint": {
                "type": "ARRAY",
                "componentType": "FLOAT64",
                "componentCount": 3,
                "semantic": "HORIZON_OCCLUSION_POINT"
              },
              "boundingSphere": {
                "type": "ARRAY",
                "componentType": "FLOAT64",
                "componentCount": 4,
                "semantic": "BOUNDING_SPHERE"
              }
            }
          }
        }
      }
    }
  },
  "root": {
    "refine": "ADD",
    "geometricError": 0.0,
    "boundingVolume": {
      "region": [-1.707, 0.543, -1.706, 0.544, 203.895, 253.113]
    },
    "content": {
      "uri": "buildings.b3dm"
    },
    "extensions": {
      "3DTILES_metadata": {
        "class": "tile",
        "properties": {
          "horizonOcclusionPoint": [6000000.0, 0.0, 0.0],
          "boundingSphere": [6005000.0, 0.0, 0.0, 5000.0]
        }
      }
    }
  }
}
```

When using the [3DTILES_implicit_tiling](../../3DTILES_implicit_tiling) extension tile metadata is stored in binary in each subtree. Here is an example subtree JSON:

```jsonc
{
  "buffers": [
    {
      "byteLength": 0
    }
  ],
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
    }
  ],
  "tileAvailability": {
    "bufferView": 0
  },
  "contentAvailability": {
    "bufferView": 1
  },
  "childSubtreeAvailability": {
    "bufferView": 2
  },
  "extensions": {
    "3DTILES_metadata": {
      "class": "tile",
      "properties": {
        "horizonOcclusionPoint": {
          "bufferView": 3
        }
      }
    }
  }
}
```

### Group Metadata

Metadata may be assigned to groups. Groups represent collections of contents, or "layers". Contents are assigned to groups with the `3DTILES_metadata` content extension.

```jsonc
{
  "extensions": {
    "3DTILES_metadata": {
      "schema": {
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
    "children": [
      {
        "geometricError": 0.0,
        "boundingVolume": {
          "region": [-1.707, 0.543, -1.706, 0.544, -10.3, 253.113]
        },
        "content": {
          "uri": "buildings.b3dm",
          "extensions": {
            "3DTILES_metadata": {
              "group": "buildings"
            }
          }
        }
      },
      {
        "geometricError": 0.0,
        "boundingVolume": {
          "region": [-1.707, 0.543, -1.706, 0.544, -10.3, 253.113]
        },
        "content": {
          "uri": "trees.i3dm",
          "extensions": {
            "3DTILES_metadata": {
              "group": "trees"
            }
          }
        }
      }
    ]
  }
}
```

### Feature Metadata

Metadata may be assigned to features using the glTF extension [EXT_feature_metadata](https://github.com/CesiumGS/glTF/pull/3).

### Statistics

Statistics provide aggregate information about select properties within a tileset.

3D Tiles has the following built-in statistics:

Name|Description|Type
--|--|--
`min`|Minimum value|Numeric types or fixed-size arrays of numeric types
`max`|Maximum value|Numeric types or fixed-size arrays of numeric types
`occurrences`|Number of enum occurrences|Enums or arrays of enums

Tileset authors may define their own additional semantics, like `mean` in the example below.

```jsonc
{
  "extensions": {
    "3DTILES_metadata": {
      "schema": {
        "enums": {
          "buildingType": {
            "valueType": "UINT16",
            "values": [
              {
                "name": "Residential",
                "value": 0
              },
              {
                "name": "Commercial",
                "value": 1
              },
              {
                "name": "Hospital",
                "value": 2
              },
              {
                "name": "Other",
                "value": 3
              }
            ]
          }
        },
        "classes": {
          "building": {
            "properties": {
              "height": {
                "type": "FLOAT32"
              },
              "owners": {
                "type": "ARRAY",
                "componentType": "STRING"
              },
              "buildingType": {
                "type": "ENUM",
                "enumType": "buildingType"
              }
            }
          }
        }
      },
      "statistics": {
        "classes": {
          "building": {
            "count": 100000,
            "properties": {
              "height": {
                "min": [3.9],
                "max": [341.7],
                "mean": [5.6]
              },
              "buildingType": {
                "occurrences": {
                  "Residential": [50000],
                  "Commercial": [40950],
                  "Hospital": [50]
                }
              }
            }
          }
        }
      }
    }
  }
}
```

### Semantics

By default properties are application-specific and do not have any inherent meaning. A **semantic** may be provided to describe how properties should be interpreted. 

A semantic is defined by a name, a description, and a property definition. `3DTILES_metadata` provides the following built-in semantics:

<!-- omit in toc -->
#### **HORIZON_OCCLUSION_POINT**

Description: The horizon occlusion point of the tile. If this point is below the horizon, the entire tile is assumed to be below the horizon as well.

Allowed `componentType`: `FLOAT32`, `FLOAT64`

```jsonc
{
  "type": "ARRAY",
  "componentType": "FLOAT64",
  "componentCount": 3,
  "semantic": "HORIZON_OCCLUSION_POINT"
}
```

<!-- omit in toc -->
#### **BOUNDING_SPHERE**

Description: The bounding sphere of the tile as `[x, y, z, radius]`.

Allowed `componentType`: `FLOAT32`, `FLOAT64`


```jsonc
{
  "type": "ARRAY",
  "componentType": "FLOAT64",
  "componentCount": 4,
  "semantic": "BOUNDING_SPHERE"
}
```

<!-- omit in toc -->
#### **MINIMUM_HEIGHT**

Description: The minimum height of the tile.

Allowed `type`: `FLOAT32`, `FLOAT64`

```jsonc
{
  "type": "FLOAT64",
  "semantic": "MINIMUM_HEIGHT"
}
```

<!-- omit in toc -->
#### **MAXIMUM_HEIGHT**

Description: The maximum height of the tile.

Allowed `type`: `FLOAT32`, `FLOAT64`

```jsonc
{
  "type": "FLOAT64",
  "semantic": "MAXIMUM_HEIGHT"
}
```

<!-- omit in toc -->
#### **NAME**

Description: The name of the entity. Names do not have to be unique.

```jsonc
{
  "type": "STRING",
  "semantic": "NAME"
}
```

<!-- omit in toc -->
#### **ID**

Description: A unique identifier for this entity.

```jsonc
{
  "type": "STRING",
  "semantic": "ID"
}
```

Tileset authors may define their own additional semantics. By convention they are preceded by an underscore but that is not required. For example:

```jsonc
{
  "extensions": {
    "3DTILES_metadata": {
      "schema": {
        "classes": {
          "building": {
            "properties": {
              "name": {
                "type": "STRING",
                "semantic": "NAME"
              },
              "id": {
                "type": "STRING",
                "semantic": "ID"
              },
              "height": {
                "type": "FLOAT32",
                "semantic": "_HEIGHT"
              }
            }
          }
        }
      }
    }
  }
}
```

## Compatibility Notes

This extension does not contain information about [Batch Table](../../../specification/TileFormats/BatchTable) properties used in the Batched 3D Model, Instanced 3D Model, and Point Cloud formats.

Similarly, the top-level [`properties`](../../../specification/schema/properties.schema.json] object in tileset JSON is limited to describing Batch Table properties and does not describe properties in this extension.

In general, this extension alongside [EXT_feature_metadata](https://github.com/CesiumGS/glTF/pull/3) can be considered a replacement of Batch Table metadata.

## Schema Updates

The full JSON schema can be found [here](schema).

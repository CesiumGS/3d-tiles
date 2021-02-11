<!-- omit in toc -->
# 3DTILES_metadata Extension

**Version 1.0.0**, [TODO: Date]

<!-- omit in toc -->
## Contributors

* Sean Lilley, Cesium
* Peter Gagliardi, Cesium
* Sam Suhag, Cesium
* Patrick Cozzi, Cesium
* Bao Tran, Cesium

<!-- omit in toc -->
## Status

Draft

<!-- omit in toc -->
## Dependencies

Written against the 3D Tiles 1.0 specification.

Adds new functionality to the [`3DTILES_implicit_tiling` extension](../../3DTILES_implicit_tiling/README.md). See [Implicit Tile Metadata](#implicit-tile-metadata).


<!-- omit in toc -->
## Optional vs. Required

This extension is optional, meaning it should be placed in tileset JSON `extensionsUsed` list, but not in the `extensionsRequired` list.

<!-- omit in toc -->
## Contents

- [Overview](#overview)
- [Use Cases](#use-cases)
- [Compatibility Notes](#compatibility-notes)
- [Concepts](#concepts)
  - [Schemas](#schemas)
  - [Tileset Metadata](#tileset-metadata)
  - [Tile Metadata](#tile-metadata)
    - [Implicit Tile Metadata](#implicit-tile-metadata)
  - [Group Metadata](#group-metadata)
  - [Feature Metadata](#feature-metadata)
  - [Statistics](#statistics)
  - [Semantics](#semantics)
- [Schema Updates](#schema-updates)

## Overview

TODO: add diagram showing how all the types of metadata might interact within a tileset with labels
TODO: interaction with declarative styling

This extension provides a standard mechanism for adding metadata to 3D Tiles. This includes:

* Tileset metadata - metadata about the tileset as a whole
* Tile metadata - metadata about individual tiles
* Group metadata - metadata about groups of content
* Feature metadata - metadata about features. See the companion glTF extension [EXT_feature_metadata](https://github.com/CesiumGS/glTF/pull/3).

A tileset defines a **schema**. A schema has a set of **classes** and **enums**. A class contains a set of **properties**, which may be numeric, boolean, string, enum, or array types.

**Entities** (such as tiles, features, etc.) conform to classes and contain **property values**. Depending on the context, property values may be stored in JSON or binary.

**Statistics** provide aggregate information about the metadata. For example, statistics may include the min/max values of a numeric property for mapping property values to gradients in the [declarative styling language](../../../specification/Styling/README.md) or the number of enum occurrences for creating histograms.

By default properties do not have any inherent meaning. A **semantic** may be provided to give a property meaning. The full list of built-in semantics can be found in the [Cesium Metadata Semantics Reference](../../../specification/Metadata/Semantics/README.md). Tileset authors may define their own additional semantics separately.

This extension references the [Cesium 3D Metadata Specification](../../../specification/Metadata/README.md), which describes the metadata format in full detail.

## Use Cases

_This section is non-normative_

This extension enables use cases including:

* Picking features and querying their properties
* Styling, including generating complex styles that synthesize tileset, tile, content, and feature metadata together
* Optimizing traversal algorithms with tile metadata
* Grouping content into layers and providing per-layer visibility and color controls 
* Selectively loading content based on properties

## Compatibility Notes

This extension provides similar capabilities to, but is independent of, the [Batch Table](../../../specification/TileFormats/BatchTable) used in the Batched 3D Model, Instanced 3D Model, and Point Cloud formats. Similarly, this extension is independent of the [`properties`](../../../specification/schema/properties.schema.json) object in tileset JSON.

glTF models contain in Batched 3D Model or Instanced 3D Model content 
The `EXT_feature_metadata` extension must not be used by glTF models contained in Batched 3D Model or Instanced 3D Model content.

> In general, `3DTILES_metadata` (along with `EXT_feature_metadata`) is considered a successor to the Batch Table and using both methods in the same tileset should be avoided.

## Concepts

### Schemas

A schema defines a set of classes and enums used in a tileset. Classes serve as templates for entities - they provide a list of properties and the type information for those properties. Enums define the allowable values for enum properties. Schemas are defined in full detail in the [Cesium 3D Metadata Specification](../../../specification/Metadata/README.md#schemas).

A schema may be embedded in the extension directly or referenced externally with the `schemaUri` property. Multiple tilesets and glTF contents may refer to the same external schema to avoid duplication.

This example shows a schema with a `building` class and `buildingType` enum. Later examples show how different types of entities conform to classes and supply property values.

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
                "description": "Names of the owners",
                "type": "ARRAY",
                "componentType": "STRING"
              },
              "buildingType": {
                "type": "ENUM",
                "enumType": "buildingType"
              }
            }
          }
        },
        "enums": {
          "buildingType": {
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
                "name": "Other",
                "value": 2
              }
            ]
          }
        }
      }
    }
  }
}
```

### Tileset Metadata

Metadata may be assigned to the tileset as a whole using the `tileset` object.

The `tileset` object may specify a `class` and contain property values. The `tileset` object may also specify a `name` and `description`.

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
        "description": "Point cloud of Philadelphia",
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

Metadata may be assigned to individual tiles. Tile metadata often contains spatial information to optimize traversal algorithms.

TODO: fix numbers in example

```jsonc
{
  "extensions": {
    "3DTILES_metadata": {
      "schema": {
        "classes": {
          "tile": {
            "properties": {
              "boundingSphere": {
                "type": "ARRAY",
                "componentType": "FLOAT64",
                "componentCount": 4,
                "semantic": "BOUNDING_SPHERE",
              },
              "countries": {
                "description": "The countries that overlap this tile",
                "type": "ARRAY",
                "componentType": "STRING"
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
          "boundingSphere": [6005000.0, 0.0, 0.0, 5000.0],
          "countries": ["United States", "Canada", "Mexico"]
        }
      }
    }
  }
}
```

#### Implicit Tile Metadata

When using the [3DTILES_implicit_tiling](../../3DTILES_implicit_tiling) extension tile metadata is stored in binary in each subtree. Here is an example subtree JSON:

TODO: update numbers in example

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
        "boundingSphere": {
          "bufferView": 3
        },
        "countries": {
          "bufferView": 4,
          "arrayOffsetBufferView": 5,
          "stringOffsetBufferView": 6
        }
      }
    }
  }
}
```

### Group Metadata

Metadata may be assigned to groups. Groups represent collections of contents. Contents are assigned to groups with the `3DTILES_metadata` content extension.

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
              "priority": {
                "type": "UINT32"
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
            "priority": 0
          }
        },
        "trees": {
          "class": "layer",
          "properties": {
            "color": [10, 240, 30],
            "priority": 1
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

TODO: add brief summary of what a feature is

Metadata may be assigned to features using the glTF extension [EXT_feature_metadata](https://github.com/CesiumGS/glTF/pull/3).

### Statistics

Statistics provide aggregate information about select properties within a tileset.

3D Tiles has the following built-in statistics:

Name|Description|Type
--|--|--
`min`|Minimum value|Numeric types or fixed-size arrays of numeric types
`max`|Maximum value|Numeric types or fixed-size arrays of numeric types
`mean`|The arithmetic mean of the values|Numeric types or fixed-size arrays of numeric types
`median`|The median value|Numeric types or fixed-size arrays of numeric types
`mode`|The most frequent value|Numeric types or fixed-size arrays of numeric types
`stddev`|The standard deviation of the values|Numeric types or fixed-size arrays of numeric types
`variance`|The variance of the values|Numeric types or fixed-size arrays of numeric types
`sum`|The sum of the values|Numeric types or fixed-size arrays of numeric types
`occurrences`|Number of enum occurrences|Enums or arrays of enums

TODO: find a new user-defined statistic

Tileset authors may define their own additional semantics, like `median` in the example below.

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
                "mode": [5.6]
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

TODO: finish this section, remove stuff that got moved

By default properties are application-specific and do not have any inherent meaning. A **semantic** may be provided to describe how properties should be interpreted. 

A semantic is defined by a name, a description, and a property definition. `3DTILES_metadata` provides the following built-in semantics:

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

## Schema Updates

The full JSON schema can be found [here](schema).

# 3DTILES_metadata Extension

**Version 0.0.0**, November 6, 2020

## Contributors

* Sam Suhag, Cesium
* Sean Lilley, Cesium
* Peter Gagliardi, Cesium
* Bao Tran, Cesium

## Status

Draft

## Dependencies

Written against the 3D Tiles 1.0 specification.

## Contents

  - [Overview](#overview)
  - [Optional vs. Required](#optional-vs-required)
  - [Concepts](#concepts)
    - [Metadata](#metadata)
      - [Classes](#classes)
      - [Properties](#properties)
      - [Tileset Metadata](#tileset-metadata)
  - [Schema Updates](#schema-updates)
  - [Examples](#examples)

## Overview

This extension to 3D Tiles enables the declaration of metadata classes and the assignment of metadata to the tileset. Metadata classes are declared and assigned based on the [Cesium 3D Metadata Specification](../../../specification/Metadata/0.0.0/README.md). Metadata may also be assigned to layers using [3DTILES_layers](../../3DTILES_layers/README.md). The following diagrams illustrates how these extensions are connected:

![3DTILES_metadata Spec Map](figures/spec_map.jpg)

## Optional vs. Required

This extension is optional, meaning it should be placed in the tileset JSON top-level `extensionsUsed` list, but not in the `extensionsRequired` list.

## Concepts

### Metadata

Metadata refers to application specific information. It can be associated with different components of 3D Tiles: tileset, layers, tiles, and features.

#### Classes

Classes serve as the templates for the metadata objects - they provide a list of properties and the type information for those properties. For example, a tileset containing different layers of 3D data might create classes for each type:

```jsonc
{
  "classes": {
    "photogrammetry": {
      "properties": {
        //...
      }
    },
    "bim": {
      "properties": {
        //...
      }
    },
    "pointCloud": {
      "properties": {
        //...
      }
    }
  }
}
```

This extension uses the classes in compliance with the [Cesium 3D Metadata Specification](../../../specification/Metadata/0.0.0/README.md#classes).

#### Properties

Each class provides a list of properties. A property has a `type` and, for the array types, it may include a `componentType` and a `componentCount`. Additionally, a property may be designated as `optional`, and if so, a `default` value for the property may be provided to apply to all instances of the class that do not set a value for the property. To learn more about properties, refer to the [Cesium 3D Metadata Specification](../../../specification/Metadata/0.0.0/README.md#classes).

```jsonc
{
  "classes": {
    "photogrammetry": {
      "properties": {
        "sensorVersion": {
          "type": "STRING"
        },
        "author": {
          "type": "STRING",
          "optional": true,
          "default": "Cesium"
        },
        "year": {
          "type": "INT32"
        }
      }
    },
    "bim": {
      "properties": {
        "modelAuthor": {
          "type": "STRING"
        }
      }
    },
    "pointCloud": {
      "properties": {
        "scanner": {
          "type": "STRING"
        }
      }
    }
  }
}
```


#### Tileset Metadata

Metadata may be assigned to the tileset as a whole with the `tileset` object.

The tileset metadata object may specify a `name` and `description`. The tileset metadata object may also specify a `class` and assign values to the `properties` defined by the selected class. The tileset object is an instance of the class and uses the [single instance shorthand syntax](../../../specification/Metadata/0.0.0/README.md#single-intance-shorthand) to assign values to its properties.

```json
{
  "extensions": {
    "3DTILES_metadata": {
      "classes": {
        "photogrammetry": {
          "properties": {
            "sensorVersion": {
              "type": "STRING"
            },
            "author": {
              "type": "STRING",
              "optional": true,
              "default": "Cesium"
            },
            "year": {
              "type": "INT32"
            }
          }
        }
      },
      "tileset": {
        "name": "Photogrammetry tileset",
        "description": "Photogrammetry tileset captured from drone survey",
        "class": "photogrammetry",
        "properties": {
          "sensorVersion": "20.1.1",
          "year": 2020
        }
      }
    }
  }
}
```

## Schema Updates

The full JSON schema can be found in [3DTILES_metadata.schema.json](schema/3DTILES_metadata.schema.json).

## Examples

Examples can be found [here](examples).

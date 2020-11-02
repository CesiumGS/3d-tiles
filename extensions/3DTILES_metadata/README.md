# 3DTILES_metadata Extension

## Contributors

Cesium

## Status

Draft (version 0.0.0)

## Overview

This extension enables the declaration and storage of metadata at the tileset, layer and tile levels in 3D Tiles. Metadata may be declared for one or all of these levels.

## Concepts

### Metadata

This extensions binds metadata to different levels of 3D Tiles through the declaration of classes and their properties, the association of classes to tileset/layer/tile metadata objects and the assignment of values to the properties of the class the metadata object conforms to.

#### Metadata Classes

Classes serve as the templates for the metadata objects - they provide a list of properties and the type information for those properties. For example, a tileset containing different layers of 3D data might create classes for each type:

```javascript
"classes": {
  "PhotogrammetryClass": {
    "properties": {
      //...
    }
  },
  "BIMClass": {
    "properties": {
      //...
    }
  },
  "PointCloudClass": {
    "properties": {
      //...
    }
  }
}
```

#### Metadata Class Properties

Each class provides a list of properties. A property has a `type` and, for the applicable types,, it may include a `componentType` and a `componentCount`. Additionally, a property may be designated as `optional`, and if so, a `defaultValue` for the property may be provided to apply to all instances of the class that do not set a value for the property.

```javascript
"classes": {
  "PhotogrammetryClass": {
    "properties": {
      "sensorVersion": {
        "type": "string",
        "optional": false
      }
    }
  },
  "BIMClass": {
    "properties": {
      "modelAuthor": {
        "type": "string",
        "optional": false
      }
    }
  },
  "PointCloudClass": {
    "properties": {
      "scanner": {
        "type": "string",
        "optional": false
      }
    }
  }
}
```

#### Tileset Metadata

The tileset metadata object may specify a `name` and `description` to display the information in a user interface. The tileset metadata object may also conform to a `class` and assign values to the `properties` defined by the selected class.


#### Layer Metadata

The layer metadata object may specify a `name` and `description` to display the information in a user interface. A layer metadata object may also conform to a `class` and assign values to the `properties` defined by the selected class.

#### Tile Metadata

*TODO*


## Examples

```json
{
  "asset": {
    "version": "1.0"
  },
  "extensionsUsed": ["3DTILES_content_gltf", "3DTILES_metadata"],
  "extensionsRequired": ["3DTILES_content_gltf", "3DTILES_metadata"],
  "extensions": {
    "3DTILES_content_gltf": {
      "extras": {
        "draftVersion": "0.0.0"
      },
      "extensionsUsed": ["EXT_3dtiles_feature_metadata"]
    },
    "3DTILES_metadata": {
      "extras": {
        "draftVersion": "0.0.0"
      },
      "namespaces": {
        "GLOBAL": {
          "enums": {
            "GEOMETRY_MODEL_TYPE": {
              "valueType": "STRING",
              "values": {
                "UNKNOWN": 0,
                "BARE_EARTH": 1,
                "SURFACE": 2,
                "3DOBJECTS": 3,
                "MIXED": 4
              }
            },
            "CONTENT_TYPE": {
              "valueType": "STRING",
              "values": {
                "UNKNOWN": 0,
                "MESH": 1,
                "VECTOR": 2,
                "RASTER": 3,
                "MIXED": 4
              }
            },
            "CAPTURE_PLATFORM_TYPE": {
              "valueType": "STRING",
              "values": {
                "UNKNOWN": 0,
                "SATELLITE": 1,
                "MIXED": 2
              }
            },
            "CAPTURE_SENSOR_TYPE": {
              "valueType": "STRING",
              "values": {
                "UNKNOWN": 0,
                "ELECTRO_OPTICAL": 1
              }
            }
          },
          "classes": {
            "_WFF_DATASET": {
              "properties": {
                "wff_version": {
                  "type": "STRING"
                },
                "runtime_enabled": {
                  "type": "BOOLEAN"
                },
                "geometry_model": {
                  "type": "ENUM",
                  "enumType": "GEOMETRY_MODEL_TYPE"
                },
                "content_type": {
                  "type": "ENUM",
                  "enumType": "CONTENT_TYPE"
                },
                "capture_platform": {
                  "type": "ENUM",
                  "enumType": "CAPTURE_PLATFORM_TYPE"
                },
                "capture_sensor": {
                  "type": "ENUM",
                  "enumType": "CAPTURE_SENSOR_TYPE"
                },
                "provider": {
                  "type": "STRING"
                },
                "id": {
                  "type": "STRING"
                },
                "created": {
                  "type": "STRING"
                },
                "semantic": {
                  "type": "STRING"
                },
                "featureClasses": {
                  "type": "ARRAY",
                  "componentType": "STRING",
                  "optional": true
                }
              }
            },
            "NDVI": {
              "properties": {
                "NDVI": {
                  "type": "UINT8",
                  "normalized": true
                }
              }
            },
            "LULC": {
              "properties": {
                "Name": {
                  "type": "STRING"
                },
                "Color": {
                  "type": "ARRAY",
                  "componentType": "UINT8",
                  "componentCount": 3
                }
              }
            }
          }
        }
      },
      "metadata": {
        "tileset": {
          "name": "Dataset",
          "class": "_WFF_DATASET",
          "properties": {
            "wff_version": "1.0",
            "runtime_enabled": true,
            "geometry_model": "BARE_EARTH",
            "content_type": "MESH",
            "capture_platform": "SATELLITE",
            "capture_sensor": "ELECTRO_OPTICAL",
            "provider": "Maxar",
            "id": "2e7444d7-e816-48c6-8786-c24ab354422e",
            "created": "2020-10-05T13:46:46.672632Z",
            "semantic": "_WFF_DATASET",
            "featureClasses": ["NDVI", "LULC"]
          }
        }
      }
    }
  },
  "geometricError": 500,
  "root": {
    "boundingVolume": {
      "region": [-1.2419, 0.7395, -1.2415, 0.7396, 0, 20.4]
    },
    "geometricError": 500,
    "refine": "REPLACE",
    "content": {
      "uri": "content.gltf"
    }
  }
}

```


## Property Reference
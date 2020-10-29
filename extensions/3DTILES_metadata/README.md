# 3DTILES_metadata Extension

## Contributors

Cesium

## Status

Draft (version 0.0.0)

## Overview

This extension to 3D Tiles enables storage of metadata at the tileset, layer and tile levels. *TODO - Use Cases*

## Concepts

This extensions binds metadata to different levels of a 3D Tiles tileset through the declaration of classes and their properties, the binding of classes to tileset/layer/tile metadata objects and the assignment of values to the properties of the class the metadata object conforms to.

### Metadata

#### Metadata Classes

Classes serve as the templates for the metadata objects - they provide a list of properties and the type information for those properties.

#### Metadata Class Properties

Each class provides a list of properties. A property has a `type` and, for the applicable types,, it may include a `componentType` and a `componentCount`.

#### Tileset Metadata

Tileset metadata refers to information about the tileset. The tileset metadata object may specify a `name` and `description` to display the information in a user interface. The tileset metadata object may also conform to a `class` and assign values to the `properties` defined by the selected class.

#### Layer Metadata

Layer metadata refers information about the tileset. The layer metadata object may specify a `name` and `description` to display the information in a user interface. A layer metadata object may also conform to a `class` and assign values to the `properties` defined by the selected class.

#### Tile Metadata

*TODO*

## Metadata Storage
### Storage Encodings

#### Choosing an Encoding

This specification provides three different encodings for representing feature properties: JSON, binary and texture encodings. Each one is designed for different purposes, so it is important to familiarize oneself with the main differences.

JSON encoding is useful for encoding data where readability matters. This works well for small amounts of data, but does not scale well to large datasets. If the metadata is expected to grow large, binary encoding would be a better choice. One situation where JSON encoding is helpful is if metadata will be edited by hand, as JSON is easier for a human to understand than editing a binary buffer.

Binary encoding is designed for storage efficiency, and is designed for use with large datasets. Data is packed in parallel arrays, one per feature property. This allows for storage optimizations based on data type, such as storing boolean properties as a tightly packed bit vector. This encoding is more involved than the JSON encoding, but it is much preferred in most cases where performance is an important consideration.

These first two encodings are designed for discrete properties indexed by feature ID. Feature textures on the other hand, are used when features are identified by spatial position (i.e. texture coordinates within a texture). Heightmaps and normal maps are two examples. This type of per-texel metadata has many uses, but is also somewhat limited by the image formats used to store data.

#### JSON Encoding

The JSON encoding is the simplest encoding, designed to be easy for a human to read.

##### Basic Types

For JSON encoding, basic types include integers, floating point numbers, booleans, and strings. These are encoded in the most natural type available in JSON. Numeric types are represented as `number`, booleans as `boolean`, and `string` as `string`.

#### Bit Depth of Numeric Types

For numeric types like `UINT8` or `INT32`, the size in bits is made explicit. Even though JSON encoding only has a single `number` type for all integers and floating point numbers, the application that consumes the JSON may make a distinction. For example, C and C++ have several different integer types such as `uint8_t`, `uint32_t`. The application is responsible for interpreting the metadata using the type declared in the class definition.

#### Array Types

Array types are straightforward to encode into JSON: instead of a single array of values, use an array of arrays. When the array has a fixed size (i.e. `componentCount` is defined), each of the inner arrays must have the same length. Otherwise, the arrays are assumed to be variable-length.


### Binary Encoding

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
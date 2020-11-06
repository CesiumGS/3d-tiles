# 3DTILES_layers

## Overview

This extension to 3D Tiles enables assigning tile content to layers. 

A layer is a user-defined grouping of content - for example, a tileset of a city may have a buildings layer, a roads layer and a vegetation layer, where each layer is independent.

This extension provides a mechanism for tiles to have multiple contents that may be requested independently from each other. For a dataset that may have several layers using the same tiling scheme, this extension removes the need to separate the layers into multiple `tileset.json` files.

This functionality is useful for pairing additional application specific content with the geometric content of a tile: an asset payload for use in game engines, for example. A tileset may choose to bundle a navigation mesh as a content layer to enable simulation capabilities. At runtime, clients can leverage layers to enhance visualization by toggling, styling or ordering the content layers.

A layer may also associate application-specific metadata by conforming to a `class` defined in [3DTILES_metadata](). Metadata must be declared in conformance with the [Cesium 3D Metadata Specification]().

## Contributors

* Sam Suhag, Cesium
* Sean Lilley, Cesium
* Peter Gagliardi, Cesium
* Bao Tran, Cesium

## Schema Changes

### Layer Metadata

Layers are declared inside the top-level `3DTILES_layers` extension dictionary. Each layer is an object with its key being the layer's ID. The layer may declare a `name` and a `description`. 

```javascript
{
  "asset": {
    "version": "1.0"
  },
  "extensions": {
    "3DTILES_layers": {
      "buildings": {
        "name": "Buildings",
        "description": "3D Buildings Layer"
      },
      "trees": {
        "name": "Trees",
        "description": "3D Vegetation Layer"
      },
      "roads": {
        "name": "Roads",
        "description": "Vector Road Layer"
      }
    }
  }
}
```

The [3DTILES_metadata extension]() enables the declaration of metadata `class` objects, which define a list of properties a conforming instance would need to provide. A layer in 3DTILES_layers may assign to itself a class declared in 3DTILES_metadata to provide additional metadata. Layers must follow the [single instance syntax]() for assigning values to the its `properties`. For example,

```javascript
{
  "asset": {
    "version": "1.0"
  },
  "extensions": {
    "3DTILES_metadata": {
      "classes": {
        "cityLayer": {
          "properties": {
            "lastModified": {
              "type": "STRING",
              "optional": false
            },
            "highlightColor": {
              "type": "STRING",
              "optional": false
            }
          }
        }
      }
    },
    "3DTILES_layers": {
      "buildings": {
        "name": "Buildings",
        "description": "3D Buildings Layer",
        "class": "cityLayer",
        "properties": {
          "lastModified": "20201030T030000-0400",
          "highlightColor": "GREEN"
        }
      },
      "trees": {
        "name": "Trees",
        "description": "3D Vegetation Layer",,
        "class": "cityLayer",
        "properties": {
          "lastModified": "20201030T030100-0400",
          "highlightColor": "RED"
        }
      },
      "roads": {
        "name": "Roads",
        "description": "Vector Road Layer",,
        "class": "cityLayer",
        "properties": {
          "lastModified": "20201030T030200-0400",
          "highlightColor": "BLUE"
        }
      }
    }
  }
}
```

### Layer Content

Layer content is associated with a tile by adding the `3DTILES_layers` extension to the [tile JSON](https://github.com/CesiumGS/3d-tiles/tree/master/specification#tile-json). The extension declares a `contents` array, which must contain one or more layer objects. Each layer object provides `uri` and a `mimeType` for its contents. The content here might be tile content, like a `b3dm` or a `glTF` file, or it may point to an external `tileset.json`. To associate this layer object with [metadata](#layer-metadata), the `layer` property may be set to the ID of a layer declared in the top-level extension. For example,

```javascript
{
  "asset": {
    "version": "1.0"
  },
  "extensions": {
    "3DTILES_layers": {
      "buildings": {
        "name": "Buildings",
        "description": "3D Buildings Layer"
      },
      "trees": {
        "name": "Buildings",
        "description": "3D Vegetation Layer"
      },
      "roads": {
        "name": "Roads",
        "description": "Vector Road Layer"
      }
    }
  },
  "root": {
    "extensions": {
      "3DTILES_layers": {
        "contents": [
          {
            "layer": "buildings",
            "mimeType": "application/json",
            "uri": "layers/buildings/tileset.json"
          },
          {
            "layer": "trees",
            "mimeType": "application/json",
            "uri": "layers/trees/tileset.json"
          },
          {
            "layer": "roads",
            "mimeType": "application/json",
            "uri": "layers/roads/tileset.json"
          }
        ]
      }
    }
  }
}
```

> Note: By default, an implementation would request and render all contents in a tile when a tile is selected.
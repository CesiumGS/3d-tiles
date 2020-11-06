# 3DTILES_layers

## Overview

This extension to 3D Tiles enables grouping of different types of content into layers. A layer is a user-defined grouping of content - for example, a tileset of a city may have a buildings layer, a roads layer and a vegetation layer. Each layer follows an independent layout for its tiles and there are not dependencies between layers. A layer may also associate with itself some metadata by conforming to a `class` declared in `3DTILES_metadata`.

This extension to 3D Tiles enables assigning tile content to layers. Layers provide a mechanism for tiles to have multiple contents that may be requested independently from each other. For a dataset that may have several layers using the same tiling scheme, this extension removes the need to separate the layers into multiple `tileset.json` files.

This functionality is useful for pairing additional application specific content with the geometric content of a tile: for example, an asset payload for use in game engines. For example, a tileset may choose to bundle a navigation mesh as a layer to enable simulation capabilities. At runtime, clients can leverage layers to enhance visualization by toggling, styling or ordering layers.

A layer may also associate application-specific metadata by conforming to a `class` defined in [3DTILES_metadata](). Metadata must be declared in conformance with the [Cesium 3D Metadata Specification]().

## Contributors

Cesium

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

The 3DTILES_metadata extensions enables the declaration of metadata `class` objects, which define a list of properties a conforming instance would need to provide. A layer in 3DTILES_layers can assign to itself a class declared in 3DTILES_metadata and use that to provide additional metadata. Layers must follow the [single instance syntax]() for assigning values to the its `properties`. For example,

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
        "name": "Buildings",
        "description": "3D Buildings Layer",
        "properties": {
          "lastModified": "20201030T030100-0400",
          "highlightColor": "RED"
        }
      },
      "roads": {
        "name": "Roads",
        "description": "Vector Road Layer",
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

To associate content with a layer, it must be added as an object to the `contents` array of the extension declared at the `root` of the tileset.json. To pair the content to a layer, we must set the `layer` property of the layer content object to the ID of the layer declared at the top level extension. This layer object needs to declare the `layer`, the `uri` of its contents and the `mimeType` for the content linked in the `uri`. For example,

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
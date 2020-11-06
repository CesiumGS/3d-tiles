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
    "version": "2.0.0-alpha.0"
  },
  "extensions": {
    "3DTILES_layers": {
      "BUILDINGS": {
        "name": "Buildings",
        "description": "3D Buildings Layer"
      }
    }
  }
}
```

Additionally, if a layer needs to associate some metadata with itself, there needs to be a corresponding class declared in the `3DTILES_metadata` extension and the layer needs to conform to that class. To learn more about metadata classes, refer to the [Cesium 3D Metadata Specification](). For example,

```javascript
{
  "asset": {
    "version": "2.0.0-alpha.0"
  },
  "extensions": {
    "3DTILES_metadata": {
      "classes": {
        "CITY_LAYER": {
          "properties": {
            "LastModified": {
              "type": "STRING",
              "optional": false
            }
          }
        }
      }
    },
    "3DTILES_layers": {
      "BUILDINGS": {
        "name": "Buildings",
        "description": "3D Buildings Layer",
        "class": "CITY_LAYER",
        "properties": {
          "LastModified": "20201030T030000-0400"
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
    "version": "2.0.0-alpha.0"
  },
  "extensions": {
    "3DTILES_layers": {
      "BUILDINGS": {
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
            "layer": "BUILDINGS",
            "mimeType": "application/json",
            "uri": "layers/BUILDINGS/tileset.json"
          }
        ]
      }
    }
  }
}
```
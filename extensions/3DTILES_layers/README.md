# 3DTILES_layers

## Overview

This extension to 3D Tiles enables grouping of different types of content into layers. A layer is a user-defined grouping of content - for example, a tileset of a city may have a buildings layer, a roads layer and a vegetation layer. Each layer follows an independent layout for its tiles and there are not dependencies between layers. A layer may also associate with itself some metadata by conforming to a `class` declared in `3DTILES_metadata`.

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

To associate content with a layers, it must be added as an object to the extension declared at the `root` of the tileset.json. To pair this content level layer object to the top level layer object, which declares the metadata, both objects must use the same key. This layer object needs to declare the `layer`, the `uri` of its contents and the `mimeType` for the content linked in the `uri`. For example,

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
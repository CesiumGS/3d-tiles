# 3DTILES_layers

## Overview

This extension to 3D Tiles enables grouping of different types of content into layers. A layer is a user-defined grouping of content - for example, a tileset of a city may have a buildings layer, a roads layer and a vegetation layer. Each layer follows an independent layout for its tiles and there are not dependencies between layers. A layer may also associate with itself some metadata by conforming to a `class` declared in `3DTILES_metadata`.

## Contributors

Cesium

## Schema Changes

### Layer Metadata

To associate a `name`, `description` with a layer, it must be delcared as a top-level extension to the tileset.json. For example,

```javascript
{
  "asset": {
    "version": 2.0.0-alpha.0
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

Additionally, if a layer needs to associate some metadata with itself, there needs to be a corresponding class declared in the `3DTILES_metadata` extension and the layer needs to conform to that class. For example,

```javascript
{
  "asset": {
    "version": 2.0.0-alpha.0
  },
  "extensions": {
    "3DTILES_metadata": {
      "classes": {
        "CITY_LAYER": {
          "properties": {
            "LastModified": {
              "type": STRING,
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

To associate content with a layers, it must be added as an object to the `contents` array in the extension declared at the `root` of the tileset.json. This layer object needs to declare the `layer`, the `uri` of its contents and the `mimeType` for the content linked in the `uri`. For example,

```javascript
{
  "asset": {
    "version": 2.0.0-alpha.0
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

### Property Reference

*TODO*

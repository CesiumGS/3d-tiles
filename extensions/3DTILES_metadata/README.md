# 3DTILES_metadata Extension

## Version

Version: **Version 0.0.0**
Revision Date: November 6, 2020.

## Contributors

Cesium

## Status

Draft (version 0.0.0)

## Overview

This extension to 3D Tiles enables the declaration of metadata classes and the assignment of metadata to the tileset. Metadata classes are declared and assigned based on the [Cesium 3D Metadata Specification](https://github.com/CesiumGS/3d-tiles/tree/3d-metadata-spec/specification/Metadata). Metadata may also be assigned to layers using [3DTILES_layers](https://github.com/CesiumGS/3d-tiles/tree/3DTILES_layers/extensions/3DTILES_layers). The following diagrams illustrates how these extensions are connected:

![3DTILES_metadata Spec Map](figures/spec_map.jpg)

## Concepts

### Metadata

Metadata refers to application specific information. It can be associated with different components of 3D Tiles: tileset, layers and tiles.

#### Classes

Classes serve as the templates for the metadata objects - they provide a list of properties and the type information for those properties. For example, a tileset containing different layers of 3D data might create classes for each type:

```javascript
"classes": {
  "DatasetClass": {
    "properties": {
      //...
    }
  },
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

This extension uses the classes in compliance with the [Cesium 3D Metadata Specification](https://github.com/CesiumGS/3d-tiles/tree/3d-metadata-spec/specification/Metadata#classes).

#### Properties

Each class provides a list of properties. A property has a `type` and, for the array types, it may include a `componentType` and a `componentCount`. Additionally, a property may be designated as `optional`, and if so, a `defaultValue` for the property may be provided to apply to all instances of the class that do not set a value for the property.

```javascript
"classes": {
  "PhotogrammetryClass": {
    "properties": {
      "sensorVersion": {
        "type": "STRING",
        "optional": false
      }
    }
  },
  "BIMClass": {
    "properties": {
      "modelAuthor": {
        "type": "STRING",
        "optional": false
      }
    }
  },
  "PointCloudClass": {
    "properties": {
      "scanner": {
        "type": "STRING",
        "optional": false
      }
    }
  }
}
```

This extension uses the classes in compliance with the [Cesium 3D Metadata Specification](https://github.com/CesiumGS/3d-tiles/tree/3d-metadata-spec/specification/Metadata#classes).

#### Tileset Metadata

The tileset metadata object may specify a `name` and `description` to display the information in a user interface. The tileset metadata object may also conform to a `class` and assign values to the `properties` defined by the selected class.

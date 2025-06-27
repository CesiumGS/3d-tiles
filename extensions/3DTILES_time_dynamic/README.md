# 3DTILES_time_dynamic

## Contributors

* Sean Lilley, Cesium

## Status

Draft

## Dependencies

Written against the 3D Tiles 1.1 specification.

## Optional vs. Required

This extension is required, meaning it must be placed in both the `extensionsUsed` and `extensionsRequired` lists in the tileset JSON.

## Overview

This extension adds support for time-dynamic 3D Tiles through two new [content metadata semantics](https://github.com/CesiumGS/3d-tiles/blob/main/specification/Metadata/Semantics/README.adoc#content):

Semantic | Type | Description
--|--|--
`CONTENT_TIMESTAMP_START`| Type: `STRING` | The start time (inclusive). Should be stored as Coordinated Universal Time (UTC) using ISO 8601 format.
`CONTENT_TIMESTAMP_STOP`| Type: `STRING` | The stop time (exclusive). Should be stored as Coordinated Universal Time (UTC) using ISO 8601 format.

Together `CONTENT_TIMESTAMP_START` and `CONTENT_TIMESTAMP_STOP` form a time interval during which the content should appear.

This extension is often used with [multiple contents](https://github.com/CesiumGS/3d-tiles/blob/main/specification/README.adoc#core-tile-content) where each content represents a keyframe on the tile's timeline.

## Explicit Tiling Example

This example shows a root tile with three contents.

The first content appears at `2024-11-01`, the second content appears at `2024-11-02`, and the third content appears at `2024-11-03`.

_Tileset JSON_

```jsonc
{
  "asset": {
    "version": "1.1"
  },
  "schema": "schema.json",
  "geometricError": 1000,
  "root": {
    "boundingVolume": {
      "region": [-1.318, 0.697, -1.319, 0.698, 0, 20]
    },
    "refine": "ADD",
    "geometricError": 0,
    "contents": [{
      "uri": "content/day_0.glb",
      "metadata": {
        "timestampStart": "2024-11-01T00:00:00Z",
        "timestampStop": "2024-11-02T00:00:00Z"
      }
    }, {
      "uri": "content/day_1.glb",
      "metadata": {
        "timestampStart": "2024-11-02T00:00:00Z",
        "timestampStop": "2024-11-03T00:00:00Z"
      }
    }, {
      "uri": "content/day_1.glb",
      "metadata": {
        "timestampStart": "2024-11-03T00:00:00Z",
        "timestampStop": "2024-11-04T00:00:00Z"
      }
    }]
  },
  "extensionsUsed": ["3DTILES_time_dynamic"],
  "extensionsRequired": ["3DTILES_time_dynamic"]
}
```

_Schema JSON_

```jsonc
{
  "id": "exampleSchema",
  "classes": {
    "content": {
      "properties": {
        "timestampStart": {
          "type": "STRING",
          "required": true,
          "semantic": "CONTENT_TIMESTAMP_START"
        },
        "timestampStop": {
          "type": "STRING",
          "required": true,
          "semantic": "CONTENT_TIMESTAMP_STOP"
        }
      }
    }
  }
}
```

## Implicit Tiling Example

A similar example using implicit tiling. Note that three extensions are being used here:

* `3DTILES_time_dynamic`
* `3DTILES_implicit_tiling_multiple_contents`
* `3DTILES_implicit_tiling_custom_template_variables`

_Tileset JSON_

```jsonc
{
  "asset": {
    "version": "1.1"
  },
  "schema": "schema.json",
  "geometricError": 1000,
  "root": {
    "boundingVolume": {
      "region": [-1.318, 0.697, -1.319, 0.698, 0, 20]
    },
    "refine": "ADD",
    "geometricError": 5000,
    "content": {
      "uri": "content/{timestampStart}_{timestampStop}.glb"
    }
  },
  "extensionsUsed": ["3DTILES_time_dynamic", "3DTILES_implicit_tiling_multiple_contents", "3DTILES_implicit_tiling_custom_template_variables"],
  "extensionsRequired": ["3DTILES_time_dynamic", "3DTILES_implicit_tiling_multiple_contents", "3DTILES_implicit_tiling_custom_template_variables"]
}
```

_Schema JSON_

```jsonc
{
  "id": "exampleSchema",
  "classes": {
    "tile": {
      "properties": {
        "contentCount": {
          "type": "SCALAR",
          "componentType": "UINT16",
          "semantic": "TILE_CONTENT_COUNT"
        }
      }
    },
    "content": {
      "properties": {
        "timestampStart": {
          "type": "STRING",
          "required": true,
          "semantic": "CONTENT_TIMESTAMP_START"
        },
        "timestampStop": {
          "type": "STRING",
          "required": true,
          "semantic": "CONTENT_TIMESTAMP_STOP"
        }
      }
    }
  }
}
```

_Subtree JSON_

```json
{
  "buffers": [...],
  "bufferViews": [...],
  "propertyTables": [
    {
      "class": "tile",
      "count": 4,
      "properties": {
        "contentCount": {
          "values": 2
        }
      }
    },
    {
      "class": "content",
      "count": 5,
      "properties": {
        "timestampStart": {
          "values": 3,
          "stringOffsets": 4,
        },
        "timestampStop": {
          "values": 5,
          "stringOffsets": 6
        }
      }
    }
  ],
  "tileAvailability": {
    "bitstream": 0,
    "availableCount": 4
  },
  "contentAvailability": [{
    "bitstream": 1,
    "availableCount": 2
  }],
  "childSubtreeAvailability": {
    "constant": 0
  },
  "tileMetadata": 0,
  "contentMetadata": [1]
}
```

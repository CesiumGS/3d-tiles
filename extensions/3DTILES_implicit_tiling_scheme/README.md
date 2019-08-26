# 3DTILES_implicit_tiling_scheme Extension

## Contributors

* Josh Lawrence, [@loshjawrence](https://github.com/loshjawrence)
* Shehzan Mohammed, [@shehzan10](https://github.com/shehzan10)
* Patrick Cozzi, [@pjcozzi](https://github.com/pjcozzi)

## Contents

* [Overview](#overview)
* [Tileset JSON Format Updates](#tileset-json-format-updates)
   * [Tiling Scheme](#tiling-scheme)
   * [Layer](#layer)
   * [Notes](#notes)
* [Resources](#resources)
* [Property Reference](#property-reference)

## Overview

This extension enables the [3D Tiles JSON](../../specification/schema/tileset.schema.json) to support streaming tilesets with implied subdivision schemes.

TODO: Availability is the bulk of the metadata info. If a binary version of layer.json doesn't have significant size advantages over the text version, just fold "available" from layer.json into tileset.json
Also if there are common use cases where you just want to look infomation other than the
availability and don't want to pay the cost of fetching the availability, we should keep it separate.

## Tileset JSON Format Updates

### Tiling Scheme

The Tileset JSON describing a [3D Tiles](../../specification/README.md) tileset may be extended to include a `3DTILES_implicit_tiling_scheme` object. This object defines
the root level context from which the entire tileset structure (boundingVolumes, geometricError, subdivision) can be implied.

Below is an example of a Tileset JSON with the implicit tiling scheme extension set:

```json
{
    "asset": {
        "extras": {
            "ion": {
                "georeferenced": true,
                "movable": false
            }
        },
        "version": "1.0"
    },
    "geometricError": 563.8721715009725,
    "extensions": {
        "3DTILES_implicit_tiling_scheme": {
            "subdivision": 2,
            "refine": "REPLACE",
            "headCount": [2,1,1],
            "boundingVolume": {
                "region": [
                     -1.5707963267948966,
                     -3.1415926535897932,
                      1.5707963267948966,
                      3.1415926535897932,
                    -11.89207010413975,
                    547.7591827297583
                ]
            }
        }
    }
}
```

#### properties

`subdivision` defines the subdivision scheme for the tiles described by the tileset.json's corresponding layer.json. In the example above, a type of 1 would indicate a quadtree subdivision.
Other possible types are defined in the type enumeration table below.


|Type|Description|
|----|-----------|
|`0`|Reserved. Indicates custom?|
|`1`|Reserved. TODO: Binary Tree? Subdivision assumed along the longest axis of root bounds. Good for self-driving highway scans? Strange/arbitrary data that's best expressed in binary tree, binary tree of metadata that stores its arbitrary data in textures?|
|`2`|Quadtree subdivision scheme for all tiles specified in the 'available' array of its corresponding tileset.json.|
|`3`|Octree subdivision scheme for all tiles specified in the 'available' array of its corresponding tileset.json|


TODO: should these be strings: "bi", "quad", "oct"? Though numbers made to line up with number of axes being split.
TODO: For binary and quad, allow specifying split axes? At most, this would optional. Do the obvious splitting otherwise.


#### time

TODO: Ignore for now? To support time dynamic maybe have an array tuples containing a timestamp its corresponding t folder
Is the timestamp milliseconds since 1970 or something more like mm/dd/yyyy/hh/mm/ss/xx?
hopefully a toplevel timestamp->t folder mapping will allow easily handing of external tilesets with different time samples / timelines
Allowed to mix time dynamic, non-time dynamic in the same tree (external tilesets)

Thoughts on folder structure if we allow arbitrary mixing of time-dynamic and subdivision schemes per external tileset:
* Extensionless files, tile data type (pnts, b3dm, ect.) determined from a file's header magic.
* Tile uri namespace is d/z/y/x (or whatever it will be).
* External tileset.jsons do not get to take one of these keys, instead they can live in an "external" folder or something at the root dir. Their availability
can be described by a "layerExternal.json" or something that follows the same schema used to specify tile availability.
* Tiles file name should probably be reserved for the smallest dimension, x, and not dictated by legacy quad tree naming conventions where the file name ends up landing on y.
* Higher dimensions from x can tacked on to the left as folders. Depth in the tree is always the assumed folder prefix.
examples: d/x, d/y/x, d/z/y/x, d/t/z/y/x this should hopefully make correlating/diffing/merging two tilesets in the same bounds but with different tiling schemes
a little more staightforward/logical when dealing with their folder structures.
* Given all of the above, if you wanted to support binary, quad, oct, time dynamic/non-time dynamic all in the same dataset, where
external tileset are dictating switches to different subdivision schemes, a d/t/z/y/x uri would work.
The x/y is only problematic if you want to go more primitive than quad tree subdivision via binary tree and have a consistent uri naming convention

#### headCount

The `headCount` property specifies the number of heads in each dimension (x, y, and z, in that order) at the root level as indicated by a three element array containing integers. A single root in the given root level `boundingVolume` would be
indicated by "headCount": [1, 1, 1]. A "dual-headed quad tree" or TMS style quadtree, where there are two roots side-by-side along the x dimension, would be indicated by
"headCount": [2, 1, 1], "subdivision": 2.
`headCount` enables mapping onto `CDB` tiling scheme where each tilesets boundingVolume.
Describes the bounds of the latitude strip and the headCount describes the resolution of cdb tiles in that strip. The layer.json would tell you what heads are actually available.

#### refine

The `refine` property specifies the refinement style and is either `REPLACE` or `ADD`. The refinement specified applies to all tiles in the tileset JSON's corresponding layer.json.
This is the same `refine` metadata as described in [3D Tiles](../../specification/README.md).

#### boundingVolume

The `boundingVolume` property specifies boundingVolume context for the tileset.json and its layers.json. The `boundingVolume` types are restricted to `region` and `box`.
The `boundingVolume`'s of descendants of a tileset.json spedified in it's layer.json are derived from its `boundingVolume` and `subdivision` types.
This is the same `boundingVolume` metadata as described in [3D Tiles](../../specification/README.md).

TODO: Unsupplied means untraversable/no spatial context but data still needs hierarchy? Can still do random access queries/hierarchical analysis. Good use-case?

TODO: Is there a good mechanism to say this bundle of tilesets are all "layers" of dataset and theres one availability to describe all of them?
could add an optional array of "layerNames" that describe a prefixes to the implicit uri's to access those layers.

#### transform

The `transform` property specifies 4x4 affine transformation to apply to the tileset. Per-tile transforms are unsupported.
This is the same `transform` metadata as described in [3D Tiles](../../specification/README.md).

#### Schema updates

See [Property reference](#reference-3dtiles_draco_point_compression-feature-table-extension) for the `3DTILES_draco_point_compression` Feature Table schema reference. The full JSON schema can be found in [3DTILES_draco_point_compression.featureTable.schema.json](schema/3DTILES_draco_point_compression.featureTable.schema.json).

### Layer

The layer.json file for a corresponding tileset.json describes the tiles that are available in the tree.
It contains a single json object that is an array. Each element of the array holds an array describing available ranges on that level of the tree.

Below is an example availability for the above Tileset JSON where the availability of levels in the quadtree is 9-13:
```json
{
    "available": [
        [
        ],
        [
        ],
        [
        ],
        [
        ],
        [
        ],
        [
        ],
        [
        ],
        [
        ],
        [
        ],
        [
            {
                "startX": 301,
                "startY": 140,
                "endX": 301,
                "endY": 140
            }
        ],
        [
            {
                "startX": 602,
                "startY": 280,
                "endX": 603,
                "endY": 280
            }
        ],
        [
            {
                "startX": 1205,
                "startY": 560,
                "endX": 1206,
                "endY": 560
            }
        ],
        [
            {
                "startX": 2411,
                "startY": 1120,
                "endX": 2412,
                "endY": 1121
            },
            {
                "startX": 2413,
                "startY": 1120,
                "endX": 2413,
                "endY": 1120
            }
        ],
        [
            {
                "startX": 4823,
                "startY": 2240,
                "endX": 4825,
                "endY": 2243
            },
            {
                "startX": 4826,
                "startY": 2240,
                "endX": 4826,
                "endY": 2241
            },
            {
                "startX": 4827,
                "startY": 2240,
                "endX": 4827,
                "endY": 2240
            }
        ]
    ]
}
```

#### properties

`properties` defines additional Batch Table properties stored in the compressed data. In the example above, intensity and classification are compressed.

Each property defined in the extension must correspond to a property name already defined in the Batch Table JSON.
When a property is compressed its `byteOffset` property is ignored and may be set to zero. Its `componentType` and `type` properties
define the component type and type, respectively, of the uncompressed data.

Each property is associated with a unique ID. This ID is used to identify the property within the compressed data.
No two properties in the Feature Table and Batch Table may use the same ID.

`byteOffset` and `byteLength` are not defined in the Batch Table extension; all compressed data is stored in the Feature Table binary.

#### Schema updates

See [Property reference](#reference-3dtiles_draco_point_compression-batch-table-extension) for the `3DTILES_draco_point_compression` Batch Table schema reference. The full JSON schema can be found in [3DTILES_draco_point_compression.batchTable.schema.json](schema/3DTILES_draco_point_compression.batchTable.schema.json).

### Notes

If some properties are compressed and others are not, the Draco encoder must apply the `POINT_CLOUD_SEQUENTIAL_ENCODING` encoding method.
This ensures that Draco preserves the original ordering of point data.

> **Implementation Note:** Draco may reorder point data to achieve better compression and smaller file sizes.
For best results, all properties in the Feature Table and Batch Table should be Draco compressed, in which
case `POINT_CLOUD_SEQUENTIAL_ENCODING` should not be applied.

## Resources
_This section is non-normative._

* [Draco Open Source Library](https://github.com/google/draco)
* [Cesium Draco Decoder Implementation](https://github.com/AnalyticalGraphicsInc/cesium/blob/master/Source/Workers/decodeDraco.js)

## Property reference

* [`3DTILES_draco_point_compression Feature Table extension`](#reference-3dtiles_draco_point_compression-feature-table-extension)
* [`3DTILES_draco_point_compression Batch Table extension`](#reference-3dtiles_draco_point_compression-batch-table-extension)

---------------------------------------
<a name="reference-3dtiles_draco_point_compression-feature-table-extension"></a>
## 3DTILES_draco_point_compression Feature Table extension

Specifies the compressed Feature Table properties and the location of the compressed data in the Feature Table binary.

**Properties**

|   |Type|Description|Required|
|---|----|-----------|--------|
|**properties**|`object`|Defines the properties stored in the compressed data. Each property is associated with a unique ID. This ID is used to identify the property within the compressed data. No two properties in the Feature Table and Batch Table may use the same ID.| :white_check_mark: Yes|
|**byteOffset**|`number`|A zero-based offset relative to the start of the Feature Table binary at which the compressed data starts.| :white_check_mark: Yes|
|**byteLength**|`number`|The length, in bytes, of the compressed data.| :white_check_mark: Yes|

Additional properties are not allowed.

### properties :white_check_mark:

Defines the properties stored in the compressed data. Each property is associated with a unique ID. This ID is used to identify the property within
the compressed data. No two properties in the Feature Table and Batch Table may use the same ID.

* **Type**: `object`
* **Required**: Yes
* **Type of each property**: `number`

### byteOffset :white_check_mark:

A zero-based offset relative to the start of the Feature Table binary at which the compressed data starts.

* **Type**: `number`
* **Required**: Yes
* **Minimum**: ` >= 0`

### byteLength :white_check_mark:

The length, in bytes, of the compressed data.

* **Type**: `number`
* **Required**: Yes
* **Minimum**: ` >= 0`

---------------------------------------
<a name="reference-3dtiles_draco_point_compression-batch-table-extension"></a>
## 3DTILES_draco_point_compression Batch Table extension

Specifies the compressed Batch Table properties.

**Properties**

|   |Type|Description|Required|
|---|----|-----------|--------|
|**properties**|`object`|Defines the properties stored in the compressed data. Each property is associated with a unique ID. This ID is used to identify the property within the compressed data. No two properties in the Feature Table and Batch Table may use the same ID.| :white_check_mark: Yes|

Additional properties are not allowed.

### properties :white_check_mark:

Defines the properties stored in the compressed data. Each property is associated with a unique ID. This ID is used to identify the property within the compressed data. No two properties in the Feature Table and Batch Table may use the same ID.

* **Type**: `object`
* **Required**: Yes
* **Type of each property**: `number`

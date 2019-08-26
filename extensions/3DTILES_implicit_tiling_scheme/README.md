# 3DTILES_implicit_tiling_scheme Extension

## Contributors

* Josh Lawrence, [@loshjawrence](https://github.com/loshjawrence)
* Shehzan Mohammed, [@shehzan10](https://github.com/shehzan10)
* Patrick Cozzi, [@pjcozzi](https://github.com/pjcozzi)

## Contents

* [Overview](#overview)
* [Tileset JSON Format Updates](#tileset-json-format-updates)
   * [Tiling Scheme](#tiling-scheme)
   * [Available](#available)
   * [Notes](#notes)
* [Resources](#resources)
* [Property Reference](#property-reference)

## Overview

This extension enables the [3D Tiles JSON](../../specification/schema/tileset.schema.json) to support streaming tilesets with implied subdivision schemes.

#### TODO: available.json is the bulk of the metadata info. If a compressed binary version of available.json doesn't have significant size advantages over a compressed text version, just fold the availability into tileset.json
Also if there are common use cases (don't think there are) where you just the tileset.json info and not the available.json info, to avoid paying the cost of fetching the availability, we should keep them separate.
#### TODO: Binary Tree Subdivision? assumed along the longest axis of root bounds. Good for self-driving highway scans? Strange/arbitrary data that's best expressed in binary tree, binary tree of metadata that stores its arbitrary data in textures?
#### TODO: For binary and quad subdivision, allow specifying split axes? At most, this would optional. Do the obvious splitting otherwise.
#### TODO: Replace indexingOrigin and indexingDirection with a flipY since that's probably the only real case?
#### TODO: boundingVolume: Unsupplied means untraversable/no spatial context but data still needs hierarchy? Can still do random access queries/hierarchical analysis. Good use-case?
#### TODO: Availability sharing: is there a good mechanism to say this bundle of tilesets are all "layers" of dataset and theres one availability to describe all of them?
* It is more more efficient traversal-wise to have 1 tileset that specifies layers in it implicit context instead of having a bunch of tilesets. Less duplication of effort, one set of traversal calculations apply to all the layers.
* Use this mechanism to encode a bunch of layers of metadata(ex: per point) as basis textures (ktx2 payloads). Analisys use-cases for? mip down to 1x1 (ave, min,max)
* The tileset specifies all of its layers as an array of strings. The base uri is modified depending on teh layer that is being fetched by either:
  * Having the layer name as the file extension (we are not using file extensions so the layer tag can go on the file extension): d/z/y/x.layerName
  * Having the layer name as a folder prefix in the uri: layerName/d/z/y/x
#### TODO: support `time`?
#### TODO: How to handle CDB's negative levels? These are mip levels of the 0 level tiles. ktx2 has ways of specifying mip levels. Is there a good way to fetch a mip level of root tile. Otherwise we would actually need a cdb subdivision or a way to specify subdivision per level.

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
            "indexingOrigin": [1,-1,1],
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

`subdivision` defines the subdivision scheme for the tiles described by the tileset.json's corresponding available.json. In the example above, a type of 2 would indicate a quadtree subdivision.
Other possible types are defined in the type enumeration table below.


|Type|Description|
|----|-----------|
|`0`|Reserved. Indicates custom? |
|`1`|Reserved. Binary tree? |
|`2`|Quadtree subdivision scheme for all tiles specified in the 'available' array of its corresponding tileset.json.|
|`3`|Octree subdivision scheme for all tiles specified in the 'available' array of its corresponding tileset.json|


#### time

To support time dynamic maybe have an array of pairs containing a timestamp its corresponding t-folder.
Is the timestamp milliseconds since 1970 or something more like mm/dd/yyyy/hh/mm/ss/xx?
Hopefully a toplevel timestamp->t-folder mapping will allow easily handing of external tilesets with different time samples / timelines
Allowed to mix time dynamic, non-time dynamic in the same tree (external tilesets)

Thoughts on folder structure if we allow arbitrary mixing of time-dynamic and subdivision schemes per external tileset:
* Extensionless files, tile data type (pnts, b3dm, ect.) determined from a file's header magic.
* Tile uri namespace is d/z/y/x (or whatever it will be).
* External tileset.jsons do not get to take one of these keys, instead they can live in an "external" folder or something at the root dir. Their availability
can be described by a "availableExternal.json" or something that follows the same schema used to specify tile availability.
* Tiles file name should probably be reserved for the smallest dimension, x, and not dictated by legacy quad tree naming conventions where the file name ends up landing on y.
* Higher dimensions from x can tacked on to the left as folders. Depth in the tree is always the assumed folder prefix.
examples: d/x, d/y/x, d/z/y/x, d/t/z/y/x this should hopefully make correlating/diffing/merging two tilesets in the same bounds but with different tiling schemes
a little more staightforward/logical when dealing with their folder structures.
* Given all of the above, if you wanted to support binary, quad, oct, time dynamic/non-time dynamic all in the same dataset, where
external tileset are dictating switches to different subdivision schemes, a d/t/z/y/x uri would work.
The x/y is only problematic if you want to go more primitive than quad tree subdivision via binary tree and have a consistent uri naming convention

#### headCount

The `headCount` property specifies the number of heads in each dimension (x, y, and z, in that order) at level 0 as indicated by a three element array containing integers. A single root would be indicated by "headCount": [1, 1, 1].
A "dual-headed quad tree" or TMS style quadtree, where there are two roots side-by-side along the x dimension, would be indicated by "headCount": [2, 1, 1], "subdivision": 2.

`headCount` enables easy mapping onto other implicit tilings schemes. For example, in a `CDB` tiling scheme, each tileset.json boundingVolume would described the bounds of the latitude strip and the tileset.json headCount
would describe the resolution of cdb tiles in that strip. The available.json would tell you what heads are actually available.

#### indexingOrigin
The `indexingOrigin` property specifies the index origin for each dimension (x, y, and z, in that order) as indicated by a three element array containing integers.

A value of "indexingOrigin": [1,1,1] would indicate that indexing origin is lower-left-back where x indexing proceeds from left to right, y indexing proceeds from bottom to top and z indexing proceeds from back to front.
A value of "indexingOrigin": [-1,-1,-1] would indicate that indexing origin is upper-right-front where x indexing proceeds from right to left, y indexing proceeds from top to bottom and z indexing proceeds from front to back.
A value of "indexingOrigin": [0,0,0] would indicate that indexing origin is middle-middle-middle where the x, y, z origin sits in the middle of the range. When any element is 0 an indexingDirection must be supplied to indicate the directions of those elements that are 0.

#### indexingDirection

The `indexingDirection` property specifies the index direction for each dimension (x, y, and z, in that order) as indicated by a three element array containing integers.
Only the elements in indexingDirection that have elements in indexingOrigin marked as 0 will be honored. The elements in indexingDirection that were non-zero in indexingOrigin will be ignored.


The following assumes a "indexingOrigin": [0,0,0]. However, if it had been "indexingOrigin": [-1,0,1], x and z in indexingDirection will be ignored since it's implied by indexingOrigin.

A value of "indexingDirection": [1,1,1] would indicate that indexing directions for each axis would be as follows:
* x: right
* y: up
* z: towards

A value of "indexingDirection": [-1,-1,-1] would indicate that indexing directions for each axis would be as follows:
* x: left
* y: down
* z: away

#### refine

The `refine` property specifies the refinement style and is either `REPLACE` or `ADD`. The refinement specified applies to all tiles in implied by a  tileset JSON.
This is the same `refine` metadata as described in [3D Tiles](../../specification/README.md).

#### boundingVolume

The `boundingVolume` property specifies boundingVolume context for the tileset.json and its available.json. The `boundingVolume` types are restricted to `region` and `box`.
The `boundingVolume`'s of descendants of a tileset.json spedified in it's available.json are derived from its `boundingVolume` and `subdivision` types.
This is the same `boundingVolume` metadata as described in [3D Tiles](../../specification/README.md).

#### transform

The `transform` property specifies 4x4 affine transformation to apply to the tileset. Per-tile transforms are unsupported.
This is the same `transform` metadata as described in [3D Tiles](../../specification/README.md).

#### Schema updates

See [Property reference](#reference-3DTILES_implicit_tiling_scheme-tileset-extension) for the `3DTILES_implicit_tiling_scheme.tileset` schema reference. The full JSON schema can be found in [3DTILES_implicit_tiling_scheme.tileset.schema.json](schema/3DTILES_implicit_tiling_scheme.tileset.schema.json).

### Available

The available.json file for a corresponding tileset.json describes the tiles that are available in the tree.
It contains a single json object that is an array. Each element of the array holds an array describing available ranges on that level of the tree.

Below is an example availability for the above Tileset JSON where the availability of levels in the quadtree (as there are only x and y ranges) is 9-13:
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

`available` defines the tiles that are available in the tree. It contains a single array where each element of the array holds an array describing available ranges on that level of the tree.

#### Schema updates

See [Property reference](#reference-3DTILES_implicit_tiling_scheme-available-extension) for the `3DTILES_implicit_tiling_scheme.available` schema reference. The full JSON schema can be found in [3DTILES_implicit_tiling_scheme.available.schema.json](schema/3DTILES_implicit_tiling_scheme.available.schema.json).

## Notes
_This section is non-normative._

## Resources
_This section is non-normative._

## Property reference

* [`3DTILES_implicit_tiling_scheme Tileset JSON extension`](#reference-3DTILES_implicit_tiling_scheme-tileset-extension)
* [`3DTILES_implicit_tiling_scheme Available JSON extension`](#reference-3DTILES_implicit_tiling_scheme-available-extension)

---------------------------------------
<a name="reference-3DTILES_implicit_tiling_scheme-tileset-extension"></a>
## 3DTILES_implicit_tiling_scheme Tileset JSON extension

Specifies the Tileset JSON properties for the 3DTILES_implicit_tiling_scheme.

**Properties**

|   |Type|Description|Required|
|---|----|-----------|--------|
|**subdivision**|`number`|Defines the implied subdivision for all tiles described by the `available` array in available.json.| :white_check_mark: Yes|
|**refine**|`string`|Defines the refinement scheme for all tiles described by the `available` array in available.json.| :white_check_mark: Yes|
|**headCount**|`array`|Defines the number of heads at level 0 in the tree.| :white_check_mark: Yes|
|**boundingVolume**|`object`|The `boundingVolumes` around level 0, not just the heads that are available.| :white_check_mark: Yes|
|**indexingOrigin**|`array`|The `indexingOrigin` property specifies the index origin for each dimension (x, y, and z, in that order) as indicated by a three element array containing integers.| :white_check_mark: Yes|
|**indexingDirection**|`array`|The `indexingDirection` property specifies the index direction for each dimension (x, y, and z, in that order) as indicated by a three element array containing integers.| :white_check_mark: No|

Additional properties are not allowed.

### subdivision :white_check_mark:

Defines the implied subdivision for all tiles described by the `available` array in available.json.

* **Type**: `number`
* **Required**: Yes
* **Minimum**: ` >= 0`

### refine :white_check_mark:

Defines the refinement scheme for all tiles described by the `available` array in available.json.

* **Type**: `string`
* **Required**: Yes

### headCount :white_check_mark:

Defines the number of heads at level 0 in the tree.

* **Type**: `array`
* **Required**: Yes
* **Type of each property**: `number`

### boundingVolume :white_check_mark:

Defines the bounds around all the heads (both available and unavailable) at level 0 in the tree.

* **Type**: `object`
* **Required**: Yes
* **Type of each property**: `array`

### indexingOrigin :white_check_mark:

Defines the indexingOrigin for all indices (x, y ,z) for all levels in the tree.

* **Type**: `array`
* **Required**: Yes
* **Type of each property**: `number`

### indexingDirection

Defines the indexingDirection for all indices (x, y, z) for all levels in the tree. Only required at least one of the indexingOrigin elements is 0.

* **Type**: `array`
* **Required**: Yes
* **Type of each property**: `number`

---------------------------------------
<a name="reference-3DTILES_implicit_tiling_scheme-available-extension"></a>
## 3DTILES_implicit_tiling_scheme Available JSON extension

Specifies the Available JSON properties.

**Properties**

|   |Type|Description|Required|
|---|----|-----------|--------|
|**available**|`array`|Defines the tiles that are available at different levels of the tree with x, y, z ranges.| :white_check_mark: Yes|

Additional properties are not allowed.

### available :white_check_mark:

Defines the tiles that are available at different levels of the tree with x, y, z ranges.

* **Type**: `array`
* **Required**: Yes
* **Type of each property**: `array`

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

#### TODO: Availability sharing: for layers of data that are all in the same context bounding volume / subdivision / availability:
* The tileset specifies all of its postfix keys (or prefix?) to its various layers of data as an array of strings in `layerNames`. The base uri is modified with the layerName as a prefix or postfix.
* It is more more efficient traversal-wise to have 1 tileset that specifies layers in it implicit context instead of having a bunch of tilesets. Less duplication of effort, one set of traversal calculations apply to all the layers.
* Use this mechanism to encode a bunch of layers of metadata(ex: per point) as basis textures (ktx2 payloads). Analisys use-cases for? mip down to 1x1 (ave, min,max)
* Use this mechanism for time-dynamic versions of the data

#### TODO: time array of pairs of key-frame timestamps and their folder (the t in d/x/y/z/t)

#### TODO: How to handle external tilesets?
  * Have the external tileset availability listed after tile availability(as described in this document)
  * For determining availability of a random tile outside the current view of the tree, we would need something like an externalAvailable.json that describes availability of external tileset.json's
    so that we can quickly determine the external tileset.json that we would need to fetch in order to to come to a conclusion about that tile's availability.

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
            },
            "available": [
                [],
                [],
                [],
                [],
                [],
                [],
                [],
                [],
                [],
                [
                    {
                        "x": [301,301],
                        "y": [140,140]
                    }
                ],
                [
                    {
                        "x": [602,603],
                        "y": [280,280]
                    }
                ],
                [
                    {
                        "x": [1205,1206],
                        "y": [560,560]
                    }
                ],
                [
                    {
                        "x": [2411,2412],
                        "y": [1120,1121]
                    },
                    {
                        "x": [2413,2413],
                        "y": [1120,1120]
                    }
                ],
                [
                    {
                        "x": [4823,4825],
                        "y": [2240,2243]
                    },
                    {
                        "x": [4826,4826],
                        "y": [2240,2241]
                    },
                    {
                        "x": [4827,4827],
                        "y": [2240,2240]
                    }

                    // OR:
                    [[4823,4825],[2240,2243]],
                    [[4826,4826],[2240,2241]],
                    [[4827,4827],[2240,2240]]
                    //for loop indexing:
                    available[level][i][X][START]
                    available[level][i][Y][END]
                ]
            ],
            "external": [
                [],
                [],
                [],
                [],
                [],
                [],
                [],
                [],
                [],
                [
                    {
                        "x": [302,140],
                        "y": [302,140]
                    }
                ],
                [],
                [],
                [],
                [
                    {
                        "x": [4827,4828],
                        "y": [2241,2242]
                    }
                ]
            ]
        }
    }
}
```

#### properties

`subdivision` defines the subdivision scheme for the tiles described by the tileset.json's corresponding available.json. In the example above, a type of 2 would indicate a quadtree subdivision.
Other possible types are defined in the type enumeration table below. The `subdivision` could be implied from `available`, however, with `headCount` you can layer `subdivision` types in any dimension so proper interpretation requires
explicitly stating the `subdivision` type.

External tilesets do not specify a `subdivision`.

|Type|Description|
|----|-----------|
|`0`|Reserved. Indicates no subdivision? (CDB negative levels, mips) |
|`1`|Reserved. Binary tree? |
|`2`|Quadtree subdivision scheme for all tiles specified in the 'available' array of its corresponding tileset.json.|
|`3`|Octree subdivision scheme for all tiles specified in the 'available' array of its corresponding tileset.json|

#### headCount

The `headCount` property specifies the number of heads in each dimension (x, y, and z, in that order) at level 0 as indicated by a three element array containing integers. A single root would be indicated by "headCount": [1, 1, 1].
A "dual-headed quad tree" or TMS style quadtree, where there are two roots side-by-side along the x dimension, would be indicated by "headCount": [2, 1, 1], "subdivision": 2.

`headCount` enables easy mapping onto other implicit tilings schemes. For example, in a `CDB` tiling scheme, each tileset.json boundingVolume would described the bounds of the latitude strip and the tileset.json headCount
would describe the resolution of cdb tiles in that strip. The available.json would tell you what heads are actually available.

External tilesets do not specify a `headCount`.

#### refine

The `refine` property specifies the refinement style and is either `REPLACE` or `ADD`. The refinement specified applies to all tiles in implied by a  tileset JSON.
This is the same `refine` metadata as described in [3D Tiles](../../specification/README.md).

External tilesets do not specify a `refine`.

#### boundingVolume

The `boundingVolume` property specifies boundingVolume context for the tileset.json and its available.json. The `boundingVolume` types are restricted to `region` and `box`.
The `boundingVolume`'s of descendants of a tileset.json spedified in it's available.json are derived from its `boundingVolume` and `subdivision` types.
This is the same `boundingVolume` metadata as described in [3D Tiles](../../specification/README.md).

External tilesets do not specify a `boundingVolume`.

#### transform

The `transform` property specifies 4x4 affine transformation to apply to the tileset. Per-tile transforms are unsupported.
This is the same `transform` metadata as described in [3D Tiles](../../specification/README.md).

External tilesets do not specify a `transform`.

### available

The `available` property describes the tiles that are available in the tree. It contains a single json object that is an array. Each element of the array holds an array describing available ranges on that level of the tree.

In the example above, the tiles that are available are on levels 9-13. The two element arrays are pairs of start and end indices making up an index bounding box to concisely say that all the tiles in this bounding box are available.
The level 9 availability is saying that there's a tile at 301, 140 while the level 10 availability is saying that are two tiles available at 602,280 and 603,280.

A tiles uri is simply D/X/Y (or D/X/Y/Z for octree) as indicated by the tile availability. For example, the tile that's available in level 9 in the above tileset would have the uri:
`9/301/140`

### external

The `external` property describes the external tilesets that are available in the tree. It contains a single json object that is an array. Each element of the array holds an array describing available ranges on that level of the tree.

In the example above, the external tilesets that are available are on levels 9 and 13. The two element serve the same function as in available except they specify availability of external tileset as opposed to tiles.
The level 9 availability is saying that there's an external tilesets at 302,140 while the level 13 availability is saying that are 4 external tilesets available at 4827,2241 4827,2242 4828,2241 and 4828,2242

External tilesets live in an external folder in the root directory of the tileset. Their uri is simply D/X/Y (or D/X/Y/Z for octree) as indicated by the external availability. For example, the external tileset that's available in level 9 in the above tileset would have the uri:
`external/9/302/140`

#### Schema updates

See [Property reference](#reference-3DTILES_implicit_tiling_scheme-tileset-extension) for the `3DTILES_implicit_tiling_scheme.tileset` schema reference. The full JSON schema can be found in [3DTILES_implicit_tiling_scheme.tileset.schema.json](schema/3DTILES_implicit_tiling_scheme.tileset.schema.json).


## Notes
_This section is non-normative._

## Resources
_This section is non-normative._

## Property reference

* [`3DTILES_implicit_tiling_scheme Tileset JSON extension`](#reference-3DTILES_implicit_tiling_scheme-tileset-extension)

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
|**available**|`array`|Defines the tiles that are available at different levels of the tree with x, y, z ranges.| :white_check_mark: Yes|
|**external**|`array`|Defines the external tilesets that are available at different levels of the tree with x, y, z ranges.| No|

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

### available :white_check_mark:

Defines the tiles that are available at different levels of the tree with x, y, z ranges.

* **Type**: `array`
* **Required**: Yes
* **Type of each property**: `array`

### external

Defines the external tilesets that are available at different levels of the tree with x, y, z ranges.

* **Type**: `array`
* **Required**: No
* **Type of each property**: `array`


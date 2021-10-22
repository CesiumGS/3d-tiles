<!-- omit in toc -->
# 3DTILES_multiple_contents

<!-- omit in toc -->
## Contributors

* Sean Lilley, Cesium
* Peter Gagliardi, Cesium
* Sam Suhag, Cesium
* Patrick Cozzi, Cesium

<!-- omit in toc -->
## Status

Draft

<!-- omit in toc -->
## Dependencies

Written against the 3D Tiles 1.0 specification.

Adds new functionality to the [`3DTILES_implicit_tiling` extension](../3DTILES_implicit_tiling). See [Implicit Tiling](#implicit-tiling).

<!-- omit in toc -->
## Optional vs. Required

This extension is required, meaning it must be placed in both the `extensionsUsed` and `extensionsRequired` lists in the tileset JSON.

<!-- omit in toc -->
## Contents

- [Overview](#overview)
- [Concepts](#concepts)
  - [Multiple Tile Contents](#multiple-tile-contents)
- [Combining With Other Extensions](#combining-with-other-extensions)  
  - [Metadata Groups](#metadata-groups)
  - [Implicit Tiling](#implicit-tiling)
  - [Metadata Groups in Implicit Tiling](#metadata-groups-in-implicit-tiling)


## Overview

This extension adds support for multiple contents per tile. Examples of contents are Batched 3D Models, Point Clouds, or other [Tile Formats](../../specification#tile-format-specifications), as well as glTF content when it is combined with the [`3DTILES_content_gltf`](../3DTILES_content_gltf) extension.

<img src="figures/overview.jpg" width="500" />

Multiple contents allows for more flexible tileset structures. For example, each tile could store two different representations of the same data using two contents: a point cloud and a triangle mesh, each representing the same surface. An application could selectively request only the point cloud contents.

When this extension is combined with [`3DTILES_metadata`](../3DTILES_metadata), contents can be organized into groups. Each group can have metadata associated with it.

<img src="figures/metadata-groups.jpg" width="500" />

In both cases, groups of contents can be used for selectively showing content or applying custom styling:

![Filtering Groups](figures/filtering-groups.jpg)

Besides styling, groups can also be used to filter out unused content resources to reduce bandwidth usage by only requesting the content that is supposed to be displayed.

Multiple contents is also compatible with the [`3DTILES_implicit_tiling`](../3DTILES_implicit_tiling) extension. See the [Implicit Tiling](#implicit-tiling) section for more details.


## Multiple tile contents

*Defined in [tile.3DTILES_multiple_contents.schema.json](schema/tile.3DTILES_multiple_contents.schema.json).*


A `tile` may be extended with the `3DTILES_multiple_contents` extension. This is an object that contains an array of [tile content](../../specification#reference-tile-content) objects that are treated as the contents of the tile.

> **Example:** : A tile that uses the `3DTILES_multiple_contents` extension to refer to a Batched 3D Model containing buildings, and an Instanced 3D Model containing trees.
> 
> ```jsonc
> {
>   "root": {
>    "refine": "ADD",
>    "geometricError": 0.0,
>    "boundingVolume": {
>      "region": [-1.707, 0.543, -1.706, 0.544, 203.895, 253.113]
>    },
>    "extensions": {
>      "3DTILES_multiple_contents": {
>        "content": [
>          {
>            "uri": "buildings.b3dm"
>          },
>          {
>            "uri": "trees.i3dm"
>          }
>        ]
>      }
>    }
>  }
>}
>```

When this extension is used the containing tile's `content` property must be omitted.

Each content object may optionally have a `boundingVolume` that tightly fits the actual content. When a content does not have a `boundingVolume` property, then the bounding volume of the enclosing tile is used. When bounding volumes for contents are given, then they must maintain the [spatial coherence](https://github.com/CesiumGS/3d-tiles/blob/main/specification/README.md#bounding-volume-spatial-coherence) of the tile hierarchy. This means that these bounding volumes must all be fully contained in the bounding volume of the enclosing tile.

## Combining With Other Extensions

### Metadata Groups

This extension may be paired with the [`3DTILES_metadata`](../3DTILES_metadata) extension to assign each content to a group, optionally associated with some metadata. Each content within a `3DTILES_multiple_contents` extension may then contain a `3DTILES_metadata` extension object, identifying a group for the content. The available groups and their schema are defined in the `3DTILES_metadata` object of the surrounding tileset.

> **Example:** A tileset where the root tile uses the `3DTILES_multiple_contents` extension to refer to two different content files. The first content uses the `3DTILES_metadata` extension to assign it to a group called `"buildings"`. The second one is assigned to a group called `"trees"`. The schema contains entity definitions for these groups. Both entities belong to the class `"layer"` that is also defined in the schema, and contain the values for the properties of this class.
> ```jsonc
> {
>   "extensions": {
>     "3DTILES_metadata": {
>       "schema": {
>         "classes": {
>           "layer": {
>             "properties": {
>               "color": {
>                 "type": "ARRAY",
>                 "componentType": "UINT8",
>                 "componentCount": 3
>               },
>               "order": {
>                 "componentType": "INT32"
>               }
>             }
>           }
>         }
>       },
>       "groups": {
>         "buildings": {
>           "class": "layer",
>           "properties": {
>             "color": [128, 128, 128],
>             "order": 0
>           }
>         },
>         "trees": {
>           "class": "layer",
>           "properties": {
>             "color": [10, 240, 30],
>             "order": 1
>           }
>         }
>       }
>     }
>   },
>   "root": {
>     "refine": "ADD",
>     "geometricError": 32768.0,
>     "boundingVolume": {
>       "region": [-1.707, 0.543, -1.706, 0.544, -10.3, 253.113]
>     },
>     "extensions": {
>       "3DTILES_multiple_contents": {
>         "content": [
>           {
>             "uri": "buildings.b3dm",
>             "extensions": {
>               "3DTILES_metadata": {
>                 "group": "buildings"
>               }
>             }
>           },
>           {
>             "uri": "trees.i3dm",
>             "extensions": {
>               "3DTILES_metadata": {
>                 "group": "trees"
>               }
>             }
>           }
>         ]
>       }
>     }
>   }
> }
> ```

### Implicit Tiling

The `3DTILES_multiple_contents` extension can also be combined with the [`3DTILES_implicit_tiling`](../3DTILES_implicit_tiling) extension. In this case, there must be one content availability bitstream for each of the multiple contents. 

> **Example:** A tileset where the root tile uses multiple contents, and the `3DTILES_implicit_tiling` extension, to define an implicit subtree of the root:
> 
> ```jsonc
> {
>   "root": {
>     "refine": "ADD",
>     "geometricError": 16384.0,
>     "boundingVolume": {
>       "region": [-1.707, 0.543, -1.706, 0.544, 203.895, 253.113]
>     },
>     "extensions": {
>       "3DTILES_multiple_contents": {
>         "content": [
>           {
>             "uri": "buildings/{level}/{x}/{y}.b3dm",
>           },
>           {
>             "uri": "trees/{level}/{x}/{y}.i3dm",
>           }
>         ]    
>       },
>       "3DTILES_implicit_tiling": {
>         "subdivisionScheme": "QUADTREE",
>         "subtreeLevels": 10,
>         "maximumLevel": 16,
>         "subtrees": {
>           "uri": "subtrees/{level}/{x}/{y}.subtree"
>         }
>       }
>     }
>   }
> }
> ```
>
> The JSON part of the `subtree` file then uses a `3DTILES_multiple_contents` object, as defined in [subtree.3DTILES_multiple_contents.schema.json](schema/3DTILES_implicit_tiling/subtree.3DTILES_multiple_contents.schema.json). This object stores an array of [content availability](../3DTILES_implicit_tiling#content-availability) objects, one for each content that was given in the `3DTILES_multiple_contents` object of the enclosing tile.
> 
> 
> ```jsonc
> {
>   "buffers": [ { "byteLength": 262160 } ],
>   "bufferViews": [ 
>     { "buffer": 0, "byteLength": 43691, "byteOffset": 0 },
>     { "buffer": 0, "byteLength": 131072, "byteOffset": 43696 },
>     { "buffer": 0, "byteLength": 43691, "byteOffset": 174768 },
>     { "buffer": 0, "byteLength": 43691, "byteOffset": 218464 }
>   ],
>   "tileAvailability": {
>     "bufferView": 0
>   },
>   "childSubtreeAvailability": {
>     "bufferView": 1
>   },
>   "extensions": {
>     "3DTILES_multiple_contents": {
>       "contentAvailability": [
>         {
>           "bufferView": 2
>         },
>         {
>           "bufferView": 3
>         }
>       ]
>     }
>   }
> }
> ```


### Metadata Groups in Implicit Tiling

If both the [`3DTILES_implicit_tiling`](../3DTILES_implicit_tiling) and [`3DTILES_metadata`](../3DTILES_metadata) extensions are used, each content template URI can be assigned to a metadata group.

> **Example:** A tileset where the root tile uses multiple contents and the `3DTILES_implicit_tiling` extension, to define an implicit subtree of the root. Each content uses a template URI. The coordinates of the implicit subtree are substituted into the template URI of both contents. The resulting subtrees are assigned to different metadata groups. This means that all implicit tiles that are created from the `buildings/{level}/{x}/{y}.b3dm` URI are assigned to the `"buildings"` group, and all implicit tiles that are created from the `"trees/{level}/{x}/{y}.i3dm"` URI are assigned to the `"trees"` group.
>
> ```jsonc
> {
>   "extensions": {
>     "3DTILES_metadata": {
>
>       ...
>
>       "groups": {
>         "buildings": {
>           "class": "layer",
>           "properties": {
>             "color": [128, 128, 128],
>             "order": 0
>           }
>         },
>         "trees": {
>           "class": "layer",
>           "properties": {
>             "color": [10, 240, 30],
>             "order": 1
>           }
>         }
>       }
>     }
>   },
>   "root": {
>     "refine": "ADD",
>     "geometricError": 16384.0,
>     "boundingVolume": {
>       "region": [-1.707, 0.543, -1.706, 0.544, 203.895, 253.113]
>     },
>     "extensions": {
>       "3DTILES_multiple_contents": {
>         "content": [
>           {
>             "uri": "buildings/{level}/{x}/{y}.b3dm",
>             "extensions": {"3DTILES_metadata": { "group": "buildings" } }
>           },
>           {
>             "uri": "trees/{level}/{x}/{y}.i3dm",
>             "extensions": { "3DTILES_metadata": { "group": "trees" } }
>           }
>         ]    
>       },
>       "3DTILES_implicit_tiling": {
>         "subdivisionScheme": "QUADTREE",
>         "subtreeLevels": 10,
>         "maximumLevel": 16,
>         "subtrees": {
>           "uri": "subtrees/{level}/{x}/{y}.subtree"
>         }
>       }
>     }
>   }
> }
> ```

## Revision History

* **Version 0.0.0** November 6, 2020
  * Initial draft (named `3DTILES_layers`) 
* **Version 1.0.0** February 24, 2021
  * Renamed to `3DTILES_multiple_contents`
* **Version 2.0.0** 
  * Renamed `content.schema.json` to `tile.content.schema.json`
  * Let extension objects extend `tilesetProperty`


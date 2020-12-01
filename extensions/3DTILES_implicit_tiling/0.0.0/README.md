# 3DTILES_implicit_tiling

**Version 0.0.0**, December 1, 2020

## Contributors

* Sam Suhag, Cesium
* Sean Lilley, Cesium
* Peter Gagliardi, Cesium
* Erixen Cruz, Cesium

## Status

Draft

## Dependencies

Written against the 3D Tiles 1.0 specification.

## Contents

- [3DTILES_implicit_tiling](#3dtiles_implicit_tiling)
  - [Contributors](#contributors)
  - [Status](#status)
  - [Dependencies](#dependencies)
  - [Contents](#contents)
  - [Overview](#overview)
  - [Concepts](#concepts)
    - [Configuration](#configuration)
    - [Tiling Schemes](#tiling-schemes)
    - [Template URIs](#template-uris)
    - [Availability](#availability)
    - [Subtrees](#subtrees)
    - [Content](#content)
    - [Buffers and BufferViews](#buffers-and-bufferviews)
  - [Examples](#examples)

## Overview

This extension to 3D Tiles enables implicit tiling. 

OUTLINE:
- What is implicit tiling? - Simpler way of describing a tileset with a predictable structure without naming every tile.
- Why would you use this? - Instead of explicitly listing a large number of tiles, use a pattern to keep the tileset.json small.

## Concepts

### Configuration

OUTLINE:
- required options: refine, geometric error, max depth
- subtree depth, bounding volume, tiling scheme (link to respective sections)
- example directory structure (not required)
  - tileset.json which uses this extension
  - buffers/level/x/y/buffer.bin
  - content/level/x/y/model.gltf
  - subtrees/level/x/y/subtree.json

### Tiling Schemes

OUTLINE:
- Quadtree vs octree
- bounding volumes are quartered/eighthed automatically
- cartesian cube or cartographic cube covering root tileset
- geometric error is halved
- refine (ADD/REPLACE) applies to every tile
- subtree branching factor
- diagram: subdivision of tile (maybe reuse some from the [old draft?](https://github.com/CesiumGS/3d-tiles/tree/3DTILES_implicit_tiling/extensions/3DTILES_implicit_tiling))

### Template URIs

OUTLINE:
- level, x, y, z are templated in
- relative to tileset
- availability buffers used to determine when a tile exists
- used to describe tile availability files, content availability files, and subtree jsons
- diagram: how a pattern corresponds to tiles

### Availability

OUTLINE:
- bit vector (describe this like in Cesium 3D Metadata spec?)
- `constant` can be used to save memory
- 1 indicates something is available, 0 indicates unavailable
- meaning depends on type of availability buffers
  - tile availability: does the tile exist?
  - content availability: does the tile have content
  - subtree availability: preview of immediate children availability so traversals can short-circuit
- diagram: tile and content availability
- diagram: subtree availability

### Subtrees

OUTLINE:
- fixed depth subtree chunk of root tree
- json file points to buffers (or constants) with tile, child subtree, content availabilities
- children availability used for traversal for retrieval of tile
- subtrees contain mutually exclusive tiles, and completely cover the entire tree
- include formulas from `example/subtree.json`
- diagram: how subtrees fit together to make a tree

### Content

OUTLINE:
- Same concept as in the main 3D Tiles spec
- One content per tile
- mimeType is required to identify the type of content. This is not in the core spec

### Buffers and BufferViews

OUTLINE:
- describe these again so they're standalone?
- Any chance we can reuse material?

## Examples

OUTLINE:
- make example more concrete
- link to it here
![](figures/3DTiles_light_color_small.png#gh-dark-mode-only)![](figures/3DTiles_dark_color_small.png#gh-light-mode-only)

# 3D Tiles
[https://cesium.com/](https://cesium.com/)

![](figures/photogrammetry-cad-fusion.jpg)

_A building CAD model is fused with photogrammetry data using 3D Tiles, data courtesy of Bentley Systems._

## Overview

3D Tiles is an open specification for sharing, visualizing, fusing, and interacting with massive heterogenous 3D geospatial content across desktop, web, and mobile applications.

#### Open and interoperable

As an open specification with an open-source runtime implementation, 3D Tiles allows data providers and app developers to make massive and complex 3D information more accessible, interoperable, and useful across all kinds of tools and applications.

#### Heterogeneous

With a defined set of file formats, multiple types of 3D geospatial content including photogrammetry/massive models, BIM/CAD, 3D buildings, instanced features, and point clouds can be converted into 3D Tiles and combined into a single dataset.

#### Designed for 3D

Bringing techniques from the field of 3D graphics and built on [glTF](https://github.com/KhronosGroup/glTF), 3D Tiles defines a spatial hierarchy for fast streaming and precision rendering, balancing performance and visual quality at any scale from global to building interiors.

#### Semantic, interactive, and styleable

3D Tiles preserve per-feature metadata to allow interaction such as selecting, querying, filtering, and styling efficiently at runtime.

## Specification

* [3D Tiles Format Specification](./specification/)
* [3D Tiles Extension Registry](./extensions/)

Please provide specification feedback by [submitting issues](https://github.com/CesiumGS/3d-tiles/issues). For questions on implementation, generating 3D Tiles, or to showcase your work, join the [Cesium community forum](https://community.cesium.com/). 

## 3D Tiles Ecosystem

The [3D Tiles Resources](./RESOURCES.md) page contains a list of implementations of the 3D Tiles standard, as well as viewers, generators, data providers, and demos. The page also includes developer resources, blog posts, and presentations that explain the concepts and applications of 3D Tiles.

## 3D Tiles Reference Cards

The [**3D Tiles Reference Cards**](./reference-cards) are approachable and concise guides to learning about the main concepts in 3D Tiles and designed to help integrate 3D Tiles into runtime engines for visualization and analysis of massive heterogeneous 3D geospatial content.

These guides augment the fully detailed 3D Tiles specification with coverage of key concepts to help developers jumpstart adopting 3D Tiles.

## Version History

- [3D Tiles 1.0](https://github.com/CesiumGS/3d-tiles/tree/1.0): The [3D Tiles Specification 1.0](http://docs.opengeospatial.org/cs/18-053r2/18-053r2.html) was submitted to the Open Geospatial Consortium (OGC), and approved as an OGC Community Standard _(2018-12-14)_
- [3D Tiles 1.1](https://github.com/CesiumGS/3d-tiles)
  - Additions:
    - Support for structured metadata that can be associated with tilesets, tiles, tile content, and tile content groups
    - Directly support glTF assets as tile contents
    - Support for multiple tile contents
    - Support for implicit tiling schemes
  - Deprecations:
    - The original tile formats (b3dm, i3dm, pnts, and cmpt) are deprecated in favor of glTF content
    - The `tileset.properties` are deprecated, in favor of the more versatile metadata support


## Contributing

3D Tiles is an open specification and contributions including specification fixes, new tile formats, and extensions are encouraged. Issues and pull requests are welcome on this repository.

---

Created by the <a href="https://cesium.com/">Cesium team</a> and built on <a href="https://www.khronos.org/gltf">glTF</a>.<br/>

<a href="https://cesium.com/"><img src="figures/cesium.jpg" height="40" /></a> <a href="https://www.khronos.org/gltf"><img src="figures/gltf.png" height="40" /></a>

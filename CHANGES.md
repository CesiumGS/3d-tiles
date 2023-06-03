

- Version 1.1, 2023-01-09

  - The [3D Tiles Specification 1.1](https://docs.ogc.org/cs/22-025r4/22-025r4.html) was submitted to the Open Geospatial Consortium (OGC), and approved as an OGC Community Standard _(2022-12-17)_
   
  - 3D Tiles 1.1 adds new capabilities to 3D Tiles. The additions have been proposed and published as a set of draft extensions, summarized under the name [*3D Tiles Next*](https://cesium.com/blog/2021/11/10/introducing-3d-tiles-next/). The proposed extensions have undergone thorough testing and review, and have been the basis for the additions to the 3D Tiles 1.1 core specification. The new capabilities that have been introduced in 3D Tiles 1.1 are the following:
    
    - **Support for glTF 2.0 assets as tile content:** 
    
      In 3D Tiles 1.1, it is possible to use [glTF 2.0](https://www.khronos.org/gltf/) as the tile content. This improves the interoperability with the broader 3D content and tooling ecosystem. 
    
      This functionality has originally been proposed as the [`3DTILES_content_gltf`](./extensions/3DTILES_content_gltf) extension for 3D Tiles 1.0.
    
    - **Support for multiple contents:**: 
      
      Each tile in a 3D Tiles 1.1 tileset can now refer to _multiple_ contents. These contents can be organized in various ways, and they may represent different map layers or different representations of the same tile data. 
      
      This functionality has originally been proposed as the [`3DTILES_multiple_contents`](./extensions/3DTILES_multiple_contents) extension for 3D Tiles 1.0.
    
    - **Implicit tiling:** 
    
      An implicit definition of the spatial structure of a tileset allows for more compact representations of tilesets and their bounding volume hierarchy, faster spatial queries due to the implicit spatial indexing, and improved interoperability with other geospatial formats.
    
      This functionality has originally been proposed as the [`3DTILES_implicit_tiling`](./extensions/3DTILES_implicit_tiling) extension for 3D Tiles 1.0.
  
    - **Metadata:**
    
      3D Tiles 1.1 provides mechanisms to associate metadata with elements of a tileset on all levels of granularity. Metadata may be assigned to tilesets, tiles, or tile content groups. It is based on the format-agnostic [3D Metadata Specification](./specification/Metadata), which defines the key concepts of schemas, property types, and storage formats.

      This functionality has originally been proposed as the [`3DTILES_metadata`](./extensions/3DTILES_metadata) extension for 3D Tiles 1.0.

    - **Recommended glTF extensions:**
   
      The new functionality for associating metadata with elements of a 3D Tiles tileset is based the [3D Metadata Specification](./specification/Metadata). This specification also serves as the basis for glTF extension proposals that allow a unified approach for managing metadata even for individual vertices and texels on glTF 2.0 geometry. The proposed glTF 2.0 extensions are:
    
      - The [`EXT_mesh_features`](https://github.com/CesiumGS/glTF/tree/3d-tiles-next/extensions/2.0/Vendor/EXT_mesh_features) extension that allows assigning identifiers to geometry and subcomponents of geometry within a glTF 2.0 asset.
    
      - The [`EXT_structural_metadata`](https://github.com/CesiumGS/glTF/tree/3d-tiles-next/extensions/2.0/Vendor/EXT_structural_metadata) extension that allows storing structured metadata within a glTF 2.0 asset.
    
      The detailed revision history for the proposed glTF extensions can be found in the [glTF extension proposals revision history](https://github.com/CesiumGS/3d-tiles/blob/eae37f6071c47201364b7823f3d5e934c0db417d/next/REVISION_HISTORY.md)

- [Version 1.0](https://github.com/CesiumGS/3d-tiles/tree/1.0), 2018-06-06

  - The [3D Tiles Specification 1.0](http://docs.opengeospatial.org/cs/18-053r2/18-053r2.html) was submitted to the Open Geospatial Consortium (OGC), and approved as an OGC Community Standard _(2018-12-14)_


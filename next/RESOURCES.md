## 3D Tiles Next Resources

> **Note:** ⚠️ **3D Tiles Next** is a set of draft extensions to the 3D Tiles 1.0 specification. These extensions have become part of the core specification in 3D Tiles 1.1. Please refer to the [main 3D Tiles 1.1 specification](../specification/README.md) for the latest information about 3D Tiles 1.1 ⚠️

**Introduction**

* [**Introducing 3D Tiles Next, Streaming Geospatial to the Metaverse**](https://cesium.com/blog/2021/11/10/introducing-3d-tiles-next/) - the announcement of the publication of the 3D Tiles Next specification, summarizing the technical goals and application areas
* [**3D Tiles Next Reference Card**](./3d-tiles-next-reference-card.pdf) - a guide to learning about the new concepts that have been introduced with 3D Tiles Next

**General Developer Resources**

* [The 3D Tiles Next section](.) - the section in the 3D Tiles repository that contains an overview, resources, and specifications of all components related to 3D Tiles Next:
  * [3D Metadata Specification](../specification/Metadata)
  * [`3DTILES_metadata`](../extensions/3DTILES_metadata)
  * [`EXT_mesh_features`](https://github.com/KhronosGroup/glTF/pull/2082) (glTF extension)
  * [`3DTILES_implicit_tiling`](../extensions/3DTILES_implicit_tiling)
  * [`3DTILES_bounding_volume_S2`](../extensions/3DTILES_bounding_volume_S2)
  * [`3DTILES_multiple_contents`](../extensions/3DTILES_multiple_contents)
  * [`3DTILES_content_gltf`](../extensions/3DTILES_content_gltf)

**Demos**
  * Demos that have been published based on the experimental 3D Tiles Next support in the [CesiumJS 1.87.1 Release:](https://github.com/CesiumGS/cesium/blob/main/CHANGES.md#1871---2021-11-09)
    * [Photogrammetry Classification Demo](https://demos.cesium.com/ferry-building)
    * [Property Textures Demo](https://demos.cesium.com/owt-uncertainty)
    * [S2 Base Globe Demo](https://demos.cesium.com/owt-globe)
    * [CDB Yemen Demo](https://demos.cesium.com/cdb-yemen)


**Selected Talks**
  * _Introducing 3D Tiles Next_, at Web3D Conference 2021. [Video and slides](https://cesium.com/learn/presentations/#web3d-conference-2021)

**Implementations**
  * [CesiumJS](https://github.com/CesiumGS/cesium) added experimental support for 3D Tiles Next features in version 1.87.1 ([Release Notes](https://github.com/CesiumGS/cesium/blob/main/CHANGES.md#1871---2021-11-09))
  * [cesium-native](https://github.com/CesiumGS/cesium-native) is in progress of adding 3D Tiles Next support ([Roadmap issue](https://github.com/CesiumGS/cesium-native/issues/386))

**Projects**
  * [minimal-pointcloud-gltf](https://github.com/wallabyway/minimal-pointcloud-gltf). A proposal for a standard point cloud representation in glTF and 3D Tiles Next
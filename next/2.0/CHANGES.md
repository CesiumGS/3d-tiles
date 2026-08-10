# Breaking changes

- 3D Tiles 2.0 no longer defines its own file format, Tileset JSON; a tileset is now a glTF 2.1 asset with the [3DTILES_tileset](https://github.com/CesiumGS/glTF/tree/3d-tiles-2.0/extensions/2.1/Vendor/3DTILES_tileset) extension.

- Implicit tiling is no longer part of the core schema; it is now an optional glTF extension: [3DTILES_implicit_tiling](https://github.com/CesiumGS/glTF/tree/3d-tiles-2.0/extensions/2.1/Vendor/3DTILES_implicit_tiling).

- Other implicit tiling changes:
  - 3D Tiles 2.0 no longer defines its own subtree format; a subtree is now a glTF 2.1 asset with the [3DTILES_subtree](https://github.com/CesiumGS/glTF/tree/3d-tiles-2.0/extensions/2.1/Vendor/3DTILES_subtree) extension.
  - The coordinate names `{x}`, `{y}`, `{z}` have been renamed and are now dependent on the shape type. This allows implicit tiling coordinates to be consistent with 3D Tiles 1.1 while operating in glTF's Y-up coordinate system.
    - For `"box"` the coordinate names are now `{right}`, `{forward}`, `{up}`.
    - For [`"ellipsoid region"`](https://github.com/CesiumGS/glTF/tree/3d-tiles-2.0/extensions/2.1/Vendor/3DTILES_shape_ellipsoid_region) the coordinate names are now `{longitude}`, `{latitude}`, `{height}`
    - For [`"cylinder region"`](https://github.com/CesiumGS/glTF/tree/3d-tiles-2.0/extensions/2.1/Vendor/3DTILES_shape_cylinder_region) the coordinate names are now `{radius}`, `{angle}`, `{height}`

- Multiple contents is no longer part of the core schema; instead glTF content may reference external assets to achieve similar behavior.

- Metadata is no longer part of the core schema, but may be assigned at multiple granularities as before with `EXT_structural_metadata` - tileset, tile, content, layer, feature, vertex, texel, etc.

- The `region` bounding volume type is no longer part of the core schema; it is now an optional glTF extension: [3DTILES_shape_ellipsoid_region](https://github.com/CesiumGS/glTF/tree/3d-tiles-2.0/extensions/2.1/Vendor/3DTILES_shape_ellipsoid_region).

- The `viewerRequestVolume` property is no longer part of the core schema; it is now an optional glTF extension: [3DTILES_viewer_request_volume](https://github.com/CesiumGS/glTF/tree/3d-tiles-2.0/extensions/2.1/Vendor/3DTILES_viewer_request_volume).

- The `group` and `groups` properties are no longer part of the core schema; layering functionality is now an optional glTF extension: [3DTILES_layers](https://github.com/CesiumGS/glTF/tree/3d-tiles-2.0/extensions/2.1/Vendor/3DTILES_layers).

- Geometric error is no longer scaled by the tile transform. This reverts back to 3D Tiles 1.0 behavior.

- Tiles with geometric error greater than or equal to their parent are now considered _unconditionally refinable_ - they will always be refined and never be rendered. This allows empty tiles to be used for culling and not rendering. Tiles that reference external tilesets and implicit root tiles are also unconditionally refinable.

- Tilesets in a global coordinate system must now specify a geocentric CRS with [EXT_crs](https://github.com/CesiumGS/glTF/tree/3d-tiles-2.0/extensions/2.1/Vendor/EXT_crs).

- Tilesets in a local coordinate system are now Y-up instead of Z-up in alignment with glTF.

- The built-in [3D Metadata Semantics](https://github.com/CesiumGS/3d-tiles/tree/main/specification/Metadata/Semantics) have been removed.
  - Bounding volume semantics (`TILE_BOUNDING_BOX`, `TILE_BOUNDING_REGION`, `TILE_BOUNDING_SPHERE`, `TILE_BOUNDING_S2_CELL`, `TILE_MINIMUM_HEIGHT`, `TILE_MAXIMUM_HEIGHT`, `CONTENT_BOUNDING_BOX`, `CONTENT_BOUNDING_REGION`, `CONTENT_BOUNDING_SPHERE`, `CONTENT_BOUNDING_S2_CELL`, `CONTENT_MINIMUM_HEIGHT`, `CONTENT_MAXIMUM_HEIGHT`) have been replaced by the equivalent subtree attributes defined in [3DTILES_implicit_tiling](https://github.com/CesiumGS/glTF/tree/3d-tiles-2.0/extensions/2.1/Vendor/3DTILES_implicit_tiling), [3DTILES_shape_ellipsoid_region](https://github.com/CesiumGS/glTF/tree/3d-tiles-2.0/extensions/2.1/Vendor/3DTILES_shape_ellipsoid_region), and [3DTILES_shape_s2](https://github.com/CesiumGS/glTF/tree/3d-tiles-2.0/extensions/2.1/Vendor/3DTILES_shape_s2).
  - Tile semantics (`TILE_GEOMETRIC_ERROR`, `TILE_REFINE`, `TILE_TRANSFORM`) have been replaced by the equivalent subtree attributes defined in [3DTILES_implicit_tiling](https://github.com/CesiumGS/glTF/tree/3d-tiles-2.0/extensions/2.1/Vendor/3DTILES_implicit_tiling), 
  - Horizon occlusion point semantics (`TILE_HORIZON_OCCLUSION_POINT`, `CONTENT_HORIZON_OCCLUSION_POINT`) have been replaced by the equivalent subtree attributes defined in [3DTILES_horizon_occlusion_point](https://github.com/CesiumGS/glTF/tree/3d-tiles-2.0/extensions/2.1/Vendor/3DTILES_horizon_occlusion_point).
  - Tileset CRS semantics (`TILESET_CRS_GEOCENTRIC`, `TILESET_CRS_COORDINATE_EPOCH`) have been replaced by [EXT_crs](https://github.com/CesiumGS/glTF/tree/3d-tiles-2.0/extensions/2.1/Vendor/EXT_crs) and [EXT_crs_wkid](https://github.com/CesiumGS/glTF/tree/3d-tiles-2.0/extensions/2.1/Vendor/EXT_crs_wkid).
  - Content group semantic `CONTENT_GROUP_ID` has been replaced by `CONTENT_LAYER_INDEX` in [3DTILES_layers](https://github.com/CesiumGS/glTF/tree/3d-tiles-2.0/extensions/2.1/Vendor/3DTILES_layers).
  - All other semantics do not currently have equivalent representations in 3D Tiles 2.0, but could in the future with extensions.

# Additions

- The entry tileset now has a recommended naming convention: `root.tileset.gltf` or `root.tileset.glb`
- Tile content can now indicate whether it is regular content, conditional content, or an external tileset.


# Other migration notes

- Package formats for 3D Tiles 1.0 and 1.1 such as `.3dtiles` and `.3tz` are superseded by glTF 2.1's native packaging mechanism: [Packaging External Assets](https://github.com/KhronosGroup/glTF/issues/2589).
- [EXT_georeference](https://github.com/CesiumGS/glTF/tree/3d-tiles-2.0/extensions/2.1/Vendor/EXT_georeference) is now the preferred way to georeference tilesets instead of using a tile transform.
- The `asset.extras.ion.georeferenced` and `asset.extras.ion.movable` properties found in some tilesets are now obsolete. An asset is considered georeferenced if it uses `EXT_crs` and movable if it uses `EXT_crs` and `EXT_georeference`.
- The 3D Tiles 1.1 extension [3DTILES_bounding_volume_s2](https://github.com/CesiumGS/3d-tiles/tree/main/extensions/3DTILES_bounding_volume_S2) has migrated to the glTF extension [3DTILES_shape_s2](https://github.com/CesiumGS/glTF/tree/3d-tiles-2.0/extensions/2.1/Vendor/3DTILES_shape_s2).
- The 3D Tiles 1.1 extension [3DTILES_bounding_volume_cylinder](https://github.com/CesiumGS/3d-tiles/tree/voxels/extensions/3DTILES_bounding_volume_cylinder) has migrated to the glTF extension [3DTILES_shape_cylinder_region](https://github.com/CesiumGS/glTF/tree/3d-tiles-2.0/extensions/2.1/Vendor/3DTILES_shape_cylinder_region).
- The 3D Tiles 1.1 extension [3DTILES_content_voxels](https://github.com/CesiumGS/glTF/tree/3d-tiles-2.0/extensions/2.1/Vendor/3DTILES_content_voxels) has migrated to the glTF extension [3DTILES_content_voxels](https://github.com/CesiumGS/glTF/tree/3d-tiles-2.0/extensions/2.1/Vendor/3DTILES_content_voxels)
- The 3D Tiles 1.1 extension [3DTILES_content_gltf_vector]() has migrated to the glTF extension [3DTILES_content_vector](https://github.com/CesiumGS/glTF/tree/3d-tiles-2.0/extensions/2.1/Vendor/3DTILES_content_vector)
- The 3D Tiles 1.1 extension [3DTILES_ellipsoid](https://github.com/CesiumGS/3d-tiles/tree/main/extensions/3DTILES_ellipsoid) is superseded by the glTF extension [EXT_crs](https://github.com/CesiumGS/glTF/tree/3d-tiles-2.0/extensions/2.1/Vendor/EXT_crs).

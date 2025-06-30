# 3DTILES_implicit_tiling_custom_template_variables

## Contributors

* Sean Lilley, Cesium

## Status

Draft

## Dependencies

Written against the 3D Tiles 1.1 specification.

## Optional vs. Required

This extension is required, meaning it must be placed in both the `extensionsUsed` and `extensionsRequired` lists in the tileset JSON.

## Overview

This extension allows arbitrary property IDs to be used in implicit tiling [template URIs](https://github.com/CesiumGS/3d-tiles/tree/main/specification/ImplicitTiling#template-uris), e.g.

```json
"content": {
  "uri": "content/{level}/{x}/{y}/{timestamp}/{revision}.glb"
}
```

This is useful for resolving tile content through mechanisms other than just its implicit tile coordinates.

Template variables are substituted with property values in [`tileMetadata`](https://github.com/CesiumGS/3d-tiles/tree/main/specification/ImplicitTiling#tile-metadata) and/or [`contentMetadata`](https://github.com/CesiumGS/3d-tiles/tree/main/specification/ImplicitTiling#content-metadata). The fully resolved values are used, i.e. after [`noData`/`default` substitution](https://github.com/CesiumGS/3d-tiles/blob/main/specification/Metadata/README.adoc#required-properties-no-data-values-and-default-values) and [`normalized`](https://github.com/CesiumGS/3d-tiles/blob/main/specification/Metadata/README.adoc#normalized-values) and [`offset` and `scale`](https://github.com/CesiumGS/3d-tiles/blob/main/specification/Metadata/README.adoc#offset-and-scale) transformations have been applied.

The following restrictions apply:

* The property must be required, i.e. `"required": true`
* The property must not be an array property, i.e. `"array": false`
* The property's `type` must be `SCALAR`, `STRING`, or `ENUM`

For `ENUM` properties, the enum's `name` is used instead of its integer value.

The resolved URI must be a valid [URI](https://github.com/CesiumGS/3d-tiles/tree/main/specification#uris), e.g. string property values cannot have spaces or other restricted characters.

## Built-in variables

The following restriction for [Template URIs](https://github.com/CesiumGS/3d-tiles/blob/main/specification/ImplicitTiling/README.adoc#template-uris) is relaxed:

> Template URIs shall include the variables `{level}`, `{x}`, `{y}`. Template URIs for octrees shall also include `{z}`.

becomes

> Template URIs **may** include the variables `{level}`, `{x}`, `{y}`. Template URIs for octrees **may** also include `{z}`.


Therefore a template URI may contain a mix of built-in and custom variables, e.g.

```json
"content": {
  "uri": "content/{level}/{unique_id}.glb"
}
```

or may contain no built-in variables:

```json
"content": {
  "uri": "content/{unique_id}.glb"
}
```

In case of name collisions, the following precedence order is used:

Precedence|Source
--|--
1|Content property
2|Tile property
3|Implicit tile coordinates

For example, if the the content and tile both have a `level` property, the content property value is used. The implicit tile coordinate level is not used.

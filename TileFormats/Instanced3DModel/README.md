# Instanced 3D Model

## Notes

**Use cases**: Trees, fire hydrants, sewer caps, lamps, traffic lights, etc.

**Format**
* Pointers to one or more internal or external (to share across tiles) glTF models.  More than one model could also be handled with a `Composite` tile, should only that be supported?
* Per-instance properties, e.g., position/translation, scale, rotation, and user-defined properties like `Batched 3D Models`.
* Like `Batched 3D Model`, this needs to support per-instance metadata (and runtime interaction)
* If it makes sense for glTF itself to support instancing, perhaps through an extension, is this tile format needed?

**Cesium implementation**: can prototype something with separate `Model` instances, but it will be slow.  Instead, add support for [ANGLE_instanced_arrays](https://www.khronos.org/registry/webgl/extensions/ANGLE_instanced_arrays/) to the Renderer, and then render glTF models with true instancing.

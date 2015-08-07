# Massive Model

## Notes

**Use cases**: Classic massive model rendering like the Boeing 777.  `Batched 3D Model` is designed for a large number of individual lightweight models.  `Massive Model` would be for one or many heavyweight models composed of millions of triangles.

**Format**
* Metadata (and runtime interaction) for individual models and parts of models, e.g., every bolt on an aircraft.
* Metadata for filling cracks between tiles and morphing (alpha and/or geometric) between LODs.
* May be used in a `Composite` tile, for example, to combine with instancing.
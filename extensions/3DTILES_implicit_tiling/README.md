# 3DTILES_implicit_tiling Extension

## Contributors

## Contents

## Overview

This extension enables 3D Tiles to support streaming tilesets with implied subdivision. When subdivision is implied, it enables simplification at every stage of the tileset's lifetime: querying tree structure from the server, data storage on the client, as well as simplification and optimization of algorithms involved with the structure of the tree such as traversal, visibility, arbitrary selection of tiles in a region, ray casting, analysis, etc. 

## Indexing Scheme

Grid's are indexed from the bottom left, with

## Tree Location

A tile's location in the tree can be defined in terms of the level at which it resides as well as the location within that level. Every level of the three can be through of as a fixed grid of equally sized tiles, where the level occupies the same space as the previous level but with double the amount of tiles along each axis that gets split.

## Root Grid

Each tileset specifies a root grid with dimensions and the locations of all available subtrees.

## Subtree

### Availability

Each subtree defines an index of availability for each level - stored as binary files.


### Metadata

Each
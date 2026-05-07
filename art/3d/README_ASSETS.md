# 3D Asset Pipeline

This folder is the staging area for imported 3D scene assets used by Jing Ke: Fate Rewritten.

## Folder Layout

- `environment/yan_camp/`: Yan camp gates, halls, tents, palisades, terrain dressing.
- `environment/qin_checkpoint/`: Qin checkpoint gates, walls, barricades, mountain props.
- `props/weapons/`: swords, daggers, spear racks, scabbards, weapon display props.
- `props/training/`: training dummies, targets, practice stands, sparring markers.
- `props/camp/`: flags, drums, crates, barrels, braziers, map tables, torches.
- `characters/`: character models and NPC prototypes.
- `materials/`: PBR material sets, HDRI references, shared texture packs.
- `animations/`: imported prototype animation clips and animation notes.

## Preferred Formats

Use formats in this order:

1. `.glb`
2. `.gltf`
3. `.blend`
4. `.fbx`
5. `.obj`

Prefer GLB/GLTF for Godot 4. Static OBJ files are acceptable for props, but avoid OBJ for animated characters.

## Recommended Sources

- Kenney: CC0 game assets.
- Quaternius: CC0 low-poly characters, buildings, nature assets.
- Poly Haven: CC0 HDRIs, PBR textures, and models.
- ambientCG: CC0 PBR materials, HDRIs, and models.
- Mixamo: animation prototyping only. Do not redistribute raw Mixamo assets as a standalone asset pack.
- Sketchfab: only use assets with clear CC0 / CC-BY or otherwise compatible licenses.

## Asset Record Requirement

Every external asset must be recorded before it is used in a scene:

| File | Source URL | Author | License | Download Date | Purpose | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| example.glb | https://example.com | Example Author | CC0 | YYYY-MM-DD | Yan camp prop | Replace placeholder gate |

Do not use assets with unclear copyright, non-commercial-only terms, editorial-only terms, or no redistribution rights.

## Current Replacement Targets

- `REPLACE_ME_GateTower`: replace primitive Yan gate towers with wood/rammed-earth gate models.
- `REPLACE_ME_WarDrum`: replace training war drum primitives.
- `REPLACE_ME_WeaponRack`: replace weapon rack and spear placeholders.
- `REPLACE_ME_Flag`: replace box flags with cloth flag meshes.
- `REPLACE_ME_Tree`: replace box tree placeholders with low-poly trees.
- `REPLACE_ME_Rock`: replace primitive rock clusters.
- `REPLACE_ME_MapTable`: replace map table with a detailed campaign table.

Keep scene nodes named clearly so imported assets can be swapped without breaking gameplay scripts.

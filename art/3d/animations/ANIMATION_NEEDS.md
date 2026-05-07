# Animation Needs

Current imported humanoid clips:

- `human/idle`
- `human/slow_run`
- `human/jump`

Prototype action clips still needed:

- `attack_slash`
- `dagger_stab`
- `dash_forward`
- `assassinate_backstab`
- `hit_react`
- `death`
- `bow`
- `draw_weapon`
- `sheathe_weapon`

Until these clips are imported, `scripts/WeaponActionController.gd` uses fallback Tween motion, slash meshes, ghost markers, floating text, and camera shake.

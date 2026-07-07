# Imported Asset Pack Organization

All assets from the Ninja Adventure Asset Pack (CC0 license) have been imported and organized by category.

## Structure

### Sprites
- **sprites/characters/actors/** — NPC/character variations (animals, people, NPCs)
- **sprites/backgrounds/pack/** — Tilesets, scenery, parallax layers, environment art
- **sprites/items/pack/** — Weapons, pickups, equipment, consumables
- **sprites/effects/pack/** — Visual effects and particle sprites
- **sprites/ui/** — UI elements (hearts, buttons, menus, icons)

Existing project sprites remain in:
- **sprites/characters/** — Player and enemy sprites for the game
- **sprites/tilesets/** — Custom tileset configurations
- **sprites/objects/** — Interactive objects and decorative elements
- **sprites/particles/** — Custom particle system sprites

### Audio
- **audio/pack/Musics/** — Background music tracks
- **audio/pack/Sounds/** — Sound effects
- **audio/pack/Jingles/** — Short notification/transition sounds

## License & Attribution

All assets in this pack are released under **CC0 (Creative Commons Zero)** — public domain.
- Created by [Pixel-boy](https://pixel-boy.itch.io/) and [AAA](https://www.instagram.com/challenger.aaa/?hl=fr)
- Attribution not required but appreciated
- Safe for commercial use

See `ASSET_PACK_LICENSE.txt` and `ASSET_PACK_README.md` for full details.

## Usage Notes

When adding assets to the game:
1. Import sprites/audio into Godot scenes as needed
2. Organize by game feature/level to avoid cluttering the scene tree
3. Already imported UI heart sprites are in use in `scenes/ui/HealthUI.tscn`
4. Feel free to delete unused assets to keep the build lean

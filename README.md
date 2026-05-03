# Frozen Highway Cabin

3D atmospheric truck-cabin prototype.

---

## ENGINE

Godot 4

---

## HOW TO RUN

1. Open Godot 4
2. Import project
3. Open Main.tscn
4. Press Play

---

## CONTROLS

- Mouse - look
- W/S - speed
- A/D - move left/right in cabin
- Shift+W / Shift+S - move forward/back in cabin
- Z/C - lean left/right
- E - interact / inspect
- Hold E - tune radio or cycle heater when prompted
- Esc - pause

Interaction reach is physical. If the reticle is on a dashboard object but the player is too far away, the hint shows `Move closer`. Use cabin movement and lean to reach the radio and heater; the light switch is easier to reach.

---

## CURRENT FEATURES

- first-person cabin
- constrained cabin micro-movement and leaning
- moving road
- cabin interactions with per-object reach distance
- fuel/heat system
- basic events
- atmospheric effects

---

## TESTING NOTES

- Look at the radio or heater from the default seated position and confirm the hint can show `Move closer`.
- Use A/D, Shift+W, and Z/C to move or lean closer, then hold E for about half a second on the radio and heater.
- Confirm the radio cycles through `WEATHER`, `COMPANY`, and `EMERGENCY` messages and the radio button/glow flickers after tuning.
- Confirm the heater cycles `OFF`, `LOW`, and `HIGH`; the heat gauge should trend differently by level, and the heater lever/glow should change.
- Look at the old dashboard photo and press E to show its short inspect line.
- Confirm the light switch can still be toggled with E from an easier reach position.

---

## PROJECT STRUCTURE

res://
  scenes/
  scripts/
  assets/
    art/        # SVG art pack (photos, notes, posters, decals)

---

## ART PACK

Cabin art (photos, notes, posters, stickers, decals) lives as SVG files under
`assets/art/`. `Cabin.gd` loads them in `_apply_art_pack()` and layers them
onto the procedural geometry as `QuadMesh` art and `Decal` nodes — no model
changes. To swap art, drop a replacement SVG with the same filename and reload
the scene.

### Testing the art pass

- Look at the dashboard — the inspectable old photo now shows a painted scene
  with one face scratched out (matches the inspect line).
- Look at the FuelDebtNote, RouteStub, and the hanging dispatch tag — they
  show painted handwritten notes instead of plain Label3D text.
- Look at the folded map on the seat — top face shows a torn road map with
  pencil X marks and margin notes.
- Turn around (rotate camera ~180°) — the bunk wall has a "FROZEN HIGHWAY"
  poster slightly crooked.
- Glance left at the cabin wall — a kid's crayon drawing is taped there.
- Look at the heater — a yellow/black hazard sticker is stuck to it.
- Notice the dashboard top: coffee ring decal and a dirt smudge.
- The floor in front of the seat has a dirt smudge decal.

---

## GOAL

Feel like:

Warm cabin.  
Frozen world outside.

---

## NOT INCLUDED

- no combat
- no inventory
- no full walking (yet)

---

## NEXT

- better interaction feel
- more atmosphere

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

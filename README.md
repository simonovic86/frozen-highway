# Frozen Highway Cabin

A 3D atmospheric truck-cabin prototype built in Godot 4.

The game is about driving through a frozen dystopian highway from inside a warm, dirty truck cabin.

Outside is hostile.  
Inside is home.

## Current Scope

This is an MVP vertical slice.

The player does not leave the truck.

GitHub namespace:

```text
simonovic86/frozen-highway
```

Implemented:
- first-person cabin view
- moving frozen road
- low-poly placeholder cabin, dashboard, windshield, road, snow, and roadside props
- mouse look while seated in the driver position
- dashboard interactions for radio, heater, and cabin lights
- fuel/heat/engine state
- diegetic dashboard gauges
- timed events: radio distress signal, snowstorm, suspicious headlights, abandoned vehicle

## Engine

Godot 4

Language: GDScript

## Controls

- Mouse: look around
- W/S: increase/decrease speed
- E: interact with the dashboard object under the cursor
- R: toggle radio
- H: toggle heater
- L: toggle cabin lights
- Esc: release/capture mouse

## How to Run

1. Install Godot 4.
2. Open the project folder in Godot.
3. Open the main scene.
4. Press Play.

Main scene:

```text
res://scenes/Main.tscn
```

## Project Structure

```text
project.godot
scenes/Main.tscn
scenes/Cabin.tscn
scenes/Road.tscn
scripts/Main.gd
scripts/TruckController.gd
scripts/CabinInteractionSystem.gd
scripts/RoadGenerator.gd
scripts/EventManager.gd
scripts/RadioSystem.gd
scripts/ResourceState.gd
```

## Manual Test Pass

1. Start the project and confirm the mouse is captured in a seated first-person view.
2. Look through the windshield and confirm road segments and snow move toward the truck.
3. Press W/S and confirm the dashboard speed readout changes.
4. Look down at the radio, heater, or overhead light switch and press E, or use R/H/L shortcuts.
5. Watch the gauges move over time as fuel drains, heat changes, and engine condition slowly wears.
6. Wait for timed events: a radio distress message, a snowstorm windshield overlay, suspicious headlights, and an abandoned vehicle.

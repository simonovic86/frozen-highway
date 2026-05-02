# Frozen Highway Cabin - AI Build Prompt

You are a senior game developer and creative director.

Create an MVP prototype of a 3D atmospheric truck-cabin game inspired by gritty European sci-fi trucker worlds.

Do NOT copy any copyrighted characters or IP.

Capture only the mood:
- frozen highways
- lone trucker
- harsh world outside
- warm cabin inside

---

## GAME CONCEPT

The entire game takes place inside a truck cabin.

First-person perspective.

The player is driving through an endless frozen highway.

Outside:
- snow
- darkness
- abandoned vehicles
- strange distant lights
- occasional threats (only visually for now)

Inside:
- warm cabin
- dashboard lights
- radio
- heater
- personal objects

---

## MVP RULE

The player NEVER leaves the truck.

---

## CORE LOOP

- drive forward
- observe road
- manage:
  - fuel
  - heat
  - engine condition
- react to events:
  - radio signals
  - storm
  - strange lights
  - blocked road

---

## TONE

- cozy inside
- brutal outside
- slow
- atmospheric
- not stressful

---

## VISUAL STYLE

3D low-poly or stylized realistic.

Inside:
- warm lighting
- orange/yellow glow

Outside:
- cold blue/white tones
- fog

---

## ENGINE

Godot 4  
Language: GDScript

---

## MVP FEATURES

### Cabin
- first-person seated camera
- look around
- interactable dashboard

### Road
- endless road illusion
- moving segments

### Systems
- fuel drain
- heat system
- engine condition

### Interactions
- radio toggle
- heater toggle
- light toggle

### Events (at least 3)
- radio distress signal
- snowstorm
- suspicious headlights
- abandoned vehicle

---

## UI

Use dashboard gauges instead of HUD where possible.

---

## ARCHITECTURE

Modules:
- TruckController
- CabinInteractionSystem
- RoadGenerator
- EventManager
- RadioSystem
- ResourceState

---

## OUTPUT

- working Godot project
- clean structure
- README
- DESIGN.md

---

## PRIORITY

The feeling:

"I am inside a warm truck, crossing a frozen hell."

This is more important than features.
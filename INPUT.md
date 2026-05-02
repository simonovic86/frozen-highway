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

This is more important than features.# Codex Execution Rules

## Main Rule

Build a runnable prototype first.

Do not overthink. Do not overbuild. Do not turn this into a giant game architecture project.

The goal is a small playable vertical slice.

## Repository Rules

1. First inspect the repository.
2. Detect whether it is empty or already has a Godot project.
3. If empty, create a minimal Godot 4 project structure.
4. If existing, preserve existing structure unless there is a clear reason to change it.
5. Do not delete existing user files without explicit reason.
6. Keep every major step runnable.

## Implementation Order

Implement in this order:

1. Godot project setup
2. main scene
3. truck cabin scene
4. first-person seated camera
5. look-around controls
6. road visible through windshield
7. moving road illusion
8. snow/fog atmosphere
9. dashboard objects
10. basic interactions:
    - radio
    - heater
    - lights
11. resource state:
    - fuel
    - heat
    - engine condition
12. simple diegetic gauges
13. radio event
14. snowstorm event
15. suspicious headlights event
16. README
17. DESIGN.md

## Scope Limits

Do NOT implement yet:
- leaving the truck
- walking outside
- combat
- inventory
- complex quests
- save/load
- complex NPCs
- real asset pipeline
- multiplayer
- procedural world simulation

## Asset Rules

Use placeholder assets:
- cubes
- planes
- cylinders
- simple materials
- basic lights
- simple particles if easy

Do not generate huge binary assets.

Do not depend on external paid assets.

## Coding Rules

Use Godot 4 and GDScript.

Keep scripts modular and readable.

Prefer simple systems over clever abstractions.

Add comments only where they explain intent or architecture.

Avoid massive scripts.

## Validation

At the end:
- confirm project structure
- confirm main scene path
- confirm scripts compile as much as possible
- document what can be tested manually in Godot

Do not ask questions unless truly blocked.

Make reasonable creative decisions and document them.# Frozen Highway Cabin Game - Design Document

## Working Title

Frozen Highway Cabin

## One-line Pitch

A first-person atmospheric truck-cabin game where the player drives through a frozen dystopian highway while managing warmth, fuel, radio signals, and the fragile comfort of the cabin.

## Core Fantasy

You are inside a warm, dirty truck cabin.

Outside is frozen hell.

The truck is not just a vehicle.  
It is home.

## Inspiration

The game is inspired by gritty European sci-fi trucker comics and frozen post-apocalyptic road fiction.

Important: the game should not copy existing characters, names, stories, logos, or exact designs.

We only want the mood:
- huge roads
- lone trucker
- brutal cold
- strange encounters
- rough humor
- dirty machinery
- warmth inside danger

## Perspective

First-person 3D.

The player sits in the driver seat.

The player can:
- look around
- interact with cabin objects
- watch the road through the windshield
- listen to radio transmissions
- manage simple truck systems

The player does not leave the truck in the MVP.

## Emotional Pillars

### 1. Cozy Isolation

The cabin should feel warm, personal, and safe.

The world outside should feel hostile and huge.

### 2. Slow Tension

The game should have danger, but not constant panic.

The player should feel pressure from the environment, not from twitch combat.

### 3. Road Hypnosis

The road, snow, engine noise, and radio static should create a hypnotic mood.

### 4. Lived-in Machine

The truck should feel old, patched, personal, and heavily used.

## MVP Scope

The MVP is a vertical slice, not a full game.

The player should be able to:
- sit in the cabin
- look around
- see the endless frozen road
- toggle radio
- toggle heater
- toggle cabin lights
- watch basic gauges
- experience random events

## MVP Systems

### TruckController

Responsible for:
- driving state
- speed
- fuel drain
- engine condition
- forwarding state to UI/gauges

### CabinInteractionSystem

Responsible for:
- detecting interactable objects
- showing simple interaction hints
- calling object actions

Interactable objects:
- radio
- heater
- light switch

### RoadGenerator

Responsible for:
- endless road illusion
- moving road segments
- spawning simple roadside props
- maintaining frozen highway atmosphere

### EventManager

Responsible for:
- triggering random road events
- timing events
- avoiding too many events too quickly

Initial events:
- radio distress signal
- snowstorm
- suspicious headlights behind the truck
- abandoned vehicle on road

### RadioSystem

Responsible for:
- radio on/off state
- static messages
- event-based transmissions
- atmospheric text/audio placeholders

### ResourceState

Responsible for:
- fuel
- cabin heat
- engine condition

Resources should change slowly.

The goal is mood, not hardcore survival.

## Visual Direction

### Inside Cabin

Warm palette:
- amber dashboard lights
- dirty orange glow
- old plastic
- worn metal
- scratched glass
- soft cabin light

Objects:
- steering wheel
- dashboard
- gauges
- radio
- heater controls
- cup/can
- hanging charm
- old photo
- sleeping blanket or jacket

### Outside

Cold palette:
- blue
- grey
- white
- black silhouettes

Environment:
- snow
- fog
- empty highway
- road signs
- abandoned vehicles
- distant towers
- occasional lights

## Audio Direction

Use placeholders if real audio is not available.

Suggested layers:
- engine rumble
- wind outside
- snowstorm intensity
- cabin hum
- radio static
- distorted voice transmissions
- button clicks

## Controls

Suggested controls:

- Mouse: look around
- W/S: increase/decrease speed or throttle
- E: interact
- R: toggle radio
- H: toggle heater
- L: toggle cabin lights
- Esc: release mouse / pause

## UI Direction

Prefer diegetic UI.

This means:
- fuel displayed as dashboard gauge
- heat displayed as dashboard gauge
- engine condition as warning light

Avoid big floating HUD unless needed for debugging.

Debug HUD is acceptable in MVP.

## First Playable Moment

The first playable moment should be:

The player starts seated in the cabin.

The engine is already running.

Snow hits the windshield.

The dashboard glows.

The road moves forward.

The radio crackles.

The player turns the heater on.

A weak transmission appears:

“...anyone on Route 9... do not stop near the black lights...”

That is enough.

## Future Roadmap

### Phase 1 - Current MVP

- cabin
- road
- basic interactions
- simple systems
- random events

### Phase 2 - Better Atmosphere

- better cabin model
- windshield effects
- real sound layers
- more radio messages
- better lighting

### Phase 3 - Journey Structure

- route map
- checkpoints
- fuel stops
- risk/reward choices

### Phase 4 - Characters

- passenger events
- conversations
- temporary guests in cabin
- moral choices

### Phase 5 - Deeper Systems

- repairs
- cargo
- reputation
- faction radio channels
- weather regions

## Design Warning

Do not let the game become generic survival crafting.

The game is not about collecting 50 items.

The game is about the feeling of surviving the road from inside a warm metal box.# Tasks

## SETUP
- [ ] create Godot project
- [ ] create folders

## SCENE
- [ ] main scene
- [ ] cabin scene
- [ ] road scene

## CAMERA
- [ ] first-person
- [ ] mouse look

## ROAD
- [ ] moving road
- [ ] snow/fog

## CABIN
- [ ] dashboard
- [ ] radio
- [ ] heater
- [ ] lights

## SYSTEMS
- [ ] fuel
- [ ] heat
- [ ] engine

## INTERACTION
- [ ] interact system

## EVENTS
- [ ] radio signal
- [ ] storm
- [ ] headlights
- [ ] abandoned vehicle

## UI
- [ ] gauges

## DOCS
- [ ] README
- [ ] DESIGNRead all documents.

Then:

1. Inspect repository
2. Create Godot 4 project if needed
3. Build first vertical slice

Important:

- stay inside truck
- no combat
- no inventory
- use placeholder geometry
- keep it simple

Start with:
- scene
- camera
- road

Then continue step by step.

At the end:
- update docs
- mark tasks
- explain how to run
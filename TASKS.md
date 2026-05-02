# Tasks

## SETUP
- [x] create Godot project
- [x] create folders

## SCENE
- [x] main scene
- [x] cabin scene
- [x] road scene

## CAMERA
- [x] first-person
- [x] mouse look

## ROAD
- [x] moving road
- [x] snow/fog

## CABIN
- [x] dashboard
- [x] radio
- [x] heater
- [x] lights

## SYSTEMS
- [x] fuel
- [x] heat
- [x] engine

## INTERACTION
- [x] interact system

## EVENTS
- [x] radio signal
- [x] storm
- [x] headlights
- [x] abandoned vehicle

## UI
- [x] gauges

## MOVEMENT UPGRADE

- [x] Add micro-movement inside cabin (left/right/forward/back)
- [x] Clamp movement to driver area
- [x] Add leaning (left/right)
- [x] Preserve existing interaction system
- [x] Update controls in README

## DOCS
- [x] README
- [x] DESIGN

## VALIDATION
- [x] Godot 4.6 metadata updated
- [x] headless runtime check
- [x] visual smoke test
- [x] basic gameplay smoke test
- [x] cabin visual polish after test

## ATMOSPHERE PASS
- [x] subtle seated cabin motion
- [x] swinging hanging charm
- [x] storm windshield wipers
- [x] docs updated for atmosphere pass

## RUN CHECK - 2026-05-03
- [x] launch Godot 4.6 project
- [x] confirm main scene starts
- [x] confirm no startup runtime errors

## NEXT PASS - 2026-05-03
- [x] Esc pause overlay
- [x] procedural cabin audio placeholders

## STYLE TASKS

- [x] Add cabin props that reflect long-term living (junk, tools, personal items)
- [x] Replace clean materials with worn/dirty materials
- [x] Add subtle asymmetry and imperfection to cabin geometry
- [x] Add at least one "improvised fix" visual (tape, patch, exposed wire)
- [x] Add ambient storytelling element (photo, note, object with history)

## ATMOSPHERE TASKS

- [x] Add distant moving lights outside (other trucks or unknown sources)
- [x] Add abandoned vehicle silhouette on roadside
- [x] Add occasional flicker or instability in cabin lighting
- [x] Add radio message with dark or cynical tone

## ATMOSPHERE PASS 001 - 2026-05-03

- [x] Warm cabin lighting pass
- [x] Cold outside fog and heavier snow pass
- [x] Dashboard glow pass
- [x] Windshield frost, grime, and snow pass
- [x] Radio crackle and disturbing 10-second opening message
- [x] Distant lights reveal during opening minute
- [x] One-shot cabin light flicker during opening minute
- [x] Delay regular road event loop until after opening beats
- [x] Add extra lived-in cabin paperwork and mess
- [x] DESIGN updated for Atmosphere Pass 001

## REACH INTERACTION PASS

- [x] Add max interaction distance per interactable
- [x] Show “Move closer” hint when looking at object from too far
- [x] Require player to lean/reposition for radio and heater
- [x] Keep E as interact
- [x] Update README controls/testing notes

## OBJECT ACTION PASS

- [x] Add hold-to-interact for heater/radio
- [x] Add simple button/lever visual feedback
- [x] Add radio tuning action with 2-3 stations/messages
- [x] Add heater level: off / low / high
- [x] Add one non-critical inspectable object: photo or note
- [x] Update README testing notes

## PRESSURE + CONSEQUENCE PASS

- [x] Add fuel drain over time (already exists → tune it)
- [x] Add low fuel threshold (e.g. < 20%)
- [x] When fuel is low:
  - dashboard warning changes (color, blinking)
  - cabin light slightly unstable
- [x] Add engine condition decay when pushing speed
- [x] Add visual feedback when engine is bad:
  - stronger shake
  - slight camera jitter
- [x] Add “almost failure” state:
  - engine struggles (no full stop yet)
- [x] Add recovery possibility:
  - slowing down improves engine

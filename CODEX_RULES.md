# Codex Execution Rules

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

Make reasonable creative decisions and document them.
# Academic Diagram Style Guide

This guide records the shared visual style used by the thesis draw.io diagrams in this folder.

## Overall Style

- Use a restrained, low-saturation academic palette suitable for papers and slides.
- Use color to separate functional modules, not as decoration.
- Keep diagrams sparse, readable in print, and consistent with a technical hardware/algorithm figure style.
- Avoid gradients, drop shadows, icons, highly saturated fills, and decorative effects.
- Prefer Times New Roman and simple geometric shapes.

## Current Draw.io Files

| File | Style role |
| --- | --- |
| `float_cpp_rtl_flow.drawio` | Minimal vertical process flow, mostly blue. |
| `quantization_flow.drawio` | Multi-stage process flow with muted blue, beige, green, and purple modules. |
| `ping_pong_scale_alignment.drawio` | System/block diagram with module colors, bank grouping, muxes, and signal arrows. |
| `fixed_point_vector_lane.drawio` | Datapath diagram with muxes, arithmetic blocks, control labels, and heavier signal arrows. |
| `trial_quotient_flow.drawio` | Algorithm flowchart using the same muted module palette. |

## Color Palette

Use these colors consistently by semantic role.

| Purpose | Fill | Stroke | Text |
| --- | --- | --- | --- |
| Primary data / storage | `#EAF2FF`, `#DAE8FC`, `#EEF4F8` | `#2F5597`, `#6C8EBF`, `#456B83` | `#17365D`, `#1F3D4D` |
| Neutral process | `#F7FBFF`, `#FFFFFF` | `#2F5597`, `#B8C7DC` | `#17365D` |
| Control / select / decision | `#F3F0E8` | `#8A7652` | `#463B27` |
| Scale / valid path / active transform | `#EDF3ED`, `#D5E8D4` | `#5F7F5F`, `#82B366` | `#2F4B2F` |
| Alternate path / pong / wrap | `#F1EDF5` | `#74628A` | `#3F314F` |
| General text and signal labels | none | none | `#1F2933` |
| Main signal arrows in block diagrams | none | `#111111` | `#1F2933` |
| Secondary/control arrows | none | `#5F6570` | `#1F2933` |

Do not introduce new colors unless a new semantic role is needed.

## Typography

- Font family: `Times New Roman`.
- Flowchart node title: 18 pt, bold.
- Flowchart node subtitle: 16 pt, normal.
- Block diagram module text: 15-16 pt.
- Small labels and internal bank rows: 12-14 pt.
- Figure title, when used: 22 pt, bold, deep navy (`#17365D`).
- Keep labels short and technical. Use line breaks instead of long sentences.

## Shapes

- Process step: rounded rectangle, `rounded=1`.
- Decision: rhombus, used sparingly for true branches.
- Mux/select: trapezoid, often rotated, beige or green depending on role.
- Arithmetic operator: ellipse/circle.
- Comparator: hexagon or rhombus depending on whether the diagram is a datapath or algorithm flow.
- Storage/bank group: rounded rectangle with internal rows; use blue/purple variants for ping/pong or parallel banks.
- Group boundary: dashed rounded rectangle with a pale fill when helpful.

## Lines and Arrows

- Flowchart connectors: 1.5 pt, filled block arrow, usually `#2F5597` or neutral gray `#5F6570`.
- Algorithm branch connectors may inherit branch color, such as green for `yes` and purple for `no`.
- Datapath arrows: black `#111111`, 2.0-3.0 pt for main data paths.
- Control arrows: gray `#5F6570`, about 1.2-1.6 pt.
- Use orthogonal or straight connectors. Keep bends deliberate and aligned.
- Keep edge labels small, Times New Roman, and close to the line they describe.

## Layout

- Use vertical flow for algorithm or implementation pipelines when space allows.
- Use left-to-right layout for hardware/datapath diagrams.
- Align repeated nodes to a common axis or grid.
- Keep module spacing regular and leave enough margin for insertion into slides or paper figures.
- Do not overcrowd diagrams; split complex behavior into a separate draw.io if needed.

## Practical Rules

- Use color to encode module/function groups consistently within a diagram.
- Keep the number of semantic colors per diagram small, usually three to five.
- Do not use color as the only explanation; labels should remain clear in grayscale print.
- Prefer existing module colors from nearby diagrams over inventing new variants.
- Export SVGs from draw.io after final edits when the figure is ready for slides or the thesis.

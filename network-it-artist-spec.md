# Network, IT (Remix) - Art & Asset Technical Specification

## 1. Project Overview
**Game Title:** Network, IT (Remix)
**Genre:** Real-Time Strategy / Puzzle
**Platform:** Web (React/Three.js)
**Concept:** Players manage a broadcast network on a floating geodesic balloon station in a stormy, retro-futuristic sky. The goal is to build transmitters, connect them with wires to a central tower, and maintain the signal against "shorts" and environmental hazards.

## 2. Visual Direction & Aesthetic
**Core Theme:** Dark Steampunk, Vintage Sci-Fi, "Aetherpunk".
**Inspiration:** 
-   *Reference:* Please see the attached concept image (Dashboard/Balloon view).
-   *Mood:* Moody, atmospheric, industrial but elegant.
-   *Materials:* Brass, copper, weathered steel, canvas, glowing vacuum tubes, electricity.
-   *Environment:* Stormy skies, heavy clouds, dramatic lighting (chiaroscuro).

## 3. Gameplay Context
The game takes place on a 3D sphere (the Balloon). The surface is divided into a hexagonal grid.
-   **The Balloon:** A large, floating geodesic structure.
-   **The Grid:** Players place items on hexagonal tiles.
-   **The Network:** "Transmitters" (towers) must be connected via "Wires" to the "Main Tower".
-   **Hazards:** "Shorts" (electrical failures) spread through wires like a virus/fire.

## 4. Asset Requirements

### A. Environment & Background
1.  **Skybox / Background Layer**:
    -   **Description:** High-quality, painterly clouds. Dark, stormy atmosphere.
    -   **Format:** High-res JPG/PNG (1920x1080 min, or seamless tileable clouds).
    -   **Style:** Oil painting style, dramatic lighting.
2.  **The Balloon Surface (Sphere Texture)**:
    -   **Description:** Texture for the geodesic sphere. Should look like panels of metal or heavy canvas riveted together.
    -   **Format:** Seamless Texture (2048x2048 PNG).
    -   **Details:** Hexagonal pattern overlay (optional, can be done in code, but base texture should imply structure).

### B. Game Units & Infrastructure (Sprites or 3D Concepts)
*Note: We can use 2D sprites facing the camera (billboards) or 3D models. Please provide 2D assets first, with side/iso views.*

1.  **Main Tower (The Hub)**:
    -   **Description:** The central command spire. Large, imposing, intricate machinery.
    -   **Size:** Large (occupies 1 hex but feels taller/bigger).
2.  **Transmitter (Unit)**:
    -   **Description:** A standard radio broadcast tower.
    -   **States:**
        -   *Inactive:* Dark, silhouette.
        -   *Active/Connected:* Glowing lights, vacuum tubes lit up.
        -   *Shorted/Broken:* Sparking, dark, smoking.
3.  **Wire (Connection)**:
    -   **Description:** Cables stringing between hexes.
    -   **Style:** Insulated copper wires or glowing energy cables.
    -   **States:**
        -   *Normal:* Copper/Dark.
        -   *Active:* Glowing (Green/Gold).
        -   *Shorted:* Arcing electricity (Blue/White).
4.  **Pylons/Poles (Optional)**:
    -   **Description:** Small support poles for long wire runs.

### C. UI / HUD Assets
*The UI should feel like a physical dashboard on an airship.*

1.  **Card Frames (Hexagonal)**:
    -   **Description:** Frames for the action buttons (Wire, Reconnect, Transmitter, Reset).
    -   **Style:** Brass/Metal rims, glass interior.
    -   **States:** Default, Hover (Glow), Selected (Bright), Disabled (Greyed out).
2.  **Icons**:
    -   **Wire:** A spool of wire or a connector.
    -   **Reconnect:** A wrench or spark plug.
    -   **Transmitter:** A radio tower symbol.
    -   **System Reset:** A refresh/cycle symbol (industrial style).
3.  **Dashboard Panels**:
    -   **Top Bar:** Frame for "Required Transmitters", "Time", etc. Dark metal with gold text areas.
    -   **Side Panel (Guide):** A frame that looks like a clipboard or a screen readout.
    -   **Bottom Bar:** Container for the hexagonal cards.
4.  **Buttons**:
    -   "Pause Broadcast", "Restart Broadcast", "Exit to Lobby".
    -   Style: Rectangular, mechanical press-buttons.

### D. Visual Effects (VFX) Elements
1.  **Sparks / Electricity**: Sprite sheet or single particles for "Shorts".
2.  **Smoke**: For damaged units.
3.  **Glows**: Soft radial glows for active lights (PNG with transparency).

## 5. Deliverables & Technical Format
-   **File Types:** 
    -   UI Elements: PNG (Transparent background) or SVG.
    -   Game Units: PNG (High res, e.g., 512x512 per unit).
    -   Textures: PNG/JPG.
-   **Resolution:** 
    -   Targeting 1080p and 4k displays. Assets should be created at 2x scale.
-   **Naming Convention:** `category_item_state.png` (e.g., `ui_card_wire_active.png`, `unit_transmitter_broken.png`).

## 6. Implementation Notes for Developer
-   The "Balloon" will be a Three.js SphereGeometry.
-   Hexes are mapped to the sphere.
-   Units will be placed on the surface (using surface normals to orient).
-   UI will be an HTML/CSS overlay on top of the canvas.

# Oops Games

## Session Start Protocol

**Every session. No exceptions. This is your memory.**

1. **Read this file completely** before taking any action
2. **Search Learning Log** before implementing any feature (see Search Triggers below)
3. **Verify app runs** before making changes

---

## User Preferences

| Setting | Value |
|---------|-------|
| **Role** | AI Development Partner |
| **Communication** | Extremely direct, no sugar-coating |
| **Quality** | AAA+ non-negotiable |
| **Decision Authority** | User is vision partner; I make all technical decisions |
| **Newsletter Tone** | Friendly, lighthearted, self-deprecating. Sign off: "Keep burning those digits. Kate and Andy" |

---

## Documentation Index

**This is the master document.** All other docs are referenced from here.

### Core Documents
| Document | Location | Purpose | When to Use |
|----------|----------|---------|-------------|
| **replit.md** | Root | Master index, session protocol, search triggers | Every session start |
| **CORE_OPERATING_CONTRACT.md** | docs/ | 15 non-negotiable rules | Before any code change |
| **LEARNING_LOG.md** | docs/ | Patterns, protocols, lessons learned | Before implementing features (search first!) |
| **LEARNING_LOG_2.md** | docs/ | Overflow lessons (older entries) | If LEARNING_LOG.md search returns nothing |
| **README.md** | Root | Public project overview | External documentation |

### Style & Architecture Guides
| Document | Location | Purpose | When to Use |
|----------|----------|---------|-------------|
| **CODING_STYLEGUIDE.md** | Root | Code conventions, naming, patterns | When writing/reviewing code |
| **ARCHITECTURE.md** | Root | System architecture, data flow | When modifying core systems |
| **UI_UX_WORKFLOW.md** | Root | 3-phase UI development workflow | When building UI components |
| **GAME_VISUAL_ARCHITECTURE.md** | docs/ | 6-pillar visual standards | When building game visuals |
| **SPRITE_GENERATION_GUIDE.md** | docs/ | Sprite creation workflow | When generating sprites |
| **SOUND_SYSTEM.md** | Root | Audio architecture, sound management | When adding sounds/music |

### Verification & Testing
| Document | Location | Purpose | When to Use |
|----------|----------|---------|-------------|
| **VISUAL_VERIFICATION_CHECKLIST.md** | docs/ | Visual QA checklist | Before presenting visuals |
| **PLATFORM_VERIFICATION_CHECKLIST.md** | Root | Cross-system verification | Before major releases |
| **GAME_VERIFICATION_TEMPLATE.md** | Root | Per-game testing template | When adding/updating games |
| **TESTING.md** | Root | Testing strategy and setup | When writing tests |

### Collaboration & Integration
| Document | Location | Purpose | When to Use |
|----------|----------|---------|-------------|
| **KATE_INTEGRATION_GUIDE.md** | Root | Parallel development with Kate | When Kate contributes |
| **MERGE_CHECKLIST.md** | Root | Branch merge procedures | Before merging branches |
| **PAYMENT_INTEGRATION_CHECKLIST.md** | Root | Payment service integration | When adding payments |
| **DEVTOOLS_SNIPPETS.md** | docs/ | Debug code snippets | When debugging |

---

## Documentation Management

### Structure Rules
1. **replit.md** is the ONLY entry point - all docs must be referenced here
2. **No duplicate content** - information lives in ONE place only
3. **Learning Log is append-only** - never delete entries, only add new ones
4. **Checklists live in root** - for easy access during verification

### How to Add New Documentation

**New Learning/Pattern:**
```bash
# Add to docs/LEARNING_LOG.md at the TOP (newest first)
## YYYY-MM-DD - [Descriptive Title]
**Context**: [What situation triggered this]
**Problem**: [What went wrong]
**Solution**: [How to fix it]
**Trigger Keywords**: [search terms for future lookup]
```

**New Game:**
1. Add to Games Catalog section in this file
2. Update README.md game list
3. Create game-specific verification checklist if needed

**New Protocol/Checklist:**
1. Create file in root (if checklist) or docs/ (if protocol)
2. Add entry to Documentation Index table above
3. Add search trigger to Pre-Task Search Triggers if applicable

### Keeping Documentation Clean

**Monthly Maintenance:**
- Review LEARNING_LOG.md for duplicate entries
- Verify all Documentation Index links work
- Archive resolved/obsolete patterns to LEARNING_LOG_2.md

**After Major Features:**
- Document any new patterns in LEARNING_LOG.md
- Update relevant checklists
- Verify this file's accuracy

### Critical Rule: Verify Against Source Code

**Documentation MUST match source code. When in doubt, check the code.**

| Data | Source of Truth |
|------|-----------------|
| Game tiers/modes | `client/src/lib/utils/subscription.ts` |
| Game list | `client/src/App.tsx` routes |
| Tech stack | `package.json` |
| API endpoints | `server/routes.ts` |

**Before updating Games Catalog or system info:**
1. Search the codebase for current values
2. Copy data from source files, don't rely on memory
3. Include "Source of truth" reference in documentation

**If documentation and code conflict → Code is correct, update documentation.**

---

## Core Rules Summary

**15 rules live in `docs/CORE_OPERATING_CONTRACT.md`** - read before any code change.

| # | Rule | Key Point |
|---|------|-----------|
| 1 | Simplicity First | What's the simplest solution? |
| 2 | Right Abstraction | Wrong mental model = clunky code |
| 2.5 | Scene-First Design | Design the PLACE, then build elements that BELONG |
| 3 | Log Every Lesson | After debugging → update Learning Log |
| 4 | Two-Strike Debugging | 2 failed attempts → STOP → architect |
| 5 | Verify Before Building | App must run before adding features |
| 6 | Architect Review | Always before marking complete |
| 7 | Root Cause Over Symptoms | No patches/hacks |
| 8 | Trace Math First | Concrete numbers before code |
| 9 | Listen First | Read entire message before responding |
| 10 | No Mock Data | Real integrations only |
| 11 | Protected Behaviors | List what must NOT break before changing |
| 12 | Incremental Validation | ONE change at a time |
| 13 | Revert-First Recovery | When broken, revert FIRST |
| 14 | Functional-First Visuals | Every visual must serve gameplay |
| 15 | Consult Past Solutions | Search Learning Log BEFORE implementing |

---

## Pre-Task Search Triggers

**MANDATORY: Before implementing ANY feature, search the Learning Log.**

```bash
grep -i "keyword" docs/LEARNING_LOG.md
```

| If task involves... | Search for... |
|---------------------|---------------|
| Rack IT / Isometric games | "PixiJS" + "Isometric" + "Depth Sorting" |
| Sound, audio, music | "Audio" + "Autoplay" |
| Sprite generation | "Sprite Generation" |
| New game to platform | "Game Integration" |
| 3D object visibility | "Visual Verification" |
| UI layout, backgrounds | "UI/UX" |
| setTimeout in useEffect | "useEffect Cleanup" |
| Adding polish/effects | "Visual Clutter" |
| Isometric rotation | "Isometric Object Rotation" |
| Moving objects + rotation | "Rotation Synchronization" |
| Debugging (2+ attempts) | "Two-Strike" |
| PixiJS performance | "PixiJS Static vs Dynamic" |
| Remix of existing game | "Remix Play-Parity Protocol" (this file) |

**No match?** Search for the most relevant keyword anyway. Also check `docs/LEARNING_LOG_2.md`.

---

## System Architecture

**Tech Stack**: React 18, Express.js, TypeScript, Vite, Tailwind CSS, Radix UI, Drizzle ORM, WebSockets, Zustand, Redux Toolkit, @tanstack/react-query

**Game Frameworks**: 
- 3D: THREE.js / React Three Fiber (R3F)
- 2D: PixiJS / Plain Canvas

**Performance Standards**:
- Load times: < 3 seconds
- Draw calls: < 300
- Frame rate: 60 FPS consistent
- Art styles: LOW_POLY_3D, CEL_SHADED, CARTOON_3D, FLAT_ART (no realism)

**Core Platform Systems**:

| System | Location |
|--------|----------|
| Subscription Tiers | `client/src/lib/utils/subscription.ts` |
| Sound Manager | `client/src/lib/stores/useSoundManager.tsx` |
| Analytics | `client/src/lib/hooks/useAnalytics.ts` |
| WebSocket Service | `client/src/lib/services/gameWebSocket.ts` |
| Navigation Helpers | `client/src/lib/utils/navigationHelpers.ts` |

---

## Games Catalog

**Source of truth**: `client/src/lib/utils/subscription.ts` (GAME_MODE_TIERS)

| Game | Type | Modes & Tiers | Description |
|------|------|---------------|-------------|
| **Manage, IT** | Card/Multiplayer | Tutorial (Free), Demo (Free), Multiplayer (Silver) | 2v2 incident resolution |
| **Network, IT** | Strategy | Demo (Free), Classic (Silver), Floodland (Gold) | Hex-grid network building |
| **Network, IT Remix** | Strategy | Remix (Free) | Enhanced visual version |
| **Phone, IT** | Puzzle | Demo (Free), Classic (Silver), Timer (Gold), Points (Gold) | Hexagonal wire connection |
| **mumble, IT** | Comedy/Card | Demo (Free), Classic (Silver) | Passive-aggressive office management |
| **Cache, IT** | Roguelike | Play Now (Free) | Memory hierarchy dungeon crawler |
| **EOFH, IT** | RPG | Play Now (Platinum) | Data center chaos comedy |
| **Farm, IT** | Idle | Start Farming (Free) | Server farming simulator |
| **Sprint, IT** | Platformer | Play Now (Free) | 2D barrel-dodging racer |
| **bit, IT** | Tunnel Racer | Demo (Free), Full Game (Silver), Long Form (Gold) | 3D binary collection |
| **bit, IT Remix** | Tunnel Racer | Remix (Free) | Enhanced visual version |
| **Rack, IT** | Tower Defense | Play (Platinum) | Isometric procedural terrain |

**Subscription Tiers**: Free → Silver → Gold → Platinum

**Platinum Games**: EOFH IT, Rack IT

---

## Critical Learnings (Quick Reference)

These are the most important patterns. Full details in Learning Log.

### Browser Autoplay Policy
Audio MUST start in click handler, NOT useEffect:
```tsx
// ✅ CORRECT
const handleStart = () => {
  startBackgroundMusic(); // In click handler
  setGameStarted(true);
};

// ❌ WRONG
useEffect(() => {
  if (gameStarted) startBackgroundMusic(); // Browser blocks this
}, [gameStarted]);
```

### Remix Play-Parity Protocol
When building visual-only remixes:
- ✅ ALLOWED: Materials, colors, models, shaders, camera
- ❌ FORBIDDEN: Game logic, timers, spawn rates, UI behavior
- Architecture: Remix imports original game's state/logic, only rendering is new

### R3F Performance Rules
- ZERO allocations in useFrame (no `new`, `clone()`, `map()`, `filter()`)
- ONE central useFrame in DecorationController
- Pre-allocate scratch vectors via useMemo

### Isometric Rendering (PixiJS)
- All 3D objects: Draw with `poly()` using rotated corners
- Never use container rotation for isometric objects
- Use `showFrontRight/showFrontLeft/etc.` for face visibility
- Store positions in GRID space, project to screen at render time

---

## External Dependencies

| Service | Details |
|---------|---------|
| Analytics | Google Analytics (G-C9852KCDZP) |
| Profanity Filter | `leo-profanity` library |
| Newsletter | `server/services/newsletterService.ts` |
| Image Processing | `@imgly/background-removal-node` |

---

## Git Branching

| Branch | Purpose |
|--------|---------|
| `main` | All AI agent work |
| `kate` | Kate's contributions (never merge automatically) |

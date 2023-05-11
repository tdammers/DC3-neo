# DC-3 neo

Douglas DC-3 for FlightGear.

Work in progress.

**This is by no means ready for anything other than early development; use at
your own risk.**

## Introduction

The DC-3 is arguably one of the most influential transport aircraft in history.
Designed in 1935 as a larger version of the DC-2, it quickly took the young
airline industry by storm, and became part of the logistical backbone of the
allied forces in WWII as the C-47, with over 16,000 airframes built in total,
the bulk of those military.

Today, some 90 years after its maiden flight, the type is still used in cargo
service in some remote areas, and remains popular for its ruggedness,
relatively low operating costs, and the ability to operate on small grass
and dirt strips.

## Goals

A detailed, faithful model of the legendary DC-3.

Specifically, we will initially focus on the DC-3A / DC-3C, equipped with 1200
HP Pratt & Whitney R-1830-94 "Twin Wasp" engines (a.k.a. R-1830-S1C3G). Adding
the 1200 HP Wright R-1820 "Cyclone" might be considered in the future.

Concrete goals:

- An accurate JSBSim FDM
- Detailed engine model, with realistic startup and performance
- Detailed systems (hydraulics, electrical, fuel, etc.)
- Choice of (at least) two panels: a "classic" panel, as used in the original
  production series, featuring 1940s steam gauges, a Sperry autopilot unit, and
  conventional navigation equipment only (VOR, ADF, transponder, VHF radios); and a
  "modern" panel, suitable for IFR in modern airspaces, featuring ~1980s steam
  gauges, a Century 41 autopilot, a full set of conventional navigation
  equipment (2 VOR/ILS, 2 ADF, transponder, 2 VHF radios) and a simple but
  RNAV-certified GPS unit (Garmin GPS155TSO).
- Passenger and cargo configurations (the real aircraft can be converted
  relatively quickly).

Wildly ambitious stretch goals:

- Retrofit glass avionics
- BT-67 turboprop (P&W PT6A-67R) conversion

Will probably not do:

- Paratroopers

## Sources & references

- [Quebecair DC-3 Manual](https://pcmuseum.tripod.com/dc3/index.html)
- [Wikipedia](https://en.wikipedia.org/wiki/Douglas_DC-3)
- [Century 41 Autopilot
  Manual](https://www.centuryflight.com/images/operating-manuals/CENT41.pdf)
- [Sperry Autopilot components and
  documentation](https://cdn.shopify.com/s/files/1/1343/9895/files/10_Autopilots_etc..pdf)

## Status & Roadmap

### 3D

Starting out with Helijah's model and some instruments from fgdata; to be
either refined or replaced eventually.

Some mild improvements have been made to the exterior model:

- A higher-resolution version of the bumpmap
- Tweaked materials, effects & shaders to look better with ALS

To do:

- Improve interior, especially the flight deck.
- Redo UV mapping
- Add more details on exterior model (e.g. door hinges)
- Reinstate liveries
- Figure out HDR vs. ALS (automatic selection)
- PBR liveries (with metalness & roughness textures etc.)

### FDM

- Aerodynamics: generated a crude starting point with Aeromatic++, and tweaked
  it to fly realistically and match performance specs. Effects currently
  modeled:
  - Adverse yaw
  - Propwash
  - Backfiring torque effects
  - Cowl flap drag
  - Flaps
  - Landing gear drag
  Not modeled yet (but planned at some point):
  - Stall hysteresis
  - Reduced rudder authority at high AoA due to fuselage wake
  - Ground effect
  - Pitch moment due to landing gear drag
  - Wing icing
- Landing gear:
  - positions are correct
  - tail wheel lock behaves realistically (in the "locked" lever position, the
    TW will lock once it moves into or through a centered position, but will
    remain free-castering until then)
  - Overall ground interactions seem plausible, ground handling matches
    descriptions (easy to taxi, differential thrust needed in crosswind
    conditions), and unlike the YASim FDM, this one can be taxied safely and
    comfortably up to about 30 knots straight, and 12-15 knots in sharp turns,
    without ground-looping or nosing over.
- Engines: partially done. We're making the entire engine model from scratch,
  using the "electric" engine model from JSBSim as a neutral powerplant with
  linear power response to throttle input. This way, we can model fuel flow,
  firing behavior, backfiring, altitude effects, blower, mixture, etc.
  ourselves. Currently simulated:
  - Startup sequence (including meshing and priming)
  - Magnetos
  - CHT
  - backfiring due to cold engine
  - backfiring due to overpriming
  - MP (including blower, density altitude, throttle)
  - Prop governor / RPM levers
  Not simulated yet:
  - Mixture
  - Automatic mixture control (including cutoff)
  - Engine overheat / fire
  - Oil pressure
  - Carburetor temperature
  - Engine icing
- Mass & balance: should be accurate; payload locations eyeballed; fluids
  (oil, brake, etc.), emergency kits, etc., not considered, but included in
  OEW.
  Fun stretch goal: model passengers and flight attendants moving around when
  seat belt sign is off.

### Systems

Currently, practically everything is stubbed out or missing. We will need the
following:

- Fuel system:
  - Engine fuel demand: partially done
  - Carburetor
  - Fuel tanks
  - Mixture control
- Electrical system
- APU
- Hydraulics (including hand pump; drives brakes, cowl flaps, wing flaps)
- Oil (including oil temperature, reduction gear oil, oil dilution)
- Heating & ventilation (cabin heat, windshield heat, air pressure)
- Vacuum system
- Lights (ALS / HDR; will probably not bother with low-spec or Rembrandt)
- Autopilots (Sperry, Century; copied over and adjusted for JSBSim, both should
  work, but need more testing and possibly tweaking).

### Avionics

- Overhead panels: 3D models copied over from helijah/PAF version. Most things
  still need to be hooked up to actual systems.
- Classic panel (1940s): 3D model copied over from helijah/PAF version. Some
  instruments don't work yet. Sperry AP deserves a better 3D model and
  textures.
- Modern steam gauges panel (1980s):
  - Reusing some instruments from classic panel (altimeter, engine gauges, VSI)
  - ASI (in knots, rather than mph): done
  - AI: Generic placeholder from FGDATA for now; working on a Collins ADI-84A
    to replace it.
  - HSI: Generic placeholder from FGDATA for now; will have to implement
    something nicer eventually.
  - ADF: Generic placeholder from FGDATA; may either eliminate entirely, or use
    the one from the classic panel, or cook up a new one.
  - GPS155tso: mostly working, GPS/NAV switch works, HSI driving needs more
    testing.
  - DME: ki266, working.
  - Weather radar: nothing yet, but may make something at some point.
  - EFB: will probably add FG-EFB at some point.
  - Radio control panel: to do.
- Both panels:
  - Radio stack: mostly working, COMM radios don't have electrical power yet,
    but, in theory, support 8.33 channels.
  - Fuel gauges need better 3D model.

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

### FDM

- Aerodynamics: crude starting point generated with Aeromatic++, and tweaked a
  bit to be flyable. Needs work.
- Landing gear: positions are correct; tail wheel lock implemented, but correct
  locking mechanism needs to be implemented (in the "locked" lever position,
  the TW will lock once it moves into or through a centered position, but will
  remain free-castering until then). Wheel friction coefficients need tweaking.
- Engines: flailing right now; entered known-correct and best-guess parameters,
  but the resulting engine model does not match the spec *at all*. Plenty of
  work needed.
- Mass & balance: should be accurate; payload locations eyeballed; fluids
  (oil, brake, etc.), emergency kits, etc., not considered, but included in
  OEW.

### Systems

Currently, practically everything is stubbed out or missing. We will need the
following:

- Fuel (including tanks, carburetor, mixture control)
- Electrical system
- Hydraulics (including hand pump; drives brakes, cowl flaps, wing flaps)
- Oil (including oil temperature, reduction gear oil, oil dilution)
- Heating & ventilation (cabin heat, windshield heat, 
- Vacuum system
- Avionics (classic, modernized)
- Autopilots (Sperry, Century)
- APU

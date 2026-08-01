(* ::Package:: *)

ClearAll["Global`*"];

root = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{root, "src", "EMRI3DOrbits.wl"}]];

params = <|
   "eps" -> 1,
   "M" -> 1,
   "chi" -> 0.8,
   "spinDirection" -> {0, 0, 1},
   "eta" -> 10^-5
   |>;

elements = <|
   "a" -> 120,
   "e" -> 1.4,
   "i" -> 0.7,
   "phi0" -> 0.2,
   "varphi0" -> 0.4,
   "varphi" -> -1.6
   |>;

state = EMRI3DStateFromOsculatingElements[elements, params];
initialData = EMRI3DSphericalFromState[state["x"], state["v"]];
times = N[Subdivide[0, 900, 240], 30];

orbit = EMRI3DOrbit[params, initialData, times,
   WorkingPrecision -> 30, AccuracyGoal -> 18, PrecisionGoal -> 18,
   "PNOrder" -> 3, MaxStepSize -> 2];

osculating = EMRI3DOsculatingElements[orbit, params];

Print["Initial spherical data:"];
Print[initialData];
Print["First orbit point:"];
Print[AssociationMap[First[orbit[#]] &, {"t", "r", "theta", "phi",
    "rdot", "thetadot", "phidot"}]];
Print["Last orbit point:"];
Print[AssociationMap[Last[orbit[#]] &, {"t", "r", "theta", "phi",
    "rdot", "thetadot", "phidot"}]];
Print["Last osculating elements:"];
Print[Last[osculating]];

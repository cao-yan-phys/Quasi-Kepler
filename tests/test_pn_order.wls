(* ::Package:: *)

ClearAll["Global`*"];

root = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{root, "src", "QKOrbits.wl"}]];

model = QKLoadModel["Unbound3PNAlignedSpin", "RootDirectory" -> root];
params = <|"En" -> 1/200, "L" -> 15, "eps" -> 1,
   "nu" -> 21/100, "delta" -> 2/5,
   "chiS" -> 7/20, "chiA" -> -3/20,
   "kappaS" -> 1, "kappaA" -> 0, "SO" -> 1|>;

times = N[Subdivide[0, 1000, 5], 40];

orbitAtPN[pn_] := Module[{ic},
  ic = QKInitialData[model, params, First[times], "t0" -> 0,
    "phi0" -> 0, "PNOrder" -> pn];
  QKOrbit[model, params,
   <|"r" -> ic["r"], "phi" -> ic["phi"], "rdot" -> ic["rdot"],
    "phidot" -> ic["phidot"]|>,
   times, "PNOrder" -> pn]
  ];

e0 = QKOrbits`Private`numericElements[model, params, 40, 0];
e1 = QKOrbits`Private`numericElements[model, params, 40, 1];
e3 = QKOrbits`Private`numericElements[model, params, 40, 3];
Print["ar elements: ", ToString[N[<|"0PN" -> e0["ar"], "1PN" -> e1["ar"],
     "3PN" -> e3["ar"]|>, 18], InputForm]];

o0 = orbitAtPN[0];
o1 = orbitAtPN[1];
o2 = orbitAtPN[2];
o3 = orbitAtPN[3];

diffs = <|
   "r1Minus0Last" -> Last[o1["r"]] - Last[o0["r"]],
   "r2Minus1Last" -> Last[o2["r"]] - Last[o1["r"]],
   "r3Minus2Last" -> Last[o3["r"]] - Last[o2["r"]],
   "phi1Minus0Last" -> Last[o1["phi"]] - Last[o0["phi"]],
   "phi2Minus1Last" -> Last[o2["phi"]] - Last[o1["phi"]],
   "phi3Minus2Last" -> Last[o3["phi"]] - Last[o2["phi"]]
   |>;

Print["PN order diffs: ", ToString[N[diffs, 20], InputForm]];

If[And @@ (PossibleZeroQ /@ Values[diffs]),
  Print["PNOrder test failed: all differences are zero."];
  Quit[2];
  ];

Print["PNOrder test completed."];

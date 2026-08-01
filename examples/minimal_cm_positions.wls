(* Minimal center-of-mass individual positions from a QK relative orbit. *)

ClearAll["Global`*"];

root = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{root, "src", "QKOrbits.wl"}]];
Get[FileNameJoin[{root, "src", "CMPositions.wl"}]];

model = QKLoadModel["Bound3PNAlignedSpin", "RootDirectory" -> root];

pnOrder = 3;
primitiveParams = <|
   "eps" -> 1,
   "nu" -> 21/100,
   "delta" -> 2/5,
   "chi1" -> 1,
   "chi2" -> 1,
   "kap1" -> 1,
   "kap2" -> 1
   |>;

initialData = <|
   "r" -> 60,
   "phi" -> 3/10,
   "rdot" -> 0.008,
   "phidot" -> 0.0026
   |>;

times = N[Subdivide[0, 400, 32], 40];

relativeOrbit = QKOrbitFromInitialData[model, primitiveParams, initialData,
   times, "PNOrder" -> pnOrder, "RootDirectory" -> root];

cmOrbit = CMPositionsFromRelativeOrbit[relativeOrbit, primitiveParams,
   "PNOrder" -> pnOrder];

relativeVectors = MapThread[#1*{Cos[#2], Sin[#2]} &,
   {relativeOrbit["r"], relativeOrbit["phi"]}];
identityResidual = Max[Norm /@
    ((cmOrbit["y1"] - cmOrbit["y2"]) - relativeVectors)];

Print["Allowed CM PNOrder values: ",
  ToString[CMPositionsAllowedPNOrders[], InputForm]];
Print["First CM point: ",
  ToString[<|"t" -> cmOrbit["t"][[1]], "y1" -> cmOrbit["y1"][[1]],
    "y2" -> cmOrbit["y2"][[1]]|>, InputForm]];
Print["Last CM point: ",
  ToString[<|"t" -> Last[cmOrbit["t"]], "y1" -> Last[cmOrbit["y1"]],
    "y2" -> Last[cmOrbit["y2"]]|>, InputForm]];
Print["Max residual of y1 - y2 == x: ",
  ToString[N[identityResidual, 16], InputForm]];

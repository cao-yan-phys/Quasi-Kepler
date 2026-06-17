(* Minimal parabolic QK orbit from physical initial data. *)

root = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{root, "src", "QKOrbits.wl"}]];

model = QKLoadModel["Parabolic3PNAlignedSpin", "RootDirectory" -> root];

pnOrder = 3;
parabolicVelocitySign = 1; (* use -1 for the opposite missing-velocity branch *)
primitiveParams = <|
   "eps" -> 1,
   "nu" -> 21/100,
   "delta" -> 2/5,
   "chi1" -> 1,
   "chi2" -> 1,
   "kap1" -> 1,
   "kap2" -> 1
   |>;

(* For a parabolic QK orbit, give r, phi, and one velocity component.
   The missing velocity is solved from En == 0. *)
initialData = <|
   "r" -> 25,
   "phi" -> 1/4,
   "phidot" -> 0.006
   |>;

times = N[Subdivide[0, 40, 20], 40];

qkInfo = QKParameterValuesFromInitialData[model, primitiveParams,
   initialData, "PNOrder" -> pnOrder, "RootDirectory" -> root,
   "ParabolicVelocitySign" -> parabolicVelocitySign];

orbit = QKOrbitFromInitialData[model, primitiveParams, initialData, times,
   "PNOrder" -> pnOrder, "RootDirectory" -> root,
   "ParabolicVelocitySign" -> parabolicVelocitySign];

Print["Allowed PNOrder values: ", QKAllowedPNOrders[] // InputForm];
Print["ParabolicVelocitySign: ", parabolicVelocitySign // InputForm];
Print["Input data: ", initialData // InputForm];
Print["Completed initial data: ", N[qkInfo["InitialData"], 16] // InputForm];
Print["Initial scales: ", N[qkInfo["InitialScales"], 16] // InputForm];
Print["Conserved labels: ",
  N[qkInfo["ConservedLabels"], 16] // InputForm];
Print["QK parameters: ",
  N[KeyTake[qkInfo["QKParameters"], {"sP", "rP"}], 16] // InputForm];

Print["First point: ",
  <|"t" -> orbit["t"][[1]], "r" -> orbit["r"][[1]],
    "phi" -> orbit["phi"][[1]], "rdot" -> orbit["rdot"][[1]],
    "phidot" -> orbit["phidot"][[1]]|> // InputForm];

Print["Last point: ",
  <|"t" -> Last[orbit["t"]], "r" -> Last[orbit["r"]],
    "phi" -> Last[orbit["phi"]], "rdot" -> Last[orbit["rdot"]],
    "phidot" -> Last[orbit["phidot"]]|> // InputForm];

(* Minimal unbound QK orbit from physical initial data. *)

root = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{root, "src", "QKOrbits.wl"}]];

model = QKLoadModel["Unbound3PNAlignedSpin", "RootDirectory" -> root];

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
   "r" -> 40,
   "phi" -> 1/5,
   "rdot" -> 0.04,
   "phidot" -> 0.007
   |>;

times = N[Subdivide[0, 70, 20], 40];

qkInfo = QKParameterValuesFromInitialData[model, primitiveParams,
   initialData, "PNOrder" -> pnOrder, "RootDirectory" -> root];

orbit = QKOrbitFromInitialData[model, primitiveParams, initialData, times,
   "PNOrder" -> pnOrder, "RootDirectory" -> root];

Print["Allowed PNOrder values: ", QKAllowedPNOrders[] // InputForm];
Print["Initial data: ", initialData // InputForm];
Print["Initial scales: ", N[qkInfo["InitialScales"], 16] // InputForm];
Print["Conserved labels: ",
  N[qkInfo["ConservedLabels"], 16] // InputForm];
Print["QK parameters: ", N[qkInfo["QKParameters"], 16] // InputForm];

Print["First point: ",
  <|"t" -> orbit["t"][[1]], "r" -> orbit["r"][[1]],
    "phi" -> orbit["phi"][[1]], "rdot" -> orbit["rdot"][[1]],
    "phidot" -> orbit["phidot"][[1]]|> // InputForm];

Print["Last point: ",
  <|"t" -> Last[orbit["t"]], "r" -> Last[orbit["r"]],
    "phi" -> Last[orbit["phi"]], "rdot" -> Last[orbit["rdot"]],
    "phidot" -> Last[orbit["phidot"]]|> // InputForm];

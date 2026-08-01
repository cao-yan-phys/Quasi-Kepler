(* ::Package:: *)

ClearAll["Global`*"];

root = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{root, "src", "Numerical3DOrbits.wl"}]];
Get[FileNameJoin[{root, "src", "OsculatingElements3D.wl"}]];

times = N[Subdivide[0, 80, 120], 30];

binaryParams = <|"eps" -> 1, "nu" -> 21/100, "delta" -> 2/5,
   "kap1" -> 1, "kap2" -> 1|>;
binaryInitial = <|
   "r" -> 80, "theta" -> 1.1, "phi" -> 0.2,
   "rdot" -> 0.01, "thetadot" -> 0.0003, "phidot" -> 0.0008,
   "chi1Vec" -> {0.4, 0.2, 0.7},
   "chi2Vec" -> {-0.2, 0.3, 0.5}
   |>;

binaryOrbit = Numerical3DOrbit["SpinningBinary3PN", binaryParams,
   binaryInitial, times, "PNOrder" -> 2.5, "RootDirectory" -> root,
   MaxStepSize -> 1/2];
binaryElements = Osculating3DElementsFromOrbit[binaryOrbit, <|"M" -> 1|>];

emriParams = <|"eps" -> 1, "M" -> 1, "chi" -> 0.8,
   "spinDirection" -> {0, 0, 1}, "eta" -> 10^-5|>;
emriElements = <|"a" -> 120, "e" -> 1.4, "i" -> 0.7,
   "phi0" -> 0.2, "varphi0" -> 0.4, "varphi" -> -1.6|>;
emriState = Osculating3DStateFromElements[emriElements, emriParams];
emriInitial = Osculating3DSphericalFromState[emriState["x"],
   emriState["v"]];
emriOrbit = Numerical3DOrbit["WillEMRI", emriParams, emriInitial, times,
   "PNOrder" -> 4.5, "IncludeRadiationReaction" -> True,
   MaxStepSize -> 1/2];
emriElementsOut = Osculating3DElementsFromOrbit[emriOrbit, emriParams];

Print["SpinningBinary3PN last point:"];
Print[AssociationMap[Last[binaryOrbit[#]] &, {"t", "r", "theta", "phi",
    "rdot", "thetadot", "phidot"}]];
Print["SpinningBinary3PN last osculating elements:"];
Print[Last[binaryElements]];

Print["WillEMRI last point:"];
Print[AssociationMap[Last[emriOrbit[#]] &, {"t", "r", "theta", "phi",
    "rdot", "thetadot", "phidot"}]];
Print["WillEMRI last osculating elements:"];
Print[Last[emriElementsOut]];

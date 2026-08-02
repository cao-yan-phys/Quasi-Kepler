(* ::Package:: *)

root = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{root, "src", "SpinOrbitScattering1p5PN.wl"}]];

elements = <|"a" -> 28., "e" -> 1.7, "i" -> 0.73,
   "phi0" -> -0.31, "varphi0" -> 0.42|>;

params = <|"M" -> 1., "nu" -> 0.21, "delta" -> 0.4,
   "chi1Vec" -> {0.31, -0.22, 0.47},
   "chi2Vec" -> {-0.19, 0.28, 0.36}, "eps" -> 1|>;

result = SpinOrbitScattering1p5PN[elements, params];

Print[KeyTake[result, {"DeltaHVector", "DeltaEVector", "KIn", "KOut",
    "ScatteringAngle", "ScatteringVector", "FrameRotationVector",
    "SpinRotationAngles", "SpinRotationVectors", "FinalSpinVectorsLinear",
    "DeltaElements"}]];

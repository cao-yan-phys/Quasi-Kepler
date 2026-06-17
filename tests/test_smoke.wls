(* ::Package:: *)

ClearAll["Global`*"];

root = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{root, "src", "QKOrbits.wl"}]];

wp = 40;
primitiveParams = <|"eps" -> 1, "nu" -> 21/100, "delta" -> 2/5,
   "chi1" -> 1, "chi2" -> 1, "kap1" -> 1, "kap2" -> 1|>;

cases = <|
   "Unbound3PNAlignedSpin" -> <|
     "initialData" -> <|"r" -> 40, "phi" -> 1/5, "rdot" -> 0.04,
       "phidot" -> 0.007|>,
     "times" -> N[Subdivide[0, 70, 16], wp]|>,
   "Parabolic3PNAlignedSpin" -> <|
     "initialData" -> <|"r" -> 25, "phi" -> 1/4,
       "phidot" -> 0.006|>,
     "times" -> N[Subdivide[0, 40, 16], wp]|>,
   "Bound3PNAlignedSpin" -> <|
     "initialData" -> <|"r" -> 45, "phi" -> 3/10,
       "rdot" -> 0.012, "phidot" -> 0.004|>,
     "times" -> N[Subdivide[0, 95, 16], wp]|>
   |>;

runSmoke[name_] := Module[{spec, model, qkInfo, qk, initialData},
  spec = cases[name];
  model = QKLoadModel[name, "RootDirectory" -> root];
  initialData = AssociationMap[N[#, wp] &, spec["initialData"]];
  qkInfo = QKParameterValuesFromInitialData[model, primitiveParams,
    initialData, "PNOrder" -> 3, "RootDirectory" -> root];
  If[! AssociationQ[qkInfo] ||
    ! KeyExistsQ[qkInfo, "ConservedLabels"] ||
    ! KeyExistsQ[qkInfo, "QKParameters"] ||
    ! KeyExistsQ[qkInfo, "InitialData"] ||
    ! KeyExistsQ[qkInfo, "InitialScales"] ||
    ! KeyExistsQ[qkInfo["ConservedLabels"], "En"] ||
    ! KeyExistsQ[qkInfo["ConservedLabels"], "L"] ||
    ! KeyExistsQ[qkInfo["InitialScales"], "vSquared"] ||
    ! KeyExistsQ[qkInfo["InitialScales"], "oneOverR"] ||
    Sort[Keys[qkInfo["InitialData"]]] =!=
     Sort[{"r", "phi", "rdot", "phidot"}] ||
    Length[Keys[qkInfo["QKParameters"]]] == 0,
   Print["QK parameter return failed for ", name];
   Quit[2]];
  qk = QKOrbitFromInitialData[model, primitiveParams, initialData,
    spec["times"], "PNOrder" -> 3, "RootDirectory" -> root];
  If[! AssociationQ[qk] ||
    Sort[Keys[qk]] =!= Sort[{"t", "r", "phi", "rdot", "phidot"}] ||
    ! FreeQ[qk["r"], _Complex | Indeterminate | DirectedInfinity],
   Print["Smoke failed for ", name];
   Quit[2]];
  Print[name, " first/last r: ",
   ToString[N[{First[qk["r"]], Last[qk["r"]]}, 16], InputForm]];
  ];

Scan[runSmoke, Keys[cases]];

badParabolicModel =
  QKLoadModel["Parabolic3PNAlignedSpin", "RootDirectory" -> root];
badParabolic = Quiet[
   QKParameterValuesFromInitialData[badParabolicModel,
    primitiveParams,
    <|"r" -> 30, "phi" -> 0, "rdot" -> 0.01,
     "phidot" -> 0.005|>,
    "PNOrder" -> 3, "RootDirectory" -> root],
   QKParameterValuesFromInitialData::parabolicic];
If[badParabolic =!= $Failed,
 Print["Parabolic full four-field input should be rejected."];
 Quit[2]];

badParabolicNoSolution = Quiet[
   QKParameterValuesFromInitialData[
    badParabolicModel, primitiveParams,
    <|"r" -> 30, "phi" -> 0, "phidot" -> 1|>,
    "PNOrder" -> 3, "RootDirectory" -> root],
   QKParameterValuesFromInitialData::parabolicnosol];
If[badParabolicNoSolution =!= $Failed,
 Print["Parabolic E=0 no-solution input should be rejected."];
 Quit[2]];

parabolicPositive = QKParameterValuesFromInitialData[badParabolicModel,
   primitiveParams,
   cases["Parabolic3PNAlignedSpin"]["initialData"],
   "PNOrder" -> 3, "RootDirectory" -> root,
   "ParabolicVelocitySign" -> 1];
parabolicNegative = QKParameterValuesFromInitialData[badParabolicModel,
   primitiveParams,
   cases["Parabolic3PNAlignedSpin"]["initialData"],
   "PNOrder" -> 3, "RootDirectory" -> root,
   "ParabolicVelocitySign" -> -1];
If[parabolicPositive["InitialData", "rdot"] <= 0 ||
  parabolicNegative["InitialData", "rdot"] >= 0,
 Print["ParabolicVelocitySign did not select the requested rdot branch."];
 Quit[2]];

If[QKAllowedPNOrders[] =!= {0, 1, 1.5, 2, 2.5, 3},
 Print["Unexpected QKAllowedPNOrders[] value: ", QKAllowedPNOrders[]];
 Quit[2]];

Print["Smoke tests completed."];

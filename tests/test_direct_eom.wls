(* ::Package:: *)

ClearAll["Global`*"];

root = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{root, "src", "QKOrbits.wl"}]];
Get[FileNameJoin[{root, "src", "DirectEOMOrbits.wl"}]];
Get[FileNameJoin[{root, "src", "EMRI3DOrbits.wl"}]];

eom = DirectEOMLoad["RootDirectory" -> root];

wp = 40;
acc = 20;
prec = 20;

primitiveParams = <|"eps" -> 1, "nu" -> 21/100, "delta" -> 2/5,
   "chi1" -> 1, "chi2" -> 1, "kap1" -> 1, "kap2" -> 1|>;

cases = <|
   "Unbound" -> <|"model" -> "Unbound3PNAlignedSpin",
     "initialData" -> <|"r" -> 200, "phi" -> 1/5,
       "rdot" -> 0.08, "phidot" -> 0.0005|>,
     "times" -> N[Subdivide[0, 80, 50], wp]|>,
   "Parabolic" -> <|"model" -> "Parabolic3PNAlignedSpin",
     "initialData" -> <|"r" -> 100, "phi" -> 1/4,
       "phidot" -> 0.001|>,
     "times" -> N[Subdivide[0, 80, 50], wp]|>,
   "Bound" -> <|"model" -> "Bound3PNAlignedSpin",
     "initialData" -> <|"r" -> 400, "phi" -> 3/10,
       "rdot" -> 0.0005, "phidot" -> 0.00007|>,
     "times" -> N[Subdivide[0, 25, 80], wp]|>
   |>;

runConservativeCase[name_] := Module[
  {spec, model, times, qkInfo, qk, inputData, initialData, direct, dr,
   dphi, drdot, dphidot, expectedKeys},
  spec = cases[name];
  model = QKLoadModel[spec["model"], "RootDirectory" -> root];
  times = spec["times"];
  inputData = AssociationMap[N[#, wp] &, spec["initialData"]];
  qkInfo = QKParameterValuesFromInitialData[model, primitiveParams,
    inputData, WorkingPrecision -> wp, "PNOrder" -> 3,
    "RootDirectory" -> root];
  If[qkInfo === $Failed, Quit[2]];
  initialData = qkInfo["InitialData"];
  qk = QKOrbitFromInitialData[model, primitiveParams, inputData, times,
    WorkingPrecision -> wp, AccuracyGoal -> acc, PrecisionGoal -> prec,
    "PNOrder" -> 3, "RootDirectory" -> root];
  direct = DirectEOMOrbit[eom, primitiveParams, initialData, times,
    WorkingPrecision -> wp, AccuracyGoal -> acc, PrecisionGoal -> prec,
    "PNOrder" -> 3, MaxStepSize -> 1/2];
  expectedKeys = {"t", "r", "phi", "rdot", "phidot"};
  If[Sort[Keys[qk]] =!= Sort[expectedKeys] ||
    Sort[Keys[direct]] =!= Sort[expectedKeys],
   Print["Unexpected orbit output keys: qk=", Keys[qk],
    ", direct=", Keys[direct]];
   Quit[2]];
  dr = Max[Abs[direct["r"] - qk["r"]]];
  dphi = Max[Abs[direct["phi"] - qk["phi"]]];
  drdot = Max[Abs[direct["rdot"] - qk["rdot"]]];
  dphidot = Max[Abs[direct["phidot"] - qk["phidot"]]];
  Print[name, " conservative direct/QK: dr=", N[dr, 8],
   ", dphi=", N[dphi, 8], ", drdot=", N[drdot, 8],
   ", dphidot=", N[dphidot, 8]];
  If[dr > 10^-3 || dphi > 10^-4 || drdot > 10^-5 ||
    dphidot > 10^-6, Quit[2]];
  ];

Scan[runConservativeCase, Keys[cases]];

If[DirectEOMAllowedPNOrders[] =!= {0, 1, 1.5, 2, 2.5, 3},
 Print["Unexpected DirectEOMAllowedPNOrders[] value: ",
  DirectEOMAllowedPNOrders[]];
 Quit[2]];

rrTimes = N[Subdivide[0, 300, 120], wp];
rrPrimitive = <|"eps" -> 1, "nu" -> 1/4, "delta" -> 0,
   "chi1" -> 0, "chi2" -> 0, "kap1" -> 1, "kap2" -> 1|>;
rrIC = <|"r" -> 30, "phi" -> 0, "rdot" -> 0,
   "phidot" -> Sqrt[1/30^3]|>;

rrOff = DirectEOMOrbit[eom, rrPrimitive, rrIC, rrTimes,
   WorkingPrecision -> wp, AccuracyGoal -> acc, PrecisionGoal -> prec,
   "PNOrder" -> 2.5, MaxStepSize -> 1/2];
rr25On = DirectEOMOrbit[eom, rrPrimitive, rrIC, rrTimes,
   WorkingPrecision -> wp, AccuracyGoal -> acc, PrecisionGoal -> prec,
   "PNOrder" -> 2.5, MaxStepSize -> 1/2,
   "Include2p5PNRadiationReaction" -> True];

rrDeltaR = Last[rr25On["r"]] - Last[rrOff["r"]];
rrDeltaPhi = Last[rr25On["phi"]] - Last[rrOff["phi"]];
Print["2.5PN radiation reaction switch: delta r=", N[rrDeltaR, 10],
 ", delta phi=", N[rrDeltaPhi, 10]];

If[Abs[rrDeltaR] < 10^-6 || Abs[rrDeltaPhi] < 10^-7,
 Print["2.5PN radiation-reaction option appears inactive."];
 Quit[2]];

rr35On = DirectEOMOrbit[eom, rrPrimitive, rrIC, rrTimes,
   WorkingPrecision -> wp, AccuracyGoal -> acc, PrecisionGoal -> prec,
   "PNOrder" -> 2.5, MaxStepSize -> 1/2,
   "Include2p5PNRadiationReaction" -> True,
   "Include3p5PNRadiationReaction" -> True];

rr35DeltaR = Last[rr35On["r"]] - Last[rr25On["r"]];
rr35DeltaPhi = Last[rr35On["phi"]] - Last[rr25On["phi"]];
Print["3.5PN radiation reaction switch: delta r=", N[rr35DeltaR, 10],
 ", delta phi=", N[rr35DeltaPhi, 10]];

If[Abs[rr35DeltaR] < 10^-9 || Abs[rr35DeltaPhi] < 10^-10,
 Print["3.5PN radiation-reaction option appears inactive."];
 Quit[2]];

rr35Expr = DirectEOMOrbits`Private`radiationReaction35Polar[];
rr35TestBody = Map[
    Coefficient[#, DirectEOMOrbits`Private`nu, 1] &,
    rr35Expr] /. {
    DirectEOMOrbits`Private`eps -> 1,
    DirectEOMOrbits`Private`s -> 1/37,
    DirectEOMOrbits`Private`rd -> 1/50,
    DirectEOMOrbits`Private`p -> 3/1000
    };
rr35EMRI = EMRI3DAcceleration[
     {37, 0, 0}, {1/50, 111/1000, 0},
     <|"M" -> 1, "eta" -> 1, "chi" -> 0, "eps" -> 1|>,
     "PNOrder" -> 3.5, "IncludeRadiationReaction" -> True] -
   EMRI3DAcceleration[
     {37, 0, 0}, {1/50, 111/1000, 0},
     <|"M" -> 1, "eta" -> 1, "chi" -> 0, "eps" -> 1|>,
     "PNOrder" -> 3, "IncludeRadiationReaction" -> True];
rr35TestBodyDelta = N[{
    rr35TestBody["rddot"] - rr35EMRI[[1]],
    rr35TestBody["phiddot"] - rr35EMRI[[2]]/37
    }, 20];
Print["3.5PN test-body-limit component differences: ",
 N[rr35TestBodyDelta, 10]];

If[Max[Abs[rr35TestBodyDelta]] > 10^-16,
 Print["3.5PN radiation reaction disagrees with the EMRI test-body limit."];
 Quit[2]];

Print["Direct EOM tests completed."];

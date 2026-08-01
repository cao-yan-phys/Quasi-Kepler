(* ::Package:: *)

BeginPackage["Numerical3DOrbits`"];

Numerical3DOrbit;
Numerical3DAllowedModels;
Begin["`Private`"];

If[! NameQ["EMRI3DOrbits`EMRI3DOrbit"],
  Get[FileNameJoin[{DirectoryName[$InputFileName], "EMRI3DOrbits.wl"}]]
  ];
If[! NameQ["SpinningBinary3PNOrbits`SpinningBinary3PNOrbit"],
  Get[FileNameJoin[{DirectoryName[$InputFileName],
     "SpinningBinary3PNOrbits.wl"}]]
  ];

Options[Numerical3DOrbit] = {WorkingPrecision -> MachinePrecision,
   AccuracyGoal -> Automatic, PrecisionGoal -> Automatic, "PNOrder" -> 3,
   MaxStepSize -> Automatic, Method -> Automatic,
   "IncludeRadiationReaction" -> False,
   "Include2p5PNRadiationReaction" -> False, "RRGaugeParameters" -> <||>,
   "SpinTerms" -> True, "SpinPrecession" -> True,
   "RootDirectory" -> Automatic};

Numerical3DAllowedModels[] := {"WillEMRI", "SpinningBinary3PN"};

Numerical3DOrbit["WillEMRI", params_Association,
  initialData_Association, times_List, OptionsPattern[]] :=
 EMRI3DOrbits`EMRI3DOrbit[params, initialData, times,
  WorkingPrecision -> OptionValue[WorkingPrecision],
  AccuracyGoal -> OptionValue[AccuracyGoal],
  PrecisionGoal -> OptionValue[PrecisionGoal],
  "PNOrder" -> OptionValue["PNOrder"],
  MaxStepSize -> OptionValue[MaxStepSize],
  Method -> OptionValue[Method],
  "IncludeRadiationReaction" -> OptionValue["IncludeRadiationReaction"],
  "Include2p5PNRadiationReaction" ->
   OptionValue["Include2p5PNRadiationReaction"],
  "RRGaugeParameters" -> OptionValue["RRGaugeParameters"],
  "ReturnCartesian" -> True
  ];

Numerical3DOrbit["SpinningBinary3PN", params_Association,
  initialData_Association, times_List, OptionsPattern[]] := Module[
  {root, eom},
  root = OptionValue["RootDirectory"];
  eom = SpinningBinary3PNOrbits`SpinningBinary3PNLoad[
    "RootDirectory" -> root];
  If[eom === $Failed, Return[$Failed]];
  SpinningBinary3PNOrbits`SpinningBinary3PNOrbit[eom, params, initialData,
   times, WorkingPrecision -> OptionValue[WorkingPrecision],
   AccuracyGoal -> OptionValue[AccuracyGoal],
   PrecisionGoal -> OptionValue[PrecisionGoal],
   "PNOrder" -> OptionValue["PNOrder"],
   MaxStepSize -> OptionValue[MaxStepSize],
   Method -> OptionValue[Method],
   "SpinTerms" -> OptionValue["SpinTerms"],
   "SpinPrecession" -> OptionValue["SpinPrecession"]]
  ];

Numerical3DOrbit[model_, ___] := (Message[Numerical3DOrbit::badmodel, model,
    Numerical3DAllowedModels[]]; $Failed);

Numerical3DOrbit::badmodel =
  "Unknown 3D numerical model `1`. Use one of `2`.";

End[];

EndPackage[];
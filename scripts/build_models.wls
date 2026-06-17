(* ::Package:: *)

(* Build compact model files for the release prototype.

   This script is intentionally run from the working repository that contains
   the derivation results.  The generated files under src/Models are the only
   large formula files the release package needs at runtime.
*)

ClearAll["Global`*"];

releaseRoot = DirectoryName[DirectoryName[$InputFileName]];
workRoot = DirectoryName[releaseRoot];
modelDir = FileNameJoin[{releaseRoot, "src", "Models"}];

eps = \[Epsilon];
Clear[En, L, s, qq];

ser6[expr_] := Cancel[PowerExpand[Normal[Series[expr, {eps, 0, 6}]]]];
ser6Bound[expr_] := Cancel[Together[Normal[Series[expr, {eps, 0, 6}]]]];
spinZero[expr_] := expr /. SO -> 0;
add3PNNS[spinExpr_, mhExpr_] := ser6[
   spinExpr + eps^6 Coefficient[spinZero[mhExpr], eps, 6]];
only3PNNS[expr_] := ser6[eps^6 Coefficient[spinZero[expr], eps, 6]];
add3PNNSBound[spinExpr_, mhExpr_] := ser6Bound[
   spinExpr + eps^6 Coefficient[spinZero[mhExpr], eps, 6]];
only3PNNSBound[expr_] := ser6Bound[
   eps^6 Coefficient[spinZero[expr], eps, 6]];
toQ[expr_] := Cancel[PowerExpand[expr /. En -> (qq^2 - 1)/(2 L^2)]];
fromQUnbound[expr_] := Cancel[PowerExpand[expr /. qq -> Sqrt[1 + 2 En L^2]]];
fromQBound[expr_] := Cancel[Together[expr /. qq -> Sqrt[1 + 2 En L^2]]];

required[assoc_Association, keys_List, label_String] := Module[{missing},
  missing = Complement[keys, Keys[assoc]];
  If[missing =!= {},
   Print["Missing keys in ", label, ": ", ToString[missing, InputForm]];
   Quit[2];
   ];
  assoc
  ];

lookupAny[assoc_Association, keys_List, default_: Missing["NotFound"]] :=
  Module[{hit = SelectFirst[keys, KeyExistsQ[assoc, #] &,
      Missing["NotFound"]]},
   If[MissingQ[hit], default, assoc[hit]]
   ];

Print["Building unbound 3PN aligned-spin model"];
unboundMerged = Get[FileNameJoin[{workRoot, "results",
      "unbound_qk_2023_spin_plus_3pn_mh_nonspin.wl"}]];
unboundMH = Get[FileNameJoin[{workRoot, "results",
      "unbound_qk_3pn_mh_harmonic_first_principles.wl"}]];
required[unboundMerged, {"Rpoly", "Spoly2023SpinPart", "qkStandard"},
  "unbound merged"];
required[unboundMH, {"Rpoly", "Dpoly", "sPlusQ", "sMinusQ"},
  "unbound MH"];

RmhQ = toQ[unboundMH["Rpoly"]];
DmhQ = toQ[unboundMH["Dpoly"]];
RbarMHQ = ser6[RmhQ/((unboundMH["sPlusQ"] - s) (s - unboundMH["sMinusQ"]))];
phidotMHQ = ser6[s^2 DmhQ Sqrt[RbarMHQ]];
phidotUnbound = ser6[
   unboundMerged["Spoly2023SpinPart"] + fromQUnbound[only3PNNS[phidotMHQ]]];

unboundModel = Association[
   "Name" -> "Unbound3PNAlignedSpin",
   "OrbitType" -> "Unbound",
   "Description" ->
    "3PN MH nonspinning + 2023 aligned-spin sectors for conservative hyperbolic orbits",
   "PNContent" ->
    "SO^0 through eps^6; SO through eps^3/eps^5; SS through eps^4/eps^6",
   "EnergyConvention" -> "En > 0",
   "Rpoly" -> unboundMerged["Rpoly"],
   "PhidotPoly" -> phidotUnbound,
   "QK" -> unboundMerged["qkStandard"],
   "TimeBasis" -> "UnboundStandard",
   "AngularBasis" -> "K[v + fPhi sin(2v) + gPhi sin(3v) + hPhi sin(4v) + iPhi sin(5v)]"
   ];

Put[unboundModel, FileNameJoin[{modelDir,
    "unbound_3pn_aligned_spin.wl"}]];

Print["Building bound 3PN aligned-spin model"];
boundRadial = Get[FileNameJoin[{workRoot, "results",
      "bound_radial_2023_3pn_spin_first_principles.wl"}]];
boundAngular = Get[FileNameJoin[{workRoot, "results",
      "verify_bound_angular_2023_3pn_spin_candidate_direct.wl"}]];
boundTime = Get[FileNameJoin[{workRoot, "results",
      "verify_bound_time_2023_3pn_spin_candidate_direct.wl"}]];
boundMH = Get[FileNameJoin[{workRoot, "results",
      "bound_qk_3pn_mh_harmonic_first_principles.wl"}]];
eomSpin = Get[FileNameJoin[{workRoot, "results",
      "unbound_eom_2023_3pn_spin_first_principles.wl"}]];

required[boundRadial, {"arQ", "erQ", "er2Q"}, "bound radial"];
required[boundAngular, {"candidateQ"}, "bound angular"];
required[boundTime, {"candidateQ"}, "bound time"];
required[boundMH, {"Rpoly", "Dpoly", "sPeriQ", "sApoQ", "qk"},
  "bound MH"];
required[eomSpin, {"Rpoly", "Spoly"}, "2023 spin EOM"];

angQ = boundAngular["candidateQ"];
timeQ = boundTime["candidateQ"];
mhQK = Association[boundMH["qk"]];

spinBoundQK = Association[
   "ar" -> fromQBound[boundRadial["arQ"]],
   "er" -> fromQBound[boundRadial["erQ"]],
   "er2" -> fromQBound[boundRadial["er2Q"]],
   "ePhi" -> fromQBound[angQ["ePhi"]],
   "ePhi2" -> ser6Bound[fromQBound[angQ["ePhi"]]^2],
   "K" -> fromQBound[angQ["K"]],
   "fPhi" -> fromQBound[angQ["G2"]],
   "gPhi" -> fromQBound[angQ["G3"]],
   "hPhi" -> 0,
   "iPhi" -> 0,
   "n" -> fromQBound[timeQ["n"]],
   "et" -> fromQBound[timeQ["et"]],
   "et2" -> ser6Bound[fromQBound[timeQ["et"]]^2],
   "gt" -> fromQBound[timeQ["Fvu"]],
   "ft" -> fromQBound[timeQ["Fv"]],
   "ht" -> 0,
   "it" -> 0
   ];

boundMap = Association[
   "n" -> "n", "K" -> "K", "ar" -> "ar", "er" -> "er",
   "er2" -> "er2", "et" -> "et", "et2" -> "et2",
   "ePhi" -> "ePhi", "ePhi2" -> "ePhi2",
   "fPhi" -> "fPhi", "gPhi" -> "gPhi",
   "hPhi" -> "hPhi", "iPhi" -> "iPhi"
   ];

boundQK = Association@Join[
    Table[k -> add3PNNSBound[spinBoundQK[k], mhQK[boundMap[k]]],
     {k, Keys[boundMap]}],
    {
     "gt" -> add3PNNSBound[spinBoundQK["gt"], mhQK["gT"]],
     "ft" -> add3PNNSBound[spinBoundQK["ft"], mhQK["fT"]],
     "ht" -> only3PNNSBound[mhQK["iT"]],
     "it" -> only3PNNSBound[mhQK["hT"]]
     }
    ];

Rbound = add3PNNSBound[eomSpin["Rpoly"], boundMH["Rpoly"]];
RboundMHQ = toQ[boundMH["Rpoly"]];
DboundMHQ = toQ[boundMH["Dpoly"]];
RbarBoundMHQ = ser6[RboundMHQ/((boundMH["sPeriQ"] - s) (s - boundMH["sApoQ"]))];
phidotBoundMHQ = ser6[s^2 DboundMHQ Sqrt[RbarBoundMHQ]];
phidotBound = ser6Bound[
   eomSpin["Spoly"] + fromQBound[only3PNNSBound[phidotBoundMHQ]]];

boundModel = Association[
   "Name" -> "Bound3PNAlignedSpin",
   "OrbitType" -> "Bound",
   "Description" ->
    "Prototype bound model: 3PN MH nonspinning + 2023 aligned-spin sectors",
   "PNContent" ->
    "SO^0 through eps^6; SO through eps^3/eps^5; SS through eps^4/eps^6",
   "EnergyConvention" -> "En < 0 and 0 < Sqrt[1 + 2 En L^2] < 1",
   "Rpoly" -> Rbound,
   "PhidotPoly" -> phidotBound,
   "QK" -> boundQK,
   "TimeBasis" -> "BoundMGS",
   "AngularBasis" -> "K[v + fPhi sin(2v) + gPhi sin(3v) + hPhi sin(4v) + iPhi sin(5v)]"
   ];

Put[boundModel, FileNameJoin[{modelDir,
    "bound_3pn_aligned_spin.wl"}]];

Print["Building parabolic 3PN aligned-spin model"];
parabolic = Get[FileNameJoin[{workRoot, "results",
      "parabolic_qk_3pn_mh_spin_first_principles.wl"}]];
required[parabolic, {"Rfull", "Sfull", "sP", "rP", "sOfW", "rOfW",
   "dtDw", "dphiDw", "tOfW", "phiOfW"}, "parabolic spin"];

parabolicModel = Association[
   "Name" -> "Parabolic3PNAlignedSpin",
   "OrbitType" -> "Parabolic",
   "Description" ->
    "Conservative marginally bound/parabolic 3PN MH nonspinning + aligned-spin sectors",
   "PNContent" ->
    "SO^0 through eps^6; SO through eps^3/eps^5; SS through eps^4/eps^6",
   "EnergyConvention" -> "En = 0",
   "Rpoly" -> parabolic["Rfull"],
   "PhidotPoly" -> parabolic["Sfull"],
   "QK" -> Association[
     "sP" -> parabolic["sP"],
     "rP" -> parabolic["rP"],
     "sOfW" -> parabolic["sOfW"],
     "rOfW" -> parabolic["rOfW"],
     "dtDw" -> parabolic["dtDw"],
     "dphiDw" -> parabolic["dphiDw"],
     "tOfW" -> parabolic["tOfW"],
     "phiOfW" -> parabolic["phiOfW"]
     ],
   "TimeBasis" -> "ParabolicBarker",
   "AngularBasis" -> "phi(w), with Newtonian limit 2 ArcTan[w]"
   ];

Put[parabolicModel, FileNameJoin[{modelDir,
    "parabolic_3pn_aligned_spin.wl"}]];

Print["Model build completed."];

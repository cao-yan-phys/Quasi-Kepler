(* ::Package:: *)

BeginPackage["QKOrbits`"];

QKLoadModel::usage =
  "QKLoadModel[name] loads a prepared QK model. Available names include \
\"Unbound3PNAlignedSpin\", \"Bound3PNAlignedSpin\", and \
\"Parabolic3PNAlignedSpin\".";

QKOrbit::usage =
  "QKOrbit[model, params, initialData, times] evaluates the \
quasi-Keplerian trajectory from initial data and returns an Association with \
t, r, phi, rdot, phidot.";

QKInitialData::usage =
  "QKInitialData[model, params, time] returns initial data {r, phi, rdot, \
phidot} from the QK trajectory.";

QKLabelsFromInitialData::usage =
  "QKLabelsFromInitialData[primitiveParams, initialData] evaluates the \
conservative labels <|\"En\" -> ..., \"L\" -> ...|> from {r, phi, rdot, \
phidot} using the retained 3PN aligned-spin conserved energy and angular \
momentum.";

QKOrbitFromInitialData::usage =
  "QKOrbitFromInitialData[model, primitiveParams, initialData, times] \
computes the conservative labels from initial data, evaluates the QK \
trajectory, and returns an Association with t, r, phi, rdot, phidot. For \
parabolic models, provide r, phi, and exactly one of rdot or phidot; the \
missing velocity is solved from En == 0.";

QKParameterValuesFromInitialData::usage =
  "QKParameterValuesFromInitialData[model, primitiveParams, initialData] \
returns the completed initial data, initial scales, conserved labels, and QK \
parameter values determined by the initial state at the requested PNOrder. \
For parabolic models, provide r, phi, and exactly one of rdot or phidot; the \
missing velocity is solved from En == 0.";

QKAllowedPNOrders::usage =
  "QKAllowedPNOrders[] returns the PN truncations accepted by the release.";

Begin["`Private`"];

$QKOrbitsRoot = If[StringQ[$InputFileName] && $InputFileName =!= "",
   DirectoryName[DirectoryName[$InputFileName]],
   Directory[]
   ];

Options[QKLoadModel] = {"RootDirectory" -> Automatic};
Options[QKOrbit] = {"t0" -> 0, "phi0" -> 0, WorkingPrecision -> 50,
   AccuracyGoal -> 28, PrecisionGoal -> 28, "PNOrder" -> 3};
Options[QKInitialData] = Options[QKOrbit];
Options[QKOrbitFromInitialData] =
  Join[Options[QKOrbit], {"RootDirectory" -> Automatic,
    "ParabolicVelocitySign" -> 1}];
Options[QKParameterValuesFromInitialData] = {"RootDirectory" -> Automatic,
   WorkingPrecision -> 50, "PNOrder" -> 3,
   "ParabolicVelocitySign" -> 1};
Options[QKLabelsFromInitialData] = {"RootDirectory" -> Automatic,
   WorkingPrecision -> 50, "PNOrder" -> 3};
Options[qkFunctions] = Options[QKOrbit];
Options[stateAtTime] = Options[QKOrbit];

initialValue[ic_Association, key_String] :=
  If[KeyExistsQ[ic, key], ic[key], Missing[key]];

modelFileName[name_String] := Module[{key = ToLowerCase[name]},
  Switch[key,
   "unbound3pnalignedspin" | "unbound-3pn-aligned-spin" |
   "unbound_3pn_aligned_spin", "unbound_3pn_aligned_spin.wl",
   "bound3pnalignedspin" | "bound-3pn-aligned-spin" |
    "bound_3pn_aligned_spin", "bound_3pn_aligned_spin.wl",
   "parabolic3pnalignedspin" | "parabolic-3pn-aligned-spin" |
    "parabolic_3pn_aligned_spin", "parabolic_3pn_aligned_spin.wl",
   _, name <> ".wl"
   ]
  ];

globalSymbolRules[] := {
   Global`En -> En,
   Global`L -> L,
   Global`s -> s,
   Global`rd -> rd,
   Global`p -> p,
   Global`w -> w,
   Global`qq -> qq,
   Global`eps -> eps,
   Global`nu -> nu,
   Global`delta -> delta,
   Global`chi1 -> chi1,
   Global`chi2 -> chi2,
   Global`kap1 -> kap1,
   Global`kap2 -> kap2,
   Global`\[Epsilon] -> \[Epsilon],
   Global`\[Nu] -> \[Nu],
   Global`\[Delta] -> \[Delta],
   Global`\[Chi]S -> \[Chi]S,
   Global`\[Chi]A -> \[Chi]A,
   Global`\[Kappa]S -> \[Kappa]S,
   Global`\[Kappa]A -> \[Kappa]A,
   Global`SO -> SO
   };

QKLoadModel[name_String, OptionsPattern[]] := Module[{root, file, model},
  root = Replace[OptionValue["RootDirectory"], Automatic -> $QKOrbitsRoot];
  file = FileNameJoin[{root, "src", "Models", modelFileName[name]}];
  If[! FileExistsQ[file],
   Message[QKLoadModel::nofile, file];
   Return[$Failed];
   ];
  model = Block[{$Context = "QKOrbits`Private`",
     $ContextPath = {"System`"}},
    Get[file]
    ];
  model = model /. globalSymbolRules[];
  If[! AssociationQ[model] || ! KeyExistsQ[model, "QK"],
   Message[QKLoadModel::badmodel, file];
   Return[$Failed];
   ];
  model
  ];

QKLoadModel::nofile = "Model file not found: `1`.";
QKLoadModel::badmodel = "File is not a valid QK model: `1`.";

paramValue[params_Association, key_String, default_] :=
  Lookup[params, key, default];

parameterRules[params_Association] := {
   En -> paramValue[params, "En", Missing["En"]],
   L -> paramValue[params, "L", Missing["L"]],
   \[Epsilon] -> paramValue[params, "eps", 1],
   \[Nu] -> paramValue[params, "nu", Missing["nu"]],
   \[Delta] -> paramValue[params, "delta", Sqrt[1 - 4 paramValue[params, "nu", 0]]],
   \[Chi]S -> paramValue[params, "chiS", 0],
   \[Chi]A -> paramValue[params, "chiA", 0],
   \[Kappa]S -> paramValue[params, "kappaS", 1],
   \[Kappa]A -> paramValue[params, "kappaA", 0],
   SO -> paramValue[params, "SO", 1]
   };

primitiveRules[params_Association] := {
   eps -> paramValue[params, "eps", 1],
   nu -> paramValue[params, "nu", Missing["nu"]],
   delta -> paramValue[params, "delta",
     Sqrt[1 - 4 paramValue[params, "nu", 0]]],
   chi1 -> paramValue[params, "chi1", 0],
   chi2 -> paramValue[params, "chi2", 0],
   kap1 -> paramValue[params, "kap1", 1],
   kap2 -> paramValue[params, "kap2", 1]
   };

qkParamsFromPrimitive[params_Association] := Module[
  {c1, c2, k1, k2},
  c1 = paramValue[params, "chi1", 0];
  c2 = paramValue[params, "chi2", 0];
  k1 = paramValue[params, "kap1", 1];
  k2 = paramValue[params, "kap2", 1];
  <|
   "eps" -> paramValue[params, "eps", 1],
   "nu" -> paramValue[params, "nu", Missing["nu"]],
   "delta" -> paramValue[params, "delta",
     Sqrt[1 - 4 paramValue[params, "nu", 0]]],
   "chiS" -> (c1 + c2)/2,
   "chiA" -> (c1 - c2)/2,
   "kappaS" -> ((k1 - 1)*c1^2 + (k2 - 1)*c2^2)/2,
   "kappaA" -> ((k1 - 1)*c1^2 - (k2 - 1)*c2^2)/2,
   "SO" -> paramValue[params, "SO", 1]
   |>
  ];

numericElements[model_Association, params_Association, wp_] :=
  Association @ KeyValueMap[
    #1 -> N[#2 /. parameterRules[params], wp] &,
    model["QK"]];

numericExpr[expr_, params_Association, wp_] :=
  N[expr /. parameterRules[params], wp];

QKAllowedPNOrders[] := {0, 1, 1.5, 2, 2.5, 3};

validPNOrderQ[pn_] := AnyTrue[QKAllowedPNOrders[],
   Chop[N[pn - #]] == 0 &
   ];

validatePNOrder[pn_, head_Symbol] := If[validPNOrderQ[pn],
   True,
   Message[head::badpn, pn, QKAllowedPNOrders[]];
   False
   ];

pnMaxPower[pn_] := Module[{val = N[pn]},
  Which[
   val <= 0, 0,
   val <= 1, 2,
   val <= 1.5, 3,
   val <= 2, 4,
   val <= 2.5, 5,
   True, 6
   ]
  ];

truncatePN[expr_, pn_] := Module[{max = pnMaxPower[pn]},
  Normal[Series[expr, {\[Epsilon], 0, max}]]
  ];

truncatePrimitivePN[expr_, pn_] := Module[{max = pnMaxPower[pn]},
  Normal[Series[expr, {eps, 0, max}]]
  ];

numericElements[model_Association, params_Association, wp_, pn_] :=
  Association @ KeyValueMap[
    #1 -> N[truncatePN[#2, pn] /. parameterRules[params], wp] &,
    model["QK"]];

numericExpr[expr_, params_Association, wp_, pn_] :=
  N[truncatePN[expr, pn] /. parameterRules[params], wp];

QKLabelsFromInitialData[primitiveParams_Association,
  initialData_Association, OptionsPattern[]] := Module[
  {root, file, labels, wp, pn, required, r0, rd0, p0, rules, en, ell},
  root = Replace[OptionValue["RootDirectory"], Automatic -> $QKOrbitsRoot];
  wp = OptionValue[WorkingPrecision];
  pn = OptionValue["PNOrder"];
  If[! validatePNOrder[pn, QKLabelsFromInitialData], Return[$Failed]];
  required = {"r", "phi", "rdot", "phidot"};
  If[Sort[Keys[initialData]] =!= Sort[required],
   Message[QKLabelsFromInitialData::badic, initialData];
   Return[$Failed];
   ];
  file = FileNameJoin[{root, "src", "Models",
      "conserved_labels_3pn_aligned_spin.wl"}];
  If[! FileExistsQ[file],
   Message[QKLabelsFromInitialData::nofile, file];
   Return[$Failed];
   ];
  labels = Block[{$Context = "QKOrbits`Private`",
     $ContextPath = {"System`"}}, Get[file]] /. globalSymbolRules[];
  If[! AssociationQ[labels] || ! KeyExistsQ[labels, "E"] ||
    ! KeyExistsQ[labels, "J"],
   Message[QKLabelsFromInitialData::badlabels, file];
   Return[$Failed];
   ];
  r0 = initialValue[initialData, "r"];
  rd0 = initialValue[initialData, "rdot"];
  p0 = initialValue[initialData, "phidot"];
  If[! FreeQ[{r0, rd0, p0}, _Missing],
   Message[QKLabelsFromInitialData::badic, initialData];
   Return[$Failed];
   ];
  rules = Join[
    primitiveRules[primitiveParams],
    {s -> 1/N[r0, wp], rd -> N[rd0, wp], p -> N[p0, wp]}
    ];
  en = N[truncatePrimitivePN[labels["E"], pn] /. rules, wp];
  ell = N[truncatePrimitivePN[labels["J"], pn] /. rules, wp];
  <|"En" -> en, "L" -> ell|>
  ];

conservedLabelExpressions[rootOpt_] := Module[{root, file, labels},
  root = Replace[rootOpt, Automatic -> $QKOrbitsRoot];
  file = FileNameJoin[{root, "src", "Models",
      "conserved_labels_3pn_aligned_spin.wl"}];
  If[! FileExistsQ[file],
   Message[QKLabelsFromInitialData::nofile, file];
   Return[$Failed];
   ];
  labels = Block[{$Context = "QKOrbits`Private`",
      $ContextPath = {"System`"}}, Get[file]] /. globalSymbolRules[];
  If[! AssociationQ[labels] || ! KeyExistsQ[labels, "E"] ||
    ! KeyExistsQ[labels, "J"],
   Message[QKLabelsFromInitialData::badlabels, file];
   Return[$Failed];
   ];
  labels
  ];

fullInitialKeys[] := {"r", "phi", "rdot", "phidot"};

requireFullInitialData[initialData_Association, wp_, head_Symbol] := Module[
  {required = fullInitialKeys[]},
  If[Sort[Keys[initialData]] =!= Sort[required],
   Message[head::badic, initialData];
   Return[$Failed];
   ];
  AssociationMap[N[initialData[#], wp] &, required]
  ];

precisionDigits[wp_] := If[IntegerQ[wp] || NumberQ[N[wp]],
   N[wp],
   30
   ];

realNumericRoots[expr_, var_, wp_] := Module[{roots, tol, digits},
  digits = precisionDigits[wp];
  tol = 10^(-Min[20, Max[8, Floor[digits/2]]]);
  roots = Quiet[var /. NSolve[expr == 0, var, WorkingPrecision -> wp]];
  DeleteDuplicates[
   Sort[
    Select[Chop[Re[N[#, wp]], tol] & /@
      Select[roots, NumericQ[N[#]] && Abs[Im[N[#, wp]]] < tol &],
     NumericQ[N[#]] &]],
   Abs[#1 - #2] < tol &]
  ];

parabolicVelocitySignValue[sign_, head_Symbol] := Module[{s = sign},
  Which[
   MemberQ[{1, "+", "Positive", "positive", "Outgoing", "outgoing",
     "Prograde", "prograde"}, s], 1,
   MemberQ[{-1, "-", "Negative", "negative", "Incoming", "incoming",
     "Retrograde", "retrograde"}, s], -1,
   True,
   Message[head::parabolicsign, sign];
   $Failed
   ]
  ];

selectSignedRoot[roots_List, guess_, sign_] := Module[{signed, target},
  target = sign Abs[N[guess]];
  signed = Select[roots, sign N[#] >= 0 &];
  If[signed === {}, Return[$Failed]];
  First[SortBy[signed, Abs[N[# - target]] &]]
  ];

completeParabolicInitialData[primitiveParams_Association,
  initialData_Association, root_, wp_, pn_, velocitySign_,
  head_Symbol] := Module[
  {keys, hasRdot, hasPhidot, labels, r0, phi0, rd0, p0, ss, expr, x,
   roots, guess, solution, sign},
  sign = parabolicVelocitySignValue[velocitySign, head];
  If[sign === $Failed, Return[$Failed]];
  keys = Sort[Keys[initialData]];
  hasRdot = KeyExistsQ[initialData, "rdot"];
  hasPhidot = KeyExistsQ[initialData, "phidot"];
  If[! KeyExistsQ[initialData, "r"] || ! KeyExistsQ[initialData, "phi"] ||
    hasRdot === hasPhidot || Length[keys] =!= 3,
   Message[head::parabolicic, initialData];
   Return[$Failed];
   ];
  labels = conservedLabelExpressions[root];
  If[labels === $Failed, Return[$Failed]];
  r0 = N[initialValue[initialData, "r"], wp];
  phi0 = N[initialValue[initialData, "phi"], wp];
  ss = 1/r0;
  expr = N[truncatePrimitivePN[labels["E"], pn] /.
      Join[primitiveRules[primitiveParams], {s -> ss}], wp];
  If[hasPhidot,
   p0 = N[initialValue[initialData, "phidot"], wp];
   roots = realNumericRoots[expr /. p -> p0 /. rd -> x, x, wp];
   guess = Sqrt[Max[0, N[2 ss - (p0/ss)^2, wp]]];
   solution = selectSignedRoot[roots, guess, sign];
   If[solution === $Failed,
    Message[head::parabolicnosol, "rdot", velocitySign, initialData];
    Return[$Failed];
    ];
   Return[<|"r" -> r0, "phi" -> phi0, "rdot" -> N[solution, wp],
     "phidot" -> p0|>];
   ];
  rd0 = N[initialValue[initialData, "rdot"], wp];
  roots = realNumericRoots[expr /. rd -> rd0 /. p -> x, x, wp];
  guess = ss Sqrt[Max[0, N[2 ss - rd0^2, wp]]];
  solution = selectSignedRoot[roots, guess, sign];
  If[solution === $Failed,
   Message[head::parabolicnosol, "phidot", velocitySign, initialData];
   Return[$Failed];
   ];
  <|"r" -> r0, "phi" -> phi0, "rdot" -> rd0,
   "phidot" -> N[solution, wp]|>
  ];

completeInitialDataForModel[model_Association, primitiveParams_Association,
  initialData_Association, root_, wp_, pn_, velocitySign_,
  head_Symbol] := If[
  model["OrbitType"] === "Parabolic",
  completeParabolicInitialData[primitiveParams, initialData, root, wp, pn,
   velocitySign, head],
  requireFullInitialData[initialData, wp, head]
  ];

initialScalesFromData[initialData_Association, wp_] := Module[
  {r0, rd0, p0, invR, vt, v2},
  r0 = N[initialData["r"], wp];
  rd0 = N[initialData["rdot"], wp];
  p0 = N[initialData["phidot"], wp];
  invR = 1/r0;
  vt = p0/invR;
  v2 = rd0^2 + vt^2;
  <|"vSquared" -> N[v2, wp], "oneOverR" -> N[invR, wp]|>
  ];

QKLabelsFromInitialData::nofile =
  "Conserved-label file not found: `1`.";
QKLabelsFromInitialData::badlabels =
  "File is not a valid conserved-label model: `1`.";
QKLabelsFromInitialData::badic =
  "Initial data must contain exactly r, phi, rdot, and phidot: `1`.";
QKLabelsFromInitialData::badpn =
  "Unsupported PNOrder `1`. Use one of `2`.";
QKOrbit::badpn = "Unsupported PNOrder `1`. Use one of `2`.";
QKInitialData::badpn = "Unsupported PNOrder `1`. Use one of `2`.";
QKOrbitFromInitialData::badpn =
  "Unsupported PNOrder `1`. Use one of `2`.";
QKParameterValuesFromInitialData::badpn =
  "Unsupported PNOrder `1`. Use one of `2`.";
QKOrbitFromInitialData::badic =
  "Initial data must contain exactly r, phi, rdot, and phidot for bound/unbound models: `1`.";
QKParameterValuesFromInitialData::badic =
  "Initial data must contain exactly r, phi, rdot, and phidot for bound/unbound models: `1`.";
QKOrbitFromInitialData::parabolicic =
  "Parabolic initial data must contain r, phi, and exactly one of rdot or phidot; the missing velocity is solved from En == 0. Received: `1`.";
QKParameterValuesFromInitialData::parabolicic =
  "Parabolic initial data must contain r, phi, and exactly one of rdot or phidot; the missing velocity is solved from En == 0. Received: `1`.";
QKOrbitFromInitialData::parabolicnosol =
  "Could not solve a real parabolic `1` with ParabolicVelocitySign -> `2` from En == 0 for initial data `3`.";
QKParameterValuesFromInitialData::parabolicnosol =
  "Could not solve a real parabolic `1` with ParabolicVelocitySign -> `2` from En == 0 for initial data `3`.";
QKOrbitFromInitialData::parabolicsign =
  "ParabolicVelocitySign must be 1 or -1, or an equivalent sign string. Received: `1`.";
QKParameterValuesFromInitialData::parabolicsign =
  "ParabolicVelocitySign must be 1 or -1, or an equivalent sign string. Received: `1`.";
QKOrbitFromInitialData::boundenergy =
  "Bound QK initial data must give En < 0 at the requested PNOrder. Got En = `1` from initial data `2`.";
QKParameterValuesFromInitialData::boundenergy =
  "Bound QK initial data must give En < 0 at the requested PNOrder. Got En = `1` from initial data `2`.";

qkSetupFromInitialData[model_Association, primitiveParams_Association,
  initialData_Association, root_, wp_, pn_, velocitySign_,
  head_Symbol] := Module[
  {completedInitialData, initialScales, labels, orbitLabels, params,
   qkParameters},
  If[! validatePNOrder[pn, head], Return[$Failed]];
  completedInitialData = completeInitialDataForModel[model, primitiveParams,
    initialData, root, wp, pn, velocitySign, head];
  If[completedInitialData === $Failed, Return[$Failed]];
  initialScales = initialScalesFromData[completedInitialData, wp];
  labels = QKLabelsFromInitialData[primitiveParams, completedInitialData,
    "RootDirectory" -> root, WorkingPrecision -> wp, "PNOrder" -> pn];
  If[labels === $Failed, Return[$Failed]];
  If[model["OrbitType"] === "Bound" && N[labels["En"]] >= 0,
   Message[head::boundenergy, labels["En"], completedInitialData];
   Return[$Failed];
   ];
  orbitLabels = If[model["OrbitType"] === "Parabolic",
    <|"L" -> labels["L"]|>,
    labels
    ];
  params = Join[orbitLabels, qkParamsFromPrimitive[primitiveParams]];
  qkParameters = Association @ KeyValueMap[
     #1 -> cleanParameterValue[#2, wp] &,
     numericElements[model, params, wp, pn]];
  <|"InitialData" -> completedInitialData,
   "InitialScales" -> initialScales,
   "ConservedLabels" -> labels, "OrbitParameters" -> params,
   "QKParameters" -> qkParameters|>
  ];

QKParameterValuesFromInitialData[model_Association,
  primitiveParams_Association, initialData_Association,
  opts : OptionsPattern[]] := Module[
  {wp, pn, root, velocitySign},
  wp = OptionValue[WorkingPrecision];
  pn = OptionValue["PNOrder"];
  root = OptionValue["RootDirectory"];
  velocitySign = OptionValue["ParabolicVelocitySign"];
  qkSetupFromInitialData[model, primitiveParams, initialData, root, wp, pn,
   velocitySign, QKParameterValuesFromInitialData]
  ];

QKOrbitFromInitialData[model_Association, primitiveParams_Association,
  initialData_Association, times_List, opts : OptionsPattern[]] := Module[
  {wp, pn, root, velocitySign, setup, params, completedInitialData},
  wp = OptionValue[WorkingPrecision];
  pn = OptionValue["PNOrder"];
  root = OptionValue["RootDirectory"];
  velocitySign = OptionValue["ParabolicVelocitySign"];
  setup = qkSetupFromInitialData[model, primitiveParams, initialData, root,
    wp, pn, velocitySign, QKOrbitFromInitialData];
  If[setup === $Failed, Return[$Failed]];
  params = setup["OrbitParameters"];
  completedInitialData = setup["InitialData"];
  QKOrbit[model, params, completedInitialData, times,
   Sequence @@ FilterRules[{opts}, Options[QKOrbit]]]
  ];

safeElement[e_Association, key_String] := Lookup[e, key, 0];

boundCycle[u_?NumericQ] := Floor[(u + Pi)/(2 Pi)];

boundTrueAnomaly[u_?NumericQ, e_?NumericQ] := Module[{k, ub, vb},
  k = boundCycle[u];
  ub = u - 2 Pi k;
  vb = 2 ArcTan[Sqrt[1 - e] Cos[ub/2],
     Sqrt[1 + e] Sin[ub/2]];
  vb + 2 Pi k
  ];

unboundTrueAnomaly[u_?NumericQ, e_?NumericQ] := Module[{arg},
  If[Abs[N[u]] < 10^-40, Return[0]];
  arg = (e - Cosh[u])/(e Cosh[u] - 1);
  Sign[u] ArcCos[arg]
  ];

qkFunctions[model_Association, params_Association, opts : OptionsPattern[]] :=
 Module[{wp, e, n, k, ar, er, et, ePhi, gt, ft, ht, it, fPhi,
   gPhi, hPhi, iPhi, orbitType, vOfU, rOfU, phiCore, timeRaw,
   dvdu, drdu, dtdu, rExpr, tExpr, phiExpr, drExpr, dtExpr,
   phidotExpr, phidotOfS},

  wp = OptionValue[WorkingPrecision];
  e = numericElements[model, params, wp, OptionValue["PNOrder"]];
  phidotExpr = numericExpr[model["PhidotPoly"], params, wp,
    OptionValue["PNOrder"]];
  phidotOfS[ss_?NumericQ] := N[phidotExpr /. s -> ss, wp];
  orbitType = model["OrbitType"];

  If[orbitType === "Parabolic",
   rExpr = e["rOfW"];
   tExpr = e["tOfW"];
   phiExpr = e["phiOfW"];
   drExpr = D[rExpr, w];
   dtExpr = D[tExpr, w];
   vOfU[u_?NumericQ] := 2 ArcTan[u];
   rOfU[u_?NumericQ] := N[rExpr /. w -> u, wp];
   timeRaw[u_?NumericQ] := N[tExpr /. w -> u, wp];
   phiCore[u_?NumericQ] := N[phiExpr /. w -> u, wp];
   dvdu[u_?NumericQ] := 2/(1 + u^2);
   drdu[u_?NumericQ] := N[drExpr /. w -> u, wp];
   dtdu[u_?NumericQ] := N[dtExpr /. w -> u, wp];
   Return[<|"elements" -> e, "vOfU" -> vOfU, "rOfU" -> rOfU,
     "timeRaw" -> timeRaw, "phiCore" -> phiCore, "dvdu" -> dvdu,
     "drdu" -> drdu, "dtdu" -> dtdu,
     "phidotOfS" -> phidotOfS,
     "scaleL" -> N[paramValue[params, "L", 1], wp]|>]
   ];

  n = e["n"]; k = e["K"]; ar = e["ar"]; er = e["er"];
  et = e["et"]; ePhi = e["ePhi"];
  gt = safeElement[e, "gt"]; ft = safeElement[e, "ft"];
  ht = safeElement[e, "ht"]; it = safeElement[e, "it"];
  fPhi = safeElement[e, "fPhi"]; gPhi = safeElement[e, "gPhi"];
  hPhi = safeElement[e, "hPhi"]; iPhi = safeElement[e, "iPhi"];
  If[orbitType === "Unbound",
   vOfU[u_?NumericQ] := unboundTrueAnomaly[u, ePhi];
   rOfU[u_?NumericQ] := ar (er Cosh[u] - 1);
   dvdu[u_?NumericQ] := Sqrt[ePhi^2 - 1]/(ePhi Cosh[u] - 1);
   drdu[u_?NumericQ] := ar er Sinh[u];
   timeRaw[u_?NumericQ] := Module[{v = vOfU[u]},
     (et Sinh[u] - u + gt v + ft Sin[v] + ht Sin[2 v] +
        it Sin[3 v])/n
     ];
   dtdu[u_?NumericQ] := Module[{v = vOfU[u], vp = dvdu[u]},
     ((et Cosh[u] - 1) + gt vp + ft Cos[v] vp +
        2 ht Cos[2 v] vp + 3 it Cos[3 v] vp)/n
     ],

   vOfU[u_?NumericQ] := boundTrueAnomaly[u, ePhi];
   rOfU[u_?NumericQ] := ar (1 - er Cos[u]);
   dvdu[u_?NumericQ] := Sqrt[1 - ePhi^2]/(1 - ePhi Cos[u]);
   drdu[u_?NumericQ] := ar er Sin[u];
   timeRaw[u_?NumericQ] := Module[{v = vOfU[u]},
     (u - et Sin[u] + gt (v - u) + ft Sin[v] + ht Sin[2 v] +
        it Sin[3 v])/n
     ];
   dtdu[u_?NumericQ] := Module[{v = vOfU[u], vp = dvdu[u]},
     (1 - et Cos[u] + gt (vp - 1) + ft Cos[v] vp +
        2 ht Cos[2 v] vp + 3 it Cos[3 v] vp)/n
     ]
   ];

  phiCore[u_?NumericQ] := Module[{v = vOfU[u]},
    k (v + fPhi Sin[2 v] + gPhi Sin[3 v] + hPhi Sin[4 v] +
       iPhi Sin[5 v])
    ];

  <|"elements" -> e, "vOfU" -> vOfU, "rOfU" -> rOfU,
   "timeRaw" -> timeRaw, "phiCore" -> phiCore, "dvdu" -> dvdu,
   "drdu" -> drdu, "dtdu" -> dtdu, "phidotOfS" -> phidotOfS|>
  ];

uGuess[orbitType_, tau_, funcs_, n_] := Module[{x = N[tau], lscale},
  If[Abs[x] < 10^-40, Return[0]];
  Switch[orbitType,
   "Bound", n x,
   "Parabolic",
   lscale = Lookup[funcs, "scaleL", 1];
   Sign[x] Max[10^-8, (6 Abs[x]/lscale^3 + 10^-24)^(1/3)],
   _, Sign[x] Max[10^-8, ArcSinh[Abs[n x] + 10^-8]]
   ]
  ];

realPart[x_, wp_] := N[Chop[Re[x]], wp];

cleanParameterValue[x_, wp_] := Module[{val = N[x, wp]},
  If[FreeQ[val, w],
   realPart[val, wp],
   Chop[val]
   ]
  ];

solveAnomaly[model_Association, funcs_Association, tau_?NumericQ, wp_,
  acc_, prec_] := Module[{guess, n, orbitType, sol},
  If[Abs[N[tau]] < 10^-40, Return[0]];
  orbitType = model["OrbitType"];
  n = Lookup[funcs["elements"], "n", 1];
  guess = uGuess[orbitType, tau, funcs, n];
  sol = Quiet@FindRoot[
     realPart[funcs["timeRaw"][u], wp] == realPart[tau, wp],
     {u, realPart[guess, wp]},
     WorkingPrecision -> wp,
     AccuracyGoal -> acc,
     PrecisionGoal -> prec,
     MaxIterations -> 100
     ];
  realPart[u /. sol, wp]
  ];

solveAnomalyWithGuess[funcs_Association, tau_?NumericQ, guess_?NumericQ,
  wp_, acc_, prec_] := Module[{sol},
  If[Abs[N[tau]] < 10^-40, Return[0]];
  sol = Quiet@FindRoot[
     realPart[funcs["timeRaw"][u], wp] == realPart[tau, wp],
     {u, realPart[guess, wp]},
     WorkingPrecision -> wp,
     AccuracyGoal -> acc,
     PrecisionGoal -> prec,
     MaxIterations -> 100
     ];
  realPart[u /. sol, wp]
  ];

stateFromAnomaly[funcs_Association, time_?NumericQ, tau_, u_, phi0_, wp_] :=
 Module[{r, phi, dt, rdot, phidot},
  r = funcs["rOfU"][u];
  phi = phi0 + funcs["phiCore"][u];
  dt = funcs["dtdu"][u];
  rdot = funcs["drdu"][u]/dt;
  phidot = funcs["phidotOfS"][1/r];
  <|"t" -> realPart[time, wp], "r" -> realPart[r, wp],
   "phi" -> realPart[phi, wp], "rdot" -> realPart[rdot, wp],
   "phidot" -> realPart[phidot, wp]|>
  ];

stateFromFunctions[model_Association, funcs_Association, time_?NumericQ,
  t0_, phi0_, wp_, acc_, prec_] := Module[
  {tau, u},
  tau = N[time - t0, wp];
  u = solveAnomaly[model, funcs, tau, wp, acc, prec];
  stateFromAnomaly[funcs, time, tau, u, phi0, wp]
  ];

stateAtTime[model_Association, params_Association, time_?NumericQ,
  opts : OptionsPattern[]] := Module[
  {wp, acc, prec, pn, t0, phi0, tau, funcs},
  wp = OptionValue[WorkingPrecision];
  acc = OptionValue[AccuracyGoal];
  prec = OptionValue[PrecisionGoal];
  pn = OptionValue["PNOrder"];
  If[! validatePNOrder[pn, QKInitialData], Return[$Failed]];
  t0 = OptionValue["t0"];
  phi0 = OptionValue["phi0"];
  tau = N[time - t0, wp];
  funcs = qkFunctions[model, params, WorkingPrecision -> wp,
    AccuracyGoal -> acc, PrecisionGoal -> prec, "PNOrder" -> pn,
    "t0" -> t0, "phi0" -> phi0];
  stateFromFunctions[model, funcs, time, t0, phi0, wp, acc, prec]
  ];

orbitOutput[states_List] := <|
  "t" -> states[[All, "t"]],
  "r" -> states[[All, "r"]],
  "phi" -> states[[All, "phi"]],
  "rdot" -> states[[All, "rdot"]],
  "phidot" -> states[[All, "phidot"]]
  |>;

initialAnomalyGuess[model_Association, funcs_Association,
  initialData_Association] := Module[
  {orbitType, r0, rd0, sign, e, ar, er, x},
  orbitType = model["OrbitType"];
  r0 = initialValue[initialData, "r"];
  rd0 = initialValue[initialData, "rdot"];
  sign = If[NumericQ[N[rd0]] && N[rd0] < 0, -1, 1];
  If[MissingQ[r0], Return[0]];
  e = funcs["elements"];
  Switch[orbitType,
   "Bound",
   ar = e["ar"]; er = e["er"];
   x = Clip[N[(1 - r0/ar)/er], {-1, 1}];
   sign*ArcCos[x],
   "Unbound",
   ar = e["ar"]; er = e["er"];
   x = Max[1, N[(r0/ar + 1)/er]];
   sign*ArcCosh[x],
   "Parabolic",
   sign*Max[10^-8, Sqrt[Abs[N[r0]]]/Max[1, Abs[Lookup[e, "L", 1]]]],
   _, 0
   ]
  ];

initialAnomalyFromData[model_Association, funcs_Association,
  initialData_Association, wp_, acc_, prec_] := Module[
  {r0, guess, sol, tolDigits, tol},
  r0 = initialValue[initialData, "r"];
  If[MissingQ[r0],
   Message[QKOrbit::badic, initialData];
   Return[$Failed];
   ];
  tolDigits = If[NumberQ[N[acc]], N[acc]/2, precisionDigits[wp]/2];
  tol = 10^(-Max[8, Floor[tolDigits]]);
  If[Abs[N[funcs["rOfU"][0] - r0, wp]] < tol, Return[0]];
  guess = initialAnomalyGuess[model, funcs, initialData];
  If[Abs[N[funcs["rOfU"][guess] - r0, wp]] < tol,
   Return[N[guess, wp]]];
  sol = Quiet@FindRoot[
     funcs["rOfU"][u] == N[r0, wp],
     {u, N[guess, wp]},
     WorkingPrecision -> wp,
     AccuracyGoal -> acc,
     PrecisionGoal -> prec,
     MaxIterations -> 100
     ];
  u /. sol
  ];

QKOrbit[model_Association, params_Association, initialData_Association,
  times_List, opts : OptionsPattern[]] := Module[
  {wp, acc, prec, pn, funcs, states, previousU = None, previousTau,
   u0, tau0, phiInitial, phiShift, tStart, required},
  wp = OptionValue[WorkingPrecision];
  acc = OptionValue[AccuracyGoal];
  prec = OptionValue[PrecisionGoal];
  pn = OptionValue["PNOrder"];
  If[! validatePNOrder[pn, QKOrbit], Return[$Failed]];
  required = {"r", "phi", "rdot", "phidot"};
  If[Sort[Keys[initialData]] =!= Sort[required],
   Message[QKOrbit::badic, initialData];
   Return[$Failed];
   ];
  funcs = qkFunctions[model, params, WorkingPrecision -> wp,
    AccuracyGoal -> acc, PrecisionGoal -> prec, "PNOrder" -> pn];
  phiInitial = initialValue[initialData, "phi"];
  u0 = initialAnomalyFromData[model, funcs, initialData, wp, acc, prec];
  If[u0 === $Failed, Return[$Failed]];
  tau0 = funcs["timeRaw"][u0];
  phiShift = N[phiInitial, wp] - funcs["phiCore"][u0];
  tStart = First[times];
  previousU = u0;
  previousTau = tau0;
  states = Table[
    Module[{tau = N[tau0 + t - tStart, wp], uval, guess, dt},
     dt = funcs["dtdu"][previousU];
     guess = If[NumericQ[N[dt]] && Abs[N[dt]] > 10^-30,
       previousU + (tau - previousTau)/dt,
       previousU
       ];
     uval = solveAnomalyWithGuess[funcs, tau, guess, wp, acc, prec];
     previousU = uval;
     previousTau = tau;
     stateFromAnomaly[funcs, t, tau, uval, phiShift, wp]
     ],
    {t, times}];
  orbitOutput[states]
  ];

QKOrbit::badic =
  "Initial data must contain exactly the physical fields r, phi, rdot, and phidot: `1`.";

QKInitialData[model_Association, params_Association, time_?NumericQ,
  opts : OptionsPattern[]] := Module[{state},
  state = stateAtTime[model, params, time, opts];
  <|"r" -> state["r"], "phi" -> state["phi"], "rdot" -> state["rdot"],
   "phidot" -> state["phidot"]|>
  ];

End[];

EndPackage[];

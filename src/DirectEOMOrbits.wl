(* ::Package:: *)

BeginPackage["DirectEOMOrbits`"];

DirectEOMLoad::usage =
  "DirectEOMLoad[] loads the prepared direct polar acceleration EOM.";

DirectEOMOrbit::usage =
  "DirectEOMOrbit[eom, primitiveParams, initialData, times] integrates the \
direct second-order polar EOM from initial data {r, phi, rdot, phidot} and \
returns an Association with t, r, phi, rdot, phidot. Use \
\"Include2p5PNRadiationReaction\" -> True to add the leading 2.5PN \
nonspinning radiation-reaction acceleration.";

DirectEOMAllowedPNOrders::usage =
  "DirectEOMAllowedPNOrders[] returns the PN truncations accepted by the \
release.";

Begin["`Private`"];

$DirectEOMOrbitsRoot = If[StringQ[$InputFileName] && $InputFileName =!= "",
   DirectoryName[DirectoryName[$InputFileName]],
   Directory[]
   ];

Options[DirectEOMLoad] = {"RootDirectory" -> Automatic};
Options[DirectEOMOrbit] = {WorkingPrecision -> MachinePrecision,
   AccuracyGoal -> Automatic, PrecisionGoal -> Automatic, "PNOrder" -> 3,
   MaxStepSize -> Automatic, Method -> Automatic,
   "Include2p5PNRadiationReaction" -> False};

DirectEOMAllowedPNOrders[] := {0, 1, 1.5, 2, 2.5, 3};

validPNOrderQ[pn_] := AnyTrue[DirectEOMAllowedPNOrders[],
   Chop[N[pn - #]] == 0 &
   ];

validatePNOrder[pn_] := If[validPNOrderQ[pn],
   True,
   Message[DirectEOMOrbit::badpn, pn, DirectEOMAllowedPNOrders[]];
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

truncatePN[expr_, pn_] := Normal[Series[expr, {eps, 0, pnMaxPower[pn]}]];

paramValue[params_Association, key_String, default_] :=
  Lookup[params, key, default];

directRules[params_Association] := {
   eps -> paramValue[params, "eps", 1],
   nu -> paramValue[params, "nu", Missing["nu"]],
   delta -> paramValue[params, "delta",
     Sqrt[1 - 4 paramValue[params, "nu", 0]]],
   chi1 -> paramValue[params, "chi1", 0],
   chi2 -> paramValue[params, "chi2", 0],
   kap1 -> paramValue[params, "kap1", 1],
   kap2 -> paramValue[params, "kap2", 1]
   };

globalSymbolRules[] := {
   Global`eps -> eps,
   Global`nu -> nu,
   Global`delta -> delta,
   Global`chi1 -> chi1,
   Global`chi2 -> chi2,
   Global`kap1 -> kap1,
   Global`kap2 -> kap2,
   Global`s -> s,
   Global`rd -> rd,
   Global`p -> p,
   Global`vt -> vt,
   Global`v2 -> v2
   };

initialValue[ic_Association, key_String] :=
  If[KeyExistsQ[ic, key], ic[key], Missing[key]];

radiationReaction25Polar[] := Module[{vtLocal, v2Local, a25, b25,
   aN25, aL25},
  vtLocal = p/s;
  v2Local = rd^2 + vtLocal^2;
  a25 = eps^5*(8*nu/5)*s*rd*(17*s/3 - 3*v2Local);
  b25 = eps^5*(8*nu/5)*s*(3*s + v2Local);
  aN25 = -s^2*(a25 + b25*rd);
  aL25 = -s^2*b25*vtLocal;
  <|"rddot" -> aN25, "phiddot" -> s*aL25|>
  ];

DirectEOMLoad[OptionsPattern[]] := Module[{root, file},
  root = Replace[OptionValue["RootDirectory"],
    Automatic -> $DirectEOMOrbitsRoot];
  file = FileNameJoin[{root, "src", "Models",
      "direct_polar_acceleration_eom_3pn_aligned_spin.wl"}];
  If[! FileExistsQ[file],
   Message[DirectEOMLoad::nofile, file];
   Return[$Failed];
   ];
  Get[file] /. globalSymbolRules[]
  ];

DirectEOMLoad::nofile = "Direct EOM file not found: `1`.";

DirectEOMOrbit[eom_Association, primitiveParams_Association,
  initialData_Association, times_List, OptionsPattern[]] := Module[
  {wp, acc, prec, pn, step, method, includeRR25, rr25, tStart, tauEnd,
   rddotExpr, phiddotExpr, r0, phi0, rd0, p0, sol, states,
   ndsolveOpts, required},

  wp = OptionValue[WorkingPrecision];
  acc = OptionValue[AccuracyGoal];
  prec = OptionValue[PrecisionGoal];
  pn = OptionValue["PNOrder"];
  If[! validatePNOrder[pn], Return[$Failed]];
  step = OptionValue[MaxStepSize];
  method = OptionValue[Method];
  includeRR25 = TrueQ[OptionValue["Include2p5PNRadiationReaction"]];
  required = {"r", "phi", "rdot", "phidot"};
  If[Sort[Keys[initialData]] =!= Sort[required],
   Message[DirectEOMOrbit::badic, initialData];
   Return[$Failed];
   ];

  tStart = First[times];
  tauEnd = N[Last[times] - tStart, wp];

  r0 = initialValue[initialData, "r"];
  phi0 = initialValue[initialData, "phi"];
  rd0 = initialValue[initialData, "rdot"];
  p0 = initialValue[initialData, "phidot"];
  If[! FreeQ[{r0, phi0, rd0, p0}, _Missing],
   Message[DirectEOMOrbit::badic, initialData];
   Return[$Failed];
   ];

  rr25 = If[includeRR25 && pnMaxPower[pn] >= 5,
    radiationReaction25Polar[],
    <|"rddot" -> 0, "phiddot" -> 0|>
    ];

  rddotExpr = N[truncatePN[eom["polarODE", "rddot"] + rr25["rddot"], pn] /.
     directRules[primitiveParams], wp];
  phiddotExpr = N[truncatePN[eom["polarODE", "phiddot"] + rr25["phiddot"],
      pn] /.
     directRules[primitiveParams], wp];

  ndsolveOpts = Sequence[
    WorkingPrecision -> wp,
    AccuracyGoal -> acc,
    PrecisionGoal -> prec,
    Method -> method,
    MaxSteps -> Infinity
    ];

  sol = Quiet[
    NDSolveValue[
    {
     rr'[tt] == vv[tt],
     vv'[tt] == Evaluate[
       rddotExpr /. {s -> 1/rr[tt], rd -> vv[tt], p -> om[tt]}],
     pp'[tt] == om[tt],
     om'[tt] == Evaluate[
       phiddotExpr /. {s -> 1/rr[tt], rd -> vv[tt], p -> om[tt]}],
     rr[0] == N[r0, wp],
     vv[0] == N[rd0, wp],
     pp[0] == N[phi0, wp],
     om[0] == N[p0, wp]
     },
    {rr, vv, pp, om},
    {tt, 0, tauEnd},
    Evaluate[ndsolveOpts],
    If[step === Automatic, Sequence @@ {}, MaxStepSize -> step]
    ],
    NDSolveValue::precw
    ];

  states = Table[
    Module[{tau = N[t - tStart, wp], rv, rdv, phiv, pv},
     rv = sol[[1]][tau];
     rdv = sol[[2]][tau];
     phiv = sol[[3]][tau];
     pv = sol[[4]][tau];
     <|"t" -> N[t, wp], "tau" -> tau, "r" -> N[rv, wp],
      "phi" -> N[phiv, wp], "rdot" -> N[rdv, wp],
      "phidot" -> N[pv, wp]|>
     ],
    {t, times}
    ];

  <|"t" -> states[[All, "t"]], "r" -> states[[All, "r"]],
   "phi" -> states[[All, "phi"]], "rdot" -> states[[All, "rdot"]],
   "phidot" -> states[[All, "phidot"]]|>
  ];

DirectEOMOrbit::badic =
  "Initial data must contain r, phi, rdot, and phidot: `1`.";
DirectEOMOrbit::badpn = "Unsupported PNOrder `1`. Use one of `2`.";

End[];

EndPackage[];

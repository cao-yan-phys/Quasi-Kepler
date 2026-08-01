(* ::Package:: *)

BeginPackage["SpinningBinary3PNOrbits`"];

SpinningBinary3PNLoad;
SpinningBinary3PNAllowedPNOrders;
SpinningBinary3PNAcceleration;
SpinningBinary3PNOrbit;
Begin["`Private`"];

$SpinningBinary3PNRoot = If[StringQ[$InputFileName] && $InputFileName =!= "",
   DirectoryName[DirectoryName[$InputFileName]],
   Directory[]
   ];

If[! NameQ["DirectEOMOrbits`DirectEOMLoad"],
  Get[FileNameJoin[{DirectoryName[$InputFileName], "DirectEOMOrbits.wl"}]]
  ];

If[! NameQ["OsculatingElements3D`Osculating3DSphericalFromState"],
  Get[FileNameJoin[{DirectoryName[$InputFileName],
     "OsculatingElements3D.wl"}]]
  ];

Options[SpinningBinary3PNLoad] = {"RootDirectory" -> Automatic};
Options[SpinningBinary3PNAcceleration] = {"PNOrder" -> 3,
   "SpinTerms" -> True};
Options[SpinningBinary3PNOrbit] = {WorkingPrecision -> MachinePrecision,
   AccuracyGoal -> Automatic, PrecisionGoal -> Automatic, "PNOrder" -> 3,
   MaxStepSize -> Automatic, Method -> Automatic, "SpinTerms" -> True,
   "SpinPrecession" -> True};

SpinningBinary3PNAllowedPNOrders[] := {0, 1, 1.5, 2, 2.5, 3};

validPNOrderQ[pn_] := AnyTrue[SpinningBinary3PNAllowedPNOrders[],
   Chop[N[pn - #]] == 0 &
   ];

includeTerm[pn_, min_, expr_, zero_] := If[N[pn] >= min, expr, zero];

paramValue[params_Association, key_String, default_] :=
  Lookup[params, key, default];

massFractions[params_Association] := Module[{nu, delta},
  nu = paramValue[params, "nu", Missing["nu"]];
  delta = paramValue[params, "delta", Sqrt[1 - 4*nu]];
  <|"nu" -> nu, "delta" -> delta, "X1" -> (1 + delta)/2,
   "X2" -> (1 - delta)/2|>
  ];

epsValue[params_Association] := paramValue[params, "eps", 1];

SpinningBinary3PNLoad[OptionsPattern[]] := Module[{root},
  root = Replace[OptionValue["RootDirectory"],
    Automatic -> $SpinningBinary3PNRoot];
  DirectEOMOrbits`DirectEOMLoad["RootDirectory" -> root]
  ];

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

pnMaxPower[pn_] := Module[{val = N[pn]},
  Which[val <= 0, 0, val <= 1, 2, val <= 1.5, 3, val <= 2, 4,
   val <= 2.5, 5, True, 6]
  ];

truncatePN[expr_, pn_] := Normal[Series[expr, {eps, 0, pnMaxPower[pn]}]];

directRules[params_Association] := Module[{nuv, deltav, epsv},
  epsv = epsValue[params];
  nuv = paramValue[params, "nu", Missing["nu"]];
  deltav = paramValue[params, "delta", Sqrt[1 - 4*nuv]];
  {eps -> epsv, nu -> nuv, delta -> deltav, chi1 -> 0, chi2 -> 0,
   kap1 -> 1, kap2 -> 1,
   DirectEOMOrbits`Private`eps -> epsv,
   DirectEOMOrbits`Private`nu -> nuv,
   DirectEOMOrbits`Private`delta -> deltav,
   DirectEOMOrbits`Private`chi1 -> 0,
   DirectEOMOrbits`Private`chi2 -> 0,
   DirectEOMOrbits`Private`kap1 -> 1,
   DirectEOMOrbits`Private`kap2 -> 1}
  ];

nonspinAcceleration[eom_Association, x_List, v_List, params_Association,
  pn_] := Module[
  {r, n, rdv, vtVec, vtMag, pAng, rddotExpr, phiddotExpr, rddot,
   phiddot, aRad, aTan, lambda},
  r = Norm[x];
  n = x/r;
  rdv = n.v;
  vtVec = v - rdv*n;
  vtMag = Norm[vtVec];
  lambda = If[TrueQ[Chop[vtMag] == 0], {0, 0, 0}, vtVec/vtMag];
  pAng = vtMag/r;
  rddotExpr =
   N[truncatePN[eom["polarODE", "rddot"], pn] /. directRules[params]];
  phiddotExpr =
   N[truncatePN[eom["polarODE", "phiddot"], pn] /. directRules[params]];
  rddot = rddotExpr /. {s -> 1/r, rd -> rdv, p -> pAng,
     DirectEOMOrbits`Private`s -> 1/r,
     DirectEOMOrbits`Private`rd -> rdv,
     DirectEOMOrbits`Private`p -> pAng};
  phiddot = phiddotExpr /. {s -> 1/r, rd -> rdv, p -> pAng,
     DirectEOMOrbits`Private`s -> 1/r,
     DirectEOMOrbits`Private`rd -> rdv,
     DirectEOMOrbits`Private`p -> pAng};
  aRad = rddot - vtMag^2/r;
  aTan = r*phiddot + 2*rdv*pAng;
  aRad*n + aTan*lambda
  ];

spinCombinations[S1_List, S2_List, params_Association] := Module[
  {mf, x1, x2},
  mf = massFractions[params];
  {x1, x2} = mf /@ {"X1", "X2"};
  <|"S" -> S1 + S2, "Sigma" -> S2/x2 - S1/x1|>
  ];

mixed[a_, b_, c_] := a.Cross[b, c];

spinOrbitAcceleration[x_List, v_List, S1_List, S2_List,
  params_Association, pn_] := Module[
  {epsv, mf, delta, nuv, r, n, nv, v2v, sc, svec, sig, nSigV, nSV,
   b15, b251, b252},
  If[N[pn] < 1.5, Return[{0, 0, 0}]];
  epsv = epsValue[params];
  mf = massFractions[params];
  delta = mf["delta"];
  nuv = mf["nu"];
  r = Norm[x];
  n = x/r;
  nv = n.v;
  v2v = v.v;
  sc = spinCombinations[S1, S2, params];
  svec = sc["S"];
  sig = sc["Sigma"];
  nSigV = mixed[n, sig, v];
  nSV = mixed[n, svec, v];

  b15 = -6*delta*nSigV*n - 12*nSV*n +
    9*nv*Cross[n, svec] + 3*delta*nv*Cross[n, sig] +
    7*Cross[svec, v] + 3*delta*Cross[sig, v];

  b251 =
   Cross[n, svec]*((-45*nuv/2)*nv^3 + (-3/2 + 45*nuv/2)*nv*v2v) +
    nSigV*v*delta*(9/2 - 6*nuv)*nv +
    Cross[n, sig]*((-15*nuv*delta)*nv^3 +
       delta*(-3/2 + 12*nuv)*nv*v2v) +
    nSV*v*(21/2 - 21*nuv/2)*nv +
    Cross[svec, v]*((-3/2 - 15*nuv)*nv^2 + 14*nuv*v2v) +
    Cross[sig, v]*(delta*(-3/2 - 9*nuv)*nv^2 +
       7*nuv*delta*v2v) +
    nSigV*n*(15*nuv*delta*nv^2 - 12*nuv*delta*v2v) +
    nSV*n*(30*nuv*nv^2 - 24*nuv*v2v);

  b252 =
   nSigV*n*delta*(24 + 37*nuv/2) +
    nSV*n*(44 + 33*nuv) +
    Cross[n, svec]*(-28 - 29*nuv)*nv +
    Cross[n, sig]*delta*(-12 - 31*nuv/2)*nv +
    Cross[svec, v]*(-24 - 19*nuv) +
    Cross[sig, v]*delta*(-12 - 19*nuv/2);

  includeTerm[pn, 1.5, epsv^3*b15/r^3, {0, 0, 0}] +
   includeTerm[pn, 2.5, epsv^5*(b251 + b252/r)/r^3, {0, 0, 0}]
  ];

spinSpinAcceleration[x_List, v_List, S1_List, S2_List,
  params_Association, pn_] := Module[
  {epsv, mf, delta, nuv, r, n, nv, v2v, sc, svec, sig, kp, km, nS,
   nSig, vS, vSig, s2, sig2, sSig, alpha40, alpha60, alpha61},
  If[N[pn] < 2, Return[{0, 0, 0}]];
  If[TrueQ[Chop[Norm[S1] + Norm[S2]] == 0], Return[{0, 0, 0}]];
  epsv = epsValue[params];
  mf = massFractions[params];
  delta = mf["delta"];
  nuv = mf["nu"];
  r = Norm[x];
  n = x/r;
  nv = n.v;
  v2v = v.v;
  sc = spinCombinations[S1, S2, params];
  svec = sc["S"];
  sig = sc["Sigma"];
  kp = paramValue[params, "kappaPlus",
    paramValue[params, "kap1", 1] + paramValue[params, "kap2", 1]];
  km = paramValue[params, "kappaMinus",
    paramValue[params, "kap1", 1] - paramValue[params, "kap2", 1]];
  nS = n.svec;
  nSig = n.sig;
  vS = v.svec;
  vSig = v.sig;
  s2 = svec.svec;
  sig2 = sig.sig;
  sSig = svec.sig;
  alpha40 =
   svec*(nS*(-12*kp - 24) +
      nSig*(-6*delta*kp - 12*delta + 6*km)) +
    sig*(nS*(-6*delta*kp - 12*delta + 6*km) +
      nSig*((6*delta*km - 6*kp) + nuv*(12*kp + 24))) +
    n*((svec.svec)*(-6*kp - 12) +
      (sig.sig)*((3*delta*km - 3*kp) + nuv*(6*kp + 12)) +
      nS^2*(30*kp + 60) +
      (svec.sig)*(-6*delta*kp - 12*delta + 6*km) +
      nSig^2*((15*kp - 15*delta*km) +
        nuv*(-30*kp - 60)) +
      nS*nSig*(30*delta*kp + 60*delta - 30*km));
  alpha60 =
   svec*(nS*(nv^2*((60*kp - 60*delta*km) +
           nuv*(60*kp + 120)) +
        v2v*((12*delta*km - 36*kp - 48) +
          nuv*(-72*kp - 144))) +
      nSig*(nv^2*((60*delta*kp - 120*delta - 60*km) +
           nuv*(30*delta*kp + 60*delta + 90*km)) +
        v2v*((24*km - 24*delta*kp) +
          nuv*(-36*delta*kp - 72*delta + 12*km))) +
      vS*nv*((30*delta*km - 30*kp + 84) +
        nuv*(-12*kp - 24)) +
      vSig*nv*((-30*delta*kp + 132*delta + 30*km) +
        nuv*(-6*delta*kp - 12*delta - 54*km))) +
    sig*(nS*nv^2*((60*delta*kp - 60*km) +
        nuv*(30*delta*kp + 60*delta + 90*km)) +
      nSig*nv^2*((-60*delta*km + 60*kp - 120) +
        nuv*(30*delta*km - 150*kp + 240) +
        nuv^2*(-60*kp - 120)) +
      nv*vS*((-30*delta*kp + 48*delta + 30*km) +
        nuv*(-6*delta*kp - 12*delta - 54*km)) +
      nv*vSig*((30*delta*km - 30*kp + 96) +
        nuv*(-24*delta*km + 84*kp - 276) +
        nuv^2*(12*kp + 24)) +
      nS*v2v*((-24*delta*kp - 24*delta + 24*km) +
        nuv*(-36*delta*kp - 72*delta + 12*km)) +
      nSig*v2v*((24*delta*km - 24*kp + 24) +
        nuv*(24*delta*km + 24*kp) +
        nuv^2*(72*kp + 144))) +
    n*(nS^2*nv^2*nuv*(-210*kp - 420) +
      nv^2*s2*((30*delta*km - 30*kp + 120) +
        nuv*(30*kp + 60)) +
      nS*nSig*nv^2*nuv*(-210*delta*kp - 420*delta + 210*km) +
      vS^2*(6*delta*km - 6*kp + 84) +
      nSig^2*nv^2*(nuv*(105*delta*km - 105*kp) +
        nuv^2*(210*kp + 420)) +
      nv^2*sSig*((-60*delta*kp + 240*delta + 60*km) +
        nuv*(30*delta*kp + 60*delta - 150*km)) +
      nv^2*sig2*((30*delta*km - 30*kp + 120) +
        nuv*(-45*delta*km + 105*kp - 360) +
        nuv^2*(-30*kp - 60)) +
      nS*nv*vS*((-30*delta*km + 30*kp - 420) +
        nuv*(60*kp + 120)) +
      nSig*nv*vS*((30*delta*kp - 240*delta - 30*km) +
        nuv*(30*delta*kp + 60*delta + 30*km)) +
      nS*nv*vSig*((30*delta*kp - 420*delta - 30*km) +
        nuv*(30*delta*kp + 60*delta + 30*km)) +
      nSig*nv*vSig*((-30*delta*km + 30*kp - 240) +
        nuv*(900 - 60*kp) + nuv^2*(-60*kp - 120)) +
      vS*vSig*((-12*delta*kp + 132*delta + 12*km) +
        nuv*(-24*km)) +
      vSig^2*((6*delta*km - 6*kp + 48) +
        nuv*(-6*delta*km + 18*kp - 180)) +
      nS^2*v2v*((60*kp + 120) + nuv*(180*kp + 360)) +
      s2*v2v*((-6*delta*km - 6*kp - 48) +
        nuv*(-36*kp - 72)) +
      nS*nSig*v2v*((60*delta*kp + 120*delta - 60*km) +
        nuv*(180*delta*kp + 360*delta - 180*km)) +
      nSig^2*v2v*((30*kp - 30*delta*km) +
        nuv*(-90*delta*km + 30*kp - 120) +
        nuv^2*(-180*kp - 360)) +
      sSig*v2v*(-72*delta +
        nuv*(-36*delta*kp - 72*delta + 60*km)) +
      sig2*v2v*(-24 +
        nuv*(24*delta*km - 24*kp + 96) +
        nuv^2*(36*kp + 72))) +
    v*(nS^2*nv*(-240*kp + nuv*(120*kp + 240)) +
      nv*s2*((-12*delta*km + 60*kp - 48) +
        nuv*(-24*kp - 48)) +
      nS*nSig*nv*((-240*delta*kp + 240*delta + 240*km) +
        nuv*(120*delta*kp + 240*delta - 120*km)) +
      nSig^2*nv*((120*delta*km - 120*kp + 240) +
        nuv*(-60*delta*km + 300*kp - 480) +
        nuv^2*(-120*kp - 240)) +
      nv*sSig*((72*delta*kp - 144*delta - 72*km) +
        nuv*(-24*delta*kp - 48*delta + 72*km)) +
      nv*sig2*((-36*delta*km + 36*kp - 96) +
        nuv*(24*delta*km - 96*kp + 240) +
        nuv^2*(24*kp + 48)) +
      nS*vS*((6*delta*km + 90*kp + 84) +
        nuv*(-36*kp - 72)) +
      nSig*vS*((42*delta*kp - 42*km) +
        nuv*(-18*delta*kp - 36*delta + 6*km)) +
      nS*vSig*((42*delta*kp + 36*delta - 42*km) +
        nuv*(-18*delta*kp - 36*delta + 6*km)) +
      nSig*vSig*((-42*delta*km + 42*kp - 48) +
        nuv*(12*delta*km - 96*kp + 12) +
        nuv^2*(36*kp + 72)));

  alpha61 =
   svec*(nS*((-24*delta*km + 72*kp + 164) +
        nuv*(36*kp + 72)) +
      nSig*((48*delta*kp + 72*delta - 48*km) +
        nuv*(18*delta*kp + 36*delta + 30*km))) +
    sig*(nS*((48*delta*kp + 84*delta - 48*km) +
        nuv*(18*delta*kp + 36*delta + 30*km)) +
      nSig*((48*kp - 48*delta*km) +
        nuv*(6*delta*km - 102*kp - 148) +
        nuv^2*(-36*kp - 72))) +
    n*(nS^2*((48*delta*km - 192*kp - 420) +
        nuv*(-96*kp - 192)) +
      s2*((-8*delta*km + 40*kp + 72) +
        nuv*(20*kp + 40)) +
      nS*nSig*((-240*delta*kp - 396*delta + 240*km) +
        nuv*(-96*delta*kp - 192*delta - 96*km)) +
      nSig^2*((120*delta*km - 120*kp) +
        nuv*(240*kp + 372) + nuv^2*(96*kp + 192)) +
      sSig*((48*delta*kp + 72*delta - 48*km) +
        nuv*(20*delta*kp + 40*delta + 12*km)) +
      sig2*((24*kp - 24*delta*km) +
        nuv*(-2*delta*km - 46*kp - 72) +
        nuv^2*(-20*kp - 40)));

  epsv^4*alpha40/(4*r^4) +
   includeTerm[pn, 3, epsv^6*(alpha60/(8*r^4) + alpha61/(4*r^5)),
    {0, 0, 0}]
  ];

SpinningBinary3PNAcceleration[eom_Association, x_List, v_List, S1_List,
  S2_List, params_Association, OptionsPattern[]] := Module[
  {pn, spinTerms, aNS, aSO, aSS},
  pn = OptionValue["PNOrder"];
  If[! validPNOrderQ[pn],
   Message[SpinningBinary3PNAcceleration::badpn, pn,
    SpinningBinary3PNAllowedPNOrders[]];
   Return[$Failed]
   ];
  spinTerms = TrueQ[OptionValue["SpinTerms"]];
  aNS = nonspinAcceleration[eom, x, v, params, pn];
  If[! spinTerms, Return[aNS]];
  aSO = spinOrbitAcceleration[x, v, S1, S2, params, pn];
  aSS = spinSpinAcceleration[x, v, S1, S2, params, pn];
  aNS + aSO + aSS
  ];

spinStateFromInitialData[initialData_Association,
  params_Association] := Module[{mf, x1, x2, s1, s2},
  mf = massFractions[params];
  {x1, x2} = mf /@ {"X1", "X2"};
  s1 = Which[
    KeyExistsQ[initialData, "S1"], initialData["S1"],
    KeyExistsQ[initialData, "chi1Vec"], x1^2*initialData["chi1Vec"],
    True, {0, 0, 0}
    ];
  s2 = Which[
    KeyExistsQ[initialData, "S2"], initialData["S2"],
    KeyExistsQ[initialData, "chi2Vec"], x2^2*initialData["chi2Vec"],
    True, {0, 0, 0}
    ];
  <|"S1" -> s1, "S2" -> s2|>
  ];

stateFromInitialData[initialData_Association] := Module[{missing},
  If[KeyExistsQ[initialData, "x"] && KeyExistsQ[initialData, "v"],
   Return[<|"x" -> initialData["x"], "v" -> initialData["v"]|>]
   ];
  missing = Complement[{"r", "theta", "phi", "rdot", "thetadot",
     "phidot"}, Keys[initialData]];
  If[missing === {},
   Return[
    OsculatingElements3D`Osculating3DStateFromSpherical[initialData]]];
  Message[SpinningBinary3PNOrbit::badic, Keys[initialData]];
  $Failed
  ];

spinDerivatives[x_List, v_List, S1_List, S2_List, params_Association,
  pn_, enabled_] := Module[{epsv, mf, x1, x2, r, lN, om1, om2},
  If[! TrueQ[enabled] || N[pn] < 1, Return[<|"dS1" -> {0, 0, 0},
      "dS2" -> {0, 0, 0}|>]];
  epsv = epsValue[params];
  mf = massFractions[params];
  {x1, x2} = mf /@ {"X1", "X2"};
  r = Norm[x];
  lN = Cross[x, v];
  om1 = epsv^2*(2 + 3*x2/(2*x1))*lN/r^3;
  om2 = epsv^2*(2 + 3*x1/(2*x2))*lN/r^3;
  <|"dS1" -> Cross[om1, S1], "dS2" -> Cross[om2, S2]|>
  ];

SpinningBinary3PNOrbit[eom_Association, params_Association,
  initialData_Association, times_List, OptionsPattern[]] := Module[
  {wp, acc, prec, pn, step, method, spinTerms, spinPrec, tStart, tauEnd,
   state, spinState, x0, v0, s10, s20, accNum, accComp, spinDotNum,
   spinComp, sol,
   ndsolveOpts, states, mf, x1, x2},
  wp = OptionValue[WorkingPrecision];
  acc = OptionValue[AccuracyGoal];
  prec = OptionValue[PrecisionGoal];
  pn = OptionValue["PNOrder"];
  If[! validPNOrderQ[pn],
   Message[SpinningBinary3PNOrbit::badpn, pn,
    SpinningBinary3PNAllowedPNOrders[]];
   Return[$Failed]
   ];
  step = OptionValue[MaxStepSize];
  method = OptionValue[Method];
  spinTerms = TrueQ[OptionValue["SpinTerms"]];
  spinPrec = TrueQ[OptionValue["SpinPrecession"]];

  state = stateFromInitialData[initialData];
  spinState = spinStateFromInitialData[initialData, params];
  If[state === $Failed, Return[$Failed]];
  {x0, v0} = Lookup[state, {"x", "v"}];
  {s10, s20} = Lookup[spinState, {"S1", "S2"}];
  mf = massFractions[params];
  {x1, x2} = mf /@ {"X1", "X2"};
  tStart = First[times];
  tauEnd = N[Last[times] - tStart, wp];

  ndsolveOpts = Sequence[WorkingPrecision -> wp, AccuracyGoal -> acc,
    PrecisionGoal -> prec, Method -> method, MaxSteps -> Infinity];
  accNum[xv_?NumericQ, yv_?NumericQ, zv_?NumericQ, vxv_?NumericQ,
    vyv_?NumericQ, vzv_?NumericQ, s1xv_?NumericQ, s1yv_?NumericQ,
    s1zv_?NumericQ, s2xv_?NumericQ, s2yv_?NumericQ,
    s2zv_?NumericQ] := SpinningBinary3PNAcceleration[eom,
    {xv, yv, zv}, {vxv, vyv, vzv}, {s1xv, s1yv, s1zv},
    {s2xv, s2yv, s2zv}, params, "PNOrder" -> pn,
    "SpinTerms" -> spinTerms];
  spinDotNum[xv_?NumericQ, yv_?NumericQ, zv_?NumericQ,
    vxv_?NumericQ, vyv_?NumericQ, vzv_?NumericQ, s1xv_?NumericQ,
    s1yv_?NumericQ, s1zv_?NumericQ, s2xv_?NumericQ,
    s2yv_?NumericQ, s2zv_?NumericQ] := spinDerivatives[
    {xv, yv, zv}, {vxv, vyv, vzv}, {s1xv, s1yv, s1zv},
    {s2xv, s2yv, s2zv}, params, pn, spinPrec];
  accComp[i_Integer][xv_?NumericQ, yv_?NumericQ, zv_?NumericQ,
    vxv_?NumericQ, vyv_?NumericQ, vzv_?NumericQ, s1xv_?NumericQ,
    s1yv_?NumericQ, s1zv_?NumericQ, s2xv_?NumericQ,
    s2yv_?NumericQ, s2zv_?NumericQ] :=
   accNum[xv, yv, zv, vxv, vyv, vzv, s1xv, s1yv, s1zv, s2xv,
     s2yv, s2zv][[i]];
  spinComp[i_Integer][xv_?NumericQ, yv_?NumericQ, zv_?NumericQ,
    vxv_?NumericQ, vyv_?NumericQ, vzv_?NumericQ, s1xv_?NumericQ,
    s1yv_?NumericQ, s1zv_?NumericQ, s2xv_?NumericQ,
    s2yv_?NumericQ, s2zv_?NumericQ] := Module[{sd},
   sd = spinDotNum[xv, yv, zv, vxv, vyv, vzv, s1xv, s1yv, s1zv,
     s2xv, s2yv, s2zv];
   Join[sd["dS1"], sd["dS2"]][[i]]
   ];

  sol = Quiet[
    NDSolveValue[
     {
      xx'[tt] == vx[tt], yy'[tt] == vy[tt], zz'[tt] == vz[tt],
      vx'[tt] == accComp[1][xx[tt], yy[tt], zz[tt], vx[tt], vy[tt],
        vz[tt], s1x[tt], s1y[tt], s1z[tt], s2x[tt], s2y[tt],
        s2z[tt]],
      vy'[tt] == accComp[2][xx[tt], yy[tt], zz[tt], vx[tt], vy[tt],
        vz[tt], s1x[tt], s1y[tt], s1z[tt], s2x[tt], s2y[tt],
        s2z[tt]],
      vz'[tt] == accComp[3][xx[tt], yy[tt], zz[tt], vx[tt], vy[tt],
        vz[tt], s1x[tt], s1y[tt], s1z[tt], s2x[tt], s2y[tt],
        s2z[tt]],
      s1x'[tt] == spinComp[1][xx[tt], yy[tt], zz[tt], vx[tt],
        vy[tt], vz[tt], s1x[tt], s1y[tt], s1z[tt], s2x[tt],
        s2y[tt], s2z[tt]],
      s1y'[tt] == spinComp[2][xx[tt], yy[tt], zz[tt], vx[tt],
        vy[tt], vz[tt], s1x[tt], s1y[tt], s1z[tt], s2x[tt],
        s2y[tt], s2z[tt]],
      s1z'[tt] == spinComp[3][xx[tt], yy[tt], zz[tt], vx[tt],
        vy[tt], vz[tt], s1x[tt], s1y[tt], s1z[tt], s2x[tt],
        s2y[tt], s2z[tt]],
      s2x'[tt] == spinComp[4][xx[tt], yy[tt], zz[tt], vx[tt],
        vy[tt], vz[tt], s1x[tt], s1y[tt], s1z[tt], s2x[tt],
        s2y[tt], s2z[tt]],
      s2y'[tt] == spinComp[5][xx[tt], yy[tt], zz[tt], vx[tt],
        vy[tt], vz[tt], s1x[tt], s1y[tt], s1z[tt], s2x[tt],
        s2y[tt], s2z[tt]],
      s2z'[tt] == spinComp[6][xx[tt], yy[tt], zz[tt], vx[tt],
        vy[tt], vz[tt], s1x[tt], s1y[tt], s1z[tt], s2x[tt],
        s2y[tt], s2z[tt]],
      xx[0] == N[x0[[1]], wp], yy[0] == N[x0[[2]], wp],
      zz[0] == N[x0[[3]], wp], vx[0] == N[v0[[1]], wp],
      vy[0] == N[v0[[2]], wp], vz[0] == N[v0[[3]], wp],
      s1x[0] == N[s10[[1]], wp], s1y[0] == N[s10[[2]], wp],
      s1z[0] == N[s10[[3]], wp], s2x[0] == N[s20[[1]], wp],
      s2y[0] == N[s20[[2]], wp], s2z[0] == N[s20[[3]], wp]
      },
     {xx, yy, zz, vx, vy, vz, s1x, s1y, s1z, s2x, s2y, s2z},
     {tt, 0, tauEnd}, Evaluate[ndsolveOpts],
     If[step === Automatic, Sequence @@ {}, MaxStepSize -> step]],
    NDSolveValue::precw
    ];

  states = Table[
    Module[{tau = N[t - tStart, wp], xval, vval, s1val, s2val, sph},
     xval = #[tau] & /@ sol[[1 ;; 3]];
     vval = #[tau] & /@ sol[[4 ;; 6]];
     s1val = #[tau] & /@ sol[[7 ;; 9]];
     s2val = #[tau] & /@ sol[[10 ;; 12]];
     sph = OsculatingElements3D`Osculating3DSphericalFromState[xval, vval];
     Join[<|"t" -> N[t, wp], "tau" -> tau|>, sph,
      <|"x" -> xval, "v" -> vval, "S1" -> s1val, "S2" -> s2val,
       "chi1Vec" -> s1val/x1^2, "chi2Vec" -> s2val/x2^2|>]
     ],
    {t, times}
    ];

  <|"t" -> Lookup[states, "t"], "r" -> Lookup[states, "r"],
   "theta" -> Lookup[states, "theta"], "phi" -> Lookup[states, "phi"],
   "rdot" -> Lookup[states, "rdot"],
   "thetadot" -> Lookup[states, "thetadot"],
   "phidot" -> Lookup[states, "phidot"], "x" -> Lookup[states, "x"],
   "v" -> Lookup[states, "v"], "S1" -> Lookup[states, "S1"],
   "S2" -> Lookup[states, "S2"], "chi1Vec" -> Lookup[states, "chi1Vec"],
   "chi2Vec" -> Lookup[states, "chi2Vec"]|>
  ];

SpinningBinary3PNAcceleration::badpn =
  "Unsupported PNOrder `1`. Use one of `2`.";
SpinningBinary3PNOrbit::badpn =
  "Unsupported PNOrder `1`. Use one of `2`.";
SpinningBinary3PNOrbit::badic =
  "Initial data must contain either x,v or r,theta,phi,rdot,thetadot,phidot. Got keys `1`.";

End[];

EndPackage[];
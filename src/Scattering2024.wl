(* ::Package:: *)

BeginPackage["Scattering2024`"];

Scattering2024Acceleration;
Scattering2024StateFromElements;
Scattering2024ElementsFromState;
Scattering2024AnalyticDeltas;
Scattering2024NumericalEncounter;
Scattering2024Compare;

Begin["`Private`"];

Options[Scattering2024NumericalEncounter] = {
   WorkingPrecision -> MachinePrecision, AccuracyGoal -> Automatic,
   PrecisionGoal -> Automatic, MaxStepSize -> Automatic,
   "AsymptoteFraction" -> 0.985};
Options[Scattering2024Compare] = Options[Scattering2024NumericalEncounter];

paramValue[params_Association, key_String, default_] :=
  Lookup[params, key, default];

massValue[params_Association] := paramValue[params, "M", 1];
qValue[params_Association] := paramValue[params, "q", 0];
nuFromQ[q_] := q/(1 + q)^2;
nuValue[params_Association] := paramValue[params, "nu", nuFromQ[qValue[params]]];
m1Value[params_Association] := massValue[params]/(1 + qValue[params]);
jValue[params_Association] := paramValue[params, "J",
   m1Value[params]^2*paramValue[params, "chi", 0]];
qMomentValue[params_Association] := paramValue[params, "Q",
   -m1Value[params]^3*paramValue[params, "chi", 0]^2];

angleDiff[a_, b_] := Arg[Exp[I (a - b)]];

gFun[e_] := ArcTan[(e - 1)/Sqrt[e^2 - 1]] + ArcSin[1/e];

termQ[terms_, name_] := MemberQ[terms, name] || MemberQ[terms, All];

clipUnit[x_] := Clip[x, {-1, 1}];

Scattering2024StateFromElements[elements_Association,
  params_Association : <||>] := Module[
  {m, a, e, inc, phi0, varphi0, varphi, r, u, pref, x, v,
   cp, sp, ci, si, cu, su},
  If[! And @@ (KeyExistsQ[elements, #] & /@
       {"a", "e", "i", "phi0", "varphi0", "varphi"}),
   Message[Scattering2024StateFromElements::missing,
    {"a", "e", "i", "phi0", "varphi0", "varphi"}];
   Return[$Failed]
   ];
  m = massValue[params];
  {a, e, inc, phi0, varphi0, varphi} =
   Lookup[elements, {"a", "e", "i", "phi0", "varphi0", "varphi"}];
  If[! TrueQ[e > 1],
   Message[Scattering2024StateFromElements::notunbound, e];
   Return[$Failed]
   ];
  r = a*(e^2 - 1)/(1 + e*Cos[varphi]);
  u = varphi + varphi0;
  pref = Sqrt[m/(a*(e^2 - 1))];
  {cp, sp, ci, si, cu, su} =
   {Cos[phi0], Sin[phi0], Cos[inc], Sin[inc], Cos[u], Sin[u]};
  x = r*{ci*cp*cu - sp*su, ci*sp*cu + cp*su, si*cu};
  v = pref*{
     -sp*(e*Cos[varphi0] + cu) - ci*cp*(e*Sin[varphi0] + su),
     cp*(e*Cos[varphi0] + cu) - ci*sp*(e*Sin[varphi0] + su),
     -si*(e*Sin[varphi0] + su)};
  <|"x" -> x, "v" -> v|>
  ];

Scattering2024ElementsFromState[x_List, v_List,
  params_Association : <||>] := Module[
  {m, zhat, xhat, r, v2, rd, lvec, l, nvec, nn, evec, ecc, a,
   inc, phi0, rawPhi0, varphi0, varphi, cosNe, cosNx, cosEr,
   orbitType, tol},
  m = massValue[params];
  zhat = {0, 0, 1};
  xhat = {1, 0, 0};
  tol = 10^-12;
  r = Norm[x];
  v2 = v.v;
  rd = (x.v)/r;
  lvec = Cross[x, v];
  l = Norm[lvec];
  nvec = Cross[zhat, lvec];
  nn = Norm[nvec];
  evec = ((v2 - m/r)*x - (x.v)*v)/m;
  ecc = Norm[evec];
  a = 1/(v2/m - 2/r);
  orbitType = Which[ecc < 1 - 10^-10, "Bound",
    ecc > 1 + 10^-10, "Unbound", True, "Parabolic"];
  inc = ArcCos[clipUnit[lvec[[3]]/l]];
  rawPhi0 = If[nn > tol,
    cosNx = clipUnit[(nvec.xhat)/nn];
    If[nvec[[2]] >= 0, ArcCos[cosNx] - Pi/2,
     -ArcCos[cosNx] + 3 Pi/2],
    0
    ];
  phi0 = If[nn > tol, angleDiff[rawPhi0 - Pi, 0], rawPhi0];
  varphi0 = If[nn > tol && ecc > tol,
    cosNe = clipUnit[(nvec.evec)/(nn*ecc)];
    If[evec[[3]] >= 0, ArcCos[cosNe] - Pi/2,
     -ArcCos[cosNe] + 3 Pi/2],
    0
    ];
  varphi = If[ecc > tol,
    cosEr = clipUnit[(evec.(x/r))/ecc];
    If[rd >= 0, ArcCos[cosEr],
     -ArcCos[cosEr] + 2 Pi],
    0
    ];
  <|"orbitType" -> orbitType, "a" -> a, "e" -> ecc, "i" -> inc,
   "phi0" -> phi0, "varphi0" -> varphi0, "varphi" -> varphi,
   "energy" -> v2/2 - m/r, "h" -> l, "hVector" -> lvec,
   "eVector" -> evec|>
  ];

Scattering2024Acceleration[x_List, v_List, params_Association,
  terms_List : {"Newtonian"}] := Module[
  {m, q, nu, delta, r, n, rd, v2, a, er, ez, jvec, jmag, kmom, nz},
  m = massValue[params];
  q = qValue[params];
  nu = nuValue[params];
  delta = Sqrt[1 - 4*nu];
  r = Norm[x];
  n = x/r;
  rd = n.v;
  v2 = v.v;
  ez = {0, 0, 1};
  a = If[termQ[terms, "Newtonian"], -m*n/r^2, {0, 0, 0}];
  If[termQ[terms, "1PN"],
   a += (m/r^2)*(((4 + 2*nu)*m/r - (1 + 3*nu)*v2 +
         (3/2)*nu*rd^2)*n + (4 - 2*nu)*rd*v)
   ];
  If[termQ[terms, "2.5PN"],
   a += (24*nu/5)*m^2/r^3*
     ((v2 + 17*m/(9*r))*rd*n - (v2/3 + m/r)*v)
   ];
  If[termQ[terms, "Spin"],
   jmag = jValue[params];
   jvec = jmag*ez;
   er = n;
   a += (1 + q)^2*(1 + delta)/(4*r^3)*
     (12*er*(Cross[er, v].jvec) -
       (7 + delta)*Cross[v, jvec] +
       (9 + 3*delta)*rd*Cross[er, jvec])
   ];
  If[termQ[terms, "Quadrupole"],
   kmom = (m/m1Value[params])*qMomentValue[params];
   nz = n.ez;
   a += (3*kmom/(2*r^4))*((1 - 5*nz^2)*n + 2*nz*ez)
   ];
  a
  ];

Scattering2024AnalyticDeltas[elements_Association,
  params_Association, term_String] := Module[
  {m, q, nu, delta, a, e, inc, varphi0, j, qmom, m1, ge, scale,
   dvarphi0 = 0, dphi0 = 0, di = 0, de = 0, da = 0},
  m = massValue[params];
  q = qValue[params];
  nu = nuValue[params];
  delta = Sqrt[1 - 4*nu];
  {a, e, inc, varphi0} = Lookup[elements, {"a", "e", "i", "varphi0"}];
  j = jValue[params];
  qmom = qMomentValue[params];
  m1 = m1Value[params];
  ge = gFun[e];
  Switch[term,
   "1PN",
   dvarphi0 = (m/a)*
     (Sqrt[e^2 - 1]*((5*nu + 2)*e^2 - 5*nu + 4) +
       12*e^2*ArcTan[(e + 1)/Sqrt[e^2 - 1]])/
      (e^2*(e^2 - 1)),

   "Spin",
   scale = (1 + q)^2*j/(e^2*(e^2 - 1)^2*Sqrt[a^3*m]);
   dvarphi0 = scale*Cos[inc]*
     (e^2*(2*nu*Cos[2*varphi0] + nu + 2*delta + 2) +
       6*e^2*ge*Sqrt[e^2 - 1]*(nu - 2*delta - 2) +
       e^4*(-nu*Cos[2*varphi0] + nu - 4*delta - 4) -
       nu*Cos[2*varphi0] - 2*nu + 2*delta + 2);
   dphi0 = scale*
     (e^2*(-2*nu*Cos[2*varphi0] + nu - 2*delta - 2) +
       2*e^2*ge*Sqrt[e^2 - 1]*(-nu + 2 + 2*delta) +
       e^4*(nu*Cos[2*varphi0] - nu + 2*delta + 2) +
       nu*Cos[2*varphi0]);
   di = ((1 + q)^2*j/Sqrt[a^3*m])*
     (-(nu*Sin[2*varphi0]/e^2)*Sin[inc]),

   "Quadrupole",
   scale = qmom/(a^2*m1);
   dvarphi0 = scale*
     ((2*(1 - e^2)*((2*e^2 - 1)*Cos[2*inc] + 1)*
          Cos[2*varphi0] -
         e^2*(3*(4*e^2 + 1)*Cos[2*inc] + 8*e^2 + 1))/
       (4*e^4*(e^2 - 1)^(3/2)) -
      ge*(15*Cos[2*inc] + 9)/(2*(e^2 - 1)^2));
   dphi0 = scale*
     ((Sqrt[e^2 - 1]*((e^2 - 1)*Cos[2*varphi0] + 3*e^2) +
        6*e^2*ge)/(e^2*(e^2 - 1)^2))*Cos[inc];
   di = scale*(-Sin[2*varphi0]*Sin[2*inc]/(2*e^2*Sqrt[e^2 - 1]));
   de = ((e^2 - 1)*Tan[inc]/e)*di,

   "2.5PN",
   de = e*(m/a)^(5/2)*
     (-(2*nu)/(45*(e^2 - 1)^2))*
      (1069 + 72*e^2 + 134/e^2 +
        6*(121*e^2 + 304)*ge/Sqrt[e^2 - 1]);
   da = a*(m/a)^(5/2)*
     (4*nu/(45*(e^2 - 1)^4))*
      (-602 + 673*e^4 - 71*e^2 +
        6*(37*e^4 + 292*e^2 + 96)*ge*Sqrt[e^2 - 1]),

   _, Message[Scattering2024AnalyticDeltas::badterm, term]; Return[$Failed]
   ];
  <|"Deltaa" -> da, "Deltae" -> de, "Deltai" -> di,
   "Deltaphi0" -> dphi0, "Deltavarphi0" -> dvarphi0|>
  ];

stateAtIncoming[elements_Association, params_Association, frac_] := Module[
  {e, phiInf, incomingElements},
  e = elements["e"];
  phiInf = Pi - ArcTan[Sqrt[e^2 - 1]];
  incomingElements = Join[elements, <|"varphi" -> -frac*phiInf|>];
  Scattering2024StateFromElements[incomingElements, params]
  ];

encounterTime[elements_Association, params_Association, frac_] := Module[
  {m, a, e, phiInf, f, ch, sh, xi, mean},
  m = massValue[params];
  {a, e} = Lookup[elements, {"a", "e"}];
  phiInf = Pi - ArcTan[Sqrt[e^2 - 1]];
  f = frac*phiInf;
  ch = (e + Cos[f])/(1 + e*Cos[f]);
  sh = Sin[f]*(e*ch - 1)/Sqrt[e^2 - 1];
  xi = ArcSinh[sh];
  mean = e*sh - xi;
  2*mean/Sqrt[m/a^3]
  ];

Scattering2024NumericalEncounter[elements_Association,
  params_Association, terms_List, OptionsPattern[]] := Module[
  {wp, acc, prec, step, frac, state, tEnd, x0, v0, sol, finalState,
   initialEl, finalEl, delta},
  wp = OptionValue[WorkingPrecision];
  acc = OptionValue[AccuracyGoal];
  prec = OptionValue[PrecisionGoal];
  step = OptionValue[MaxStepSize];
  frac = OptionValue["AsymptoteFraction"];
  state = stateAtIncoming[elements, params, frac];
  If[state === $Failed, Return[$Failed]];
  {x0, v0} = Lookup[state, {"x", "v"}];
  tEnd = N[encounterTime[elements, params, frac], wp];
  sol = NDSolveValue[
    {
     xx'[t] == vx[t], yy'[t] == vy[t], zz'[t] == vz[t],
     vx'[t] == Scattering2024Acceleration[{xx[t], yy[t], zz[t]},
        {vx[t], vy[t], vz[t]}, params, terms][[1]],
     vy'[t] == Scattering2024Acceleration[{xx[t], yy[t], zz[t]},
        {vx[t], vy[t], vz[t]}, params, terms][[2]],
     vz'[t] == Scattering2024Acceleration[{xx[t], yy[t], zz[t]},
        {vx[t], vy[t], vz[t]}, params, terms][[3]],
     xx[0] == N[x0[[1]], wp], yy[0] == N[x0[[2]], wp],
     zz[0] == N[x0[[3]], wp], vx[0] == N[v0[[1]], wp],
     vy[0] == N[v0[[2]], wp], vz[0] == N[v0[[3]], wp]
     },
    {xx, yy, zz, vx, vy, vz}, {t, 0, tEnd},
    WorkingPrecision -> wp, AccuracyGoal -> acc, PrecisionGoal -> prec,
    MaxSteps -> Infinity,
    If[step === Automatic, Sequence @@ {}, MaxStepSize -> step]
    ];
  initialEl = Scattering2024ElementsFromState[x0, v0, params];
  finalState = <|"x" -> (#[tEnd] & /@ sol[[1 ;; 3]]),
    "v" -> (#[tEnd] & /@ sol[[4 ;; 6]])|>;
  finalEl = Scattering2024ElementsFromState[
    finalState["x"], finalState["v"], params];
  delta = <|
    "Deltaa" -> finalEl["a"] - initialEl["a"],
    "Deltae" -> finalEl["e"] - initialEl["e"],
    "Deltai" -> finalEl["i"] - initialEl["i"],
    "Deltaphi0" -> angleDiff[finalEl["phi0"], initialEl["phi0"]],
    "Deltavarphi0" -> angleDiff[finalEl["varphi0"], initialEl["varphi0"]]
    |>;
  <|"InitialElements" -> initialEl, "FinalElements" -> finalEl,
   "Delta" -> delta, "InitialState" -> state, "FinalState" -> finalState,
   "IntegrationTime" -> tEnd|>
  ];

Scattering2024Compare[elements_Association, params_Association,
  term_String, OptionsPattern[]] := Module[
  {terms, numeric, analytic, keys, err},
  terms = {"Newtonian", term};
  numeric = Scattering2024NumericalEncounter[elements, params, terms,
    WorkingPrecision -> OptionValue[WorkingPrecision],
    AccuracyGoal -> OptionValue[AccuracyGoal],
    PrecisionGoal -> OptionValue[PrecisionGoal],
    MaxStepSize -> OptionValue[MaxStepSize],
    "AsymptoteFraction" -> OptionValue["AsymptoteFraction"]];
  If[numeric === $Failed, Return[$Failed]];
  analytic = Scattering2024AnalyticDeltas[elements, params, term];
  keys = Keys[analytic];
  err = AssociationMap[
    <|"Numeric" -> numeric["Delta", #], "Analytic" -> analytic[#],
      "AbsError" -> numeric["Delta", #] - analytic[#],
      "RelError" -> If[analytic[#] == 0, Indeterminate,
        (numeric["Delta", #] - analytic[#])/analytic[#]]|> &,
    keys];
  <|"Term" -> term, "Comparison" -> err, "Numeric" -> numeric,
   "Analytic" -> analytic|>
  ];

Scattering2024AnalyticDeltas::badterm =
  "Unknown 2024 scattering analytic term `1`.";
Scattering2024StateFromElements::missing =
  "Scattering2024StateFromElements requires elements `1`.";
Scattering2024StateFromElements::notunbound =
  "Scattering2024StateFromElements requires e > 1. Got e = `1`.";

End[];

EndPackage[];

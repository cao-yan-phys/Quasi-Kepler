(* ::Package:: *)

BeginPackage["EMRI3DOrbits`"];

EMRI3DAllowedPNOrders;
EMRI3DAcceleration;
EMRI3DOrbit;
EMRI3DStateFromSpherical;
EMRI3DSphericalFromState;
EMRI3DStateFromOsculatingElements;
EMRI3DOsculatingElementsFromState;
EMRI3DOsculatingElements;
EMRI3DHyperbolicGaussianRates;

Begin["`Private`"];

Options[EMRI3DAcceleration] = {"PNOrder" -> 3,
   "Include2p5PNRadiationReaction" -> False,
   "IncludeRadiationReaction" -> False, "RRGaugeParameters" -> <||>};
Options[EMRI3DOrbit] = {WorkingPrecision -> MachinePrecision,
   AccuracyGoal -> Automatic, PrecisionGoal -> Automatic, "PNOrder" -> 3,
   MaxStepSize -> Automatic, Method -> Automatic,
   "Include2p5PNRadiationReaction" -> False,
   "IncludeRadiationReaction" -> False, "RRGaugeParameters" -> <||>,
   "ReturnCartesian" -> False};

EMRI3DAllowedPNOrders[] := {0, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5};

validPNOrderQ[pn_] := AnyTrue[EMRI3DAllowedPNOrders[],
   Chop[N[pn - #]] == 0 &
   ];

includeTerm[pn_, min_, expr_, zero_] := If[N[pn] >= min, expr, zero];

paramValue[params_Association, key_String, default_] :=
  Lookup[params, key, default];

massValue[params_Association] := paramValue[params, "M", 1];

etaValue[params_Association] :=
  paramValue[params, "eta", paramValue[params, "nu", 0]];

spinVector[params_Association] := Module[{dir, norm},
  dir = paramValue[params, "spinDirection",
    paramValue[params, "eSpin", {0, 0, 1}]];
  norm = Norm[dir];
  If[TrueQ[norm == 0],
   Message[EMRI3DAcceleration::badspin, dir];
   Return[$Failed]
   ];
  dir/norm
  ];

rotZ[a_] := {{Cos[a], -Sin[a], 0}, {Sin[a], Cos[a], 0}, {0, 0, 1}};
rotX[a_] := {{1, 0, 0}, {0, Cos[a], -Sin[a]}, {0, Sin[a], Cos[a]}};

sphericalBasis[theta_, phi_] := <|
   "er" -> {Sin[theta] Cos[phi], Sin[theta] Sin[phi], Cos[theta]},
   "etheta" -> {Cos[theta] Cos[phi], Cos[theta] Sin[phi], -Sin[theta]},
   "ephi" -> {-Sin[phi], Cos[phi], 0}
   |>;

safeTheta[x_] := Module[{r = Norm[x], z},
  If[TrueQ[r == 0], Return[Indeterminate]];
  z = Clip[x[[3]]/r, {-1, 1}];
  ArcCos[z]
  ];

signedAngle[u_, v_, normal_] := ArcTan[u.v, normal.Cross[u, v]];

EMRI3DAcceleration[x_List, v_List, params_Association,
  OptionsPattern[]] := Module[
  {pn, includeRR25, includeRR, rrGauge, eps, m, eta, chi, e, r, n,
   rdot, v2, ne, ve, sc, a0, a1, a15, a2, a25, a3, aRR25, aRR35,
   aRR4SO, aRR45, aRR, a35, b35, a4SO, b4SO, c4SO, d4SO, e45, f45,
   gp},

  pn = OptionValue["PNOrder"];
  If[! validPNOrderQ[pn],
   Message[EMRI3DAcceleration::badpn, pn, EMRI3DAllowedPNOrders[]];
   Return[$Failed]
   ];
  includeRR25 = TrueQ[OptionValue["Include2p5PNRadiationReaction"]];
  includeRR = TrueQ[OptionValue["IncludeRadiationReaction"]];
  rrGauge = OptionValue["RRGaugeParameters"];
  eps = paramValue[params, "eps", 1];
  m = massValue[params];
  eta = etaValue[params];
  chi = paramValue[params, "chi", 0];
  e = spinVector[params];
  If[e === $Failed, Return[$Failed]];

  r = Sqrt[x.x];
  n = x/r;
  rdot = n.v;
  v2 = v.v;
  ne = n.e;
  ve = v.e;
  sc = e.Cross[n, v];

  a0 = -m*n/r^2;
  a1 = -(m/r^2)*((v2 - 4*m/r)*n - 4*rdot*v);
  a15 = (m^2/r^3)*chi*(6*sc*n + 6*rdot*Cross[n, e] -
      4*Cross[v, e]);
  a2 = -(m^2/r^3)*(((9*m/r - 2*rdot^2)*n + 2*rdot*v) -
      (3/2)*(m/r)*chi^2*(5*n*ne^2 - 2*e*ne - n));
  a25 = -(m^2/r^3)*chi*((m/r)*(20*sc*n + 16*rdot*Cross[n, e] -
        12*Cross[v, e]) + 6*rdot*sc*v);
  a3 = (m^3/r^4)*(((16*m/r - rdot^2)*n + 4*rdot*v) +
      chi^2*((3/2)*(5*n*ne^2 - 2*e*ne - n)*(v2 - 4*m/r) -
        6*v*(5*rdot*ne^2 - 2*ve*ne - rdot) +
        (2*m/r)*(n - 6*n*ne^2 + ne*e)));
  aRR25 = If[(includeRR || includeRR25) && N[pn] >= 2.5,
    (8/5)*eta*m^2*eps^5/r^3*
     (((3*v2 + (17/3)*m/r)*rdot)*n - (v2 + 3*m/r)*v),
    {0, 0, 0}
    ];

  a35 = (183/28)*v2^2 + (519/42)*v2*m/r -
    (285/4)*v2*rdot^2 + (147/4)*rdot^2*m/r +
    70*rdot^4 + (989/14)*m^2/r^2;
  b35 = (313/28)*v2^2 - (205/42)*v2*m/r -
    (339/4)*v2*rdot^2 + (205/12)*rdot^2*m/r +
    75*rdot^4 + (1325/42)*m^2/r^2;
  aRR35 = If[includeRR && N[pn] >= 3.5,
    -(8/5)*eta*m^2*eps^7/r^3*(a35*rdot*n - b35*v),
    {0, 0, 0}
    ];

  a4SO = 120*v2 + 280*rdot^2 + 453*m/r;
  b4SO = 87*v2 - 675*rdot^2 - (901/3)*m/r;
  c4SO = 48*v2 + 15*rdot^2 + 364*m/r;
  d4SO = 31*v2^2 - 260*v2*rdot^2 + 245*rdot^4 -
    (689/3)*v2*m/r + 537*rdot^2*m/r + (4/3)*m^2/r^2;
  aRR4SO = If[includeRR && N[pn] >= 4,
    -(1/5)*eta*m^3*eps^8*chi/r^4*
     (sc*(a4SO*rdot*n + b4SO*v) -
       (2/3)*Cross[v, e]*rdot*c4SO + (1/2)*Cross[n, e]*d4SO),
    {0, 0, 0}
    ];

  gp[key_String] := paramValue[rrGauge, key, 0];
  e45 =
   (779/168 + 3*gp["psi2"] - 3*gp["chi6"])*v2^3 -
    (295/84 + 5*gp["psi2"] - 5*gp["chi6"] - 5*gp["psi4"] +
       5*gp["chi8"])*v2^2*rdot^2 -
    9*gp["psi7"]*rdot^6 +
    (145/6 - 7*gp["psi4"] + 7*gp["chi8"] + 7*gp["psi7"])*
     v2*rdot^4 +
    (6793/84 - 2*gp["psi1"] - 3*gp["psi2"] + 3*gp["chi6"] +
       3*gp["psi6"] - 3*gp["chi9"])*v2^2*m/r -
    (218401/504 + 4*gp["psi2"] + 5*gp["psi4"] + 6*gp["psi6"] -
       5*gp["psi8"] - 2*gp["chi6"] - 5*gp["chi8"] -
       6*gp["chi9"])*v2*rdot^2*m/r +
    (54161/126 - 2*gp["psi4"] - 7*gp["psi7"] -
       8*gp["psi8"])*rdot^4*m/r -
    (83 + 2*gp["psi3"] + 3*gp["psi6"] - 3*gp["chi9"] -
       3*gp["psi9"])*v2*m^2/r^2 +
    (83407/252 - 2*gp["psi6"] - 5*gp["psi8"] -
       7*gp["psi9"])*rdot^2*m^2/r^2 +
    (41297/108 - 2*gp["psi5"] - 3*gp["psi9"])*m^3/r^3;
  f45 =
   (417/28 - gp["psi1"])*v2^3 -
    (380/3 - 3*gp["psi1"] + 3*gp["chi6"])*v2^2*rdot^2 -
    (485/6 - 7*gp["chi8"])*rdot^6 +
    (34445/168 + 5*gp["chi6"] - 5*gp["chi8"])*v2*rdot^4 +
    (1859/56 + gp["psi1"] - gp["psi3"])*v2^2*m/r -
    (16687/42 - 4*gp["psi1"] - 4*gp["psi3"] -
       3*gp["chi6"] + 3*gp["chi9"])*v2*rdot^2*m/r +
    (99499/252 + 2*gp["chi6"] + 5*gp["chi8"] +
       6*gp["chi9"])*rdot^4*m/r -
    (2967/28 - gp["psi3"] + gp["psi5"])*v2*m^2/r^2 +
    (3166/21 + 2*gp["psi3"] + 5*gp["psi5"] +
       3*gp["chi9"])*rdot^2*m^2/r^2 +
    (395929/2268 + gp["psi5"])*m^3/r^3;
  aRR45 = If[includeRR && N[pn] >= 4.5,
    (8/5)*eta*m^2*eps^9/r^3*(e45*rdot*n - f45*v),
    {0, 0, 0}
    ];
  aRR = aRR25 + aRR35 + aRR4SO + aRR45;

  a0 +
   includeTerm[pn, 1, eps^2*a1, {0, 0, 0}] +
   includeTerm[pn, 1.5, eps^3*a15, {0, 0, 0}] +
   includeTerm[pn, 2, eps^4*a2, {0, 0, 0}] +
   includeTerm[pn, 2.5, eps^5*a25, {0, 0, 0}] +
   includeTerm[pn, 3, eps^6*a3, {0, 0, 0}] +
   aRR
  ];

EMRI3DStateFromSpherical[initialData_Association] := Module[
  {required, missing, r, theta, phi, rd, thetad, phid, basis, x, v},
  required = {"r", "theta", "phi", "rdot", "thetadot", "phidot"};
  missing = Select[required, ! KeyExistsQ[initialData, #] &];
  If[missing =!= {},
   Message[EMRI3DStateFromSpherical::missing, missing];
   Return[$Failed]
   ];
  {r, theta, phi, rd, thetad, phid} = Lookup[initialData, required];
  basis = sphericalBasis[theta, phi];
  x = r*basis["er"];
  v = rd*basis["er"] + r*thetad*basis["etheta"] +
    r*Sin[theta]*phid*basis["ephi"];
  <|"x" -> x, "v" -> v|>
  ];

EMRI3DSphericalFromState[x_List, v_List] := Module[
  {r, theta, phi, basis, rd, thetad, phid, sinTheta},
  r = Norm[x];
  theta = safeTheta[x];
  phi = ArcTan[x[[1]], x[[2]]];
  basis = sphericalBasis[theta, phi];
  rd = v.basis["er"];
  thetad = If[TrueQ[r == 0], Indeterminate, (v.basis["etheta"])/r];
  sinTheta = Sin[theta];
  phid = If[TrueQ[r == 0 || Chop[sinTheta] == 0],
    Indeterminate,
    (v.basis["ephi"])/(r*sinTheta)
    ];
  <|"r" -> r, "theta" -> theta, "phi" -> phi, "rdot" -> rd,
   "thetadot" -> thetad, "phidot" -> phid|>
  ];

stateFromInitialData[initialData_Association] := Module[{missing},
  If[KeyExistsQ[initialData, "x"] && KeyExistsQ[initialData, "v"],
   Return[<|"x" -> initialData["x"], "v" -> initialData["v"]|>]
   ];
  missing = Complement[{"r", "theta", "phi", "rdot", "thetadot",
     "phidot"}, Keys[initialData]];
  If[missing === {}, Return[EMRI3DStateFromSpherical[initialData]]];
  Message[EMRI3DOrbit::badic, Keys[initialData]];
  $Failed
  ];

EMRI3DOrbit[params_Association, initialData_Association, times_List,
  OptionsPattern[]] := Module[
  {wp, acc, prec, pn, step, method, includeRR25, includeRR, rrGauge,
   returnCartesian, tStart, tauEnd, state, x0, v0, accVec, sol, states,
   ndsolveOpts, cart},

  wp = OptionValue[WorkingPrecision];
  acc = OptionValue[AccuracyGoal];
  prec = OptionValue[PrecisionGoal];
  pn = OptionValue["PNOrder"];
  If[! validPNOrderQ[pn],
   Message[EMRI3DOrbit::badpn, pn, EMRI3DAllowedPNOrders[]];
   Return[$Failed]
   ];
  step = OptionValue[MaxStepSize];
  method = OptionValue[Method];
  includeRR25 = TrueQ[OptionValue["Include2p5PNRadiationReaction"]];
  includeRR = TrueQ[OptionValue["IncludeRadiationReaction"]];
  rrGauge = OptionValue["RRGaugeParameters"];
  returnCartesian = TrueQ[OptionValue["ReturnCartesian"]];

  state = stateFromInitialData[initialData];
  If[state === $Failed, Return[$Failed]];
  {x0, v0} = Lookup[state, {"x", "v"}];
  tStart = First[times];
  tauEnd = N[Last[times] - tStart, wp];

  ndsolveOpts = Sequence[
    WorkingPrecision -> wp,
    AccuracyGoal -> acc,
    PrecisionGoal -> prec,
    Method -> method,
    MaxSteps -> Infinity
    ];

  accVec[tt_] := EMRI3DAcceleration[
    {xx[tt], yy[tt], zz[tt]}, {vx[tt], vy[tt], vz[tt]}, params,
    "PNOrder" -> pn,
    "Include2p5PNRadiationReaction" -> includeRR25,
    "IncludeRadiationReaction" -> includeRR,
    "RRGaugeParameters" -> rrGauge
    ];

  sol = Quiet[
    NDSolveValue[
     {
      xx'[tt] == vx[tt],
      yy'[tt] == vy[tt],
      zz'[tt] == vz[tt],
      vx'[tt] == Evaluate[accVec[tt][[1]]],
      vy'[tt] == Evaluate[accVec[tt][[2]]],
      vz'[tt] == Evaluate[accVec[tt][[3]]],
      xx[0] == N[x0[[1]], wp],
      yy[0] == N[x0[[2]], wp],
      zz[0] == N[x0[[3]], wp],
      vx[0] == N[v0[[1]], wp],
      vy[0] == N[v0[[2]], wp],
      vz[0] == N[v0[[3]], wp]
      },
     {xx, yy, zz, vx, vy, vz},
     {tt, 0, tauEnd},
     Evaluate[ndsolveOpts],
     If[step === Automatic, Sequence @@ {}, MaxStepSize -> step]
     ],
    NDSolveValue::precw
    ];

  states = Table[
    Module[{tau = N[t - tStart, wp], xval, vval, sph},
     xval = #[tau] & /@ sol[[1 ;; 3]];
     vval = #[tau] & /@ sol[[4 ;; 6]];
     sph = EMRI3DSphericalFromState[xval, vval];
     Join[<|"t" -> N[t, wp], "tau" -> tau|>, sph,
      If[returnCartesian, <|"x" -> xval, "v" -> vval|>, <||>]]
     ],
    {t, times}
    ];

  cart = If[returnCartesian,
    <|"x" -> Lookup[states, "x"], "v" -> Lookup[states, "v"]|>,
    <||>
    ];

  Join[
   <|"t" -> Lookup[states, "t"], "r" -> Lookup[states, "r"],
    "theta" -> Lookup[states, "theta"], "phi" -> Lookup[states, "phi"],
    "rdot" -> Lookup[states, "rdot"],
    "thetadot" -> Lookup[states, "thetadot"],
    "phidot" -> Lookup[states, "phidot"]|>,
   cart
   ]
  ];

EMRI3DStateFromOsculatingElements[elements_Association,
  params_Association : <||>] := Module[
  {m, e, inc, omega, phi0, omegaNode, f, p, a, r, h, rd, vt, xpf,
   vpf, rot},
  m = massValue[params];
  If[! KeyExistsQ[elements, "e"],
   Message[EMRI3DStateFromOsculatingElements::missing, {"e"}];
   Return[$Failed]
   ];
  e = elements["e"];
  inc = paramValue[elements, "i", paramValue[elements, "inclination", 0]];
  omega = paramValue[elements, "varphi0",
    paramValue[elements, "omega", 0]];
  phi0 = paramValue[elements, "phi0", Pi/2];
  omegaNode = paramValue[elements, "Omega", phi0 - Pi/2];
  f = paramValue[elements, "varphi",
    paramValue[elements, "trueAnomaly", 0]];
  p = If[KeyExistsQ[elements, "p"],
    elements["p"],
    If[KeyExistsQ[elements, "a"],
     a = elements["a"];
     Which[e > 1, a*(e^2 - 1), e < 1, a*(1 - e^2),
      True, Message[EMRI3DStateFromOsculatingElements::needp]; Return[$Failed]],
     Message[EMRI3DStateFromOsculatingElements::missing, {"a or p"}];
     Return[$Failed]
     ]
    ];
  r = p/(1 + e*Cos[f]);
  h = Sqrt[m*p];
  rd = (m/h)*e*Sin[f];
  vt = h/r;
  xpf = r*{Cos[f], Sin[f], 0};
  vpf = {rd*Cos[f] - vt*Sin[f], rd*Sin[f] + vt*Cos[f], 0};
  rot = rotZ[omegaNode].rotX[inc].rotZ[omega];
  <|"x" -> rot.xpf, "v" -> rot.vpf|>
  ];

EMRI3DOsculatingElementsFromState[x_List, v_List,
  params_Association : <||>] := Module[
  {m, zhat, r, v2, energy, hvec, h, hhat, nvec, nnorm, evec, ecc,
   p, a, inc, omegaNode, phi0, omega, f, orbitType, tol},
  m = massValue[params];
  zhat = {0, 0, 1};
  tol = 10^-12;
  r = Norm[x];
  v2 = v.v;
  energy = v2/2 - m/r;
  hvec = Cross[x, v];
  h = Norm[hvec];
  hhat = hvec/h;
  nvec = Cross[zhat, hvec];
  nnorm = Norm[nvec];
  evec = Cross[v, hvec]/m - x/r;
  ecc = Norm[evec];
  p = h^2/m;
  a = Which[energy < -tol, -m/(2*energy),
    energy > tol, m/(2*energy),
    True, Infinity];
  orbitType = Which[ecc < 1 - 10^-10, "Bound",
    ecc > 1 + 10^-10, "Unbound",
    True, "Parabolic"];
  inc = ArcCos[Clip[hvec[[3]]/h, {-1, 1}]];
  omegaNode = If[nnorm > tol, ArcTan[nvec[[1]], nvec[[2]]], 0];
  phi0 = omegaNode + Pi/2;
  omega = If[nnorm > tol && ecc > tol,
    signedAngle[nvec/nnorm, evec/ecc, hhat],
    0
    ];
  f = If[ecc > tol,
    signedAngle[evec/ecc, x/r, hhat],
    If[nnorm > tol, signedAngle[nvec/nnorm, x/r, hhat], 0]
    ];
  <|"orbitType" -> orbitType, "a" -> a, "e" -> ecc, "p" -> p,
   "i" -> inc, "Omega" -> omegaNode, "phi0" -> phi0,
   "varphi0" -> omega, "varphi" -> f, "energy" -> energy,
   "h" -> h, "hVector" -> hvec, "eVector" -> evec|>
  ];

EMRI3DOsculatingElements[orbit_Association,
  params_Association : <||>] := Module[
  {required, missing, states},
  required = {"r", "theta", "phi", "rdot", "thetadot", "phidot"};
  missing = Select[required, ! KeyExistsQ[orbit, #] &];
  If[missing =!= {},
   Message[EMRI3DOsculatingElements::missing, missing];
   Return[$Failed]
   ];
  states = MapThread[
    EMRI3DStateFromSpherical[
       <|"r" -> #1, "theta" -> #2, "phi" -> #3, "rdot" -> #4,
        "thetadot" -> #5, "phidot" -> #6|>] &,
    Lookup[orbit, required]];
  MapThread[
   Join[<|"t" -> #1|>,
     EMRI3DOsculatingElementsFromState[#2["x"], #2["v"], params]] &,
   {orbit["t"], states}]
  ];

forceComponents[elements_Association, force_, params_Association] :=
 Module[{state, x, v, er, ez, evarphi},
  If[AssociationQ[force],
   Return[<|"Fr" -> paramValue[force, "Fr", 0],
     "Fvarphi" -> paramValue[force, "Fvarphi",
       paramValue[force, "Fphi", 0]],
     "FZ" -> paramValue[force, "FZ", 0]|>]
   ];
  state = EMRI3DStateFromOsculatingElements[elements, params];
  If[state === $Failed, Return[$Failed]];
  {x, v} = Lookup[state, {"x", "v"}];
  er = x/Norm[x];
  ez = Normalize[Cross[x, v]];
  evarphi = Cross[ez, er];
  <|"Fr" -> force.er, "Fvarphi" -> force.evarphi, "FZ" -> force.ez|>
  ];

EMRI3DHyperbolicGaussianRates[elements_Association, force_,
  params_Association : <||>] := Module[
  {m, a, e, inc, phi0, varphi0, varphi, omegaK, b, r, ch, sh, xi,
   comps, fr, fv, fz, phidot0, idot, varphi0dot, adot, edot,
   mdot, varphidot},
  m = massValue[params];
  If[! And @@ (KeyExistsQ[elements, #] & /@ {"a", "e", "i", "phi0",
        "varphi0", "varphi"}),
   Message[EMRI3DHyperbolicGaussianRates::missing,
    {"a", "e", "i", "phi0", "varphi0", "varphi"}];
   Return[$Failed]
   ];
  {a, e, inc, phi0, varphi0, varphi} =
   Lookup[elements, {"a", "e", "i", "phi0", "varphi0", "varphi"}];
  If[! TrueQ[e > 1],
   Message[EMRI3DHyperbolicGaussianRates::notunbound, e];
   Return[$Failed]
   ];
  omegaK = Sqrt[m/a^3];
  b = a*Sqrt[e^2 - 1];
  r = a*(e^2 - 1)/(1 + e*Cos[varphi]);
  ch = (e + Cos[varphi])/(1 + e*Cos[varphi]);
  sh = Sin[varphi]*(e*ch - 1)/Sqrt[e^2 - 1];
  xi = ArcSinh[sh];
  comps = forceComponents[elements, force, params];
  If[comps === $Failed, Return[$Failed]];
  {fr, fv, fz} = Lookup[comps, {"Fr", "Fvarphi", "FZ"}];
  phidot0 =
   r*Sin[varphi + varphi0 + Pi/2]*fz/
    (a^2*omegaK*Sqrt[e^2 - 1]*Sin[inc]);
  idot =
   r*Cos[varphi + varphi0 + Pi/2]*fz/
    (a^2*omegaK*Sqrt[e^2 - 1]);
  adot = a*(-2/omegaK)*
    ((e*Sin[varphi]/(a*Sqrt[e^2 - 1]))*fr +
      (Sqrt[e^2 - 1]/r)*fv);
  edot = Sqrt[e^2 - 1]/(a*omegaK)*
    ((Cos[varphi] + ch)*fv + Sin[varphi]*fr);
  varphi0dot =
   Sqrt[e^2 - 1]/(a*e*omegaK)*
     ((1 + a*r/b^2)*Sin[varphi]*fv - Cos[varphi]*fr) -
    Cos[inc]*phidot0;
  mdot = omegaK +
    (1 - e*ch)*(a*ch*edot - (1 - e*ch)*adot)/(a*e*sh) +
    sh*edot;
  varphidot = a^2*omegaK*Sqrt[e^2 - 1]/r^2 -
    (varphi0dot + Cos[inc]*phidot0);
  <|"adot" -> adot, "edot" -> edot, "varphi0dot" -> varphi0dot,
   "phi0dot" -> phidot0, "idot" -> idot, "Mdot" -> mdot,
   "varphidot" -> varphidot, "Fr" -> fr, "Fvarphi" -> fv,
   "FZ" -> fz, "xi" -> xi|>
  ];

EMRI3DAcceleration::badpn = "Unsupported PNOrder `1`. Use one of `2`.";
EMRI3DAcceleration::badspin =
  "spinDirection/eSpin must be a nonzero vector, got `1`.";
EMRI3DOrbit::badpn = "Unsupported PNOrder `1`. Use one of `2`.";
EMRI3DOrbit::badic =
  "Initial data must contain either x,v or r,theta,phi,rdot,thetadot,phidot. Got keys `1`.";
EMRI3DStateFromSpherical::missing =
  "Spherical initial data is missing keys `1`.";
EMRI3DStateFromOsculatingElements::missing =
  "Osculating elements are missing keys `1`.";
EMRI3DStateFromOsculatingElements::needp =
  "Parabolic elements with e == 1 require p.";
EMRI3DOsculatingElements::missing =
  "Orbit is missing keys `1`.";
EMRI3DHyperbolicGaussianRates::missing =
  "Hyperbolic Gaussian rates require elements `1`.";
EMRI3DHyperbolicGaussianRates::notunbound =
  "Hyperbolic Gaussian rates require e > 1. Got e = `1`.";

End[];

EndPackage[];

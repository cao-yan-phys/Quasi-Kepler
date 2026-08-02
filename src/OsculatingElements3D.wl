(* ::Package:: *)

BeginPackage["OsculatingElements3D`"];

Osculating3DStateFromSpherical;
Osculating3DSphericalFromState;
Osculating3DStateFromElements;
Osculating3DElementsFromState;
Osculating3DElementsFromOrbit;
Osculating3DHyperbolicGaussianRates;
Begin["`Private`"];

paramValue[params_Association, key_String, default_] :=
  Lookup[params, key, default];

massValue[params_Association] := paramValue[params, "M", 1];

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
wrapAngle[x_] := Arg[Exp[I*x]];

paperOrbitalBasis[inc_, phi0_, varphi0_] := Module[
  {aHat, bHat, pHat, qHat},
  aHat = {Cos[inc]*Cos[phi0], Cos[inc]*Sin[phi0], Sin[inc]};
  bHat = {-Sin[phi0], Cos[phi0], 0};
  pHat = aHat*Cos[varphi0] + bHat*Sin[varphi0];
  qHat = -aHat*Sin[varphi0] + bHat*Cos[varphi0];
  <|"pHat" -> pHat, "qHat" -> qHat,
   "LHat" -> Cross[pHat, qHat]|>
  ];

phaseFromTrueAnomaly[e_, p_, a_, f_, m_, orbitType_] := Module[
  {cosu, sinu, u, mean, omega, ch, sh, xi, d, tau},
  Switch[orbitType,
   "Bound",
   cosu = (e + Cos[f])/(1 + e*Cos[f]);
   sinu = Sqrt[1 - e^2]*Sin[f]/(1 + e*Cos[f]);
   u = ArcTan[cosu, sinu];
   mean = u - e*Sin[u];
   omega = Sqrt[m/a^3];
   <|"anomaly" -> u, "eccentricAnomaly" -> u,
    "meanAnomaly" -> mean, "phaseTime" -> mean/omega|>,
   "Unbound",
   ch = (e + Cos[f])/(1 + e*Cos[f]);
   sh = Sqrt[e^2 - 1]*Sin[f]/(1 + e*Cos[f]);
   xi = ArcSinh[sh];
   mean = e*sh - xi;
   omega = Sqrt[m/a^3];
   <|"anomaly" -> xi, "hyperbolicAnomaly" -> xi,
    "meanAnomaly" -> mean, "phaseTime" -> mean/omega|>,
   "Parabolic",
   d = Tan[f/2];
   tau = Sqrt[p^3/m]*(d + d^3/3)/2;
   <|"anomaly" -> d, "barkerVariable" -> d,
    "meanAnomaly" -> Missing["NotApplicable"], "phaseTime" -> tau|>
   ]
  ];

trueAnomalyFromTime[e_, p_, a_, time_, t0_, m_] := Module[
  {omega, mean, u, xi, d, b, cosf, sinf},
  Which[
   e < 1,
   omega = Sqrt[m/a^3];
   mean = omega*(time - t0);
   u = u /. Quiet[FindRoot[u - e*Sin[u] == mean, {u, mean}]];
   cosf = (Cos[u] - e)/(1 - e*Cos[u]);
   sinf = Sqrt[1 - e^2]*Sin[u]/(1 - e*Cos[u]);
   ArcTan[cosf, sinf],
   e > 1,
   omega = Sqrt[m/a^3];
   mean = omega*(time - t0);
   xi = xi /. Quiet[FindRoot[e*Sinh[xi] - xi == mean,
       {xi, ArcSinh[mean/e]}]];
   cosf = (e - Cosh[xi])/(e*Cosh[xi] - 1);
   sinf = Sqrt[e^2 - 1]*Sinh[xi]/(e*Cosh[xi] - 1);
   ArcTan[cosf, sinf],
   True,
   b = 2*(time - t0)/Sqrt[p^3/m];
   d = 2*Sinh[ArcSinh[3*b/2]/3];
   2*ArcTan[d]
   ]
  ];

Osculating3DStateFromSpherical[initialData_Association] := Module[
  {required, missing, r, theta, phi, rd, thetad, phid, basis, x, v},
  required = {"r", "theta", "phi", "rdot", "thetadot", "phidot"};
  missing = Select[required, ! KeyExistsQ[initialData, #] &];
  If[missing =!= {},
   Message[Osculating3DStateFromSpherical::missing, missing];
   Return[$Failed]
   ];
  {r, theta, phi, rd, thetad, phid} = Lookup[initialData, required];
  basis = sphericalBasis[theta, phi];
  x = r*basis["er"];
  v = rd*basis["er"] + r*thetad*basis["etheta"] +
    r*Sin[theta]*phid*basis["ephi"];
  <|"x" -> x, "v" -> v|>
  ];

Osculating3DSphericalFromState[x_List, v_List] := Module[
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

Osculating3DStateFromElements[elements_Association,
  params_Association : <||>] := Module[
  {m, e, inc, omega, phi0, f, p, a, r, h, rd, vt, xpf,
   vpf, basis, time, t0},
  m = massValue[params];
  If[! KeyExistsQ[elements, "e"],
   Message[Osculating3DStateFromElements::missing, {"e"}];
   Return[$Failed]
   ];
  e = elements["e"];
  inc = paramValue[elements, "i", paramValue[elements, "inclination", 0]];
  omega = paramValue[elements, "varphi0",
    paramValue[elements, "omega", 0]];
  phi0 = paramValue[elements, "phi0", Pi/2];
  p = If[KeyExistsQ[elements, "p"],
    elements["p"],
    If[KeyExistsQ[elements, "a"],
     a = elements["a"];
     Which[e > 1, a*(e^2 - 1), e < 1, a*(1 - e^2),
      True, Message[Osculating3DStateFromElements::needp]; Return[$Failed]],
     Message[Osculating3DStateFromElements::missing, {"a or p"}];
     Return[$Failed]
     ]
    ];
  a = Which[e < 1, p/(1 - e^2), e > 1, p/(e^2 - 1), True, Infinity];
  f = Which[
    KeyExistsQ[elements, "varphi"], elements["varphi"],
    KeyExistsQ[elements, "trueAnomaly"], elements["trueAnomaly"],
    KeyExistsQ[elements, "t"] && KeyExistsQ[elements, "t0"],
    time = elements["t"];
    t0 = elements["t0"];
    trueAnomalyFromTime[e, p, a, time, t0, m],
    True, 0
    ];
  r = p/(1 + e*Cos[f]);
  h = Sqrt[m*p];
  rd = (m/h)*e*Sin[f];
  vt = h/r;
  basis = paperOrbitalBasis[inc, phi0, omega];
  xpf = r*(Cos[f]*basis["pHat"] + Sin[f]*basis["qHat"]);
  vpf = rd*(Cos[f]*basis["pHat"] + Sin[f]*basis["qHat"]) +
    vt*(-Sin[f]*basis["pHat"] + Cos[f]*basis["qHat"]);
  <|"x" -> xpf, "v" -> vpf|>
  ];

osculatingElementsFromState[x_List, v_List, time_,
  params_Association : <||>] := Module[
  {m, zhat, r, v2, energy, hvec, h, hhat, nvec, nnorm, evec, ecc,
   p, a, inc, omegaNode, phi0, omega, f, orbitType, tol, phase, t0},
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
    wrapAngle[signedAngle[nvec/nnorm, evec/ecc, hhat] - Pi/2],
    0
    ];
  f = If[ecc > tol,
    signedAngle[evec/ecc, x/r, hhat],
    If[nnorm > tol, signedAngle[nvec/nnorm, x/r, hhat], 0]
     ];
  phase = phaseFromTrueAnomaly[ecc, p, a, f, m, orbitType];
  t0 = If[MissingQ[time], Missing["TimeNotProvided"],
    time - phase["phaseTime"]];
  <|"orbitType" -> orbitType, "a" -> a, "e" -> ecc, "p" -> p,
    "i" -> inc, "Omega" -> omegaNode, "phi0" -> phi0,
    "varphi0" -> omega, "t0" -> t0, "varphi" -> f,
    "anomaly" -> phase["anomaly"],
    "meanAnomaly" -> phase["meanAnomaly"], "energy" -> energy,
    "h" -> h, "hVector" -> hvec, "eVector" -> evec|>
  ];

Osculating3DElementsFromState[x_List, v_List,
  params_Association : <||>] :=
 osculatingElementsFromState[x, v, Missing["TimeNotProvided"], params];

Osculating3DElementsFromState[x_List, v_List, time_?NumericQ,
  params_Association : <||>] :=
 osculatingElementsFromState[x, v, time, params];

stateFromOrbitPoint[orbit_Association, index_Integer] := Module[
  {state},
  If[KeyExistsQ[orbit, "x"] && KeyExistsQ[orbit, "v"],
   Return[<|"x" -> orbit["x"][[index]], "v" -> orbit["v"][[index]]|>]
   ];
  state = Osculating3DStateFromSpherical[
    AssociationThread[{"r", "theta", "phi", "rdot", "thetadot",
      "phidot"} -> (#[[index]] & /@ Lookup[orbit, {"r", "theta", "phi",
         "rdot", "thetadot", "phidot"}])]];
  state
  ];

Osculating3DElementsFromOrbit[orbit_Association,
  params_Association : <||>] := Module[
  {requiredSpherical, missing, npts, states},
  If[KeyExistsQ[orbit, "x"] && KeyExistsQ[orbit, "v"],
   npts = Length[orbit["x"]],
   requiredSpherical = {"r", "theta", "phi", "rdot", "thetadot",
     "phidot"};
   missing = Select[requiredSpherical, ! KeyExistsQ[orbit, #] &];
   If[missing =!= {},
    Message[Osculating3DElementsFromOrbit::missing, missing];
    Return[$Failed]
    ];
   npts = Length[orbit["r"]]
   ];
  states = stateFromOrbitPoint[orbit, #] & /@ Range[npts];
  MapThread[
   Join[If[KeyExistsQ[orbit, "t"], <|"t" -> #1|>, <||>],
     If[MissingQ[#1],
      Osculating3DElementsFromState[#2["x"], #2["v"], params],
      Osculating3DElementsFromState[#2["x"], #2["v"], #1, params]]] &,
   {If[KeyExistsQ[orbit, "t"], orbit["t"], ConstantArray[Missing["t"], npts]],
    states}]
  ];

forceComponents[elements_Association, force_, params_Association] :=
 Module[{state, x, v, er, ez, evarphi},
  If[AssociationQ[force],
   Return[<|"Fr" -> paramValue[force, "Fr", 0],
     "Fvarphi" -> paramValue[force, "Fvarphi",
       paramValue[force, "Fphi", 0]],
     "FZ" -> paramValue[force, "FZ", 0]|>]
   ];
  state = Osculating3DStateFromElements[elements, params];
  If[state === $Failed, Return[$Failed]];
  {x, v} = Lookup[state, {"x", "v"}];
  er = x/Norm[x];
  ez = Normalize[Cross[x, v]];
  evarphi = Cross[ez, er];
  <|"Fr" -> force.er, "Fvarphi" -> force.evarphi, "FZ" -> force.ez|>
  ];

Osculating3DHyperbolicGaussianRates[elements_Association, force_,
  params_Association : <||>] := Module[
  {m, a, e, inc, phi0, varphi0, varphi, omegaK, b, r, ch, sh, xi,
   comps, fr, fv, fz, phidot0, idot, varphi0dot, adot, edot,
   mdot, varphidot, mean, t0dot},
  m = massValue[params];
  If[! And @@ (KeyExistsQ[elements, #] & /@ {"a", "e", "i", "phi0",
        "varphi0", "varphi"}),
   Message[Osculating3DHyperbolicGaussianRates::missing,
    {"a", "e", "i", "phi0", "varphi0", "varphi"}];
   Return[$Failed]
   ];
  {a, e, inc, phi0, varphi0, varphi} =
   Lookup[elements, {"a", "e", "i", "phi0", "varphi0", "varphi"}];
  If[! TrueQ[e > 1],
   Message[Osculating3DHyperbolicGaussianRates::notunbound, e];
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
  mean = e*sh - xi;
  t0dot = 1 - mdot/omegaK - (3/2)*(adot/a)*mean/omegaK;
  varphidot = a^2*omegaK*Sqrt[e^2 - 1]/r^2 -
    (varphi0dot + Cos[inc]*phidot0);
  <|"adot" -> adot, "edot" -> edot, "varphi0dot" -> varphi0dot,
    "phi0dot" -> phidot0, "idot" -> idot, "t0dot" -> t0dot,
    "Mdot" -> mdot,
   "varphidot" -> varphidot, "Fr" -> fr, "Fvarphi" -> fv,
   "FZ" -> fz, "xi" -> xi|>
  ];

Osculating3DStateFromSpherical::missing =
  "Spherical initial data is missing keys `1`.";
Osculating3DStateFromElements::missing =
  "Osculating elements are missing keys `1`.";
Osculating3DStateFromElements::needp =
  "Parabolic elements with e == 1 require p.";
Osculating3DElementsFromOrbit::missing =
  "Orbit is missing keys `1`.";
Osculating3DHyperbolicGaussianRates::missing =
  "Hyperbolic Gaussian rates require elements `1`.";
Osculating3DHyperbolicGaussianRates::notunbound =
  "Hyperbolic Gaussian rates require e > 1. Got e = `1`.";

End[];

EndPackage[];
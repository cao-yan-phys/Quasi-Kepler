(* ::Package:: *)

BeginPackage["SpinOrbitScattering1p5PN`"];

SpinOrbitScattering1p5PN;
VelocityScatteringVector;
Begin["`Private`"];

paramValue[params_Association, key_String, default_] := Lookup[params, key, default];

massFractions[params_Association] := Module[{nu, delta, q},
  q = paramValue[params, "q", Missing["q"]];
  nu = paramValue[params, "nu",
    If[MissingQ[q], Missing["nu"], q/(1 + q)^2]];
  delta = paramValue[params, "delta",
    If[MissingQ[nu], Missing["delta"], Sqrt[1 - 4*nu]]];
  If[MissingQ[delta], Return[$Failed]];
  <|"nu" -> nu, "delta" -> delta, "X1" -> (1 + delta)/2,
   "X2" -> (1 - delta)/2|>
  ];

spinVectors[params_Association, fractions_Association, mass_] := Module[
  {x1, x2, s1, s2},
  {x1, x2} = Lookup[fractions, {"X1", "X2"}];
  s1 = Which[
    KeyExistsQ[params, "S1"], params["S1"],
    KeyExistsQ[params, "chi1Vec"], mass^2*x1^2*params["chi1Vec"],
    True, {0, 0, 0}
    ];
  s2 = Which[
    KeyExistsQ[params, "S2"], params["S2"],
    KeyExistsQ[params, "chi2Vec"], mass^2*x2^2*params["chi2Vec"],
    True, {0, 0, 0}
    ];
  <|"S1" -> s1, "S2" -> s2, "S" -> s1 + s2,
   "Sigma" -> s2/x2 - s1/x1|>
  ];

orbitalBasis[elements_Association] := Module[
  {inc, phi0, varphi0, aHat, bHat, pHat, qHat},
  {inc, phi0, varphi0} = Lookup[elements, {"i", "phi0", "varphi0"}];
  aHat = {Cos[inc]*Cos[phi0], Cos[inc]*Sin[phi0], Sin[inc]};
  bHat = {-Sin[phi0], Cos[phi0], 0};
  pHat = aHat*Cos[varphi0] + bHat*Sin[varphi0];
  qHat = -aHat*Sin[varphi0] + bHat*Cos[varphi0];
  <|"pHat" -> pHat, "qHat" -> qHat,
   "LHat" -> Cross[pHat, qHat]|>
  ];

hyperbolicIntegrals[e_] := Module[
  {rho, fInf, is2, ic2, is2c, ic1, ic3, i2, i3, icPoly},
  rho = Sqrt[e^2 - 1];
  fInf = ArcCos[-1/e];
  is2 = fInf + rho/e^2;
  ic2 = fInf - rho/e^2;
  is2c = 2*rho^3/(3*e^3);
  ic1 = 2*rho/e;
  ic3 = 2*rho/e - 2*rho^3/(3*e^3);
  i2 = is2 + e*is2c;
  i3 = ic2 + e*ic3;
  icPoly = ic1 + 2*e*ic2 + e^2*ic3;
  <|"rho" -> rho, "fInfinity" -> fInf, "ISin2" -> is2,
   "ISin2Cos" -> is2c, "I2" -> i2, "I3" -> i3,
   "ICosPolynomial" -> icPoly|>
  ];

VelocityScatteringVector[kIn_List, kOut_List] := Module[
  {kin, kout, cross, crossNorm, angle},
  kin = Normalize[kIn];
  kout = Normalize[kOut];
  cross = Cross[kin, kout];
  crossNorm = Norm[cross];
  angle = ArcTan[Clip[kin.kout, {-1, 1}], crossNorm];
  If[TrueQ[Chop[crossNorm] == 0], {0, 0, 0}, angle*cross/crossNorm]
  ];

frameRotationVector[rotation_?MatrixQ] := Module[{log},
  If[! MatrixQ[rotation, NumericQ],
   Return[Missing["NumericParametersRequired"]]
   ];
  log = Chop[MatrixLog[N[rotation]]];
  {log[[3, 2]], log[[1, 3]], log[[2, 1]]}
  ];

SpinOrbitScattering1p5PN[elements_Association,
  params_Association : <||>] := Module[
  {required, missing, mass, eps, fractions, delta, x1, x2, spins, svec, sigma,
   a, e, p, h, basis, pHat, qHat, lHat, ints, rho, fInf, is2, is2c,
   i2, i3, icPoly, sp, sq, sl, sigp, sigq, sigl, dhp, dhq, deq,
   del, deltaH, deltaE, deltaLHat, deltaPHat, deltaQHat, hOutHat,
   pOutHat, qOutHat, kIn, kOut0, deltaKOut, kOut, bIn, bOut,
   frameIn, frameOut, rotation, frameVector, chiVector, chiAngle, chiNewton,
   spinCoefficient1, spinCoefficient2, spinAngle1, spinAngle2,
   spinRotationVector1, spinRotationVector2, deltaSpin1, deltaSpin2,
   inc, omegaNode, nodeDirection, iDirection, deltaI, deltaPhi0,
   deltaVarphi0},

  required = {"a", "e", "i", "phi0", "varphi0"};
  missing = Select[required, ! KeyExistsQ[elements, #] &];
  If[missing =!= {},
   Message[SpinOrbitScattering1p5PN::missing, missing];
   Return[$Failed]
   ];
  {a, e, inc} = Lookup[elements, {"a", "e", "i"}];
  If[! TrueQ[e > 1],
   Message[SpinOrbitScattering1p5PN::notunbound, e];
   Return[$Failed]
   ];
  mass = paramValue[params, "M", 1];
  eps = paramValue[params, "eps", 1];
  fractions = massFractions[params];
  If[fractions === $Failed,
   Message[SpinOrbitScattering1p5PN::massratio];
   Return[$Failed]
   ];
  delta = fractions["delta"];
  {x1, x2} = Lookup[fractions, {"X1", "X2"}];
  spins = spinVectors[params, fractions, mass];
  {svec, sigma} = Lookup[spins, {"S", "Sigma"}];

  p = a*(e^2 - 1);
  h = Sqrt[mass*p];
  basis = orbitalBasis[elements];
  {pHat, qHat, lHat} = Lookup[basis, {"pHat", "qHat", "LHat"}];
  ints = hyperbolicIntegrals[e];
  {rho, fInf, is2, is2c, i2, i3, icPoly} =
   Lookup[ints, {"rho", "fInfinity", "ISin2", "ISin2Cos", "I2",
     "I3", "ICosPolynomial"}];

  {sp, sq, sl} = {svec.pHat, svec.qHat, svec.lHat};
  {sigp, sigq, sigl} = {sigma.pHat, sigma.qHat, sigma.lHat};

  dhp = eps^3/p*(2*e*is2c*sq + i2*(7*sq + 3*delta*sigq));
  dhq = eps^3/p*(2*e*is2c*sp - i3*(7*sp + 3*delta*sigp));
  deq = eps^3/(h*p)*
    (sl*(-4*e*is2 - 2*e^2*is2c) -
      (5*sl + 3*delta*sigl)*icPoly);
  del = -eps^3/(h*p)*
    (2*e^2*sq*is2c + e*(7*sq + 3*delta*sigq)*i2);

  deltaH = dhp*pHat + dhq*qHat;
  deltaE = deq*qHat + del*lHat;
  deltaLHat = deltaH/h;
  deltaPHat = deltaE/e;
  deltaQHat = Cross[deltaLHat, pHat] + Cross[lHat, deltaPHat];
  hOutHat = Normalize[lHat + deltaLHat];
  pOutHat = Normalize[pHat + deltaPHat];
  qOutHat = Normalize[qHat + deltaQHat];

  kIn = Normalize[pHat/e + rho*qHat/e];
  kOut0 = Normalize[-pHat/e + rho*qHat/e];
  deltaKOut = -deltaPHat/e + rho*deltaQHat/e;
  kOut = Normalize[kOut0 + deltaKOut];
  kOut = Normalize[kOut - (kOut.hOutHat)*hOutHat];
  bIn = Normalize[Cross[kIn, lHat]];
  bOut = Normalize[Cross[kOut, hOutHat]];
  frameIn = Transpose[{bIn, kIn, lHat}];
  frameOut = Transpose[{bOut, kOut, hOutHat}];
  rotation = frameOut.Transpose[frameIn];
  frameVector = frameRotationVector[rotation];
  chiVector = VelocityScatteringVector[kIn, kOut];
  chiAngle = Norm[chiVector];
  chiNewton = 2*ArcSin[1/e];

  spinCoefficient1 = 2 + 3*x2/(2*x1);
  spinCoefficient2 = 2 + 3*x1/(2*x2);
  spinAngle1 = 2*eps^2*spinCoefficient1*(fInf + rho)/p;
  spinAngle2 = 2*eps^2*spinCoefficient2*(fInf + rho)/p;
  spinRotationVector1 = spinAngle1*lHat;
  spinRotationVector2 = spinAngle2*lHat;
  deltaSpin1 = Cross[spinRotationVector1, spins["S1"]];
  deltaSpin2 = Cross[spinRotationVector2, spins["S2"]];

  omegaNode = elements["phi0"] - Pi/2;
  nodeDirection = {Cos[omegaNode], Sin[omegaNode], 0};
  iDirection = Normalize[Cross[nodeDirection, lHat]];
  deltaI = deltaLHat.iDirection;
  deltaPhi0 = If[TrueQ[Chop[Sin[inc]] == 0], Indeterminate,
    deltaLHat.nodeDirection/Sin[inc]];
  deltaVarphi0 = If[TrueQ[Indeterminate === deltaPhi0], Indeterminate,
    deltaPHat.qHat - Cos[inc]*deltaPhi0];

  <|"Order" -> "1.5PN spin-orbit", "a" -> a, "e" -> e,
   "p" -> p, "h" -> h, "fInfinity" -> fInf,
   "S1" -> spins["S1"], "S2" -> spins["S2"], "S" -> svec,
   "Sigma" -> sigma, "InitialBasis" -> basis,
   "DeltaHVector" -> deltaH, "DeltaEVector" -> deltaE,
   "InitialHVector" -> h*lHat, "InitialEVector" -> e*pHat,
   "FinalHVectorLinear" -> h*lHat + deltaH,
   "FinalEVectorLinear" -> e*pHat + deltaE,
   "KIn" -> kIn, "NewtonianKOut" -> kOut0,
   "DeltaKOut" -> deltaKOut, "KOut" -> kOut,
   "NewtonianScatteringAngle" -> chiNewton,
   "ScatteringAngle" -> chiAngle,
   "SpinScatteringAngleCorrection" -> chiAngle - chiNewton,
   "ScatteringVector" -> chiVector,
   "IncomingFrame" -> frameIn, "OutgoingFrame" -> frameOut,
   "FrameRotationMatrix" -> rotation,
   "FrameRotationVector" -> frameVector,
   "FinalBasisLinear" -> {pOutHat, qOutHat, hOutHat},
   "SpinRotationAxis" -> lHat,
   "SpinRotationAngles" -> <|"S1" -> spinAngle1,
     "S2" -> spinAngle2|>,
   "SpinRotationVectors" -> <|"S1" -> spinRotationVector1,
     "S2" -> spinRotationVector2|>,
   "DeltaSpinVectors" -> <|"S1" -> deltaSpin1,
     "S2" -> deltaSpin2|>,
   "FinalSpinVectorsLinear" -> <|"S1" -> spins["S1"] + deltaSpin1,
     "S2" -> spins["S2"] + deltaSpin2|>,
   "DeltaElements" -> <|"Deltaa" -> 0, "Deltae" -> 0,
     "Deltai" -> deltaI, "Deltaphi0" -> deltaPhi0,
     "Deltavarphi0" -> deltaVarphi0|>|>
  ];

SpinOrbitScattering1p5PN::missing =
  "Spin-orbit scattering requires elements `1`.";
SpinOrbitScattering1p5PN::notunbound =
  "Spin-orbit scattering requires e > 1. Got e = `1`.";
SpinOrbitScattering1p5PN::massratio =
  "Supply nu and optionally delta, or supply q.";

End[];

EndPackage[];
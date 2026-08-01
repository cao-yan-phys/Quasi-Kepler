(* ::Package:: *)

BeginPackage["CMPositions`"];

CMPositionsFromRelativeOrbit;
CMPositionsAllowedPNOrders;
Begin["`Private`"];

Options[CMPositionsFromRelativeOrbit] = {"PNOrder" -> 3, "R0Prime" -> 1,
   "Include2p5PNRadiationReaction" -> False};

CMPositionsAllowedPNOrders[] := {0, 1, 1.5, 2, 2.5, 3};

validPNOrderQ[pn_] := AnyTrue[CMPositionsAllowedPNOrders[],
   Chop[N[pn - #]] == 0 &
   ];

paramValue[params_Association, key_String, default_] :=
  Lookup[params, key, default];

ellCrossVec[a_, vec_] := a*{-vec[[2]], vec[[1]]};

vecCrossEll[vec_, a_] := a*{vec[[2]], -vec[[1]]};

includeTerm[pn_, min_, expr_, zero_] := If[N[pn] >= min, expr, zero];

requiredOrbitKeys[] := {"t", "r", "phi", "rdot", "phidot"};

validateOrbit[orbit_Association] := Module[{required, missing, lengths},
  required = requiredOrbitKeys[];
  missing = Select[required, ! KeyExistsQ[orbit, #] &];
  If[missing =!= {},
   Message[CMPositionsFromRelativeOrbit::missing, missing];
   Return[False];
   ];
  lengths = Length /@ Lookup[orbit, required];
  If[Length[Union[lengths]] =!= 1,
   Message[CMPositionsFromRelativeOrbit::lengths,
    AssociationThread[required -> lengths]];
   Return[False];
   ];
  True
  ];

validateParams[params_Association] := If[KeyExistsQ[params, "nu"],
   True,
   Message[CMPositionsFromRelativeOrbit::missingparams, {"nu"}];
   False
   ];

cmShiftAtPoint[r_, phi_, rd_, phidot_, params_Association, pn_, r0p_] :=
 Module[{epsv, nuv, deltav, chi1v, chi2v, x1, x2, nvec, lambdavec,
   xvec, vt, vvec, v2v, s, includeRR25, sl, sigmaL, p1, p2, p3, q2,
   q25, q3, pScalar, qScalar, zNS, sigmaCrossV, sCrossV, nCrossS,
   nCrossSigma, tripleS, zSO15, zSO25, zSO},

  epsv = paramValue[params, "eps", 1];
  nuv = paramValue[params, "nu", Missing["nu"]];
  deltav = paramValue[params, "delta", Sqrt[1 - 4 nuv]];
  chi1v = paramValue[params, "chi1",
    paramValue[params, "chiS", 0] + paramValue[params, "chiA", 0]];
  chi2v = paramValue[params, "chi2",
    paramValue[params, "chiS", 0] - paramValue[params, "chiA", 0]];

  x1 = (1 + deltav)/2;
  x2 = (1 - deltav)/2;
  nvec = {Cos[phi], Sin[phi]};
  lambdavec = {-Sin[phi], Cos[phi]};
  xvec = r*nvec;
  vt = r*phidot;
  vvec = rd*nvec + vt*lambdavec;
  v2v = rd^2 + vt^2;
  s = 1/r;
  includeRR25 = TrueQ[paramValue[params, "Include2p5PNRadiationReaction",
     False]];

  sl = (chi2v*(1 - deltav - 2*nuv) +
      chi1v*(1 + deltav - 2*nuv))/2;
  sigmaL = (chi1v*(-1 - deltav) + chi2v*(1 - deltav))/2;

  p1 = v2v/2 - s/2;
  p2 = 3*v2v^2/8 - 3*nuv*v2v^2/2 +
    s*(-rd^2/8 + 3*nuv*rd^2/4 + 19*v2v/8 +
       3*nuv*v2v/2) +
    s^2*(7/4 - nuv/2);
  p3 = 5*v2v^3/16 - 11*nuv*v2v^3/4 + 6*nuv^2*v2v^3 +
    s*(rd^4/16 - 5*nuv*rd^4/8 + 21*nuv^2*rd^4/16 -
       5*rd^2*v2v/16 + 21*nuv*rd^2*v2v/16 -
       11*nuv^2*rd^2*v2v/2 + 53*v2v^2/16 -
       7*nuv*v2v^2 - 15*nuv^2*v2v^2/2) +
    s^2*(-7*rd^2/3 + 73*nuv*rd^2/8 + 4*nuv^2*rd^2 +
       101*v2v/12 - 33*nuv*v2v/8 + 3*nuv^2*v2v) +
    s^3*(-14351/1260 + nuv/8 - nuv^2/2 +
       22*Log[r/r0p]/3);
  q2 = -7*rd/4;
  q25 = 4*v2v/5 - 8*s/5;
  q3 = rd*(5*rd^2/12 - 19*nuv*rd^2/24 -
      15*v2v/8 + 21*nuv*v2v/4) +
    s*rd*(-235/24 - 21*nuv/4);

  pScalar =
   includeTerm[pn, 1, epsv^2*p1, 0] +
    includeTerm[pn, 2, epsv^4*p2, 0] +
    includeTerm[pn, 3, epsv^6*p3, 0];
  qScalar =
   includeTerm[pn, 2, epsv^4*q2, 0] +
    If[includeRR25, includeTerm[pn, 2.5, epsv^5*q25, 0], 0] +
    includeTerm[pn, 3, epsv^6*q3, 0];
  zNS = nuv*deltav*(pScalar*xvec + qScalar*vvec);

  sigmaCrossV = ellCrossVec[sigmaL, vvec];
  sCrossV = ellCrossVec[sl, vvec];
  nCrossS = vecCrossEll[nvec, sl];
  nCrossSigma = vecCrossEll[nvec, sigmaL];
  tripleS = nvec.sCrossV;

  zSO15 = -nuv*epsv^3*sigmaCrossV;
  zSO25 = nuv*epsv^5*((-1/2 + 2*nuv)*v2v*sigmaCrossV +
      s*(deltav*tripleS*nvec - (3*deltav*rd/2)*nCrossS +
        (-1 + 4*nuv)*rd*nCrossSigma -
        (deltav/2)*sCrossV + (-2 - nuv)*sigmaCrossV));
  zSO = includeTerm[pn, 1.5, zSO15, {0, 0}] +
    includeTerm[pn, 2.5, zSO25, {0, 0}];

  <|"X1" -> x1, "X2" -> x2, "x" -> xvec, "z" -> zNS + zSO|>
  ];

CMPositionsFromRelativeOrbit[orbit_Association, primitiveParams_Association,
  OptionsPattern[]] := Module[
  {pn, r0p, includeRR25, cmParams, points, x1s, x2s, y1s, y2s},

  pn = OptionValue["PNOrder"];
  r0p = OptionValue["R0Prime"];
  includeRR25 = OptionValue["Include2p5PNRadiationReaction"];
  cmParams = Join[primitiveParams,
    <|"Include2p5PNRadiationReaction" -> includeRR25|>];

  If[! validPNOrderQ[pn],
   Message[CMPositionsFromRelativeOrbit::badpn, pn,
    CMPositionsAllowedPNOrders[]];
   Return[$Failed];
   ];
  If[! TrueQ[r0p > 0],
   Message[CMPositionsFromRelativeOrbit::badr0, r0p];
   Return[$Failed];
   ];
  If[! validateParams[primitiveParams], Return[$Failed]];
  If[! validateOrbit[orbit], Return[$Failed]];

  points = MapThread[
    cmShiftAtPoint[#1, #2, #3, #4, cmParams, pn, r0p] &,
    Lookup[orbit, {"r", "phi", "rdot", "phidot"}]];

  x1s = Lookup[points, "X1"];
  x2s = Lookup[points, "X2"];
  y1s = MapThread[#1*#2 + #3 &, {x2s, Lookup[points, "x"],
      Lookup[points, "z"]}];
  y2s = MapThread[-#1*#2 + #3 &, {x1s, Lookup[points, "x"],
      Lookup[points, "z"]}];

  <|"t" -> orbit["t"], "y1" -> y1s, "y2" -> y2s|>
  ];

CMPositionsFromRelativeOrbit::badpn =
  "PNOrder `1` is not supported. Allowed values are `2`.";
CMPositionsFromRelativeOrbit::missing =
  "Relative orbit is missing required keys `1`.";
CMPositionsFromRelativeOrbit::lengths =
  "Relative orbit arrays must have the same length. Got `1`.";
CMPositionsFromRelativeOrbit::missingparams =
  "Primitive parameter association is missing required keys `1`.";
CMPositionsFromRelativeOrbit::badr0 =
  "R0Prime must be positive. Got `1`.";

End[];

EndPackage[];
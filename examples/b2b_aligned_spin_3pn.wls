(* Boundary-to-bound angular-invariant check for the retained 3PN
   aligned-spin QK models.

   This checks the QK angular sector behind

     DeltaPhi(E,J) = chi(E,J) + chi(E,-J)

   where DeltaPhi is the periastron excess and chi is the hyperbolic
   scattering angle.  The aligned-spin signed continuation uses

     j -> -j, chiA -> -chiA, chiS -> -chiS

   with j=1/L, together with delta^2=1-4 nu.
*)

ClearAll["Global`*"];

root = DirectoryName[DirectoryName[$InputFileName]];
bound = Get[FileNameJoin[{root, "src", "Models",
     "bound_3pn_aligned_spin.wl"}]];
unbound = Get[FileNameJoin[{root, "src", "Models",
     "unbound_3pn_aligned_spin.wl"}]];

symbolRules = {
   \[Epsilon] -> eps,
   \[Nu] -> nu,
   \[Delta] -> delta,
   \[Chi]A -> chiA,
   \[Chi]S -> chiS,
   \[Kappa]A -> kappaA,
   \[Kappa]S -> kappaS
   };

deltaIdentity = delta^2 -> 1 - 4 nu;
signedB2B[expr_] := expr /. {j -> -j, chiA -> -chiA, chiS -> -chiS};

pnSeries[expr_] := Normal[Series[expr, {eps, 0, 6}]] // Expand;
signedSeries[expr_, order_:7] :=
  pnSeries[
    PowerExpand[
      Normal[Series[expr /. {L -> 1/j, En -> en}, {j, 0, order}]]
      ] // Expand
    ];

zeroQ[expr_] := TrueQ[FullSimplify[Expand[expr] === 0]];
massReduced[expr_] := FullSimplify[Expand[Together[expr] /. deltaIdentity]];

qkBound = bound["QK"] /. symbolRules;
qkUnbound = unbound["QK"] /. symbolRules;

kResidualRaw = FullSimplify[Expand[Together[qkBound["K"] - qkUnbound["K"]]]];
kResidual = massReduced[kResidualRaw];

parityResidual[name_String, expected_String] := Module[
  {series, residual},
  series = signedSeries[qkUnbound[name]];
  residual = If[expected === "even",
    series - signedB2B[series],
    series + signedB2B[series]
    ];
  massReduced[residual]
  ];

parityResiduals = <|
   "KEven" -> parityResidual["K", "even"],
   "fPhiEven" -> parityResidual["fPhi", "even"],
   "gPhiOdd" -> parityResidual["gPhi", "odd"],
   "hPhiEven" -> parityResidual["hPhi", "even"],
   "iPhiOdd" -> parityResidual["iPhi", "odd"]
   |>;

ePhi2 = If[KeyExistsQ[qkUnbound, "ePhi2"],
   qkUnbound["ePhi2"],
   qkUnbound["ePhi"]^2
   ];

(* This is the cheap equivalent branch check for vInf=Pi/2+odd part:
   if j^2 ePhi^2 is even, then 1/ePhi is odd on the positive-ePhi branch. *)
ePhiBranchResidual = massReduced[
   pnSeries[(j^2 ePhi2) /. {L -> 1/j, En -> en}] -
    signedB2B[pnSeries[(j^2 ePhi2) /. {L -> 1/j, En -> en}]]
   ];

result = <|
   "KResidualBeforeDeltaIdentity" -> kResidualRaw,
   "KResidualAfterDeltaIdentity" -> kResidual,
   "AngularParityResiduals" -> parityResiduals,
   "jSquaredEPhiSquaredEvenResidual" -> ePhiBranchResidual
   |>;

Print["3PN aligned-spin B2B angular-sector residuals:"];
Print[result // InputForm];

passed = zeroQ[kResidual] &&
   AllTrue[Values[parityResiduals], zeroQ] &&
   zeroQ[ePhiBranchResidual];

Print["Passed: ", passed];

If[! passed, Exit[1]];

(* Minimal QK vs direct-EOM comparison for unbound, parabolic, and bound
   aligned-spin orbits.

   Plot convention: the red curve labelled "0PN QK" is the Newtonian QK
   trajectory generated from the same initial data, used only as a visual
   baseline.  Direct-EOM curves are blue solid; PN QK curves are black dashed.
*)

ClearAll["Global`*"];

root = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{root, "src", "QKOrbits.wl"}]];
Get[FileNameJoin[{root, "src", "DirectEOMOrbits.wl"}]];

eom = DirectEOMLoad["RootDirectory" -> root];
outDir = FileNameJoin[{root, "outputs", "qk_vs_direct_three_orbits"}];
If[DirectoryQ[outDir], DeleteDirectory[outDir, DeleteContents -> True]];
CreateDirectory[outDir, CreateIntermediateDirectories -> True];

includeRR25 = False;
parabolicVelocitySign = 1;
pnOrder = 3;
allowedPNOrders = QKAllowedPNOrders[];
wp = MachinePrecision;
acc = Automatic;
prec = Automatic;
directWP = 40;
directAcc = 20;
directPrec = 20;
directMaxStepSize = 500;

primitive = <|"eps" -> 1, "nu" -> 21/100, "delta" -> 2/5,
   "chi1" -> 1, "chi2" -> 1, "kap1" -> 1, "kap2" -> 1|>;

publicQKParameterKeys[modelName_String, qkParams_Association] := Module[
  {keys},
  keys = If[StringContainsQ[modelName, "Parabolic"],
    {"sP", "rP"},
    {"n", "K", "ar", "er", "et", "ePhi", "fPhi", "gPhi", "hPhi",
     "iPhi", "gt", "ft", "ht", "it"}
    ];
  Select[keys, KeyExistsQ[qkParams, #] &]
  ];

publicQKInfo[modelName_String, info_Association] := Module[{keys},
  keys = publicQKParameterKeys[modelName, info["QKParameters"]];
  Join[KeyDrop[info, {"QKParameters"}],
   <|"QKParameters" -> KeyTake[info["QKParameters"], keys]|>]
  ];

cases = <|
   "unbound" -> <|"model" -> "Unbound3PNAlignedSpin",
     "initialData" -> <|
       "r" -> 20,
       "phi" -> 1/5,
       "rdot" -> 0.18,
       "phidot" -> 0.02|>,
     "times" -> N[Subdivide[0, 70, 200], wp]|>,
   "parabolic" -> <|"model" -> "Parabolic3PNAlignedSpin",
     "initialData" -> <|
       "r" -> 25,
       "phi" -> 1/4,
       "phidot" -> 0.006|>,
     "times" -> N[Subdivide[0, 22, 140], wp]|>,
   "bound" -> <|"model" -> "Bound3PNAlignedSpin",
     "initialData" -> <|
       "r" -> 20,
       "phi" -> 3/10,
       "rdot" -> 0.08,
       "phidot" -> 0.011|>,
     "times" -> N[Subdivide[0, 55, 170], wp]|>
   |>;

runCase[name_String] := Module[
  {spec = cases[name], model, qkInfo, qk0, qk, inputIC, completeIC,
   direct},
  model = QKLoadModel[spec["model"], "RootDirectory" -> root];
  inputIC = AssociationMap[N[#, wp] &, spec["initialData"]];
  qkInfo = QKParameterValuesFromInitialData[model, primitive, inputIC,
    WorkingPrecision -> wp, "PNOrder" -> pnOrder,
    "RootDirectory" -> root,
    "ParabolicVelocitySign" -> parabolicVelocitySign];
  If[qkInfo === $Failed, Return[$Failed]];
  completeIC = qkInfo["InitialData"];
  qk0 = QKOrbitFromInitialData[model, primitive, inputIC, spec["times"],
    WorkingPrecision -> wp,
    AccuracyGoal -> acc, PrecisionGoal -> prec, "PNOrder" -> 0,
    "RootDirectory" -> root,
    "ParabolicVelocitySign" -> parabolicVelocitySign];
  qk = QKOrbitFromInitialData[model, primitive, inputIC, spec["times"],
    WorkingPrecision -> wp,
    AccuracyGoal -> acc, PrecisionGoal -> prec, "PNOrder" -> pnOrder,
    "RootDirectory" -> root,
    "ParabolicVelocitySign" -> parabolicVelocitySign];
  direct = DirectEOMOrbit[eom, primitive, completeIC, spec["times"],
    WorkingPrecision -> directWP, AccuracyGoal -> directAcc,
    PrecisionGoal -> directPrec,
    "PNOrder" -> pnOrder, MaxStepSize -> directMaxStepSize,
    "Include2p5PNRadiationReaction" -> includeRR25];
  <|"qk0" -> qk0, "qk" -> qk, "direct" -> direct, "inputData" -> inputIC,
   "initialData" -> completeIC,
   "qkInfo" -> publicQKInfo[spec["model"], qkInfo]|>
  ];

results = Association[(# -> runCase[#]) & /@ Keys[cases]];

directStyle = Directive[RGBColor[0.08, 0.32, 0.78], AbsoluteThickness[2.4]];
qkStyle = Directive[Black, Dashed, AbsoluteThickness[2.8]];
qk0Style = Directive[RGBColor[0.85, 0.05, 0.05], AbsoluteThickness[2.1]];
singleQKStyle = Directive[Black, AbsoluteThickness[2.4]];
fields = {"r", "phi", "rdot", "phidot"};
fieldLabels = <|"r" -> "r / M", "phi" -> "\[Phi]",
   "rdot" -> "\!\(\*OverscriptBox[\(r\), \(.\)]\)",
   "phidot" -> "M \!\(\*OverscriptBox[\(\[Phi]\), \(.\)]\)"|>;
caseNames = {"unbound", "parabolic", "bound"};

styleFor[label_] := Which[
   label === "0PN QK", qk0Style,
   label === "QK", qkStyle,
   StringContainsQ[label, "direct"], directStyle,
   True, singleQKStyle
   ];

realValues[x_] := Chop[Re[N[x]]];

seriesPanel[name_String, orbits_Association, field_String,
  label_String] := Module[
  {t, vals, yGrid, curves, labels},
  labels = Keys[orbits];
  t = realValues[First[Values[orbits]]["t"]];
  vals = Join @@ (realValues[#[field]] & /@ Values[orbits]);
  curves = (Transpose[{realValues[#["t"]], realValues[#[field]]}] & /@
     Values[orbits]);
  yGrid = Subdivide[Min[vals], Max[vals], 4];
  ListLinePlot[
   curves,
   PlotStyle -> (styleFor /@ labels),
   Frame -> True,
   FrameLabel -> {"t / M", label},
   PlotLabel -> Style[name <> "  " <> label, 15, Bold, Black],
   FrameTicks -> Automatic,
   GridLines -> {Subdivide[Min[t], Max[t], 4], yGrid},
   GridLinesStyle -> Directive[GrayLevel[0.85], AbsoluteThickness[0.6]],
   AspectRatio -> 0.62,
   ImageSize -> 330,
   ImagePadding -> {{86, 24}, {58, 30}},
   BaseStyle -> {FontFamily -> "Arial", FontSize -> 12, Black},
   LabelStyle -> {Black, 13},
   FrameTicksStyle -> Directive[Black, 11],
   PlotRange -> All,
   PlotRangePadding -> Scaled[0.05]
   ]
  ];

orbitFigure[name_String, orbits_Association] := Legended[
   GraphicsGrid[
    Partition[
     Table[seriesPanel[name, orbits, field, fieldLabels[field]],
      {field, fields}], 2],
    Spacings -> {0.2, 0.25}],
   Placed[
    LineLegend[styleFor /@ Keys[orbits], Keys[orbits],
     LegendLayout -> "Row", LabelStyle -> {Black, 14},
     LegendMarkerSize -> 34],
    Below]
   ];

directLabel = If[includeRR25, "direct EOM + 2.5PN RR", "direct EOM"];

overlayFigures = AssociationMap[
   orbitFigure[#, <|"0PN QK" -> results[#, "qk0"],
      directLabel -> results[#, "direct"],
      "QK" -> results[#, "qk"]|>] &,
   caseNames];
qkFigures = AssociationMap[
   orbitFigure[# <> " QK", <|"0PN QK" -> results[#, "qk0"],
      "QK" -> results[#, "qk"]|>] &,
   caseNames];
directFigures = AssociationMap[
   orbitFigure[# <> " direct", <|"0PN QK" -> results[#, "qk0"],
      directLabel -> results[#, "direct"]|>] &,
   caseNames];

orbitRows[orbit_Association] := Prepend[
   Transpose[orbit /@ {"t", "r", "phi", "rdot", "phidot"}],
   {"t", "r", "phi", "rdot", "phidot"}
   ];

Do[
  Export[FileNameJoin[{outDir, name <> "_overlay.png"}],
   overlayFigures[name],
   ImageResolution -> 170];
  Export[FileNameJoin[{outDir, name <> "_qk.png"}], qkFigures[name],
   ImageResolution -> 170];
  Export[FileNameJoin[{outDir, name <> "_direct.png"}],
   directFigures[name],
   ImageResolution -> 170];
  Export[FileNameJoin[{outDir, name <> "_qk.tsv"}],
   orbitRows[results[name, "qk"]], "TSV"];
  Export[FileNameJoin[{outDir, name <> "_direct.tsv"}],
   orbitRows[results[name, "direct"]], "TSV"];
  Put[results[name, "qkInfo"],
   FileNameJoin[{outDir, name <> "_qk_parameters.wl"}]];
  ,
  {name, caseNames}
  ];

shortAssoc[a_Association] := AssociationMap[N[#, 16] &, a];

Put[<|"include2p5PNRadiationReaction" -> includeRR25,
   "pnOrder" -> pnOrder,
   "allowedPNOrders" -> allowedPNOrders,
   "parabolicVelocitySign" -> parabolicVelocitySign,
   "directWorkingPrecision" -> directWP,
   "directAccuracyGoal" -> directAcc,
   "directPrecisionGoal" -> directPrec,
   "directMaxStepSize" -> directMaxStepSize,
   "primitive" -> primitive,
   "cases" -> AssociationMap[
     <|"inputData" -> shortAssoc[results[#, "inputData"]],
       "initialData" -> shortAssoc[results[#, "initialData"]],
       "initialScales" -> shortAssoc[results[#, "qkInfo", "InitialScales"]]|> &,
     caseNames],
   "files" -> AssociationMap[
     <|"overlayFigure" -> FileNameJoin[{outDir, # <> "_overlay.png"}],
       "qkFigure" -> FileNameJoin[{outDir, # <> "_qk.png"}],
       "directFigure" -> FileNameJoin[{outDir, # <> "_direct.png"}],
       "qk" -> FileNameJoin[{outDir, # <> "_qk.tsv"}],
       "direct" -> FileNameJoin[{outDir, # <> "_direct.tsv"}],
       "qkParameters" ->
        FileNameJoin[{outDir, # <> "_qk_parameters.wl"}]|> &,
     caseNames]|>,
  FileNameJoin[{outDir, "summary.wl"}]];

Print["Wrote orbit figures and data tables to ", outDir];
Print["Plot convention: red 0PN QK = Newtonian QK from the same initial data; blue = direct EOM; black dashed = PN QK."];

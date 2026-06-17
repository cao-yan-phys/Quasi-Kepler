(* Generate the editable notebook example. *)

ClearAll["Global`*"];

root = DirectoryName[DirectoryName[$InputFileName]];
nbFile = FileNameJoin[{root, "examples", "qk_vs_direct_three_orbits.nb"}];

SetAttributes[inputCell, HoldFirst];
inputCell[expr_] := Cell[BoxData @ ToBoxes[Unevaluated[expr]], "Input"];

setupGroup = CellGroupData[
   {
    Cell["Setup", "Section"],
    inputCell[
     ClearAll["Global`*"];
     root = ParentDirectory[NotebookDirectory[]];
     Get[FileNameJoin[{root, "src", "QKOrbits.wl"}]];
     Get[FileNameJoin[{root, "src", "DirectEOMOrbits.wl"}]];
     eom = DirectEOMOrbits`DirectEOMLoad["RootDirectory" -> root];

     ClearAll[makeTimes, cleanInitialData, computeQKInfo, computeQKPN, computeQK,
      computeDirect, orbitRows, realValues, shortValue, shortAssoc,
      publicQKParameterKeys, qkInfoDisplay, styleFor, seriesPanel, plotOrbit,
      exportOrbit];

     makeTimes[tStart_, tEnd_, samples_] :=
       N[Subdivide[tStart, tEnd, samples], wp];

     cleanInitialData[data_Association] := AssociationMap[N[#, wp] &, data];

     computeQKInfo[modelName_String, initialData_Association] :=
       Module[{model},
        model = QKOrbits`QKLoadModel[modelName, "RootDirectory" -> root];
        QKOrbits`QKParameterValuesFromInitialData[model, primitiveParams,
         initialData, WorkingPrecision -> wp, "PNOrder" -> pnOrder,
         "RootDirectory" -> root,
         "ParabolicVelocitySign" -> parabolicVelocitySign]
        ];

     computeQKPN[modelName_String, initialData_Association, times_List,
       order_] :=
       Module[{model},
        model = QKOrbits`QKLoadModel[modelName, "RootDirectory" -> root];
        QKOrbits`QKOrbitFromInitialData[model, primitiveParams, initialData, times,
         WorkingPrecision -> wp,
         AccuracyGoal -> accGoal,
         PrecisionGoal -> precGoal,
         "PNOrder" -> order,
         "RootDirectory" -> root,
         "ParabolicVelocitySign" -> parabolicVelocitySign]
        ];

     computeQK[modelName_String, initialData_Association, times_List] :=
       computeQKPN[modelName, initialData, times, pnOrder];

     computeDirect[initialData_Association, times_List] :=
       DirectEOMOrbits`DirectEOMOrbit[eom, primitiveParams, initialData, times,
        WorkingPrecision -> directWP,
        AccuracyGoal -> directAccGoal,
        PrecisionGoal -> directPrecGoal,
        "PNOrder" -> pnOrder,
        MaxStepSize -> directMaxStepSize,
        "Include2p5PNRadiationReaction" -> includeRR25];

     orbitRows[orbit_Association] := Prepend[
       Transpose[orbit /@ {"t", "r", "phi", "rdot", "phidot"}],
       {"t", "r", "phi", "rdot", "phidot"}];

     directStyle = Directive[RGBColor[0.08, 0.32, 0.78],
       AbsoluteThickness[2.4]];
     qkStyle = Directive[Black, Dashed, AbsoluteThickness[2.8]];
     qk0Style = Directive[RGBColor[0.85, 0.05, 0.05],
       AbsoluteThickness[2.1]];
     otherStyle = Directive[RGBColor[0.70, 0.12, 0.12],
       DotDashed, AbsoluteThickness[2.2]];

     fields = {"r", "phi", "rdot", "phidot"};
     fieldLabels = <|"r" -> "r / M", "phi" -> "\[Phi]",
       "rdot" -> "\!\(\*OverscriptBox[\(r\), \(.\)]\)",
       "phidot" -> "M \!\(\*OverscriptBox[\(\[Phi]\), \(.\)]\)"|>;

     directLabel[] := If[includeRR25, "direct EOM + 2.5PN RR",
       "direct EOM"];

     shortValue[x_] := If[NumberQ[N[x]], N[x, 16], x];
     shortAssoc[a_Association] := AssociationMap[shortValue, a];

     publicQKParameterKeys[modelName_String, qkParams_Association] := Module[
       {keys},
       keys = If[StringContainsQ[modelName, "Parabolic"],
         {"sP", "rP"},
         {"n", "K", "ar", "er", "et", "ePhi", "fPhi", "gPhi", "hPhi",
          "iPhi", "gt", "ft", "ht", "it"}];
       Select[keys, KeyExistsQ[qkParams, #] &]
       ];

     qkInfoDisplay[modelName_String, info_Association] := Module[
       {params = info["QKParameters"], keys},
       keys = publicQKParameterKeys[modelName, params];
       <|
        "InitialData" -> shortAssoc[info["InitialData"]],
        "InitialScales" -> shortAssoc[info["InitialScales"]],
        "ConservedLabels" -> shortAssoc[info["ConservedLabels"]],
        "QKParameters" -> shortAssoc[KeyTake[params, keys]]
        |>
       ];

     styleFor[label_] := Which[
       label === "0PN QK", qk0Style,
       label === "QK", qkStyle,
       StringContainsQ[label, "direct"], directStyle,
       True, otherStyle];

     realValues[x_] := Chop[Re[N[x]]];

     seriesPanel[title_String, orbits_Association,
       field_String] := Module[{names, t, vals, curves, yGrid},
       names = Keys[orbits];
       t = realValues[First[Values[orbits]]["t"]];
       vals = Join @@ (realValues[#[field]] & /@ Values[orbits]);
       curves = (Transpose[{realValues[#["t"]],
             realValues[#[field]]}] & /@ Values[orbits]);
       yGrid = Subdivide[Min[vals], Max[vals], 4];
       ListLinePlot[
        curves,
        PlotStyle -> (styleFor /@ names),
        Frame -> True,
        FrameTicks -> Automatic,
        FrameLabel -> {"t / M", fieldLabels[field]},
        PlotLabel -> Style[title <> "  " <> fieldLabels[field], 15,
          Bold, Black],
        GridLines -> {Subdivide[Min[t], Max[t], 4], yGrid},
        GridLinesStyle -> Directive[GrayLevel[0.85],
          AbsoluteThickness[0.6]],
        AspectRatio -> 0.62,
        ImageSize -> 360,
        ImagePadding -> {{86, 24}, {58, 30}},
        BaseStyle -> {FontFamily -> "Arial", FontSize -> 12, Black},
        LabelStyle -> {Black, 13},
        FrameTicksStyle -> Directive[Black, 11],
        PlotRange -> All,
        PlotRangePadding -> Scaled[0.05]]
       ];

     plotOrbit[title_String, orbits_Association] :=
       Legended[
        GraphicsGrid[
         Partition[seriesPanel[title, orbits, #] & /@ fields, 2],
         Spacings -> {0.2, 0.25}],
        Placed[
         LineLegend[styleFor /@ Keys[orbits], Keys[orbits],
          LegendLayout -> "Row",
          LabelStyle -> {Black, 14},
          LegendMarkerSize -> 34],
         Below]];

     exportOrbit[name_String, qkInfo_Association, qk_Association,
       direct_Association, qkFig_, directFig_, overlayFig_] := Module[
       {dir = outDir},
       If[! DirectoryQ[dir],
        CreateDirectory[dir, CreateIntermediateDirectories -> True]];
       Export[FileNameJoin[{dir, name <> "_qk.png"}], qkFig,
        ImageResolution -> 170];
       Export[FileNameJoin[{dir, name <> "_direct.png"}], directFig,
        ImageResolution -> 170];
       Export[FileNameJoin[{dir, name <> "_overlay.png"}], overlayFig,
        ImageResolution -> 170];
       Export[FileNameJoin[{dir, name <> "_qk.tsv"}],
        orbitRows[qk], "TSV"];
       Export[FileNameJoin[{dir, name <> "_direct.tsv"}],
        orbitRows[direct], "TSV"];
       Put[qkInfo, FileNameJoin[{dir, name <> "_qk_parameters.wl"}]];
       dir];
     ]
    },
   Closed
   ];

nb = Notebook[
   {
    Cell["QK vs Direct EOM", "Title"],
    Cell[
     "Run Setup once. Edit the Global Inputs cell and the input cell at the start of each orbit section. Each section first returns the completed initial data, initial scales, conserved labels, and QK parameters, then computes QK and direct EOM trajectories with t, r, phi, rdot, phidot. Units are G=c=M=1, so plot axes use t/M, r/M, and M phidot. In all plots the red curve labelled 0PN QK is the Newtonian QK trajectory generated from the same initial data. In overlay plots the direct-EOM curve is drawn first and the black dashed QK curve is drawn second.",
     "Text"],
    setupGroup,

    Cell["Global Inputs", "Section"],
    Cell[
     "PNOrder must be one of allowedPNOrders. Use eps -> 1 for physical orbits; smaller eps values are bookkeeping diagnostics only and are not the PN truncation switch. includeRR25 affects only the direct EOM trajectory. parabolicVelocitySign chooses the sign of the missing parabolic velocity. directWP, directAccGoal, directPrecGoal, and directMaxStepSize control only the direct EOM solver.",
     "Text"],
    inputCell[
     allowedPNOrders = QKOrbits`QKAllowedPNOrders[];
     pnOrder = 3;
     includeRR25 = False;
     parabolicVelocitySign = 1;
     wp = MachinePrecision;
     accGoal = Automatic;
     precGoal = Automatic;
     directWP = 40;
     directAccGoal = 20;
     directPrecGoal = 20;
     directMaxStepSize = 500;

     primitiveParams = <|
       "eps" -> 1,
       "nu" -> 21/100,
       "delta" -> 2/5,
       "chi1" -> 1,
       "chi2" -> 1,
       "kap1" -> 1,
       "kap2" -> 1
       |>;

     allowedPNOrders
     ],

    Cell["Unbound", "Section"],
    Cell[
     "Change r, phi, rdot, phidot, tStart, tEnd, and samples here. The time and radius inputs are dimensionless t/M and r/M.",
     "Text"],
    inputCell[
     unboundInitialData = cleanInitialData[<|
        "r" -> 20,
        "phi" -> 1/5,
        "rdot" -> 0.18,
        "phidot" -> 0.02
        |>];
     unboundTimes = makeTimes[0, 70, 200];
     ],
    inputCell[
     unboundModelName = "Unbound3PNAlignedSpin";
     unboundQKInfo = computeQKInfo[unboundModelName,
       unboundInitialData];
     qkInfoDisplay[unboundModelName, unboundQKInfo]
     ],
    inputCell[
     unboundQK0 = computeQKPN["Unbound3PNAlignedSpin",
       unboundInitialData, unboundTimes, 0];
     ],
    inputCell[
     unboundQK = computeQK["Unbound3PNAlignedSpin", unboundInitialData,
       unboundTimes];
     ],
    inputCell[
     unboundDirect = computeDirect[unboundInitialData, unboundTimes];
     ],
    inputCell[
     unboundQKFigure = plotOrbit["unbound QK",
       <|"0PN QK" -> unboundQK0, "QK" -> unboundQK|>];
     unboundQKFigure
     ],
    inputCell[
     unboundDirectFigure = plotOrbit["unbound direct",
       <|"0PN QK" -> unboundQK0, directLabel[] -> unboundDirect|>];
     unboundDirectFigure
     ],
    inputCell[
     unboundFigure = plotOrbit["unbound",
       <|"0PN QK" -> unboundQK0, directLabel[] -> unboundDirect,
        "QK" -> unboundQK|>];
     unboundFigure
     ],

    Cell["Parabolic", "Section"],
    Cell[
     "Change r, phi, phidot, tStart, tEnd, and samples here. The time and radius inputs are dimensionless t/M and r/M. For parabolic QK, rdot is solved automatically from En == 0; parabolicVelocitySign chooses its sign. If no real solution exists for that sign, the calculation reports an error.",
     "Text"],
    inputCell[
     parabolicInitialData = cleanInitialData[<|
        "r" -> 25,
        "phi" -> 1/4,
        "phidot" -> 0.006
        |>];
     parabolicTimes = makeTimes[0, 22, 140];
     ],
    inputCell[
     parabolicModelName = "Parabolic3PNAlignedSpin";
     parabolicQKInfo = computeQKInfo[parabolicModelName,
       parabolicInitialData];
     qkInfoDisplay[parabolicModelName, parabolicQKInfo]
     ],
    inputCell[
     parabolicQK0 = computeQKPN["Parabolic3PNAlignedSpin",
       parabolicInitialData, parabolicTimes, 0];
     ],
    inputCell[
     parabolicQK = computeQK["Parabolic3PNAlignedSpin",
       parabolicInitialData, parabolicTimes];
     ],
    inputCell[
     parabolicDirect = computeDirect[parabolicQKInfo["InitialData"],
       parabolicTimes];
     ],
    inputCell[
     parabolicQKFigure = plotOrbit["parabolic QK",
       <|"0PN QK" -> parabolicQK0, "QK" -> parabolicQK|>];
     parabolicQKFigure
     ],
    inputCell[
     parabolicDirectFigure = plotOrbit["parabolic direct",
       <|"0PN QK" -> parabolicQK0,
        directLabel[] -> parabolicDirect|>];
     parabolicDirectFigure
     ],
    inputCell[
     parabolicFigure = plotOrbit["parabolic",
       <|"0PN QK" -> parabolicQK0, directLabel[] -> parabolicDirect,
        "QK" -> parabolicQK|>];
     parabolicFigure
     ],

    Cell["Bound", "Section"],
    Cell[
     "Change r, phi, rdot, phidot, tStart, tEnd, and samples here. The time and radius inputs are dimensionless t/M and r/M.",
     "Text"],
    inputCell[
     boundInitialData = cleanInitialData[<|
        "r" -> 20,
        "phi" -> 3/10,
        "rdot" -> 0.08,
        "phidot" -> 0.011
        |>];
     boundTimes = makeTimes[0, 55, 170];
     ],
    inputCell[
     boundModelName = "Bound3PNAlignedSpin";
     boundQKInfo = computeQKInfo[boundModelName,
       boundInitialData];
     qkInfoDisplay[boundModelName, boundQKInfo]
     ],
    inputCell[
     boundQK0 = computeQKPN["Bound3PNAlignedSpin", boundInitialData,
       boundTimes, 0];
     ],
    inputCell[
     boundQK = computeQK["Bound3PNAlignedSpin", boundInitialData,
       boundTimes];
     ],
    inputCell[
     boundDirect = computeDirect[boundInitialData, boundTimes];
     ],
    inputCell[
     boundQKFigure = plotOrbit["bound QK",
       <|"0PN QK" -> boundQK0, "QK" -> boundQK|>];
     boundQKFigure
     ],
    inputCell[
     boundDirectFigure = plotOrbit["bound direct",
       <|"0PN QK" -> boundQK0, directLabel[] -> boundDirect|>];
     boundDirectFigure
     ],
    inputCell[
     boundFigure = plotOrbit["bound",
       <|"0PN QK" -> boundQK0, directLabel[] -> boundDirect,
        "QK" -> boundQK|>];
     boundFigure
     ],

    Cell["Optional Export", "Section"],
    inputCell[
     outDir = FileNameJoin[{root, "outputs",
        "qk_vs_direct_three_orbits"}];
     exportOrbit["unbound", unboundQKInfo, unboundQK, unboundDirect,
      unboundQKFigure, unboundDirectFigure, unboundFigure];
     exportOrbit["parabolic", parabolicQKInfo, parabolicQK,
      parabolicDirect, parabolicQKFigure, parabolicDirectFigure,
      parabolicFigure];
     exportOrbit["bound", boundQKInfo, boundQK, boundDirect,
      boundQKFigure, boundDirectFigure, boundFigure];
     outDir
     ]
    },
   WindowSize -> {1120, 820},
   WindowMargins -> {{Automatic, 80}, {Automatic, 40}},
   StyleDefinitions -> "Default.nb"
   ];

Export[nbFile, nb];
Print["Wrote ", nbFile];

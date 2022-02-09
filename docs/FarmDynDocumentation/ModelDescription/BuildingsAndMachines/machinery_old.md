
# Farm Machinery


The model includes farm machineries in quite some detail:

[^Comment][embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/templ_decl.gms GAMS /(?i)set.*?machtype/ /;/)
```GAMS
set machType   /  tractor
                      tractorSmall
                      plough                  "Pflug"
                      chiselPlough            "Schwergrubber"
                      sowMachine              "Saemaschine"
                      directSowMachine        "DirektSaemaschine"
                      seedBedCombi            "Saatbeetkombination"
                      circHarrow              "Scheibenegge"
                      springTineHarrow        "Federzinkenegge"
                      fingerHarrow            "Hackstriegel"
                      combine                 "Maehdrescher"
                      cuttingUnitCere         "Getreideschneidwerk"
                      cuttingAddRape          "Zusatzausruestung Rapsernte"
                      cuttingUnitMaiz         "Maispflueckeinrichtung fuer Maehdrescher"
                      rotaryHarrow            "Kreiselegge"
                      mulcher                 "Mulcher"
                      potatoPlanter           "Kartoffellegegeraet"
                      potatoLifter            "Kartoffelroder"
                      hoe                     "Hackmachine, 5-reihig"
                      ridger                  "Haeufler"
                      haulmCutter             "Krautschlaeger"
                      forkLiftTruck           "Gabelstapler"
                      threeWayTippingTrailer  "Dreiseitenkippanhaenger"
                      Sprayer                 "Feldspritze"
                      singleSeeder            "Einzelkornsaehgeraet (Rueben/Mais)"
                      beetHarvester           "Ruebenroder"
                      fertSpreaderSmall       "Duengerstreuer, 0.8cbm"
                      fertSpreaderLarge       "Duengerstreuer, 4.0cbm"
                      chopper                 "Feldhaecksler"
                      cornHeader              "Maisgebiss fuer Haecksler"
                      mowerConditioner        "Maehaufbereiter"
                      grasReseedingUnit       "Gasnachsaemaschine"
                      rotaryTedder            "Kreiselzettwender"
                      rake                    "Schwader"
                      roller                  "Walze"
                      silageTrailer           "Silage trailer, service"
                      balePressWrap           "Baler and bale wrapper, service"
                      balePressHay            "Baler"
                      closeSilo

                      manbarrel,draghose,injector,trailingshoe

                      solidManDist      "Miststreuer"
                      frontLoader       "Frontlader"
                      siloBlockCutter   "Siloblockschneider"
                      shearGrab         "Schneidzange"
                      dungGrab          "Dungzange"
                      fodderMixingVeh8  "Futtermischwagen,  8m3, horizontale Schnecke, mit Befuellschild"
                      fodderMixingVeh10 "Futtermischwagen, 10m3, vertikale Schnecke, mit Befuellschild"
                      fodderMixingVeh16 "Futtermischwagen, 16m3, 2 vertikale Schnecken, mit Befuellschild"
                    /;
```

For further information see Appendix A1.

Each machinery type is characterised by set of attributes *p\_machAttr*
(see *coeffgen\\mach.gms*), for example:

[^Comment][embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/mach.gms GAMS /table.*?p_mach/ /5\.0/)
```GAMS
table p_machAttr(machType,machAttr) "Machinery attribute for default size (67kw, 2 ha)"

*
* --- Data from KTBL 2014/2015, if not otherwise stated
*
*
* --- KTBL. 82, 4 Schare, 140 cm
*
                      price        hour       ha       m3     t     varCost_ha  varCost_t  varCost_h  diesel_h  fixCost_h  fixCost_t years varCost_m3
 Plough               13000                 2000                        12.0
*
* --- KTBL. 84, Schwergrubber, angebaut, 2.5m
*
 ChiselPlough          5600                 2600                         5.0
```

## Farm Operations: Machinery Needs and Related Costs

Machinery is linked to specific farm operations (see *tech.gms*):

[^Comment][embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/tech.gms GAMS /set\soperation/ /;/)
```GAMS
set operation "Field operators as defined by KTBL"

             /
                      soilSample              "Bodenprobe"
                      manDist                 "Guelleausbringung"
                      basFert                 "P und K Duengung, typischerweise Herbst"
                      plow                    "Pfluegen"
                      chiselPlow              "Tiefengrubber"
                      seedBedCombi            "Saatbettkombination"
                      herb                    "Herbizidmassnahme"
                      sowMachine              "Saemaschine"
                      directSowMachine        "Direktsaatmaschine"
                      circHarrowSow           "Kreiselegge u. Drillmaschine Kombination"
                      springTineHarrow        "Federzinkenegge"
                      weedValuation           "Unkrautbonitur"
                      weederLight             "Striegeln"
                      weederIntens            "Hacken"
                      plantvaluation          "Bestandsbonitur"
                      NFert320
                      NFert160
                      combineCere             "Maehdrusch, Getreide"
                      combineRape             "Maehdrusch, Raps"
                      combineMaiz             "Maehdrusch, Mais"
                      cornTransport           "Getreidetransport"
                      store_n_dry_8
                      store_n_dry_4
                      store_n_dry_beans
                      store_n_dry_rape
                      store_n_dry_corn
                      lime_fert               "Kalkung"
                      stubble_shallow         "Stoppelbearbeitung flach"
                      stubble_deep            "Stoppelbearbeitung tief"
                      rotaryHarrow            "Kreiselegge"
                      NminTesting             "Nmin Probenahme"
                      mulcher                 "Mulcher"
                      chitting                "Vorkeimen"
                      solidManDist            "Miststreuer"
                      seedPotatoTransp        "Pflanzkartoffeltransport"
                      potatoLaying            "Legen von Kartoffeln"
                      rakingHoeing            "Hacken, striegeln"
                      earthingUp              "haeufeln"
                      knockOffHaulm           "Kartoffelkraut schlagen"
                      killingHaulm            "Krautabtoeten"
                      potatoHarvest           "Kartoffeln roden"
                      potatoTransport         "Kartoffeln zum Lager transportieren"
                      potatoStoring           "Kartoffeln lagern"
                      singleSeeder            "Einzelkornlegegeraet fuer Zuckerrueben/Mais"
                      weederHand              "von Hand hacken"
                      uprootBeets             "Zuckerrueben roden"
                      DiAmmonium              "Diammonphosphat streuen"
                      grinding                "KornMahlen"
                      disposal                "Erntegut festfahren"
                      coveringSilo            "Silo reinigen und mit Folie verschliessen, Maiz"
                      chopper                 "Haeckseln"
                      grasReSeeding           "Grasnachsaeen"
                      roller                  "Walzen"
                      mowing                  "Maehen mit Maehaufbereiter"
                      raking                  "Schwaden"
                      tedding                 "Wenden mit Kreiselzettwender"
                      silageTrailer           "Anwelkgut bergen mit Ladewagen"
                      closeSilo               "Silo reinigen und mit Folie verschliessen"
* Hay/Bale specific tasks
                      balePressWrap           "Ballen pressen und wickeln, Silage (Anwelkgut)"
                      baleTransportSil        "Ballentransport Silageballen"
                      baleTransportHay        "Ballentransport Heuballen"
                      balePressHay            "Bodenheu pressen"
               /;
```

For more details see Appendix A2.

Labour needs, diesel, variable and fixed machinery costs are linked to
these operations. An extraction is shown in the following:

[^Comment][embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/tech.gms GAMS /table\sop_attr/ /;/)
```GAMS
table op_attr(operation,machVar,plotSize,opAttr)

                                                labTime         diesel      fixCost      varCost   nPers  amount
    soilSample                .67kw.2ha         0.2              0.5          1.05         0.30
    manDist                   .67kw.2ha         1.7              6.7         20.20        24.65
    basFert                   .67kw.2ha         0.25             0.9          2.04         2.11
*
*   --- page 153, KTBL 2010/2011
*
    plow                      .67kw.2ha         1.89            23.0         20.39        40.76
    chiselPlow                .67kw.2ha         1.09            15.1          9.02        22.92
    SeedBedCombi              .67kw.2ha         0.58             6.0          7.98        12.05
    sowMachine                .67kw.2ha         0.84             4.9          9.44        10.62
    directSowMachine          .67kw.2ha         0.71             6.5         23.01        22.59
    circHarrowSow             .67kw.2ha         1.29            12.9         16.96        27.16
    springTineHarrow          .67kw.2ha         0.75             7.3          6.56        13.60
    weedValuation             .67kw.2ha         0.16             0.3          1.59         0.35
    herb                      .67kw.2ha         0.28             1.0          4.37         3.25
    weederLight               .67kw.2ha         0.42             2.6          3.93         6.22
    weederIntens              .67kw.2ha         0.73             3.8         13.10         9.70
    plantValuation            .67kw.2ha         0.13             0.1          0.91         0.18
    NFert320                  .67kw.2ha         0.23             0.9          1.75         1.95
    NFert160                  .67kw.2ha         0.19             0.8          1.16         1.58
    lime_fert                 .67kw.2ha         0.48             3.6         12.54         6.51
    combineCere               .67kw.2ha         1.20            20.8         66.43        31.94
    combineRape               .67kw.2ha         1.25            22.83        86.11        40.73
    combineMaiz               .67kw.2ha         1.32            23.99       115.57        54.54
    cornTransport             .67kw.2ha         0.23             0.8          5.28         3.41
    store_n_dry_8             .67kw.2ha         1.29                        100.81        29.28
    store_n_dry_4             .67kw.2ha         0.64                         50.41        14.64
    store_n_dry_beans         .67kw.2ha         0.47                         33.42        11.56
    store_n_dry_rape          .67kw.2ha         0.64                         49.38        40.52
    store_n_dry_corn          .67kw.2ha         1.50                        107.36       255.20
*
*   --- page 152 KBL 2010/2011
*
    stubble_shallow           .67kw.2ha         0.85             8.4          7.54        16.59
    stubble_deep              .67kw.2ha         0.92             9.8          7.99        18.04
*
*--- KTBL 12/13 S. 420 [TK,24.07.13]
*
    rotaryHarrow              .67kw.2ha         1.17            9.40           8.27       22.06
    NminTesting               .67kw.2ha         0.51            0.18           1.32        0.34
    mulcher                   .67kw.2ha         1.40            8.39          14.51       20.59
    chitting                  .67kw.2ha         2.36                         481.82       97.80
    solidManDist              .67kw.2ha         1.61           10.88          32.73       30.99
    seedPotatoTransp          .67kw.2ha         0.26            0.94           2.77        2.72
    potatoLaying              .67kw.2ha         1.19           11.84          23.94       31.60
    rakingHoeing              .67kw.2ha         0.73            4.12          11.65       10.80
    earthingUp                .67kw.2ha         0.70            3.49           7.67       10.03
    knockOffHaulm             .67kw.2ha         1.92            8.41          22.24       23.46
    killingHaulm              .67kw.2ha         0.23            1.15           5.48        3.09
    potatoHarvest             .67kw.2ha        19.94           55.23         189.53      133.98      3
    potatoTransport           .67kw.2ha         1.61            5.37          31.63       22.82
*
*   --- fix costs covered by potaStore type buildings
*
    potatoStoring             .67kw.2ha        10.00                                     148.50


*
*---  KTBL 12/13 S.437 und 445  (BL 10.02.2014)
*
   singleSeeder               .67kw.2ha         1.0            4.26           28.3        18.39
   weederHand                 .67kw.2ha        71.52           0.35           1.26         1.09
   uprootBeets                .67kw.2ha         4.41          49.73         149.98       134.33

*
*---  KTBL 12/13 S.348  (BL 10.02.2014)
*
   DiAmmonium                 .67kw.2ha        0.16            0.65           0.86        1.48
   grinding                   .67kw.2ha                                                     84
   disposal                   .67kw.2ha         0.7            3.57           4.19        7.55
*---  KTBL 14/15 S.331  (WB 27.07.2016)
*  coveringSilo               .67kw.2ha         4.2                         265.15       60.61
   coveringSilo               .67kw.2ha         4.2                         000.00       60.61

*     H?cksler wird bei KTBL nur als Dienstleistung gef?hrt, nicht zur Eigenanschaffung
*
   chopper                    .67kw.2ha                                                    410
*
*---  KTBL 14/15 S.453 (CP 28.02.2018)
*
*                                               labTime         diesel      fixCost      varCost   nPers  amount
   mowing                     .67Kw.2ha         0.64            5.47          8.48         11.39
   tedding                    .67kw.2ha         0.43            2.78          3.56          6.88
   raking                     .67kw.2ha         0.51            3.12          4.45          8.02
   silageTrailer              .67kw.2ha                                                    98.00           11.9
   closeSilo                  .67kw.2ha         1.09                         69.42         15.87
   grasReSeeding              .67kw.2ha         0.27            2.07          3.63          4.44
   roller                     .67kw.2ha         0.34            1.72          3.91          4.36
*---  KTBL 14/15 S.458 (Silage)/S.515 (Hay) (CP 27.02.2018)
*---  Ballenpressen mit Wickeln wird bei KTBL als Dienstleistung aufgefuehrt
   balePressWrap              .67kw.2ha                                                   240.00           11.9
   balePressHay               .67kw.2ha          0.5            3.02         15.45         14.19            4.8
   baleTransportSil           .67kw.2ha         1.65            3.29         21.66         16.27           11.9
   baleTransportHay           .67kw.2ha         1.62            3.02         15.45         14.19            4.8
;
```

Furthermore, the model considers the effect of different plot sizes and
the mechanisation levels:

[^Comment][embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/tech.gms GAMS /(?i)table\sp_plotsize/ /;/)
```GAMS
table p_plotSizeEffect(crops,machVar,opAttr,plotSize)

                                    1ha    2ha   5ha  20ha

     winterWheat. 67kw .labTime    12.4   10.5   9.3   8.0
     winterWheat. 67kw .diesel       90     83    78    73
     winterWheat. 67kw .varCost     205    188   176   168
     winterWheat. 67kw .fixCost     282    258   241   231

     winterWheat.102kw .labTime    11.1    9.1   7.6   6.8
     winterWheat.102kw .diesel       95     86    78    74
     winterWheat.102kw .varCost     209    188   172   164
     winterWheat.102kw .fixCost     315    284   262   249

     winterWheat.200kw .labTime    11.9    8.6   6.3   4.9
     winterWheat.200kw .diesel      118     99    84    75
     winterWheat.200kw .varCost     240    201   173   157
     winterWheat.200kw .fixCost     396    334   292   267
 ;
```
[^Comment][embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/tech.gms GAMS /p_plotSize.*?"n/ /;/)
```GAMS
p_plotSizeEffect("winterWheat",machVar,"nPers",plotSize) = 1;
```
[^Comment][embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/tech.gms GAMS /p_plotSize.*?"am/ /;/)
```GAMS
p_plotSizeEffect("winterWheat",machVar,"amount",plotSize) = 1;
```

[^Comment][embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/tech.gms GAMS /p_plotSize.*?\$/ /;/)
```GAMS
p_plotSizeEffect(crops,machVar,opAttr,plotSize) $ (not p_plotSizeEffect(crops,machVar,opAttr,plotSize))
  = sum( crops1,  p_plotSizeEffect(crops1,machVar,opAttr,plotSize))
   /sum( crops1 $ p_plotSizeEffect(crops1,machVar,opAttr,plotSize),1);
```

The farm operations are linked to cropping activities (below an example
for potatoes):

[^Comment][embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/tech.gms GAMS /(?i)table\scrop_op_per_till/ /0.333/)
```GAMS
table crop_op_per_till(crops,operation,labPeriod,till)
                                                              plough     minTill   noTill          eco  silo  bales

 potatoes     .    soilSample          .  AUG1                   0.2         0.2                   0.2
 potatoes     .    basFert             .  AUG1                   1.0         1.0                   1.0
 potatoes     .    solidManDist        .  AUG2                                                     1.0
 potatoes     .    plow                .  AUG2                                                     1.0
 potatoes     .    chiselPlow          .  AUG2                   1.0         1.0
 potatoes     .    sowmachine          .  AUG2                   1.0         1.0
 potatoes     .    mulcher             .  NOV1                   1.0         1.0                   1.0
 potatoes     .    plow                .  NOV1                   1.0                               1.0
 potatoes     .    chiselPlow          .  NOV1                               1.0
 potatoes     .    NminTesting         .  FEB1                   1.0         1.0
 potatoes     .    NFert320            .  MAR1                   1.0         1.0                   1.0
 potatoes     .    chitting            .  MAR1                                                     1.0
 potatoes     .    seedBedCombi        .  MAR2                   1.0
 potatoes     .    rotaryHarrow        .  MAR2                               1.0                   1.0
 potatoes     .    seedPotatoTransp    .  APR1                   1.0         1.0                   1.0
 potatoes     .    potatoLaying        .  APR1                   1.0         1.0                   1.0
 potatoes     .    rakingHoeing        .  APR2                                                     1.0
 potatoes     .    earthingUp          .  APR2                   1.0         1.0
 potatoes     .    weedValuation       .  MAY1                   1.0         1.0                   1.0
 potatoes     .    earthingUP          .  MAY1
 potatoes     .    plantvaluation      .  JUN1                   1.0                               1.0
 potatoes     .    herb                .  JUN1                                                     1.0
 potatoes     .    plantValuation      .  JUN2                   2.0         2.0                   1.0
 potatoes     .    herb                .  JUN2                   2.0         2.0                   2.0
 potatoes     .    plantValuation      .  JUL1                   2.0         2.0
 potatoes     .    herb                .  JUL1                   2.0         2.0                   1.0
 potatoes     .    plantValuation      .  JUL2                   1.0         1.0
 potatoes     .    herb                .  JUL2                   1.0         1.0                   1.0
 potatoes     .    plantValuation      .  AUG1                   1.0         1.0
 potatoes     .    herb                .  AUG1                   1.0         1.0                   1.0
 potatoes     .    plantValuation      .  AUG2                   1.0         1.0
 potatoes     .    herb                .  AUG2                   1.0         1.0
 potatoes     .    knockOffHaulm       .  AUG2                                                     1.0
 potatoes     .    killingHaulm        .  AUG2                   1.0         1.0
 potatoes     .    potatoHarvest       .  SEP1                   0.5         0.5                   0.5
 potatoes     .    potatoTransport     .  SEP1                   0.5         0.5                   0.5
 potatoes     .    potatoStoring       .  SEP1                   0.5         0.5                   0.5
 potatoes     .    potatoHarvest       .  SEP2                   0.5         0.5                   0.5
 potatoes     .    potatoTransport     .  SEP2                   0.5         0.5                   0.5
 potatoes     .    potatoStoring       .  SEP2                   0.5         0.5                   0.5
 potatoes     .    lime_fert           .  OCT1                 0.333
```

These information on farm operations determine

1.  The **number of necessary field working days** and *monthly labour
    need* per ha (excluding the time used for fertilising, which is
    determined endogenously)

2.  The **machinery need** for the different crops

3.  Related **variable costs**

The labour needs per month are determined by summing up over all farm
operations, considering the labour period, the effect of plot size and
mechanisation (*coeffgen\\labour.gms*):

[^Comment][embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/labour.gms GAMS /p_cropLab/ /;/)
```GAMS
p_cropLab(crops,till,intens,m) $ sum(plot,c_s_t_i(crops,plot,till,intens))

     = sum( (operation,actmachVar,actPlotSize,labPeriod_to_month(labPeriod,m)),
              crop_op_per_till(crops,operation,labPeriod,till)
                     * op_attr(operation,"67kW","2ha","labTime")
*
*                    -- effect of plot size and mechanisation on labour time
*
                         * p_plotSizeEffect(crops,actMachVar,"labTime",actPlotSize)
                          /p_plotSizeEffect(crops,"67kW","labTime","2ha")   );
```

## Endogenous Machine Inventory

The inventory equation for machinery is shown in *machInv\_*, where
*v\_machInv* is the available inventory by type, *machType,* in
operation hours. *v\_machNeed* is the machinery need of the farm in
operating hours and *v\_buyMach* are investments in new machines.

[^Comment][embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/templ.gms GAMS /machInv_\(cur/ /;/)
```GAMS
machInv_(curMachines(machType),machLifeUnit,tFull(t),nCur)
         $ (     (v_machInv.up(machType,machLifeUnit,t,nCur) ne 0)
               $ p_lifeTimeM(machType,machLifeUnit)  $ p_priceMach(machType,t)
               $ (not sameas(machLifeUnit,"years"))  $ t_n(t,nCur) )  ..
*
*      --- inventory end of current year (in operating hours, hectares etc.)
*
       v_machInv(machType,machLifeUnit,t,nCur)

             =e=
*
*        --- inventory end of last year (in operating hours)
*
          sum(t_n(t-1,nCur1) $ anc(nCur,nCur1), v_machInv(machType,machLifeUnit,t-1,nCur1))
*
*        --- new machines, converted in operation time
*
        + (v_buyMach(machType,t,nCur)+v_buyMachFlex(machType,t,nCur)) * p_lifeTimeM(machType,MachLifeUnit)
*
*        --- minus operating hours in current year if in normal planning period
*
        - v_machNeed(machType,machLifeUnit,t,nCur)  $ tCur(t)
*
*        --- minus operating hours of weighted average over normal planning period
*            if beyond the normal planning period
*
        - [sum( (t_n(t1,nCur1)) $ ( (p_year(t1) lt p_year(t)) $ tCur(t1) $ isNodeBefore(nCur,nCur1)),
                          v_machNeed(machType,machLifeUnit,t1,nCur1)
                                                                      * 1/(p_year(t)+5 - p_year(t1)) )
          /sum( (t1) $ ( (p_year(t1) lt p_year(t)) $ tCur(t1)),         1/(p_year(t)+5 - p_year(t1)) )
           ]
                       $ ( (not tCur(t)) and p_prolongCalc)
       ;
```

The last expression is used when the farm program for the simulated
period is used to estimate the machinery needs for all years until the
stables are fully depreciated.

The machinery need in each year is defined from activities or processes requiring machinery::

[^Comment][embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/GENERAL_HERD_MODULE.gms GAMS /machNeedHerds_\(c/ /;/)
```GAMS
machNeedHerds_(curMachines(machType),machLifeUnit,tCur(t),nCur)
        $ (sum(actHerds(sumHerds,breeds,feedRegime,t,m),
               p_machNeed(sumHerds,"plough","normal",machType,machLifeUnit)) $ t_n(t,nCur)) ..

       v_machNeedHerds(machType,machLifeUnit,t,nCur)

         =e=
*
*      --- herd sizes times their request for specific machine type
*
          sum(actHerds(sumHerds,breeds,feedRegime,t,m) $ p_prodLength(sumHerds,breeds),
             v_herdSize(sumHerds,breeds,feedRegime,t,nCur,m)
              * p_machNeed(sumHerds,"plough","normal",machType,machLifeUnit)
                          * 1/min(12,p_prodLength(sumHerds,breeds)) * 12/card(herdM));
```
[^Comment][embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/templ.gms GAMS /machines_\(c/ /;/)
```GAMS
machines_(curMachines(machType),machLifeUnit,tCur(t),nCur) $ (p_lifeTimeM(machType,machLifeUnit) $ t_n(t,nCur)) ..
*
*      --- crops times their request for specific machine type
*
     + sum( c_s_t_i(curCrops(crops),plot,till,intens),
           v_cropHa(crops,plot,till,intens,t,nCur)
            * p_machNeed(crops,till,intens,machType,machLifeUnit))

     + sum( (c_s_t_i(curCrops(crops),plot,till,intens),syntFertilizer,m),
              v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)
               * p_machNeed(syntFertilizer,"plough","normal",machType,machLifeUnit))

*        ---- machine need for the application of N (manure/fertilizer)

$iftheni.man %manure% == true

     + sum((c_s_t_i(curCrops(crops),plot,till,intens),manApplicType_manType(ManApplicType,curManType),m)
              $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0),
                v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                  * p_machNeed(ManApplicType,"plough","normal",machType,machLifeUnit))

$endif.man

$iftheni.herd %herd%==true

      + v_machNeedHerds(machType,machLifeUnit,t,nCur)
           $ sum(actHerds(sumHerds,breeds,feedRegime,t,m),
                 p_machNeed(sumHerds,"plough","normal",machType,machLifeUnit))
$endif.herd
*
*         --- total machinery need
*
              =L= v_machNeed(machType,machLifeUnit,t,nCur)
    ;
```

A small set of machinery, such as the front loader, dung grab, shear
grab or fodder mixing vehicles are depreciated by time and not by use:

[^Comment][embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/templ.gms GAMS /machInvT_\(c/ /;/)
```GAMS
machInvT_(curMachines(machType),tFull(t),nCur)
        $ (      (v_machInv.up(machType,"years",t,nCur) ne 0)
                $ p_lifeTimeM(machType,"years")
                $ p_priceMach(machType,t) $ t_n(t,nCur)  )  ..
*
*      --- inventory end of current year (in operating hours)
*
       v_machInv(machType,"years",t,nCur)

     +  sum( t_n(t1,nCur1) $ (  (p_year(t1) gt smax( tOld $ p_iniMachT(machType,told),
                                                     p_year(tOld) + p_lifeTimeM(machType,"years")))
                             $  (p_year(t1)+p_prolongLen gt p_year(t))
                             $ tCur(t1)  $ isNodeBefore(nCur,nCur1)),
                 v_machInv(machType,"years",t1,nCur1)/p_proLongLen)
                                                $ ( (not tCur(t)) and p_prolongCalc)

          =L=
*
*         --- old machines according to investment dates
*             (will drop out of equation if too old)
*
          sum( tOld $ (   ((p_year(tOld) + p_lifeTimeM(machType,"years")) ge p_year(t))
                              $ ( p_year(told)                            le p_year(t))),
                                 p_iniMachT(machType,tOld))

*
*         --- plus (old) investments - de-investments
*
       +  sum( t_n(t1,nCur1) $ (  ((p_year(t1)  + p_lifeTimeM(machType,"years") ) ge p_year(t))
                                $ ( p_year(t1)                                    le p_year(t))
                                $ isNodeBefore(nCur,nCur1)),
                                                v_buyMach(machType,t1,nCur1));
```

The aforementioned set of machinery, depreciated by time and not usage, are linked to the existence of stables, i.e. stables cannot be
used if machinery is not present:

[^Comment][embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/general_herd_module.gms GAMS /machInvStable_\(c/ /;/)
```GAMS
machInvStable_(curMachines(machType),stables,tCur(t),nCur) $ ( (v_machInv.up(machType,"years",t,nCur) ne 0)
                                                                 $  (   sum( t_n(t1,nCur1) $ isNodeBefore(nCur,nCur1),
                                                                            v_buyStables.up(stables,"long",t1,nCur1))
                                                                    or  sum( tOld, p_iniStables(stables,"long",tOld)))
                                                                  $ sum(stables_to_mach(stables,machType),1)

                                                    $ p_lifeTimeM(machType,"years")  $ p_priceMach(machType,t)  $ t_n(t,nCur))  ..

       sum(stables_to_mach(stables,machType), v_stableInv(stables,"long",t,nCur))
          =L= v_machInv(machType,"years",t,nCur);
```

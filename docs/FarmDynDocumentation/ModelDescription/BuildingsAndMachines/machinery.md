# Farm Machinery and Field Operations
> **_Abstract_**  
Field operations and associated machinery needs are depicted in high detail. For each crop required field operations and related machinery applications are included. The machinery requirements are based on the level of mechanization selected in the GUI. Based on the mechanization level and information on plot sizes and farm to field distances resource requirements and variable costs are calculated.

Different types of machines and field operations are implemented in FarmDyn, using data from two different databases: The *default-database* is manually implemented in FarmDyn. The data reports required field operations and related machine applications for grassland management, fertilization operations as well as specific crops for policy implementations (e.g. flowerstrips). In addition, it includes data for ~20 default crops. Based on the crop-data selection in the GUI, data on field operations and machinery needs can further be imported from a large scale *KTBL-database*. The *KTBL-database* includes more than 400 machines and 1500 field operations for ~145 crops. It distinguishes between conventional and organic farming systems, reflecting system specific field operations.
Both databases consider different types of tillage and are differentiated by mechanization levels, which reflect substitution possibilities between labor and capital. Labour and resource requirements related to machine applications are further conditional on plot sizes and farm to field distances.

## Machinery and Machine Attributes

The models default farm machinery includes various different machines (see *tech.gms*).
An extraction is shown in the following:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/mach_de.gms GAMS /set set_machType/ /"Mulcher"/)
```GAMS
set set_machType /tractor
                      tractorSmall
                      plough                  "Pflug"
                      chiselPlough            "Schwergrubber"
                      sowMachine              "Saemaschine"
                      directSowMachine        "Direktsaemaschine"
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
```
Based on the crop-data selection in the GUI, further machines are imported from the *KTBL-database*. Here, each machine is assigned a machine type and an unique ID:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/mach_de.gms GAMS /sets/ /;/)
```GAMS
sets
     set_machType                                         "name of a machine"
     set_machTypeID                                       "unique ID of a machine"
     set_machTypeID_machType(set_machTypeID,set_machType) "crossset between machType and machTypeID"
     machineType                                          "Type of a machine, e.g. tractor, plough"
     set_machType_machineType(set_machType,machineType)       "assigns a machineType to each machine"
   ;
```

[^Comment] ??? For further information see Appendix A1.

Each machinery type is characterized by set of attributes *p\_machAttr*, for example:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/mach_de.gms GAMS /table.*?p_mach/ /5\.0/)
```GAMS
table p_machAttr(machType,machAttr)

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

## Field Operations: Machinery Needs and Related Costs

### Default Database

The models *default-database* includes different field operations (see *cropop_de.gms*). An extraction is shown in the following:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/cropop_de.gms GAMS /set\soperation/ /Bestandsbonitur/)
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
                      plantvaluation          "Bestandsbonitur
```

For each field operation required machinery is stated, for example:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/cropop_de.gms GAMS /set op_machType\(operation,machType\)/ /sowMachine/)
```GAMS
set op_machType(operation,machType) "Links the operations to machinery";
* was ist mit dem Trecker? muss nicht f�r jeden Arbeitsgang auch noch der Traktor zu den
* Arbeitsg�ngen verlinkt werden? oder ist das woanders schon mit Treckeranspr�chen pro ha und Frucht abgegolten?
* Die Kosten f�r Trecker in den Arbeitsg�ngen sind ja durch KTBL Angaben zu var und fixCost schon abgegolten, aber die
* Treckerstunden evtl. nicht die die Nutzungsdauer beeinflussen (BL 10.02.2014)

 op_machType("plow","plough")                                  = yes;
 op_machType("chiselplow","chiselPlough")                      = yes;
 op_machType("stubble_shallow","chiselPlough")                 = yes;
 op_machType("stubble_deep","chiselPlough")                    = yes;
 op_machType("seedBedCombi","seedBedCombi")                    = yes;
 op_machType("springTineHarrow","springTineHarrow")            = yes;
 op_machType("circHarrowSow","circHarrow")                     = yes;
 op_machType("circHarrowSow","sowMachine
```

???? For more details see Appendix A2.

The performance of field operations involves labour and diesel requirements, variable and fixed machinery costs.
An extraction is shown in the following:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/cropop_de.gms GAMS /table\sop_attr/ /0\.18/)
```GAMS
table op_attr(operation,machVar,rounded_plotsize,opAttr) "resource requirements of operations"

                                                labTime         diesel      fixCost      varCost   nPers  amount
    soilSample                .67kw."2"          0.2              0.5          1.05         0.30
    manDist                   .67kw."2"          1.7              6.7         20.20        24.65
    basFert                   .67kw."2"          0.25             0.9          2.04         2.11
*
*   --- page 153, KTBL 2010/2011
*
    plow                      .67kw."2"          1.89            23.0         20.39        40.76
    chiselPlow                .67kw."2"          1.09            15.1          9.02        22.92
    SeedBedCombi              .67kw."2"          0.58             6.0          7.98        12.05
    sowMachine                .67kw."2"          0.84             4.9          9.44        10.62
    directSowMachine          .67kw."2"          0.71             6.5         23.01        22.59
    circHarrowSow             .67kw."2"          1.29            12.9         16.96        27.16
    springTineHarrow          .67kw."2"          0.75             7.3          6.56        13.60
    weedValuation             .67kw."2"          0.16             0.3          1.59         0.35
    herb                      .67kw."2"          0.28             1.0          4.37         3.25
    weederLight               .67kw."2"          0.42             2.6          3.93         6.22
    weederIntens              .67kw."2"          0.73             3.8         13.10         9.70
    plantValuation            .67kw."2"          0.13             0.1          0.91         0.18
```

Per hectare resource requirements and costs of field operations are conditional on plot sizes and mechanisation level.
The *default-database* considers these effect for four different plot sizes and three mechanisation levels. Farm-plot distances are not considered. Thereby, idle serves as placeholder for all crops in the *default-database*:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/cropop_de.gms GAMS /(?i)table\sp_plotsize/ /;/)
```GAMS
table p_plotSizeEffect(crops,machVar,opAttr,rounded_plotSize)

                            "1"    "2"   "5"  "20"

     idle. 67kw .labTime    12.4   10.5   9.3   8.0
     idle. 67kw .diesel       90     83    78    73
     idle. 67kw .varCost     205    188   176   168
     idle. 67kw .fixCost     282    258   241   231

     idle.102kw .labTime    11.1    9.1   7.6   6.8
     idle.102kw .diesel       95     86    78    74
     idle.102kw .varCost     209    188   172   164
     idle.102kw .fixCost     315    284   262   249

     idle.200kw .labTime    11.9    8.6   6.3   4.9
     idle.200kw .diesel      118     99    84    75
     idle.200kw .varCost     240    201   173   157
     idle.200kw .fixCost     396    334   292   267
  ;
```
FarmDyn distinguishes in total seven different mechanisation levels. As the *default-database* does not report input requirements for all mechanisation levels, data of similar mechanisation is used:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/cropop_de.gms GAMS /p_plotSize.*?45/ /;/)
```GAMS
p_plotSizeEffect("idle","45kW",opAttr,rounded_plotSize)=p_plotSizeEffect("idle","67kW",opAttr,rounded_plotSize);
```
[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/cropop_de.gms GAMS /p_plotSize.*?83/ /;/)
```GAMS
p_plotSizeEffect("idle","83kW",opAttr,rounded_plotSize)=p_plotSizeEffect("idle","67kW",opAttr,rounded_plotSize);
```
[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/cropop_de.gms GAMS /p_plotSize.*?120/ /;/)
```GAMS
p_plotSizeEffect("idle","120kW",opAttr,rounded_plotSize)=p_plotSizeEffect("idle","102kW",opAttr,rounded_plotSize);
```
[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/cropop_de.gms GAMS /p_plotSize.*?230/ /;/)
```GAMS
p_plotSizeEffect("idle","230kW",opAttr,rounded_plotSize)=p_plotSizeEffect("idle","200kW",opAttr,rounded_plotSize);
```
[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/cropop_de.gms GAMS /p_plotSize.*?"n/ /;/)
```GAMS
p_plotSizeEffect("idle",machVar,"nPers",rounded_plotSize) = 1;
```
[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/cropop_de.gms GAMS /p_plotSize.*?"am/ /;/)
```GAMS
p_plotSizeEffect("idle",machVar,"amount",rounded_plotSize) = 1;
```

Subsequentely, the effect of plot size is assigned to all crops included in the *default-dataset*, for example:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/tech.gms GAMS /p_plotSize.*?\$/ /;/)
```GAMS
p_plotSizeEffect(crops,"67kW",opAttr,rounded_plotSize) $ ((not p_plotSizeEffect(crops,"67kW",opAttr,rounded_plotSize)) $ (not sum(till, c_p_t_i_GDX(crops,"plot",till,"normal"))))
     =  (sum( crops1,  p_plotSizeEffect(crops1,"67kW",opAttr,rounded_plotSize))
       / sum( crops1 $ p_plotSizeEffect(crops1,"67kW",opAttr,rounded_plotSize),1)) $sum(crops1, p_plotSizeEffect(crops1,"67kW",opAttr,rounded_plotSize));
```

The plot size effect is used to scale resource requirements of machines and field operations that are not included in *KTBL-database*:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/tech.gms GAMS /p_machAttr\(machType,"diesel_h"\)/ /techEval_c_t_i/)
```GAMS
p_machAttr(machType,"diesel_h") $ (sum(op_machType(operation,machType),1) or sameas(machType,"Tractor"))
   =  p_machAttr(machType,"diesel_h")
        *  sum( (curCrops(crops),actMachVar,act_rounded_plotsize)
           $$iftheni.data "%database%" == "KTBL_database"
              $ (not sum(till, c_p_t_i_GDX(crops,"plot",till,"normal")))
           $$endif.data
            ,p_plotSizeEffect(crops,actMachVar,"diesel",act_rounded_plotsize)
                                               /p_plotSizeEffect(crops,"67Kw","diesel","2"))
         / sum( (curCrops(crops),actMachVar,act_rounded_plotsize) $ p_plotSizeEffect(crops,actMachVar,"diesel",act_rounded_plotsize),1);


  op_attr(operation,actmachVar,rounded_plotsize,"diesel") $ op_attr(operation,actMachVar,rounded_plotsize,"diesel")
   = op_attr(operation,actmachVar,rounded_plotsize,"diesel")
        *  sum( (curCrops(crops),act_rounded_plotsize)
           $$iftheni.data "%database%" == "KTBL_database"
              $ (not sum(till, c_p_t_i_GDX(crops,"plot",till,"normal")))
           $$endif.data
           ,p_plotSizeEffect(crops,actMachVar,"diesel",act_rounded_plotsize)
                                               /p_plotSizeEffect(crops,"67Kw","diesel","2"))
         / sum( (curCrops(crops),act_rounded_plotsize) $ p_plotSizeEffect(crops,actMachVar,"diesel",act_rounded_plotsize),1);


  set techEval_c_t_i
```

The field operations are linked to monthly cropping activities, considering the frequency of a field operation in the production (below an example for potatoes):

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/User/cropsData_DE_Default.gms GAMS /table p_crop_op_per_tilla\(crops,operation,labPeriod,till\)/ /0.333/)
```GAMS
table p_crop_op_per_tilla(crops,operation,labPeriod,till)
                                                              plough     minTill   noTill          org  silo  bales  hay      graz

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

### KTBL Database

Further field operations can be included from the *KTBL-database*. Here, each operation is assigned to an operation type and receives an unique ID. Field operations are linked to cropping activities on a monthly resolution  *p_crops_operationID*, considering the frequency of a field operation in the production.
Data distinguish between different types of tillage and conventional and organic farming systems, reflecting system specific field operations. Further, different soil types and amounts (e.g. transport volumes, application quantities) are considered, reflecting their impact on resource requirements of field operations.Field operations are reported for seven mechanisation levels between 45 and 230kW.
 Details on resource requirements and costs of each operation are expressed as function of plot sizes and farm to field distances, building on a polynomial regression function. For each operation and resource/cost *item*, regression coefficients **p_RegCoeff** are specified.  For field operations that are independent of plot sizes and distances (e.g. loading and cleaning operations), constant values **p_noRegCoeff** are reported. Based on information on soil type, mechanisation, plot sizes and distances entered in the GUI, resource requirement are calculated. Plot sizes of up to 40 ha and farm to field distances up to 30 km are considered.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/tech.gms GAMS /p_opIDInputReq\(curCrops,till,items,operationID\) = sum\(\(crops_operationID\(/ /;/)
```GAMS
p_opIDInputReq(curCrops,till,items,operationID) = sum((crops_operationID(curCrops,sys,till,operationID,labperiod,amount,actMachVar),amountUnit,
              Soil) $ sum(soil_plot(soil,plot),c_p_t_i(curCrops,plot,till,"normal"))
              ,
             (
              p_noRegCoeff(operationID,amount,soil,items)
                 $ (not p_regCoeff(operationID,amount,"m","time","intercept"))
      +
              Max(p_RegCoeff(operationID,amount,Soil,items,"minvalue"),
              Min(p_regCoeff(operationID,Amount,soil,items,"maxvalue"),
          ((
               p_regCoeff(operationID,amount,Soil,items,"intercept")
            +  p_regCoeff(operationID,amount,Soil,items,"size_linear")   * p_actPlotSize
            +  p_regCoeff(operationID,amount,Soil,items,"size_sqr")      * sqr(p_actPlotSize)
            +  p_regCoeff(operationID,amount,Soil,items,"sqroot_size")   * sqrt(p_actPlotSize)
            +  p_regCoeff(operationID,amount,Soil,items,"size_distance") * p_actPlotSize * p_actPlotDist
            +  p_regCoeff(operationID,amount,Soil,items,"dist_linear")   * p_actPlotDist
            +  p_regCoeff(operationID,amount,Soil,items,"dist_sqr")      * sqr(p_actPlotDist)
             ) $ p_regCoeff(operationID,amount,"m","time","intercept"))
             )))
             * p_crops_operationID(curCrops,sys,till,operationID,labperiod,amount,amountUnit,actMachVar)
           );
```

These information on required field operation and related resource requirements and cost in crop production determine

1.  The **number of necessary field working days** and *monthly labour
    need* per ha (excluding the time used for fertilisation, which is
    determined endogenously)

2.  The **machinery need** for the different crops

3.  Related **variable costs**


### Depreciation of machines included in *KTBL-database*

Deprecation cost of machine applications in the *KTBL-database* are calculated at the level of a field operations. Field operations, however, often require more than one machine such that deprecation costs refer to multiple machines. To draw conclusions about the value of the machine park and necessary new acquisitions, data on cost of depreciation are required on level of a single machine. Therefore, total depreciation cost are allocated to individual machines, considering the respective depreciation type and usage. An extraction is shown in the following (at the example of machines depreciated by area use).

First, total depreciation costs are assigned to *p_physDepr*.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/tech.gms GAMS /p_physDepr.*?curCrops/ /;/)
```GAMS
p_physDepr(curCrops,till,operation,"","","cost")
       = p_opInputReq(curCrops,till,"deprec",operation);
```

For each machine of a field operation that is depreciated by area use, depreciation cost per hectare are calculated:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/tech.gms GAMS /p_physDepr.*?areaCost/ /;/)
```GAMS
p_physDepr(curCrops,till,op_machType(operation,machType),"","areaCost")
      $ (p_machAttr(machType,"ha") $ p_physDepr(curCrops,till,operation,"","","cost"))
      = p_machAttr(machType, "price")/p_machAttr(machType,"ha") + eps;
```

The total depreciation cost allocated to area use are summarized for each operation:   

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/tech.gms GAMS /p_physDepr.*?"","","areaCost"/ /;/)
```GAMS
p_physDepr(curCrops,till,operation,"","","areaCost")
       $ p_opInputReq(curCrops,till,"deprec",operation)
     = sum(op_machType(operation,machType)
           $ p_machAttr(machType,"ha"),
                p_physDepr(curCrops,till,operation,machType,"","areaCost"));
```

In case the total depreciation allocated to area use costs exceed the total deprecation cost of a field operation, the depreciation costs of each machine are scaled

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/tech.gms GAMS /p_physDepr.*?op_machType/ /;/)
```GAMS
p_physDepr(curCrops,till,op_machType(operation,machType),"","areaCost")
      $ (p_machAttr(machType,"ha") $ p_physDepr(curCrops,till,operation,"","","cost"))
      = p_machAttr(machType, "price")/p_machAttr(machType,"ha") + eps;
```

The depreciation costs allocated to area use are subtracted from total deprecation cost of a field operation:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/tech.gms GAMS /p_physDepr.*?op_machType/ /;/)
```GAMS
p_physDepr(curCrops,till,op_machType(operation,machType),"","areaCost")
      $ (p_machAttr(machType,"ha") $ p_physDepr(curCrops,till,operation,"","","cost"))
      = p_machAttr(machType, "price")/p_machAttr(machType,"ha") + eps;
```
The same procedure is repeated to allocate the remaining depreciation costs to machines depreciated over time and mass use and to machines that are not depreciated over specific use but have fixed annual depreciated costs.

For each field operation, the total depreciation costs allocated to machine applications are summed to check for any remaining depreciation costs not allocated to any machine.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/tech.gms GAMS /p_physDepr.*?totCost/ /;/)
```GAMS
p_physDepr(curCrops,till,operation,"","","totCost")
       = sum((op_machType(operation,machType),depCost),
               p_physDepr(curCrops,till,operation,machType,"",depCost));
```

Any remaining depreciation costs are allocated to all machines of a field operation.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/tech.gms GAMS /p_physDepr.*?depCost/ /;/)
```GAMS
p_physDepr(curCrops,till,operation,machType,"",depCost));
```

Some field operations are not associated with any machine applications (e.g. drying and storing; covering of silo). Here, remaining depreciation costs can not be distributed to machines but reflect depreciation of associated buildings and facilities (storage facility, silo):

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/tech.gms GAMS /p_physDepr.*?Buildings/ /;/)
```GAMS
p_physDepr(curCrops,till,operation,"Buildings and Facilities","","totcost")
       $ (abs(p_physDepr(curCrops,till,operation,"","","error")) gt 1)
      = abs(p_physDepr(curCrops,till,operation,"","","error"));
```

Total depreciation cost of a machine per hectare crop production are calculated over all field operations that are required to produce a crop under specific production system and all deprecation types, as some machines are depreciated by more than one deprecation type (e.g. area and mass use):

Comment[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/tech.gms GAMS /Report.*?machType/ /;/)
```GAMS
*
*    --- sum depreciation of a machType over all field operations of a crop (sys,till)
*
     p_physDepr(curCrops,till,"mach_crop",machType,"",depCost)
       =sum(op_machType(operation,machType) $ p_physDepr(curCrops,till,operation,"","","cost"),
          p_physDepr(curCrops,till,operation,machType,"",depCost));
*
*   --- total depreciation of a machine over all deprec types for a crop,sys,till
*
    p_physDepr(curCrops,till,"mach_crop",machType,"","totCost")
       = sum(depCost,p_physDepr(curCrops,till,"mach_crop",machType,"",depCost));

```
The depreciation costs per hectare are assigned to the machinery requirements by each crop per hectare

Comment[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/tech.gms GAMS /p_machNeed.*?invcost/ /;.*?Buildings/)
```GAMS
*
*   --- machine costs per hectare
*

    p_machNeed(crops,till,"normal",machType,"invCost")
       = p_physDepr(crops,till,"mach_crop",machType,"","totCost");

*   --- builidng costs per hectare (e.g. deprecation of silos and storage facilities)
    p_machNeed(crops,till,"normal","Buildings and Facilities","invCost")
     = p_physDepr(crops,till,"mach_crop","","Buildings and Facilities","totcost");

```
## Labour Requirements in Crop Production

The labour needs per month are determined by summing up over all farm
operations, considering the labour period, the effect of plot size and
mechanisation (*coeffgen\\labour.gms*):

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/labour.gms GAMS /p_cropLab/ /;/)
```GAMS
p_cropLab(c_t_i(curCrops,till,intens),m)

     =
*
* --- crops included in KTBL database
*
$iftheni.data "%database%" == "KTBL_database"
   sum((operation),
          p_opInputReq(curCrops,till,"labTime",operation)
          $ (sum((amount,labperiod),  p_crop_op_per_tillaKTBL(curCrops,operation,labperiod,till,amount)
          $ labPeriod_to_month(labPeriod,m))))
$endif.data
*
* --- crops not included in KTBL database
*
+     sum( (curOperation(operation),actmachVar,act_rounded_plotsize,labPeriod_to_month(labPeriod,m))
                  $((not contractOperation(operation)
                  $$iftheni.data "%database%" == "KTBL_database"
                  $(not (sum(operationID $operationID_operation(operationID,operation),1)))
                  $$endif.data
                  )),
              p_crop_op_per_till(curCrops,operation,labPeriod,till,intens)
                     * op_attr(operation,"67kW","2","labTime")
*
*                    -- effect of plot size and mechanisation on labour time
*
                         * p_plotSizeEffect(curCrops,actMachVar,"labTime",act_rounded_plotsize)
                          /p_plotSizeEffect(curCrops,"67kW","labTime","2")
               )
               $$iftheni.data "%database%" == "KTBL_database"
               $ (not c_p_t_i_GDX(curCrops,"plot",till,"normal"))
               $$endif.data
 ;
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

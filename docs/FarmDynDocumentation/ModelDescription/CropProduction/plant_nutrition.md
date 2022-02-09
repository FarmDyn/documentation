# Plant Nutrition

Crops in FarmDyn require nitrogen (N) and phosphate (P2O5) to grow. Conceptually, the nutrient need is opposed by different nutrient sources such as chemical fertilizer, manure, mineralization or deposition. In addition, nutrient losses such as ammonia volatilization are accounted.
FarmDyn supports two differently detailed ways to calculate the plant nutrient need. The default approach and an approach in line with the fertilizing planning of the German Fertilization Ordinance. They differ amongst other by the calculation of the plant need, loss factors and accounted sources. In addition, different N fertilizing intensities and corresponding yield levels can be additionally used.

The fertilization is mainly reflected in two equations in the file general_cropping_module.gms. Nutrient need, sources and losses are listed in the equation NutBalCropSour and opposed in NutBalCrop_. This allows to clearly specify different elements of the fertilization and facilitates the validation.

The nutrient need p_nutNeed and the N fertilizing intensities are defined in the file cropping_nutNeed.gms. In the default fertilization approach, the nutrient need equals the nutrient content of the plants.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/cropping_nutNeed.gms GAMS /p_nutNeed\(c_ss_t_i\(curCrops\(crops\),soil,till,intens\),nut,t\)/ /;/)
```GAMS
p_nutNeed(c_ss_t_i(curCrops(crops),soil,till,intens),nut,t)
         = sum( prods $ p_OCoeffC(crops,soil,till,intens,prods,t), p_OCoeffC(crops,soil,till,intens,prods,t)/p_storageLoss(prods)
             * (  p_nutContent(crops,prods,"conv",nut) $ (not sameas(till,"org"))
                + p_nutContent(crops,prods,"org",nut)  $      sameas(till,"org") )*10);
```

In the approach following the Fertilization Ordinance, the nutrient need is defined by the legislation.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/cropping_nutNeed.gms GAMS /p_nutNeed\(c_ss_t_i\(curCrops\(crops\),soil,till,"normal"\),nut,t\)/ /;/)
```GAMS
p_nutNeed(c_ss_t_i(curCrops(crops),soil,till,"normal"),nut,t)
                 = p_NneedFerPlan(crops,soil,till,"normal",nut,t) ;
```

When switched on at the graphical user interface, the nutrient need for the different N fertilizing intensities is defined. Here, the calculation using the findings from Heyn and Olfs (2018) is exemplary shown. The underlying data can be found in the crop data file.

xxx

Beside the nutrient need, the variable v_nutOverNeed is introduced into the equation NutBalCropSour_ to allow manure application over plant need.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/general_cropping_module.gms GAMS /v_nutBalCropSour\(fertSour,crops,plot,till,intens,nut,t,nCur\)/ /\$sameas\(fertSour,"NBOverNeed"\)/)
```GAMS
v_nutBalCropSour(fertSour,crops,plot,till,intens,nut,t,nCur)

       =E=

* --- N and P need of crops which needs to be met.

         [
            sum(plot_soil(plot,soil),

                       p_nutNeed(crops,soil,till,intens,nut,t)

            ) * v_cropHa(crops,plot,till,intens,t,nCur)

         ] $sameas(fertSour,"NBcropNeed")

*  ---  Application over plant need of fertilizer is possible (e.g. if mineralisation
*        plus atmospheric deposition exceed crop needs, or in case too much nutrients
*        from manure are available on farm)

         + v_nutOverNeed(crops,plot,till,intens,nut,t,nCur) $sameas(fertSour,"NBOverNeed")
```

Mineralization and deposition are further N sources of plants. Under the default setting, FarmDyn accounts N mineralization in spring and deposition. Following the fertilizer planning of the Fertilization Ordinance, only mineralization in spring is accounted.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/general_cropping_module.gms GAMS /\+  \[ sum\( plot_soil\(plot,soil\),/ /] \$sameas\(fertSour,"NBbasNut"\)/)
```GAMS
+  [ sum( plot_soil(plot,soil),
                 $$iftheni.fert %Fertilization% == Default
*                    Default - p_basNut, refelct Nmin in spring and N depostion from atmosphere
                     sum(soilNutSour,p_basNut(crops,soil,till,soilNutSour,nut,t))
                 $$else.fert
*                   Fertilization Ordinance - Nmin in spring
                    p_NutFromSoil(crops,soil,till,nut,t)
                 $$endif.fert
              ) * v_cropHa(crops,plot,till,intens,t,nCur)
            ] $sameas(fertSour,"NBbasNut")
```

Chemical fertilizer application is summarized in the following part of the equation. In the case of the default setting, also losses from fertilizer application are included (not shown here).

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/general_cropping_module.gms GAMS /\+ \[ sum \(\(curInputs\(syntFertilizer\),m\),/ /] \$ sameas\(fertSour,"NBminFert"\)/)
```GAMS
+ [ sum ((curInputs(syntFertilizer),m),
                 v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m) * p_nutInSynt(syntFertilizer,nut))
           ] $ sameas(fertSour,"NBminFert")
```

Manure spreading and excretion on pasture (the latter not shown here) are other sources for N and P2O5. As illustrated exemplary for manure spreading, the amount of applied nutrients results from the volume of manure applied and the nutrient content.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/general_cropping_module.gms GAMS /\+  \[ sum \( \(manApplicType_manType\(ManApplicType,curManType\),m\)/ /] \$sameas\(fertSour,"NBmanure"\)/)
```GAMS
+  [ sum ( (manApplicType_manType(ManApplicType,curManType),m)
                      $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0),
                         v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)

                   * sum( (manChain_applic(curManChain,ManApplicType),nut2_nut(nut2,nut)),
                           p_nut2inMan(nut2,curManType,curManChain))
                )
              ] $sameas(fertSour,"NBmanure")
```

N losses following manure application are calculated, using different emission factors for the two calculation schemes.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/general_cropping_module.gms GAMS /\+ \[  sum \( \(manApplicType_manType\(ManApplicType,curManType\),m\)/ /] \$sameas\(fertSour,"NBmanureloss"\)/)
```GAMS
+ [  sum ( (manApplicType_manType(ManApplicType,curManType),m)
                    $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0),
                       v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)

                   $$iftheni.fert %Fertilization% == FertilizationOrdinance

*                        Fertilization Ordinance - standard loss factors provided by ordinance (N and P)
                          * sum( (manChain_applic(curManChain,ManApplicType),nut2_nut(nut2,nut)),
                              p_nut2inMan(nut2,curManType,curManChain)
                                 * (1 - p_nutEffFOPlan(curManType,crops,m,nut)))

                  $$else.fert
*                        Default - different N losses from env accounting module

                         * sum( (manChain_type(curManChain,curManType),nut2N),
                                      p_nut2inMan(nut2N,curManType,curManChain)
                                         * (     p_EFapplMan(curCrops,curManType,manApplicType,nut2N,m) $ sameas(nut2N,"NTAN")
                                              +  p_EFApplMin("N2O")
                                              +  p_EFApplMin("NOx")
                                              +  p_EFApplMin("N2")   )
                              ) $ sameas(nut,"N")
                  $$endif.fert
                )
              ] $sameas(fertSour,"NBmanureloss")
```

Finally, N fixation from legumes and N supply from vegetable residues are included.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/general_cropping_module.gms GAMS /\$\$iftheni\.fert %Fertilization% ==  Default/ /;/)
```GAMS
$$iftheni.fert %Fertilization% ==  Default

     + [
           v_cropHa(crops,plot,till,intens,t,nCur) *   (  p_NfromLegumes(Crops,"org")  $ sameas(till,"org")
                                                        + p_NfromLegumes(Crops,"conv") $ (not sameas(till,"org"))
                                                       ) $ (sameas (nut,"N") )
        ]  $sameas(fertSour,"NBlegumes")

       $$iftheni.data "%database%" == "KTBL_database"
    + [
          v_cropHa(crops,plot,till,intens,t,nCur) *   (  p_NfromVegetables(Crops)
                                                      ) $ (sameas (nut,"N") )
       ]  $sameas(fertSour,"NBvegetables")
       $$endif.data
    $$endif.fert
   ;
```

The equation NutBalCrop_ opposes the described nutrient need, nutrient sources and losses.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/general_cropping_module.gms GAMS /NutBalCrop_\(c_p_t_i\(curCrops\(crops\),plot,till,intens\),nut,t_n\(tCur\(t\),nCur\)\)/ /;/)
```GAMS
NutBalCrop_(c_p_t_i(curCrops(crops),plot,till,intens),nut,t_n(tCur(t),nCur))
         $ ( (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0)  $ fertCrops(Crops) ) ..

* --- Equation which oppons nutrient need, sources and losses based on the
*     definition in NutBalCropSour_

* --- Nutrient need
          v_nutBalCropSour("NBcropNeed",crops,plot,till,intens,nut,t,nCur)

* --- Nutrient application over plant need with manure
         + v_nutBalCropSour("NBOverNeed",crops,plot,till,intens,nut,t,nCur)

            =E=

* --- Nutrient delivered from soil and air
          v_nutBalCropSour("NBbasNut",crops,plot,till,intens,nut,t,nCur)

* --- Nutrient from chemical fertilizer
        + v_nutBalCropSour("NBminFert",crops,plot,till,intens,nut,t,nCur)

* --- Losses from chemical fertilizer application
        - v_nutBalCropSour("NBminFertLoss",crops,plot,till,intens,nut,t,nCur)

        $$iftheni.man "%manure%" == "true"
* --- Nutrients from manure application
        + v_nutBalCropSour("NBmanure",crops,plot,till,intens,nut,t,nCur)

* --- Losses from manure application
        - v_nutBalCropSour("NBmanureloss",crops,plot,till,intens,nut,t,nCur)
        $$endif.man

        $$iftheni.dh "%cattle%" == "true"
* --- Nutrients on pasture from grazing
        + v_nutBalCropSour("NBpasture",crops,plot,till,intens,nut,t,nCur)

* --- Losses on pasture from grazing
        - v_nutBalCropSour("NBpastureLoss",crops,plot,till,intens,nut,t,nCur)

        $$endif.dh
* ---- Nutrients from legumes
        + v_nutBalCropSour("NBlegumes",crops,plot,till,intens,nut,t,nCur)

* ---- Nutrients from vegetables
        $$iftheni.data "%database%" == "KTBL_database"
        + v_nutBalCropSour("NBvegetables",crops,plot,till,intens,nut,t,nCur)
        $$endif.data
;
```


<!--

The template supports two differently detailed ways to account for plant
nutrition need.

1.  A **fixed factor approach** with yearly nutrient balances per crop

    a.  Using N response curves

    b.  Using planning data

2.  Using data output of the crop modeling framework SIMPLACE

*p\_nutNeed* is the nutrient need for different crops tat enters the
equation for fixed factor approach and the flow model. For the fixed
factor approach, nutrient need can be calculated based on N response
curves and alternatively based on planning data. In the detailed flow
model, nutrient need is calculated based on N response curves.
All relevant calculations can be found in *coeffgen\\cropping.gms*.

## The fixed factor approach

The fixed factor approach is used in combination with the use of N response curves
and planning data. Generally, the plant need in *p\_nutneed* has to be met with manure and
synthetic fertiliser. There is the option to allow manure application over plant need as
manure nutrients on livestock farms with high stocking densities partly treated as waste.

[^Comment][embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/templ.gms GAMS /NutBalCrop_\(c_/ /;/)
```GAMS
NutBalCrop_(c_s_t_i(curCrops(crops),plot,till,intens),nut,tCur(t),nCur)
       $ ((v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0) $ t_n(t,nCur) $( not sameas (crops,"catchCrop")) ) ..

*               ---  crop need based on plant uptake and calculated further need

                sum(plot_soil(plot,soil),
                         p_nutNeed(crops,soil,till,intens,nut,t) * v_cropHa(crops,plot,till,intens,t,nCur)
                                * (1 + p_nutLossUnavoidable(soil,till,intens,nut)))

               $$iftheni.man %manure% == true
*               ---  application over plant need of organic fertilizer is possible
                + v_nutOrganicOverNeed(crops,plot,till,intens,nut,t,nCur)
               $$endif.man

               =E=

              $$iftheni.dh "%cattle%" == "true"
*
*                 --- manure excreted during grazing on pasture: N , different calculation of losses [TK 01.03.16 revised]
*
                 [sum( (nut2,m) $ ( sameas(nut2,"norg") or sameas(nut2,"ntan") ),
*
*                        --- excretion by herds which graze only for a part of the year
*
                         v_nut2ManurePast(crops,plot,till,intens,nut2,t,nCur,m)
                     )
                  $$iftheni.NorgAcc "%NorgAccounting%" == "Interface"
                                     *   %NOrgAccountedInt%
                  $$elseifi.NorgAcc "%NorgAccounting%" == "PlanningDueV16"
                                      *  0.8
                  $$else.NorgAcc
*
*                           WB: here, something needs to change ... cannot work with several pasture options
                            - v_niEmissionsPast(crops,plot,till,intens,t,nCur)

                      $$ontext
                               *  p_nutEffectivPastDueVNv
                      $$offtext
                  $$endif.NorgAcc

                  ] $  (past(crops) and sameas(nut,"N"))

*                  --- manure excreted during grazing pasture: P [TK 01.03.16 revised]

                   + sum(m,v_nut2ManurePast(crops,plot,till,intens,"P",t,nCur,m)) $ (past(Crops) and sameas(nut,"P"))

              $$endif.dh


              $$iftheni.man "%manure%" == "true"

*
*               -- application of N and P with organic fertilizer [TK 09.02.15 revised]
*
*                + sum( (nut2_nut(nut2,nut),manApplicType_manType(ManApplicType,curManType),m)
*                         $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0),
*                       v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
*                          * sum(manChain_applic(manChain,ManApplicType), p_nut2inMan(nut2,curManType,manChain))
*                               * p_nut2UsableShare(crops,curManType,ManApplicType,nut2,m))


                    + sum( (nut2_nut(nut2,nut),manApplicType_manType(ManApplicType,curManType),m)
                             $(not sameas(plot,"plot7") $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0 )),
                           v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                              * sum(manChain_applic(manChain,ManApplicType), p_nut2inMan(nut2,curManType,manChain))
                                   * p_nut2UsableShare(crops,curManType,ManApplicType,nut2,m))


              $$endif.man

*               -- mineral N application

                + sum ((syntFertilizer,m)$(not sameas(plot,"plot7")),
                      v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)
                                                       * p_nutInSynt(syntFertilizer,nut) )
 ;
```

## N response curves

The yield level of different crops is chosen in the GUI. The following
equations show that the yield,
*p\_OCoeffC*, equals the yield given by the GUI, *p\_cropYieldInt* , and
takes a growth rate given by the GUI into account.

[^Comment][embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/cropping.gms GAMS /p\_OCoeffC(c\_ss\_t\_i\(curCrops\(arabCrops\)\,soil\,till\,intens\)\,prods\,t\)/ /;/)
```GAMS
p_OCoeffC(c_ss_t_i(curCrops(arabCrops),soil,till,intens),prods,t)
             $(sameas(arabCrops,prods) $ (not sameas(till,"org")))
   =  p_cropYieldInt(arabCrops,"conv")
        $$iftheni.data "%database%" == "KTBL_database"
        *  ((1.00 + p_cropYieldInt(arabCrops,'Change,conv % p.a.')/100)**t.pos)
        $$endif.data
        ;
```

Further, two different intensities and their related nutrient needs in *N* are available as options.
First, the nutrient needs for the different intensities are based on nitrogen
response functions from field trials. The intensity can be reduced from
100 % to an N fertiliser application of 80 %, 60 %, 40 % and 20 %. The
yield level, *p\_OCoeffC*, is reduced to 96 %, 90 %, 82 % and 73 %, respectively. These
steps reflect the diminishing yield increases from increased N
fertiliser application.

[^Comment][embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/cropping_intens.gms GAMS /\*/ /;/)
```GAMS
*
    p_OCoeffC(c_ss_t_i(curCrops(arabCrops),soil,till,"fert80p"),prods,t) $ (not sameas(till,"org"))
     = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.96;
    p_OCoeffC(c_ss_t_i(curCrops(arabCrops),soil,till,"fert60p"),prods,t) $ (not sameas(till,"org"))
     = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.90;
    p_OCoeffC(c_ss_t_i(curCrops(arabCrops),soil,till,"fert40p"),prods,t) $ (not sameas(till,"org"))
     = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.82;
    p_OCoeffC(c_ss_t_i(curCrops(arabCrops),soil,till,"fert20p"),prods,t) $ (not sameas(till,"org"))
     = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.73;
```

The second option relates to the paper by Heyn,J. and Olfs, H.-W. (2018) where a yield reduction, *p_yieldReducN*,
based on nitrogen application levels is estimated. The calculation can be seen in the following equation:

[^Comment][embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/crops_de.gms GAMS // /;/)
```GAMS

      p_yieldReducN(crops,intens) $ ( (not sameas (intens,"normal")) $ p_intens(crops,intens))
                                      =   p_NrespFunct(crops,"a") * sqr(p_intens(crops,intens)*100)
                                        + p_NrespFunct(crops,"b") * p_intens(crops,intens)*100
                                        + p_NrespFunct(crops,"c") ;
```

Similar to the first option, the crop yield is then reduced by the calculated yield reduction level.

[^Comment][embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/cropping_intens.gms GAMS // /;/)
```GAMS

  p_OCoeffC(c_ss_t_i(curCrops(arabCrops),soil,till,intens),prods,t)
             $ sum(  soil_plot(soil,plot),c_p_t_i(arabCrops,plot,till,intens) )
                 =   p_OCoeffC(arabCrops,soil,till,"normal",prods,t)  * p_yieldReducN(arabCrops,intens)/100 ;
```

The output coefficient, *p\_OCoeffC*, represents the yields per hectare.
It is used to define the nutrient uptake by the crops, *p\_nutNeed,*
based on the nutrient content, *p\_nutContent*. Values for
*p\_nutContent* are taken from the German Fertiliser Directive
(DüV 2007, Appendix 1).

[^Comment][embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/cropping.gms GAMS /* --- nutrient need, taking into that output coefficient are measured in t and not dt, therefore * 10./ /;/)
```GAMS
* --- nutrient need, taking into that output coefficient are measured in t and not dt, therefore * 10.

  p_nutNeed(c_ss_t_i(curCrops(crops),soil,till,intens),nut,t)
         = sum( prods $ p_OCoeffC(crops,soil,till,intens,prods,t), p_OCoeffC(crops,soil,till,intens,prods,t)/p_storageLoss(prods)
             * (  p_nutContent(crops,prods,"conv",nut) $ (not sameas(till,"org"))
                + p_nutContent(crops,prods,"org",nut)  $      sameas(till,"org") )*10);
```

For different intensities, the corresponding amount of nutrient applied
has to fulfil the need *p\_nutNeed*.

The parameter *p\_basNut* defines the amount of nutrients coming from
other sources than directly applied fertilizer, for example mineralization and atmospheric deposition:

[^Comment][embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/crops_de.gms /\* --- Nutrient provided from atmospheric deposition/ /;/)
```GAMS
* --- Nutrient provided from atmospheric deposition

   p_basNut(crops,soil,till,"NAtmos","N",t) $ sum(prods, p_OCoeffC(crops,soil,till,"normal",prods,t))  =  18;

* --- Nutrient provided from N mineralization in spring based on LWK NRW [updated 2/2021]

   p_basNut(crops,soil,till,"Nmin","N",t)       $ sum(prods, p_OCoeffC(crops,soil,till,"normal",prods,t))     = p_Nmin(crops);

```
[DO NOT FIND p_nutApplied is there already a corrected version of plant nutrition?]
The amount of nutrients applied, *p\_nutApplied,* is estimated as shown
in the following equation. It is assumed that at least 20% of the
default leaching and NH<sub>3</sub> losses will occur.

[^Comment][embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_nutApplied.*?"fert20p"/ /;/)
```GAMS
p_nutApplied(crops,soil,till,"fert20p","N",t) $ sum(soil_plot(soil,plot),c_s_t_i(crops,plot,till,"fert20p"))
    = p_nutNeed(crops,soil,till,"normal","N",t)*(1 + p_FracGaseF + p_FracLeach)*0.2;
```

[^Comment][embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_nutApplied.*?"fert40p"/ /;/)
```GAMS
p_nutApplied(crops,soil,till,"fert40p","N",t) $ sum(soil_plot(soil,plot),c_s_t_i(crops,plot,till,"fert40p"))
    = p_nutNeed(crops,soil,till,"normal","N",t)*(1 + p_FracGaseF + p_FracLeach)*0.2 * 1.5;
```

[^Comment][embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_nutApplied.*?"fert60p"/ /;/)
```GAMS
p_nutApplied(crops,soil,till,"fert60p","N",t) $ sum(soil_plot(soil,plot),c_s_t_i(crops,plot,till,"fert60p"))
    = p_nutNeed(crops,soil,till,"normal","N",t)*(1 + p_FracGaseF + p_FracLeach)*0.2 * 2;
```

[^Comment][embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_nutApplied.*?"fert80p"/ /;/)
```GAMS
p_nutApplied(crops,soil,till,"fert80p","N",t) $ sum(soil_plot(soil,plot),c_s_t_i(crops,plot,till,"fert80p"))
    = p_nutNeed(crops,soil,till,"normal","N",t)*(1 + p_FracGaseF + p_FracLeach)*0.2 * 2.5;
```

[^Comment][embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_nutApplied.*?"normal"/ /;/)
```GAMS
p_nutApplied(crops,soil,till,"normal","N",t)  $ sum(soil_plot(soil,plot),c_s_t_i(crops,plot,till,"normal") )
    = p_nutNeed(crops,soil,till,"normal","N",t)*(1 + p_FracGaseF + p_FracLeach)*0.2 * 3;
```

The nutrient application, *p\_nutApplied,* in combination with the basis
delivery from soil and air, *p\_basNut,* allows defining the loss rates
for each intensity level, *p\_nutLossUnavoidable,* as the difference
between the deliveries and the nutrient uptake, *p\_nutNeed,* by the
plants:

[^Comment][embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /\s\sp_nutLossUnavoidable\(s.*?nut/ /;/)
```GAMS
  p_nutLossUnavoidable(soil,till,intens,nut)
     $ (sum( (crops,t) $ p_nutNeed(crops,soil,till,intens,nut,t), 1))
      =  sum( (crops,t) $ p_nutNeed(crops,soil,till,intens,nut,t),
           max(0,Min(50, p_nutApplied(crops,soil,till,intens,nut,t)
                 + p_basNut(crops,soil,till,nut,t) - p_nutNeed(crops,soil,till,intens,nut,t)))
              / p_nutNeed(crops,soil,till,intens,nut,t))

        /sum( (crops,t) $ p_nutNeed(crops,soil,till,intens,nut,t), 1);
```

*p\_nutLossUnavoidable* enters the Standard Nutrient Fate Model (see
chapter 2.11.2). It represents the factor that has to be applied over
the plant removal, *p\_nutNeed*, to reach a certain yield level. It
indicates the nutrient efficiency of the fertiliser management.

## Planning Data

The nutrient need can also be derived from planning data from the revised
Fertiliser Directive (BMEL 2015). The proposed directive includes
compulsory fertiliser planning to increase N use efficiency on farms.
This measure is included in FarmDyn. When fertiliser management follows
the planning data, different intensities do not exist, and yield levels
are fixed, i.e. cannot be changed by the GUI.

The yield level *p\_OCoeffC* is fixed in the following equation, showing
the example of winter cereals.

[^Comment][embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /\s\s[^\n]\sp_OCoeffC\("winterW/ /;/)
```GAMS

   p_OCoeffC("winterWheat",soil,till,intens,"winterWheat",t)   $ sum(soil_plot(soil,plot),c_s_t_i("winterWheat",plot,till,intens))      =  8   ;
```

The yield corresponds to a certain amount of needed N, *p\_nutNeed*,
given by the directive.

[^Comment][embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_nutNeed\("winter/ /;/)
```GAMS
p_nutNeed("winterWheat",soil,till,intens,"N",t)   $ sum(soil_plot(soil,plot), c_s_t_i("winterWheat",plot,till,intens))  =   230 - p_basNut("winterWheat",soil,till,"N",t)  ;
```

In the case of P, it is assumed that the nutrient need corresponds to
the nutrients removed by the harvested product.

[^Comment][embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /\s\sp_nutNeed\(c.*?"P"/ /;/)
```GAMS
  p_nutNeed(crops,soil,till,intens,"P",t) $ sum(soil_plot(soil,plot), c_s_t_i(crops,plot,till,intens))
        = sum( prods, p_OCoeffC(crops,soil,till,intens,prods,t) * (p_nutContent(crops,prods,"P")*10));
```

The directive prescribes that nutrients delivered from soil and air have
to be taken into account. This reduces the amount of fertiliser that
needs to be applied, i.e. p_nutNeed is lowered.
`

[^Comment][embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /\s[^\n]\sp_basNut\(c.*?[^\$]"N"/ /p_NfromLegumes\(crops\);/)
```GAMS
   p_basNut(crops,soil,till,"N",t) $ arableCrops(crops) =  50 ;
   p_basNut(crops,soil,till,"N",t) $ grassCrops(crops)  =  10 + p_NfromLegumes(crops);
```

-->

## References

Heyn, J. and Olfs, H.-W. (2018):  Wirkungen reduzierter N-Düngung auf Produktivität, Bodenfruchtbarkeit und N-Austragsgefährdung – Beurteilung anhand mehrjähriger Feldversuche. VDLUFA. Schriftenreihe 72.

[^4]: QIP solvers do not allow for equality conditions which are by
   definition non-convex

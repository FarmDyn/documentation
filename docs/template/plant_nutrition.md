
# Plant Nutrition

!!! abstract
    The equations related to plant nutrition make sure that the nutrient need of crops is met. Nutrient need can be derived from N response functions or from planning data for fixed yield levels. Furthermore, FarmDyn is loosely connected to the crop modelling framework SIMPLACE which provides data on cropping activities. Needed nutrients are provided by manure and synthetic fertilizer.

The template supports two differently detailed ways to account for plant
nutrition need.

1.  A **fixed factor approach** with yearly nutrient balances per crop

    a.  Using N response curves

    b.  Using planning data

2.  Using data output of the crop modelling framework SIMPLACE

*p\_nutNeed* is the nutrient need for different crops and enters the
equation for fixed factor approach and the flow model. For the fixed
factor approach, nutrient need can be calculated based on N response
curves and alternatively based on planning data. In the detailed flow
model, nutrient need is calculated based on N response curves.
All relevant calculation can be found in *coeffgen\\cropping.gms*.

## The fixed factor approach

The fixed factor approach is used in combination with the use of N response curves
and planning data. Generally, the plant need in p_nutneed has to be met with manure and
chemical fertilizer. There is the option to allow manure application over plant need as
manure nutrients on livestock farms with high stocking densities partly are waste.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /NutBalCrop_\(c_/ /;/)
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
                             $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0),
                           v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                              * sum(manChain_applic(manChain,ManApplicType), p_nut2inMan(nut2,curManType,manChain))
                                   * p_nut2UsableShare(crops,curManType,ManApplicType,nut2,m))


              $$endif.man

*               -- mineral N application

                + sum ((syntFertilizer,m),
                      v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)
                                                       * p_nutInSynt(syntFertilizer,nut) )
 ;
```

## N response curves

The yield level of different crops is chosen in the GUI. The following
equations show, using the example of winter cereals, that the yield,
*p\_OCoeffC*, equals the yield given by the GUI, *p\_cropYieldInt* , and
takes a growth rate given by the GUI into account.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/regionalData/yields.gms GAMS /p_OCoeffC\("winterCere"/ /;/)
```GAMS
p_OCoeffC("winterCere",soil,till,intens,"winterCere",t)     $ sum(soil_plot(soil,plot),c_s_t_i("winterCere",plot,till,intens))       =  8   * (1.00 + p_cropYieldInt("winterCere","GrowthRateY")/100) **t.pos;
```

In the next step, the nutrient need for crops are linked to the
different cropping intensities. There are five different intensity
levels with regard to the amount of N fertilizer applied:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ_decl.gms GAMS /set\sintens/ /;/)
```GAMS
set intens      / normal   "Full N fertilization"
                    fert80p  "80 % N"
                    fert60p  "60 % N"
                    fert40p  "40 % N"
                    fert20p  "20 % N"

                    bales
                    silo
                    Graz

                    /;
```


These nutrient needs for the different intensities are based on nitrogen
response functions from field trials. The intensity can be reduced from
100 % to an N fertilizer application of 80 %, 60 %, 40 % and 20 %. The
yield level is reduced to 96 %, 90 %, 82 % and 73 %, respectively. These
steps reflect the diminishing yield increases from increased N
fertilizer application.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_OCoeffC.*?"fert80p"/ /0\.53;/)
```GAMS
p_OCoeffC(arabCrops,soil,till,"fert80p",prods,t) $ (not sameas(till,"eco"))   = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.96;
    p_OCoeffC(arabCrops,soil,till,"fert60p",prods,t) $ (not sameas(till,"eco"))   = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.90;
    p_OCoeffC(arabCrops,soil,till,"fert40p",prods,t) $ (not sameas(till,"eco"))   = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.82;
    p_OCoeffC(arabCrops,soil,till,"fert20p",prods,t) $ (not sameas(till,"eco"))   = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.73;

    p_OCoeffC(arabCrops,soil,till,"fert80p",prods,t) $ (not sameas(till,"eco"))   = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.95;
    p_OCoeffC(arabCrops,soil,till,"fert60p",prods,t) $ (not sameas(till,"eco"))   = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.85;
    p_OCoeffC(arabCrops,soil,till,"fert40p",prods,t) $ (not sameas(till,"eco"))   = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.71;
    p_OCoeffC(arabCrops,soil,till,"fert20p",prods,t) $ (not sameas(till,"eco"))   = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.53;
```


The output coefficients, *p\_OCoeffC*, represent the yields per hectare.
They are used to define the nutrient uptake by the crops, *p\_nutNeed,*
based on the nutrient content, *p\_nutContent*. Values for
*p\_nutContent* are taken from the German Fertilizer Directive
(DüV 2007, Appendix 1).

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /\s\sp_nutNeed\(c.*?nut.*?\$/ /;/)
```GAMS

 p_nutNeed(crops,soil,till,intens,nut,t) $ sum(soil_plot(soil,plot), c_s_t_i(crops,plot,till,intens))
        = sum( prods, p_OCoeffC(crops,soil,till,intens,prods,t) * (p_nutContent(crops,prods,nut)*10));
```

For different intensities, the corresponding amount of nutrient applied
has to be determined to fulfil the need *p\_nutNeed*.

The parameter *p\_basNut* defines the amount of nutrients coming from
other sources than directly applied fertilizer. The curve suggests that
for a 53%-level of yield, only 20% of the N dose at full yield is
necessary. Assuming a minimum nutrient loss factor that allows defining
how much N a crop takes up from other sources (mineralisation,
atmospheric deposition):

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_basNut\(crops.*?nut.*?\$.*?\$/ /;/)
```GAMS
p_basNut(crops,soil,till,nut,t) $ (sum(prods, p_OCoeffC(crops,soil,till,"normal",prods,t)) $ sameas(nut,"N"))
       = smax( (soil_plot(soil,plot),c_s_t_i(crops,plot,till,"normal"),intens),
           sum(prods, p_OCoeffC(crops,soil,till,intens,prods,t) * (p_nutContent(crops,prods,nut)*10))
             - p_nutNeed(crops,soil,till,"normal",nut,t)*(1 + p_FracGaseF + p_FracLeach) * (  0.2 $ sameas(intens,"fert20p")
                                                                                            + 0.4 $ sameas(intens,"fert40p")
                                                                                            + 0.6 $ sameas(intens,"fert60p")
                                                                                            + 0.8 $ sameas(intens,"fert80p")
                                                                                            + 1.0 $ sameas(intens,"normal")) );
```

The amount of nutrient applied, *p\_nutApplied,* is estimated as shown
in the following equation. It is assumed that at least 20% of the
default leaching and NH<sub>3</sub> losses will occur.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_nutApplied.*?"fert20p"/ /;/)
```GAMS
p_nutApplied(crops,soil,till,"fert20p","N",t) $ sum(soil_plot(soil,plot),c_s_t_i(crops,plot,till,"fert20p"))
    = p_nutNeed(crops,soil,till,"normal","N",t)*(1 + p_FracGaseF + p_FracLeach)*0.2;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_nutApplied.*?"fert40p"/ /;/)
```GAMS
p_nutApplied(crops,soil,till,"fert40p","N",t) $ sum(soil_plot(soil,plot),c_s_t_i(crops,plot,till,"fert40p"))
    = p_nutNeed(crops,soil,till,"normal","N",t)*(1 + p_FracGaseF + p_FracLeach)*0.2 * 1.5;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_nutApplied.*?"fert60p"/ /;/)
```GAMS
p_nutApplied(crops,soil,till,"fert60p","N",t) $ sum(soil_plot(soil,plot),c_s_t_i(crops,plot,till,"fert60p"))
    = p_nutNeed(crops,soil,till,"normal","N",t)*(1 + p_FracGaseF + p_FracLeach)*0.2 * 2;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_nutApplied.*?"fert80p"/ /;/)
```GAMS
p_nutApplied(crops,soil,till,"fert80p","N",t) $ sum(soil_plot(soil,plot),c_s_t_i(crops,plot,till,"fert80p"))
    = p_nutNeed(crops,soil,till,"normal","N",t)*(1 + p_FracGaseF + p_FracLeach)*0.2 * 2.5;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_nutApplied.*?"normal"/ /;/)
```GAMS
p_nutApplied(crops,soil,till,"normal","N",t)  $ sum(soil_plot(soil,plot),c_s_t_i(crops,plot,till,"normal") )
    = p_nutNeed(crops,soil,till,"normal","N",t)*(1 + p_FracGaseF + p_FracLeach)*0.2 * 3;
```

The nutrient application, *p\_nutApplied,* in combination with the basis
delivery from soil and air, *p\_basNut,* allows defining the loss rates
for each intensity level, *p\_nutLossUnavoidable,* as the difference
between the deliveries and the nutrient uptake, *p\_nutNeed,* by the
plants:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /\s\sp_nutLossUnavoidable\(s.*?nut/ /;/)
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
indicates the nutrient efficiency of the fertilizer management.

## Planning Data

The nutrient need can also be derived from planning data from the revised
Fertilizer Directive (BMEL 2015). The proposed directive includes
compulsory fertilizer planning to increase N use efficiency on farms.
This measure is included in FarmDyn. When fertilizer management follows
the planning data, different intensities do not exist and yield levels
are fixed, i.e. cannot be changed by the GUI.

The yield level *p\_OCoeffC* is fixed in the following equation, showing
the example of winter cereals.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /\s\s[^\n]\sp_OCoeffC\("winterW/ /;/)
```GAMS

   p_OCoeffC("winterWheat",soil,till,intens,"winterWheat",t)   $ sum(soil_plot(soil,plot),c_s_t_i("winterWheat",plot,till,intens))      =  8   ;
```

The yield corresponds to a certain amount of needed N, *p\_nutNeed*,
given by the directive.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_nutNeed\("winter/ /;/)
```GAMS
p_nutNeed("winterWheat",soil,till,intens,"N",t)   $ sum(soil_plot(soil,plot), c_s_t_i("winterWheat",plot,till,intens))  =   230 - p_basNut("winterWheat",soil,till,"N",t)   ;
```

In the case of P, it is assumed that the nutrient need corresponds to
the nutrients removed by the harvested product.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /\s\sp_nutNeed\(c.*?"P"/ /;/)
```GAMS
  p_nutNeed(crops,soil,till,intens,"P",t) $ sum(soil_plot(soil,plot), c_s_t_i(crops,plot,till,intens))
        = sum( prods, p_OCoeffC(crops,soil,till,intens,prods,t) * (p_nutContent(crops,prods,"P")*10));
```

The directive prescribes that nutrients delivered from soil and air have
to be taken into account. This reduces the amount of fertilizer that
needs to be applied, i.e. p_nutNeed is lowered.
`

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /\s[^\n]\sp_basNut\(c.*?[^\$]"N"/ /p_NfromLegumes\(crops\);/)
```GAMS
   p_basNut(crops,soil,till,"N",t) $ arableCrops(crops) =  50 ;
   p_basNut(crops,soil,till,"N",t) $ grassCrops(crops)  =  10 + p_NfromLegumes(crops);
```


## Using data output of the crop modelling framework SIMPLACE

FarmDyn is loosely connected to the crop modelling framework [SIMPLACE](http://www.simplace.net/Joomla/index.php). This crop model provides cropping activities consisting of different managements and corresponding yields and externalities. They are provided as a gdx file
and loaded into FarmDyn.
The parameter *p\_simres* contains all information from the crop model for
different crops, crop rotations (represented in the set till) and intensities. Intensities represent a whole
range of management, consisting of different amounts of fertilizer, straw removal and catch crop growing. The elements of
the set @Till add setname contain the information on yields and externalities for the different cropping activities.
The use of the SIMPLACE data is activated in the GUI by selecting the BWA mode. It requires to choose specific farm types
and their location in different soil-climate regions. Currently, SIMPLACE data are available for the German Federal State
of North Rhine-Westphalia.

First, the shares of different crops in FarmDyn have to equal the crop rotation represented in
the SIMPLACE data. Crop rotations can be selected at the GUI.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/simplace_module.gms GAMS /SimplaceRot_\(c_/ /;/)
```GAMS
SimplaceRot_(c_s_t_i(curCrops(crops),plot,curRotTill(till),intens),tCur(t),nCur)
                     $ ( (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0) $ t_n(t,nCur)
                     $ (not sameas (crops,"idle") )
                     $ (not sameas (crops,"catchcrop") )  ) ..

       v_cropHa(crops,plot,till,intens,t,nCur)

           =e=

             sum ( crops1 $  (c_s_t_i(crops1,plot,till,intens) $ (curCrops(crops1)
                              $ (not sameas(crops1,"idle"))
                              $ (not sameas(crops1,"catchcrop")))),
                     v_cropHa(crops1,plot,till,intens,t,nCur))    *   p_cropShare(till,crops);
```


The synthetic fertilizer need linked to cropping activities in the SIMPLACE data has to be provided
by synthetic fertilizer distribution in FarmDyn.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/simplace_module.gms GAMS /NMineralSim_\(c_/ /;/)
```GAMS
NMineralSim_(c_s_t_i(curCrops(crops),plot,curRotTill(till),intens),"N",tCur(t),nCur)
                     $ ((v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0) $ t_n(t,nCur)   $   (not sameas (curCrops,"catchcrop") ) $ (not sameas (curCrops,"idle") )    ) ..

         sum ( (syntFertilizer,m) , v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)  * p_nutInSynt(syntFertilizer,"N") * (1 - p_EFApplMinNH3(syntFertilizer)) )

           =e=

               v_cropHa(crops,plot,till,intens,t,nCur) *  p_SimRes(till,crops,intens,"Nchem")
;
```

The manure application in spring linked to cropping activities in the SIMPLACE data has to be provided
by manure application in FarmDyn in the months January to June. Note that other restrictions such as
the Fertilization Ordinance may restrict application in certain months.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/simplace_module.gms GAMS /NOrgSpringSim_\(c_/ /;/)
```GAMS
NOrgSpringSim_(c_s_t_i(curCrops(crops),plot,curRotTill(till),intens),"N",tCur(t),nCur)
                  $ ((v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0) $ t_n(t,nCur)  $ (not sameas (curCrops,"catchcrop") ) $ (not sameas (curCrops,"idle") )  ) ..


*                --- NOrg Applied

                  sum( (manApplicType_manType(ManApplicType,curManType),m_spring(m) )
                   $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m_spring) ne 0),
                       v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m_spring )
                          * sum(manChain_applic(manChain,ManApplicType), p_nut2inMan("NOrg",curManType,manChain))   )

*               -- NTAN applied minus losses with application

                + sum( (manApplicType_manType(ManApplicType,curManType),m_spring(m) )
                    $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m_spring) ne 0),
                       v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m_spring)
                           * sum(manChain_applic(manChain,ManApplicType), p_nut2inMan("NTan",curManType,manChain))
                               * p_nut2UsableShare(crops,curManType,ManApplicType,"NTAN",m)
                                   )
                   =e=

                       v_cropHa(crops,plot,till,intens,t,nCur) *   p_SimRes(till,crops,intens,"NOrgS")

                                        ;
```

The manure application in autumn linked to cropping activities in the SIMPLACE data has to be provided
by manure application in FarmDyn in the months July to December.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/simplace_module.gms GAMS /NOrgAutumnSim_\(c_/ /;/)
```GAMS
NOrgAutumnSim_(c_s_t_i(curCrops(crops),plot,curRotTill(till),intens),"N",tCur(t),nCur)
                  $ ((v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0) $ t_n(t,nCur)
                   $ (not sameas (crops,"catchcrop") ) $ (not sameas (crops,"idle") )  ) ..


*                --- NOrg Applied

                  sum( ( manApplicType_manType(ManApplicType,curManType),m_autumn(m) )
                   $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m_autumn) ne 0),
                       v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m_autumn )
                          * sum(manChain_applic(manChain,ManApplicType), p_nut2inMan("NOrg",curManType,manChain))   )

*               -- NTAN applied minus losses with application

                + sum(  ( manApplicType_manType(ManApplicType,curManType),m_autumn(m) )
                    $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m_autumn) ne 0),
                       v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m_autumn)
                           * sum(manChain_applic(manChain,ManApplicType), p_nut2inMan("NTan",curManType,manChain))
                               * p_nut2UsableShare(crops,curManType,ManApplicType,"NTAN",m)
                                     )

                  =e=

                       v_cropHa(crops,plot,till,intens,t,nCur) *  p_SimRes(till,crops,intens,"NOrgA") ;
```

The cropping activities provided by SIMPLACE do not contain information of P<sub>2</sub>O<sub>5</sub> fertilizer need. Therefore,
the following equation ensures that P<sub>2</sub>O<sub>5</sub> removal with the harvested product has to be meet by P<sub>2</sub>O<sub>5</sub> in manure and
chemical fertilizer.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/simplace_module.gms GAMS /PFertilizingSim_.*?\.\./ /;/)
```GAMS
PFertilizingSim_("P",tCur(t),nCur)  $ t_n(t,nCur)  ..

                sum( (prods,c_s_t_i(curcrops(crops),plot,till,intens))   $ (    not sameas (prods,"WCresidues") $ ( not sameas (prods,"WBresidues")) $ (not sameas (prods,"SCresidues"))
                                                                             $ (not sameas (curCrops,"catchcrop") )  $ (not sameas (curCrops,"idle") )  )
                            ,  p_SimRes(till,crops,intens,"yield")  * p_nutContent(crops,prods,"P") * 10/1000
                                                                            * v_cropHa(crops,plot,till,intens,t,nCur)   )

                     =l=

$iftheni.man %manure% == true

                      sum( (manApplicType_manType(ManApplicType,curManType),m,c_s_t_i(curCrops(crops),plot,till,intens))  $ (  (not sameas (curCrops,"catchcrop") )  $ (not sameas (curCrops,"idle") )
                         $ (   v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0)     ),
                            v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                              * sum(manChain_applic(manChain,ManApplicType), p_nut2inMan("P",curManType,manChain))

                             )

                            +

$endif.man

                       sum ( (syntFertilizer,m,c_s_t_i(curcrops(crops),plot,till,intens) ) $(  (not sameas (curCrops,"catchcrop") )  $ (not sameas (curCrops,"idle") )  )
                                   , v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)  * p_nutInSynt(syntFertilizer,"P")  )
                                                           ;
```

Some crops require minimum chemical fertilizer doses such as the starter fertilization of maize. For N, minimum
chemical fertilizer needs are reflected in the SIMPLACE results. For P<sub>2</sub>O<sub>5</sub>, the following equations ensures that
the minimum chemical fertilizer needs are met.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/simplace_module.gms GAMS /MinChemFertSimplace_.*?\.\./ /;/)
```GAMS
MinChemFertSimplace_(tCur(t),nCur)    $ t_n(t,nCur)  ..

                sum( (c_s_t_i(curcrops(crops),plot,till,intens))   $ (  (not sameas (curCrops,"catchcrop") )  $ (not sameas (curCrops,"idle") )  )
                            ,   v_cropHa(crops,plot,till,intens,t,nCur) * p_minChemFert(crops,"P")
                                         )

                                    =l=

                 sum ( (syntFertilizer,m,c_s_t_i(curcrops(crops),plot,till,intens) )  $ (  (not sameas (curCrops,"catchcrop") )  $ (not sameas (curCrops,"idle") )  )
                                   , v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)   * p_nutInSynt(syntFertilizer,"P")  )
                                                     ;
```

The SIMPLACE results contains scenarios, captured in the set intensities, with and without residue removal. Therebey, it is assumed that straw from
cereal production can be sold. The following equation maps the cropping activities on the variable *v\_residuesRemoval*
which is used in other parts of FarmDyn to calculate the costs and revenues related to residue removal.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/simplace_module.gms GAMS /ResidRemovalSim_\(cu/ /;/)
```GAMS
ResidRemovalSim_(curCrops(crops),plot,till,intens,tCur(t),nCur)
                 $ ( t_n(t,nCur) $  c_s_t_i(crops,plot,till,intens)  $ (not sameas (curCrops,"catchcrop") )  $ (not sameas (curCrops,"idle"))
                                $ intensResRem(intens)   $ cropsResidueRemo(crops)  ) ..

                     v_residuesRemoval(crops,plot,till,intens,t,nCur)    =e=          v_cropHa(crops,plot,till,intens,t,nCur)  ;
```

The SIMPLACE results contain scenarios, captured in the set intensities, with and without catch crops.
They are linked to the catch crop growing represented in *v\_cropHa*.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/simplace_module.gms GAMS /CatchCropsSimHa_\(p.*?r\)/ /;/)
```GAMS
CatchCropsSimHa_(plot,curRotTill(till),intens,tCur(t),nCur)
                $ ( t_n(t,nCur) $ (sum (crops, c_s_t_i(crops,plot,till,intens)))     ) ..

            sum (c_s_t_i("catchCrop",plot,till,intens), v_cropHa("catchCrop",plot,till,intens,t,nCur)    )

                                   =e=
                                         sum( c_s_t_i(curCrops(crops),plot,till,intens) $ intensCatchCro(intens),
                                                           v_cropHa(crops,plot,till,intens,t,nCur)
                                                               *  p_SimRes(till,crops,intens,"catCroShare")   )
                                           ;
```

The SIMPLACE results contain nitrate leaching for the different cropping activities. This externality is
summarized in the following equation for the environmental accounting in FarmDyn.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/simplace_module.gms GAMS /NleachSim_\(cu/ /;/)
```GAMS
NleachSim_(curCrops(crops),tCur(t),nCur)
                 $ ( t_n(t,nCur) $ sum ( (plot,till,intens), c_s_t_i(crops,plot,till,intens)) $ (not sameas (curCrops,"catchcrop") )  $ (not sameas (curCrops,"idle") )  ) ..


                 v_NleachSim(crops,t,nCur)

                       =e=

                          sum( c_s_t_i(curCrops,plot,curRotTill,intens),  v_cropHa(crops,plot,curRotTill,intens,t,nCur)
                                                                              * p_SimRes(curRotTill,crops,intens,"Nleach")  )  ;
```

Furthermore, the SIMPLACE results contain an N balance which is summarized in the following equation. Please note
that the calculation of this balance differs from the balance calculation under the Fertilization Ordinance.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/simplace_module.gms GAMS /NSurplusSim_\(cu/ /;/)
```GAMS
NSurplusSim_(curCrops(crops),tCur(t),nCur)
                    $ ( t_n(t,nCur) $ sum ( (plot,till,intens), c_s_t_i(crops,plot,till,intens))  $ (not sameas (curCrops,"catchcrop") ) $ (not sameas (curCrops,"idle") )  ) ..


                 v_NSurplusSim(crops,t,nCur)

                       =e=

                     sum(  c_s_t_i(curCrops,plot,curRotTill,intens),  v_cropHa(crops,plot,curRotTill,intens,t,nCur)
                                                                             * p_SimRes(curRotTill,crops,intens,"NSur") ) ;
```















[^4]: QIP solvers do not allow for equality conditions which are by
   definition non-convex

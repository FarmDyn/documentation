
# Environmental Accounting Module


!!! abstract
    The environmental accounting module *env\_acc\_module.gms* allows quantifying Ammonia (NH<sub>3</sub>), nitrous oxide (N<sub>2</sub>O), nitrogen oxides (NO<sub>x</sub>), elemental nitrogen (N<sub>2</sub>). For nitrogen (N) and phosphate (P), soil surface balances are calculated indicating potential nitrate leaching and phosphate losses. Environmental impacts are related to relevant farming operation.

## Gaseous emissions

All relevant calculations are listed in *model\\env\_acc\_module.gms.*
Emissions of NH<sub>3</sub>, N<sub>2</sub>O, NO<sub>x</sub> and N<sub>2</sub> are calculated, following
calculation schemes and emission factors from relevant guidelines (IPCC
2006, Rösemann et al. 2015, EMEP 2013). We apply a mass
balance approach to quantify different N emissions, subtracting emission
factors from different N pools along the nutrient flow of the farm.
Emissions factors are listed in *coeffgen\\env\_acc.gms*.

The sets *emissions* and *sources* contain relevant emissions and their
sources. The cross set *source\_emissions* links emissions to relevant
sources (Methane (CH<sub>4</sub>) is also included but still on the development
stage and therefore not described here).

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ_decl.gms GAMS /set\semissions/ /;/)
```GAMS
set emissions / NO3,NH3,N2O,NOx,N2,N2Oind,NSoilSurplus,PsoilSurplus,CH4 /;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ_decl.gms GAMS /set\ssource\s/ /;/)
```GAMS
set source / entFerm,staSto,past,manAppl,minAppl,field /    ;
```
[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ_decl.gms GAMS /set\ssource_/ /;/)
```GAMS
set source_emissions(source,emissions) /
                                           staSto.(NH3,N2O,NOx,N2,N2Oind,CH4)
                                           past.(NH3,N2O,NOx,N2,N2Oind)
                                           manAppl.(NH3,N2O,NOx,N2,N2Oind)
                                           minAppl.(NH3,N2O,NOx,N2,N2Oind)
                                           field.(NSoilSurplus,PsoilSurplus)
                                           entFerm.CH4
                                           / ;
```

All gaseous emissions are calculated in the equation *emissions\_* on a
monthly basis. By the use of *sameas* statements, only relevant sources
and emissions are activated in the corresponding part of the equation.

![](../media/image153.png)

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/env_acc_module.gms GAMS /v_emissions\(.*?curChain,s/ /=E=/)
```GAMS
v_emissions(curChain,source,emissions,t,nCur,m)

       =E=
```

Calculation of emissions from stable and manure storage.
[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/env_acc_module.gms GAMS /\$iftheni.h/ /\$endif.h/)
```GAMS
$iftheni.h %herd% == true

*     --- Calculation of NH3, N2O, NOx, N2, N2Oind from stable and storage (staSto)

      {
        $$iftheni.loss "%nutLossStorageTime%" == true
          sum(sameas(curManChain,curChain),   (v_nut2ManureM(curManChain,"NTAN",t,nCur,m)
                                              * p_EFSta("NH3")
                                              + v_nutPoolInStorage(curManChain,"NTAN",t,nCur,m)
                                              * p_EFSto("NH3"))) $ sameas(emissions,"NH3")
        $$else.loss
          sum(sameas(curManChain,curChain),   (v_nut2ManureM(curManChain,"NTAN",t,nCur,m)  $ (not sameas(curmanchain,"LiquidBiogas"))
                                              * (p_EFSta("NH3") + p_EFSto("NH3") * 12))) $( sameas(emissions,"NH3"))


        $$endif.loss

       + sum(sameas(curManChain,curChain),  v_nut2ManureM(curManChain,"NTAN",t,nCur,m)$ (not sameas(curmanChain,"LiquidBiogas"))
                                         +  v_nut2ManureM(curManChain,"NOrg",t,nCur,m)$ (not sameas(curmanChain,"LiquidBiogas"))
)

                                        * (   p_EFStaSto("N2O")    $ sameas(emissions,"N2O")
                                            + p_EFStaSto("NOx")    $ sameas(emissions,"NOx")
                                            + p_EFStaSto("N2")     $ sameas(emissions,"N2")
                                            + p_EFStaSto("N2Oind") $ sameas(emissions,"N2Oind")
                                          )
      }  $ sameas(source,"staSto")

$endif.h
```

Calculation of emissions from manure excreted on pasture (only relevant
for dairy).

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/env_acc_module.gms GAMS /\s\$iftheni.ch/ /\$endif.ch/)
```GAMS

$iftheni.ch %cattle% == true

     + {
           + sum(c_s_t_i(past,plot,till,intens),
                  v_nut2ManurePast(past,plot,till,intens,"NTAN",t,nCur,m))
                   * (  p_EFpasture("NH3")        $ sameas(emissions,"NH3")
                      + p_EFpasture("NH3") * 0.01 $ sameas(emissions,"NO2Ind")
                      )

           + sum(c_s_t_i(past,plot,till,intens),
                 (v_nut2ManurePast(past,plot,till,intens,"NTAN",t,nCur,m)
               +  v_nut2ManurePast(past,plot,till,intens,"Norg",t,nCur,m))

                   * (  p_EFpasture("N2O")        $ sameas(emissions,"N2O")
                      + p_EFpasture("NOx")        $ sameas(emissions,"Nox")
                      + p_EFpasture("NOx") * 0.01 $ sameas(emissions,"NO2Ind")
                      + p_EFpasture("N2")         $ sameas(emissions,"N2")
                     )
              )
     } $ sameas(source,"past")

$endif.ch
```


Calculation of emissions from manure application, application techniques
have different emission factors.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/env_acc_module.gms GAMS /\+\s\{\r\n\r/ /\}\s\$\ssameas\(source,"manAppl"\)/)
```GAMS
+ {

           sum( (c_s_t_i(curCrops(crops),plot,till,intens),manApplicType_manType(ManApplicType,curManType))
                          $ ( sum(sameas(curChain,curManChain) $ manChain_type(curManChain,curManType),1) $( not sameas (crops,"catchCrop"))   ),
             v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                     * sum(manChain,p_nut2inMan("NTAN",curManType,manChain))
                 * (1- p_nut2UsableShare(crops,curManType,manApplicType,"NTAN",m)))
                 * (   1    $ sameas(emissions,"NH3")
                     + 0.01 $ sameas(emissions,"NO2Ind"))

        +  sum((sameas(curManChain,curChain),nut2) $ (not sameas(nut2,"P")),
                   v_nut2ManApplied(curManChain,nut2,t,nCur,m)  * (  p_EFApplManN2O $ sameas(emissions,"N2O")
                                                                   + 0.012          $ sameas(emissions,"NOx")
                                                                   + 0.012 * 0.01   $ sameas(emissions,"NO2Ind")
                                                                   + 0.07           $ sameas(emissions,"N2")
                                                                  ))

      } $ sameas(source,"manAppl")
```


Calculation of emissions from mineral fertilizer application.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/env_acc_module.gms GAMS /\+\s\{\r\n\r/ /"minAppl"\)/)
```GAMS
+ {

           sum( (c_s_t_i(curCrops(crops),plot,till,intens),manApplicType_manType(ManApplicType,curManType))
                          $ ( sum(sameas(curChain,curManChain) $ manChain_type(curManChain,curManType),1) $( not sameas (crops,"catchCrop"))   ),
             v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                     * sum(manChain,p_nut2inMan("NTAN",curManType,manChain))
                 * (1- p_nut2UsableShare(crops,curManType,manApplicType,"NTAN",m)))
                 * (   1    $ sameas(emissions,"NH3")
                     + 0.01 $ sameas(emissions,"NO2Ind"))

        +  sum((sameas(curManChain,curChain),nut2) $ (not sameas(nut2,"P")),
                   v_nut2ManApplied(curManChain,nut2,t,nCur,m)  * (  p_EFApplManN2O $ sameas(emissions,"N2O")
                                                                   + 0.012          $ sameas(emissions,"NOx")
                                                                   + 0.012 * 0.01   $ sameas(emissions,"NO2Ind")
                                                                   + 0.07           $ sameas(emissions,"N2")
                                                                  ))

      } $ sameas(source,"manAppl")
$endif.h

*    --- Calculation of NH3, N2O, NOx, N2 and N2Oind from mineral fertilizer application
*        Based on R�semann et al. 2015, pp. 316-317

    + sum( (c_s_t_i(curCrops(crops),plot,till,intens),syntFertilizer),
                     v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)  * p_nutInSynt(syntFertilizer,"N")
                * (
                       0.037 $ sameas(emissions,"NH3")
                     + 0.01  $ sameas(emissions,"N2O")
                     + 0.012 $ sameas(emissions,"NOx")
                     + 0.07  $ sameas(emissions,"N2")
                     * (0.037 + 0.012) * 0.01  $ sameas(emissions,"N2Oind")
       )) $  sameas(source,"minAppl")
```
continue!

## N and P surplus

The losses of N, mainly as Nitrate to groundwater bodies, and P, mainly
via erosion and entry to surface waters, are most relevant environmental
threats of farming systems. Since it is highly depending on
environmental and geographical conditions, fixed emissions factors are
less commonly used than for gaseous losses. Therefore, we calculate N
and P surplus balances in the equation *SoilBal\_* as an indicator for
potential loss of N and P after field application. This part of the
environmental accounting will be replaced by results from crop models as
part as of an ongoing research project
(<http://www.ilr.uni-bonn.de/pe/research/project/pro/pro16_e.html>).

The balance is calculated as the difference between the nutrient input
via organic and mineral fertilizer and the removal of nutrients via the
harvested product.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/env_acc_module.gms GAMS /SoilBal_.*?\.\./ /;/)
```GAMS
SoilBal_(nut,t,nCur) $ (tCur(t) $ t_n(t,nCur)) ..

       v_soilbalance(nut,t,nCur)  =e=

$iftheni.h %herd% ==true

*          --- Calculation of manure applied minus losses from application

           sum( (c_s_t_i(curCrops(crops),plot,till,intens),manApplicType_manType(ManApplicType,curManType),m)
               $ ( (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0)
                   $( not sameas (crops,"catchCrop"))    ),

                  v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)

                * (    sum(manChain,p_nut2inMan("NORG",curManType,manChain)) $ sameas(nut,"N")
                    +  sum(manChain,p_nut2inMan("NTAN",curManType,manChain)) $ sameas(nut,"N")
                    +  sum(manChain,p_nut2inMan("P",curManType,manChain)) $ sameas(nut,"P")
                  ))

        -  sum( (curChain,NiEmissions(Emissions),m) $ chain_source(curChain,"manAppl"),
                       v_emissions(curChain,"manAppl",emissions,t,nCur,m) ) $ sameas(nut,"N")

$endif.h

*          --- Calculation of mineral N and P applied minus losses from application

         + sum( (c_s_t_i(curCrops(crops),plot,till,intens),syntFertilizer,m),
                  v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m) * p_nutInSynt(syntFertilizer,nut)   )

        - sum( (NiEmissions(Emissions),m), v_emissions("","minAppl",emissions,t,nCur,m) ) $ sameas(nut,"N")

*         --- Minus the removal of N and P by harvested product

        - sum ( (plot_soil(plot,soil),c_s_t_i(curCrops(crops),plot,till,intens)),
                 p_nutNeed(crops,soil,till,intens,nut,t) * v_cropHa(crops,plot,till,intens,t,nCur)   )

        + sum( (plot_soil(plot,soil),c_s_t_i(curCrops(crops),plot,till,intens)),
                 p_basNut(crops,soil,till,nut,t) *  v_cropHa(crops,plot,till,intens,t,nCur)  )
         ;
```

Note, that the calculated surplus differs from the surplus calculated
for the threshold under the fertilizer directive (see chapter 2.11.4).
For the environmental accounting, the estimated losses from storage,
stable etc. are modelled precisely whereas fixed, prescribed values are
used for the fertilizer directive.

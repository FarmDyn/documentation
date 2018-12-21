
# Environmental Accounting Module


!!! abstract
    The environmental accounting module utilizes commonly applied methodology as laid down in IPCC (2006), Haenel (2018) and EMEP (2013, 2016) for the quantification of methane (CH4), ammonia (NH3), nitrous dioxide (N2O), nitrogen oxides (NOx) and di nitrogen (N2). An extension of the scope of accounting to LCA methodology enables the consideration of emissions prior to on-farm activities such are the provision of major inputs (EcoInvent 2.X). Emissions are characterized at midpoint level using characterization factors from ReCiPe (2016). A soil surface balance is calculated for nitrogen (N) and (P) indicating N and P prone to loss through run off or leaching.

## Gaseous emissions

All calculations related to the environmental accounting are listed in *model\\env\_acc\_module.gms.* while the respective emission factors, characterization factors and other input data are specified in *coeffgen\\env\_acc.gms*. The calculation of emissions follows Haenel et al. (2018). An overview of the methodology, data and the respective (primary) sources used are presented in table XY.

| Source/Emission | Methodology applied | Emission factor | Revised EF |
|:--------------|:-------------|:--------------|
| CH4 enteric fermentation	| IPCC(2006)-10.30 f. tier 2+3	| Hanele et al. (2018) p.140, p.145, p.155, p.168, p.214, p.194, IPCC p.10.30	| Haenel et al. (2018), DAMMGEN et al. (2013), IPCC (2006)- 10.30, DAMMGEN et al. (2012C)|
| CH4 stable, storage and pasture	| Haenel et al. (2018) p. 42 No. 3.28 and 3.29 Following IPCC, 2006, eq. 10.23 |	Hanel et al. p.108 and p. 185. IPCC 2006 p.10.41	| DAMMGEN et al., (2012a), IPCC (2006)-|
| NH3 emissions from stable and storage |	EMEP (2016) |	Haenel 2018 p.108, p. 109, Haenel et al. (2018) p.186 p.187 |	DAMMGEN et al. (2010a), DAMMGEN et al. (2010b)|
| N2O, NOx, N2 emissions from stable and storage	| EMEP (2016), Haenel 2018 p. 53 |	Haenel 2018 p. 110, HAENEL et al. (2012), JARVIS & PAIN (1994), Haenel et al. 2015 pp. 188 |	IPCC (2006), DAMMGEN et al. (2010b)|
| NH3 from manure application |	EMEP (2016) |	Haenel et al. (2018), pp. 111-112, 189, 64	| DOHLER et al. (2002) |
|N2O, NOx, N2 emissions from manure application	| EMEP (2016), Haenel et al. 2018, pp. 316-317	| Haenel et al. (2018) p.326, Stehfest and Bouwman (2006) N2 Roesemann et al. 2015, pp. 316-317 | |
| NH3 from excreta from pasture	| EMEP (2016), Haenel et al. (2018) p.55 |	Haenel 2018 p.137/EMEP(2013): 3B , pp. 27 | |
| N2O, NOx, N2 emissions from excreta on pastures	| EMEP (2016), Haenel et al. (2018) p.55	| Haenel et al. (2018) p. 332; IPCC (2006) 11.11, table 11.1, Haenel et al. (2018) p. 332, STEHFEST UND BOUWMAN (2006) Roesemann et al. 2015, pp. 324 | |
| NH3, N2O, NOx, N2 emissions from mineral fertilizer application |	Haenel et al. 2018, pp. 316-317 |	Haenel et al. (2018) p.325, Haenel et al. (2018) p.326, Stehfest and Bouwman(2006) N2 Roesemann et al. 2015 | |
| Indirect N2O emissions from prior NOx, NH3 and NO3 emissions 	| IPCC (2006) |	IPCC(2006)-11.24, Table 11.3	| IPCC (2006) |
| CO2 emission from provision of inputs |		| Ecoinvent | |
| NO3-N leach	| Agroscope | | |
| P-loss	| Agroscope | | | |

The considered emissions are listed in the set *emissions*, the included sources in the set *sources*. The cross set *source\_emissions* links emissions to relevant sources. The set *emCat* lists midpoint emission categories according to ReCiPe (2016).


[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ_decl.gms GAMS /set\semissions/ /;/)
```GAMS
set emissions / NO3,NH3,N2O,NOx,N2,N2Oind,NSoilSurplus,PsoilSurplus,CH4,CO2 /;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ_decl.gms GAMS /set\ssource\s/ /;/)
```GAMS
set source / entFerm,staSto,past,manAppl,minAppl,field,input /    ;
```
[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ_decl.gms GAMS /set\ssource_/ /;/)
```GAMS
set source_emissions(source,emissions) /
                                           staSto.(NH3,N2O,NOx,N2,N2Oind,CH4)
                                           past.(NH3,N2O,NOx,N2,N2Oind,CH4)
                                           manAppl.(NH3,N2O,NOx,N2,N2Oind)
                                           minAppl.(NH3,N2O,NOx,N2,N2Oind)
                                           field.(NSoilSurplus,PsoilSurplus,NO3,N2Oind)
                                           entFerm.CH4
                                           input.CO2
                                           / ;
```
[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ_decl.gms GAMS /set\semCat/ /;/)
```GAMS
set emCat /GWP,PMFP,TAP,FEP,MEP/;
```
The actual calculation of the emissions is realized in the equation *emissions\_*. The timely resolution allows for reporting of emissions on a monthly basis. The different compartments of the equation represent the order of emission accounting by emissions and sources based on Haenel et al. (2018). By the use of conditional sameas statements only relevant emissions and sources are activated. The different compartments of the equation emissions are presented in the following in their order of appearance:

1.	Methane emissions from enteric fermentation

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/env_acc_module.gms GAMS /emissions_[\S\s][^;]*?\.\./ /"entFerm"\)  \)/)
```GAMS
emissions_(chain_source(curChain,source),emissions,t_n(t,nCur),m) $ (tCur(t) $ source_emissions(source,emissions) )  ..

     v_emissions(curChain,source,emissions,t,nCur,m)

       =E=

*     --- Calculation of CH4 emissions from enteric fermentation linked to gross energy intake (IPCC, 2006, eq. 10.21)
*         in kg CH4 per month (yearly emissions averaged for monthly reporting),

$iftheni.h %herd% == true
        + [  (
   $$iftheni.ch %cattle% == true
              +  sum((feeds,dcows,n),
                         p_feedContFMton(feeds,"GE") * v_feedUseHerds(dcows,feeds,t,n) * p_Ym("dcows"))

             +  sum((feeds,mcows,n),
                         p_feedContFMton(feeds,"GE") * v_feedUseHerds(mcows,feeds,t,n) * p_Ym("mcows"))

             +  sum((feeds,heifs,n),
                         p_feedContFMton(feeds,"GE") * v_feedUseHerds(heifs,feeds,t,n) * p_Ym("heifs"))

             +  sum((feeds,bulls,n),
                         p_feedContFMton(feeds,"GE") * v_feedUseHerds(bulls,feeds,t,n) * p_Ym("bulls"))

             +  sum((feeds,calvs,n),
                         p_feedContFMton(feeds,"GE") * v_feedUseHerds(calvs,feeds,t,n) * p_Ym("calvs"))
   $$endif.ch
   $$iftheni.fat "%farmBranchfattners%" == "on"
                   +  sum((actHerds(fatHerd,breeds,feedRegime,t,m)),
                              p_feedReqPig(fatHerd,feedRegime,"energ")*1000 * v_herdsize(fatHerd,breeds,feedRegime,t,nCur,m) * p_YM("fatHerd"))
   $$endif.fat
   $$iftheni.sows "%farmBranchSows%" == "on"
                    +  sum((actHerds(sows,breeds,feedRegime,t,m)),
                              p_feedReqPig(sows,feedRegime,"energ")*1000   * v_herdsize(sows,breeds,feedRegime,t,nCur,m) * p_YM("sows"))
   $$endif.sows
                    )/(100 * 55.65)      * 1/card(herdM)

        ]   $ ( sameas(emissions,"CH4") $ sameas(source,"entFerm")  )
```

2.	Methane emissions from stable and storage

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/env_acc_module.gms GAMS /\*.*?CH4 from manure/ /"staSto"\)  \)/)
```GAMS
*  CH4 from manure storage:

        + [  sum( (curManChain,manStorage),   v_volInStorageType(curManChain,manStorage,t,nCur,m)
                      *  1000 * p_avDmMan(curManChain) * p_oTSMan(curManChain) * p_BO(curManChain)
                      * p_densM * p_MCF(Manstorage,curManChain)
                      /12)
          ] $ ( sameas(emissions,"CH4") $ sameas(source,"staSto")  )
```

3.	Methane emissions from excreta on pastures

N-emissions are calculated using a mass-flow approach starting with the N excretion by farm animals. Three N-pools are considered, N-TAN, N-Org and total N. The correction of the N pools by previous losses are not part of the *env\_acc module* but are considered in the *manure\_module*.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/env_acc_module.gms GAMS /\*.*?Pasture:/ /"past"\)  \)/)
```GAMS
*   Pasture:

  $$iftheni.ch %cattle% == true

       + [  sum(curManChain,   v_manQuantPast(curManChain,t,nCur,m)
                    *  1000 * p_avDmMan(curManchain) * p_oTSMan(curManChain) * p_BO(curManchain)
                    * p_densM * p_MCFPast
                    )
         ] $ ( sameas(emissions,"CH4") $ sameas(source,"past")  )
```

4.	Ammonia emissions from stable and storage

xx

5.  N2O, NOx, N2, N2Oind from stable and storage

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/env_acc_module.gms GAMS /\*.*?\(staSto\)/ /,"staSto"\)/)
```GAMS
*     --- Calculation of NH3, N2O, NOx, N2, N2Oind from stable and storage (staSto)

  +    [
        $$iftheni.loss "%nutLossStorageTime%" == true
          sum(sameas(curManChain,curChain),   (v_nut2ManureM(curManChain,"NTAN",t,nCur,m)
                                              * p_EFSta("NH3")
                                              + v_nutPoolInStorage(curManChain,"NTAN",t,nCur,m)
                                              * p_EFSto("NH3"))) $ sameas(emissions,"NH3")
        $$else.loss
          sum(sameas(curManChain,curChain),   (v_nut2ManureM(curManChain,"NTAN",t,nCur,m)  $ (not sameas(curmanchain,"LiquidBiogas"))
                                              * (p_EFSta("NH3") + p_EFSto("NH3") * 12))) $( sameas(emissions,"NH3"))


        $$endif.loss

        + sum(sameas(curManChain,curChain),  (v_nut2ManureM(curManChain,"NTAN",t,nCur,m)$ (not sameas(curmanchain,"LiquidBiogas"))
                                          +  v_nut2ManureM(curManChain,"NOrg",t,nCur,m)$ (not sameas(curmanchain,"LiquidBiogas")))
                                          *  ( p_EFStaSto("N2O",curManChain)    $ sameas(emissions,"N2O")
                                             + p_EFStaSto("NOx",curManChain)    $ sameas(emissions,"NOx")
                                             + p_EFStaSto("N2",curManChain)     $ sameas(emissions,"N2")
                                             ))

        + (sum(sameas(curManChain,curChain) , v_emissions(curChain,"stasto","NH3",t,nCur,m)
                                            + v_emissions(curChain,"stasto","NOx",t,nCur,m))
                                          * p_EFN2Oind ) $ sameas(emissions,"N2Oind")

      ]  $ sameas(source,"staSto")
```

6.	Calculation of NH3, N2O, NO and N2 losses from manure excretion on pasture for cattle

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/env_acc_module.gms GAMS /\*.*?NH3.*?from\smanure\sexc/ /\(emissions,\"N2\"/)
```GAMS
*     --- Calculation of NH3, N2O, NO and N2 losses from manure excretion on pasture for cattle according to Haenel et al. (2018) p.55
*         in kg NH3-N, N2O-N, NO-N and N2 per month

$$iftheni.ch %cattle% == true
     + [
           + sum(c_s_t_i(past,plot,till,intens),
                  v_nut2ManurePast(past,plot,till,intens,"NTAN",t,nCur,m)
                   * (  p_EFpasture("NH3")       $ sameas(emissions,"NH3")  ))

           + sum(c_s_t_i(past,plot,till,intens),
                 (v_nut2ManurePast(past,plot,till,intens,"NTAN",t,nCur,m)
               +  v_nut2ManurePast(past,plot,till,intens,"Norg",t,nCur,m))
                   * (  p_EFpasture("N2O")        $ sameas(emissions,"N2O")
                      + p_EFpasture("NOx")        $ sameas(emissions,"NOx")
                      + p_EFpasture("N2")         $ sameas(emissions,"N2"
```

7.	Calculation of NH3, N2O, NOx, N2 from manure application

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/env_acc_module.gms GAMS /\*.*?from\smanure\sappl/ /"manAppl"\)/)
```GAMS
*     --- Calculation of NH3, N2O, NOx, N2 from manure application
*         NH3 losses depending on technology, source EMEP (2016)
*         in kg NH3-N, N2O-N, NO-N and N2 per month

    + [   sum( (c_s_t_i(curCrops(crops),plot,till,intens),manApplicType_manType(ManApplicType,curManType))
                          $ ( sum(sameas(curChain,curManChain) $ manChain_type(curManChain,curManType),1) $( not sameas (crops,"catchCrop"))),
             v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                     * sum(manChain,p_nut2inMan("NTAN",curManType,manChain))
                 * (1- p_nut2UsableShare(crops,curManType,manApplicType,"NTAN",m))) $ sameas(emissions,"NH3")

        + sum((sameas(curManChain,curChain),nut2) $ (not sameas(nut2,"P")),
                   v_nut2ManApplied(curManChain,nut2,t,nCur,m)  * (  p_EFApplMin("N2O") $ sameas(emissions,"N2O")
                                                                   + p_EFApplMin("NOx") $ sameas(emissions,"NOx")
                                                                   + p_EFApplMin("N2")  $ sameas(emissions,"N2")))


        + (sum(sameas(curManChain,curChain) ,  v_emissions(curChain,"manAppl","NH3",t,nCur,m)
                                             + v_emissions(curChain,"manAppl","NOx",t,nCur,m))
                              * p_EFN2Oind ) $ sameas(emissions,"N2Oind")

      ] $ sameas(source,"manAppl")
```

8.	Calculation of NH3, N2O, NOx, N2 from mineral fertilizer application

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/env_acc_module.gms GAMS /\*.*?from\smineral\sfer/ /"minAppl"\)/)
```GAMS
*    --- Calculation of NH3, N2O, NOx, N2 from mineral fertilizer application
*        Based on Haenel et al. 2018, pp. 316-317
*         in kg NH3-N, N2O-N, NO-N and N2 per month

    + [sum( (c_s_t_i(curCrops(crops),plot,till,intens),syntFertilizer),
                     v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)  * p_nutInSynt(syntFertilizer,"N")
                * (    p_EFApplMinNH3(syntFertilizer) $ sameas(emissions,"NH3")
                     + p_EFApplMin("N2O") $ sameas(emissions,"N2O")
                     + p_EFApplMin("NOx") $ sameas(emissions,"NOx")
                     + p_EFApplMin("N2")  $ sameas(emissions,"N2")))

            + (( v_emissions(" ","minAppl","NH3",t,nCur,m) + v_emissions(" ","minAppl","NOx",t,nCur,m))
                          * p_EFN2Oind ) $ sameas(emissions,"N2Oind")
      ] $  sameas(source,"minAppl")
```

9.	Calculation of CO2 emissions from bought inputs

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/env_acc_module.gms GAMS /\\*.*?Calculation of yearly CO2/ /"input"\)\)/)
```GAMS
* --- Calculation of yearly CO2 emissions from bought inputs in kg CO2eq per month devided by 12 for monthly resolution

   +  [ sum((inputs,sys),
                     v_buy(inputs,sys,t,nCur)  *  p_EFInput(inputs,emissions)/12)
      ] $ ( sameas (emissions,"CO2") $ sameas (source,"input"))
```


To ease the calculation of the emissions along the N mass flow N-emissions are calculated according to their N-weight. The equation *emissionsMass\_* converts the weight into the actual mass of the molecule as a preliminary step for further calculations, chracterizations and weightings.

The equation *emissionsCat* relates the emissions to midpoint categories using characterization factors from ReCiPe (2016). The emissions in the respective category are then summed over the manure chains, sources and month to gain an emission profile for the whole farm.



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

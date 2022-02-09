# Investments and Financing

> **_Abstract_**  
Investment decisions in machinery, stables and structures (silos, biogas plants, storage) are depicted as binary variables with a yearly resolution. Physical depreciation can be based on lifetime or use. Machinery use can alternatively be re-invested continuously rendering the investment costs variable based on a Euro per hectare threshold. Investments can be financed out of (accumulated) cash flow or by credits of different length and related interest rates. For stables and biogas plants, maintenance investments are reflected as well.


## General Investments in Comparative-Static Mode

This section describes the investment procedures for all types of investment in FarmDyn. Calculation of investments and related fixed costs differentiate between the chosen model dynamic. The types of investment include, inter alia, stables, buildings, machinery, and manure silos. In a comparative-static mode, the investment costs are given as the yearly depreciation costs (exl. interest). For buildings in general, the yearly depreciation costs are realised by dividing the original price (e.g. <i>p_priceStables</i>, <i>p_priceMach</i>, <i>p_priceSilo</i>) by the lifetime. In the case of machinery, the calculated depreciation differs from machinery to machinery and is either determined by hectare, lifetime, or other metrics such as cubic metre.  

The equation <i>costInv_</i> captures all investment/ buying decision on-farm given by the variables <i><b>v_buy</b>Mach/Stables/Silos/etc</b></i> and their related costs.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/templ.gms GAMS /\*   --- costs of different types of investment/ /;/)
```GAMS
*   --- costs of different types of investment (different stables, buildings, machinery, manure silos)v_
*
    costInv_(inv,t_n(tCur(t),nCur)) $ curInv(inv) ..

      v_costInv(inv,t,nCur) =E=

         $$ifthen.stables "%herd%"=="true"
*
*        --- new stables bought
*
            sum( (stables,hor) $ ((v_buyStables.up(stables,hor,t,nCur) ne 0) and (v_hasFarm.up(t,nCur) ne 0) and sameas(inv,stables)),
               v_buyStablesF(stables,hor,t,nCur)*p_priceStables(stables,hor,t)*p_vPriceInv("stables"))

          + sum( (stableTypes,hor) $ ((v_minInvStables.up(stableTypes,hor,t,nCur) ne 0) and (v_hasFarm.up(t,nCur) ne 0) and sameas(inv,stableTypes)),
                v_minInvStables(stableTypes,hor,t,nCur) * p_minInvStableCost(stableTypes,hor,t))

         $$endif.stables
*
*      --- buildings and structures
*
      + sum(curBuildings(buildings) $ sameas(inv,buildings), p_priceBuild(buildings,t) * p_vPriceInv("buildings") *
                                         v_buyBuildingsF(buildings,t,nCur))
*
*       --- new machinery bought (integer and continous depreciation solution)
*
    +   sum(curMachines(machType) $ sameas(machType,inv),
                   (v_buyMach(machType,t,nCur)+v_buyMachFlex(machType,t,nCur))*p_priceMach(machType,t)*p_vPriceInv("machines"))
*
*        --- new manure silos bought
*
       $$ifthen.silos defined v_buySilos.up
          + sum( (curManChain(manChain),silos) $ ((v_hasFarm.up(t,nCur) ne 0) $ sameas(silos,inv)),
                 v_buySilosF(manChain,silos,t,nCur)*p_priceSilo(silos,t)*p_vPriceInv("silos"))
       $$endif.silos
;
```

 As can be seen in the equation <i>costInv_</i> all buildings have a buying decision name ending with an <i>F</i> as <i>v_buyStables<b>F</b></i>.
<i>F</i> refers to being a fractional number and not a binary variable one would assume in a buying decision. The fractional character of the variables stems from the fact that FarmDyn interpolates between two different size classes of a building on a concave curve with multiple size classes to return a fitting size class for a given desired size. An example: A farmer wants to build a stable with 80 stable places. However, literature only provides information on costs, labour needs, etc. for stables with 50 an 100 places. To provide the farmer with the option to have more than 50 but less than 100 stable places, FarmDyn interpolates between the two size classes on a concave set determined by multiple size classes which are taken from literature. This is shown in the following equation:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/general_herd_module.gms GAMS /\*   --- only two types of stables can be bought for each type of herd\,/ /;/)
```GAMS
*   --- only two types of stables can be bought for each type of herd,
*       in between two points of the concave curve
*
    stableConvexComb_(stableTypes,hor,t_n(tFull,nCur)) $ sum(stableTypes_to_stables(stableTypes,stables)
                                                          $ (v_buyStables.up(stables,hor,tFull,nCur) ne 0),1) ..

         sum(stableTypes_to_stables(stableTypes,stables) $ (v_buyStables.up(stables,hor,tFull,nCur) ne 0),
                                                                  v_buyStablesF(stables,hor,tFull,nCur)) =E= 1;
```

These fractional stables are further restricted by the then binary buying decision of stables <i>v_buyStables</i>, as seen in the following equation.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/general_herd_module.gms GAMS /\*   --- restrict choice for convex combination to the two points implicitly defined above/ /;/)
```GAMS
*   --- restrict choice for convex combination to the two points implicitly defined above
*
    stableBin_(stables,hor,t_n(tFull,nCur)) $ ((v_buyStablesF.up(stables,hor,tFull,nCur) ne 0) $ (v_hasFarm.up(tFull,nCur) ne 0)) ..

         v_buyStablesF(stables,hor,tFull,nCur) =L= v_buyStables(stables,hor,tFull,nCur);
```

Eventually, all investment costs from on-farm buying decision combined with land acquisition and biogas is summed up in the equation <i>sumInv_</i>.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/templ.gms GAMS /sumInv\_\(t\_n\(tFull\(t\),nCur\)\)/ /;/)
```GAMS
sumInv_(t_n(tFull(t),nCur)) ..
*
       v_sumInv(t,nCur) =e=
*
*        --- new land bought
*
$ifi %landBuy% == true  sum( plot, v_buyPlot(plot,t,nCur)*p_buyPlotSize*p_pland(plot,t)) $ tCur(t)
*
*        --- stables, silos, buildings and machines
*
       + sum(inv $ curInv(inv), v_costinv(inv,t,nCur)) $ tCur(t)
*
*        --- new biogas plant bought
*
$iftheni %biogas%==true

                  + sum((curBhkw(bhkw), curEeg(eeg)),
                        v_buyBioGasPlant(bhkw,eeg,"ih20",t,nCur) $tCur(t)
                                                * p_priceBioGasPlant(bhkw,"ih20"))

                  + sum((curBhkw(bhkw), ih),
                        v_buyBioGasPlantParts(bhkw,ih,t,nCur)
                                                * ( p_priceBioGasPlant(bhkw,ih) $ (not(ih20(ih)))
*                                                 + p_priceFlexBioGasPlant(bhkw,eeg,ih)$eegDM(eeg) )
                                                  ))
$endif
       ;
```


## Investments in Fully Dynamic Mode

The investments in fully dynamic differ from those in comparative static, especially in their financing. Whereas the comparative-static mode assumes yearly depreciation costs, in the fully dynamic mode the model also accounts for available liquidity and equity as well as for the need of credits to make investments.

To facilitate the understanding of the structure in the financing of investments in fully dynamic, we start by looking at the equation <i>Liquid_</i>. The equation returns the given liquidity <i>v_liquid</i> in a certain year given the liquidity of last year plus the net cashflow in a given year <i>v_netCashFlow</i>.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/templ.gms GAMS /Liquid_\(tFull\(t.*?\.\./ /;/)
```GAMS
Liquid_(tFull(t),nCur) $ t_n(t,nCur) ..
*
       v_liquid(t,nCur) =e=
*
*      --- last years liquidity
*
          + sum(t_n(t-1,nCur1) $ anc(nCur,nCur1), v_liquid(t-1,nCur1))
*
*      --- total cash flow of the agricultural enterprise
*
          + v_netCashFlow(t,nCur)
        ;
```

The available funds to make an investment are then given by the already presented equation <i>netCashFlow_</i> (section <i>Household income and cash flow</i>). To cover the expenses of investment cash flows, <i>v_InvCashFlow</i>, there has to be some kind of financing for this part which is not covered by the available liquidity from <i>v_liquid</i>. This is given by the variable <i>v_finCashFlow</i>.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/templ.gms GAMS /netCashFlow\_\(t\_n\(tFull\(t\),nCur\)\)/ /;/)
```GAMS
netCashFlow_(t_n(tFull(t),nCur))  ..
*
       v_netCashFlow(t,nCur) =e=
*
*       --- financial cash flows (including household withdrawals) in rec-dyn version
*
$ifi not "%dynamics%"=="comparative-static"            + v_finCashFlow(t,nCur)
*
*       --- household withdrawals as sole financial cash flow in comp-stat version
*
$ifi     "%dynamics%"=="comparative-static"            - v_withDraw(t,nCur)
*
*       --- investment cash flows
*
        + v_InvCashFlow(t,nCur) $ sum(branches,v_hasBranch.up(branches,t,nCur))
*
*       --- operational cash flow
*
        +  v_opCashFlow(t,nCur)
     ;
```

The variable <i>v_finCashFlow</i> is then the part which covers the credit options of a farmer. It captures the re-payment on past credits including repayment itself and the interest and new credits taken up in a certain year to pay for new investments. In contrast to the comparative-static part of FarmDyn, the withdraw from household members are included in the financial cash flow. A further detailed description on differences between credit options follows next.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/fin_cashflow.gms GAMS /\*   --- financial cash flow in current period/ /;/)
```GAMS
*   --- financial cash flow in current period
*
    finCashFlow_(t_n(tFull(t),nCur)) ..

       v_finCashFlow(t,nCur) =E=
*
*       --- re-payments on past credits
*
         - sum((creditType,t1,nCur1) $ ( (    ((p_year(t1)    + p_payBackTime(creditType))  ge p_year(t))
                                          $   ( p_year(t1)+1                                le p_year(t)))
                                           $ tFull(t1)  $ isNodeBefore(nCur,nCur1) $ t_n(t1,nCur1)  ),
                                                v_credits(creditType,t1,nCur1) * 1/p_payBackTime(creditType))
*
*       --- new credits
*
         + sum(creditType, v_credits(creditType,t,nCur)) $ (p_year(t) lt p_year("%lastYear%"))
*
*      -- profit withdrawals by households
*
          - v_withDraw(t,nCur)
     ;
```

The model differentiates credits by repayment period, <i>p_payBackTime</i>, and interest rate. Credits are paid back in equal instalments over the repayment period, hence, annuities decrease over time. The amount of outstanding credits is defined by the following equation:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/fin_cashFlow.gms GAMS /credSum_.*?\.\./ /;/)
```GAMS
credSum_(creditType,tFull(t),nCur) $ (t_n(t,nCur) $ (v_sumCredits.up(creditType,t,nCur) ne 0))    ..
*
       v_sumCredits(creditType,t,nCur) =e=
*
            sum( t_n(t1,nCur1) $ (  (((p_year(t1)  + p_payBackTime(creditType))  ge p_year(t))
                            $     ( p_year(t1)                                  le p_year(t)))
                            $ tCur(t1) $ isNodeBefore(nCur,nCur1)),
                                    v_credits(creditType,t1,nCur1)
                                    * (1-1/p_payBackTime(creditType) * (p_year(t)-p_year(t1))));
```


In fully dynamic mode, the model also accounts for revenues from liquidation of investments. However, these are only assumed to take place in the last year of the simulation:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/fin_cashFlow.gms GAMS /liquidation_.*?\.\./ /;/)
```GAMS
liquidation_(nCur) $ t_n("%lastYearCalc%",nCur) ..

       v_liquidation(nCur) =e=
*
*           --- assume that past credits
*               are paid back fully in the last year (to prevent over-investments)
*
            - sum(creditType, v_sumCredits(creditType,"%lastYearCalc%",nCur))
*
*            --- sell machinery (assumption for resell avalue: non-depreciated stock
*                according to time or load, minus 33%)
*
             + [  sum( curMachines(machType) $ sum(machLifeUnit,p_lifeTimeM(machType,machLifeUnit)),
                      sum(machLifeUnit $ p_lifeTimeM(machType,machLifeUnit),
                         v_machInv(machType,machLifeUnit,"%lastYearCalc%",nCur)
                                                /p_lifeTimeM(machType,machLifeUnit)
                            * p_priceMach(machType,"%lastYearCalc%") * 2/3)
                / sum(machLifeUnit $ p_lifeTimeM(machType,machLifeUnit), 1)) ] $ card(curMachines) $ p_liquid
*
*            --- sell land (transaction costs set to 4 times the yearly land rent)
*                (only in case land can be bought or sold - eases the interpretation of the average objective value in each year)
*
$iftheni.lb %landBuy% == true
               + sum( plot, v_totPlotLand(plot,"%lastYear%",nCur)
                            * ( p_pland(plot,"%lastYear%") - 4 * p_landRent(plot,"%lastYear%")))  $ p_liquid
$endif.lb
$iftheni.dh %cowherd%==true
*
*              -- cows go for slaughter
*
             + sum( actHerds(cows,curBreeds,feedRegime,"%lastYear%","dec"),
                       v_herdSize(cows,curBreeds,feedRegime,"%lastYear%",nCur,"dec")
                          * p_OCoeff(cows,"oldCow",curBreeds,"%lastYear%") * p_price("oldCow","conv","%lastYearCalc%")) $ p_liquid
*
*              -- heifers at 30% of value of a young cow
*
             + sum( actHerds(heifs,curBreeds,feedRegime,"%lastYear%","dec"),
                       v_herdSize(heifs,curBreeds,feedRegime,"%lastYear%",nCur,"dec")
                                * p_price("youngCow","conv","%lastYearCalc%") * 0.3 ) $ p_liquid
*
*              -- raising cavles at 10% of value of a young cow
*
             + sum( actHerds("fCalvsRais",curBreeds,feedRegime,"%lastYear%","dec"),
                       v_herdSize("fCalvsRais",curBreeds,feedRegime,"%lastYear%",nCur,"dec")
                                * p_price("youngCow","conv","%lastYearCalc%") * 0.1 ) $ p_liquid
$endif.dh
       ;
```

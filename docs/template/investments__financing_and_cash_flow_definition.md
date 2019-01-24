
# Investments, Financing and Cash Flow Definition

!!! abstract
    The investment module depicts investment decisions in machinery, stables and structures (silos, biogas plants, storage) as binary variables with a yearly resolution. Physical depreciation can be based on lifetime or use. Machinery use can be alternatively depicted as continuous re-investment rendering investment costs variable, based on a Euro per ha threshold. Investment can be financed out of (accumulated) cash flow or by credits of different length and related interest rates. For stables and biogas plants maintenance investment are reflected as well.

The total investment sum *v\_sumInv* in each year is defined by:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /invSum_\(tFull.*?\.\./ /;/)
```GAMS
invSum_(tFull(t),nCur) $ t_n(t,nCur)   ..
*
       v_sumInv(t,nCur) =e=
*
*        --- new land bought
*
$ifi %landBuy% == true  sum( plot, v_buyPlot(plot,t,nCur)*p_pland(plot,t)) $ tCur(t)
*
*        --- new stables bought
*
$ifi %herd%==true +   sum( (stables,hor), v_buyStables(stables,hor,t,nCur)*p_priceStables(stables,hor,t))
*
*        --- buildings and structures
*
           + sum(curBuildings(buildings), v_buyBuildings(buildings,t,nCur) * p_priceBuild(buildings,t))
*
*        --- new machinery bought (integer and continous depreciation solutinN
*
           +   sum(curMachines(machType),
                   (v_buyMach(machType,t,nCur)+v_buyMachFlex(machType,t,nCur))*p_priceMach(machType,t))
*
*        --- new manure silos bought
*
$ifi %herd%==true + sum( (curManChain(manChain),silos), v_buySilos(manChain,silos,t,nCur)*p_priceSilo(silos,t))

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

Investments can be financed either by equity or by credits, and enters
accordingly the cash balance definition, *v\_liquid*. The cash balance
represents the cash at the end of the forgone year plus the net cash flow,
*v\_netCashFlow*, in the current year plus new credits, *v\_credits*,
minus fixed household expenditures, *p\_hcon*, and new investments,
*v\_sumInv*:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /Liquid_\(tFull\(t.*?\.\./ /;/)
```GAMS
Liquid_(tFull(t),nCur) $ t_n(t,nCur) ..
*
       v_liquid(t,nCur) =e=
*
*      --- last years liquidity
*
          + sum(t_n(t-1,nCur1) $ anc(nCur,nCur1), v_liquid(t-1,nCur1))
*
*      --- total cash flow
*
          + v_netCashFlow(t,nCur)
       ;
```

The model differentiates credits by repayment period, *p\_payBackTime*,
and interest rate. Credits are paid back in equal instalments over the
repayment period, hence, annuities decrease over time. The amount of
outstanding credits is defined by the following equation:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /credSum_.*?\.\./ /;/)
```GAMS
credSum_(creditType,tFull(t),nCur) $ t_n(t,nCur)     ..
*
       v_sumCredits(creditType,t,nCur) =e=
*
            sum( t_n(t1,nCur1) $ (  (((p_year(t1)  + p_payBackTime(creditType))  ge p_year(t))
                            $     ( p_year(t1)                                  le p_year(t)))
                            $ tCur(t1) $ isNodeBefore(nCur,nCur1)),
                                    v_credits(creditType,t1,nCur1)
                                    * (1-1/p_payBackTime(creditType) * (p_year(t)-p_year(t1))));
```

The net cash flow is defined as the sum of the gross margins, *v\_objeTS* plus received interest and revenue from liquidation (selling equipment or land) minus storing costs for manure, interest paid on outstanding credits and repayment of credits:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /netCashFlow_.*?\.\./ /;/)
```GAMS
netCashFlow_(tFull(t),nCur) $ t_n(t,nCur)  ..
*
       v_netCashFlow(t,nCur) =e=
*
*       --- financial and investment link cash flows
*
        + v_finCashFlow(t,nCur)
        + v_InvCashFlow(t,nCur)
*
*       --- operation cash flow
*
        +  v_opCashFlow(t,nCur)
     ;
```

Revenues from liquidation are only assumed to take place in the last
year (of the simulation):

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /liquidation_.*?\.\./ /;/)
```GAMS
liquidation_(nCur) $ t_n("%lastYearCalc%",nCur) ..

       v_liquidation(nCur) =e=
*
*           --- assume that past credits
*              are paid back in the last year (to prevent over-investments)
*
            - sum(creditType, v_sumCredits(creditType,"%lastYearCalc%",nCur))
*
*            --- liquidity at the end of the simulation horizon
*
*
*            --- sell machinery (assumption: linear according to
*                operation time minus 33%)
*
             + [  sum( (curMachines(machType),machLifeUnit) $ p_lifeTimeM(machType,machLifeUnit),
                         v_machInv(machType,machLifeUnit,"%lastYearCalc%",nCur)
                                                /p_lifeTimeM(machType,machLifeUnit)
                            * p_priceMach(machType,"%lastYearCalc%") * 2/3)
                / sum( (curMachines(machType),machLifeUnit)
                                $ p_lifeTimeM(machType,machLifeUnit), 1) ] $ card(curMachines) $ p_liquid
*
*            --- sell land (transaction costs set to 4 times the yearly land rent)
*                (only in case land can be bought or sold - eases the interpreation of the average objective value in each year)
*
$iftheni.lb %landBuy% == true
               + sum( plot, v_totPlotLand(plot,"%lastYear%",nCur)
                            * ( p_pland(plot,"%lastYear%") - 4 * p_landRent(plot,"%lastYear%")))  $ p_liquid
$endif.lb
$iftheni.dh %cowherd%==true
*
*            --- sell cows, heifers, calves for raising in last year
*

*
*              -- cows at 60% of value of a young cow
*
             + sum( actHerds("cows",curBreeds,feedRegime,"%lastYear%",herdm),
                       sum(m_to_herdm("dec",herdm), v_herdSize("cows",curBreeds,feedRegime,"%lastYear%",nCur,herdm))
                                * p_price("youngCow","conv","%lastYearCalc%") * 0.6 ) $ p_liquid
*
*              -- heifers at 30% of value of a young cow
*
             + sum( actHerds("heifs",curBreeds,feedRegime,"%lastYear%",herdm),
                       sum(m_to_herdm("dec",herdm), v_herdSize("heifs",curBreeds,feedRegime,"%lastYear%",nCur,herdm))
                                * p_price("youngCow","conv","%lastYearCalc%") * 0.3 ) $ p_liquid
*
*              -- raising cavles at 10% of value of a young cow
*
             + sum( actHerds("fCalvsRais",curBreeds,feedRegime,"%lastYear%",herdm),
                       sum(m_to_herdm("dec",herdm), v_herdSize("fCalvsRais",curBreeds,feedRegime,"%lastYear%",nCur,herdm))
                                * p_price("youngCow","conv","%lastYearCalc%") * 0.1 ) $ p_liquid
$endif.dh
       ;
```

Liquidation is active if the model runs in fully dynamic mode and not in
comparative static and short run mode.

The gross margin for each year is defined as revenues from
sales, *v\_salRev*, income from renting out land, *v\_rentOutLand*, and
salary from working off-farm minus variable costs. The latter relate to
costs of buying intermediate inputs such as fertiliser, feed or young
animals comprised in the equations structure of the model template,
*v\_buyCost*, and other variable costs, *v\_varCosts*. For off-farm work
(full-and half-time, v*\_workOff*) the weekly work time in hours,
*p\_weekTime*, is given. In addition, it is assumed that off-farm work
covers 46 weeks each year, so that income is defined from
multiplying these two terms with hourly wage, *p\_wage*.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/EMV.gms GAMS /objeTS_\(.*?\.\./ /;/)
```GAMS
objeTS_(t,s)    ..  v_objeTS(t,s)
                              =e=   sum(c,  v_cropHa(c,t,s) * p_cropGrossMarg(c,t,s))
                                  + v_salRev(t,s);
```

The sales revenues, *v\_salRev*, that enter the equation above are
defined from net production quantities, *v\_prods*, and given prices in
each year and SON, *p\_price*:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /salRev_\(.*?\.\./ /;/)
```GAMS
salRev_(tCur(t),nCur) $ t_n(t,nCur)    ..
*
       v_salRev(t,nCur)  =e= sum(  (curProds(prodsYearly),sys) $ (v_saleQuant.up(prodsYearly,sys,t,nCur) ne 0),
                                  p_price(prodsYearly,sys,t)
$iftheni.sp "%stochProg%"=="true"
*
*     --- a product is both output and input, use price of inputs to avoid a situation
*           where the product can be bought cheaper than it is sold
*
      * ( 1 + (p_randVar("priceOutputs",nCur)-1) $ (randProbs(prodsYearly) and (not sum(sameas(prodsYearly,inputs),1)))
            + (p_randVar("priceInputs",nCur)-1)  $ (randProbs(prodsYearly) and (    sum(sameas(prodsYearly,inputs),1)))
         )
$endif.sp
                                   *  v_saleQuant(prodsYearly,sys,t,nCur));
```

The sale quantity, *v\_saleQuant*, plus feed use, *v\_feedUse*, must
exhaust the production quantity, *v\_prods*:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /saleQuant_\(.*?\.\./ /;/)
```GAMS
saleQuant_(curProds(prodsYearly),tCur(t),nCur) $ (sum(sys,p_price(prodsYearly,sys,t)) $ t_n(t,nCur)) ..

       sum(sys $ p_price(prodsYearly,sys,t),v_saleQuant(prodsYearly,sys,t,nCur))

$iftheni.dh %cattle%==true

       + sum( sameas(prodsYearly,feedsY), v_feedUseProds(feedsY,t,nCur))


$endif.dh
*
$iftheni %biogas%==true
       +  sum( sameas(prodsYearly,crM),
                     sum( (curBhkw(bhkw),curEeg(eeg),m),
                             v_feedBiogas(bhkw,eeg,crM,t,nCur,m) ) )


$endif
$iftheni.p %pigherd%==true
       +  sum(sameas(prodsYearly,feedsPig),
                             v_feedOwnPig(feedspig,t,nCur))
$endif.p
         =L= v_prods(prodsYearly,t,nCur)



*
*        --- buying of products which are also produced on farm
*            (silage, cereals)
*
*         + sum(sameas(prodsYearly,curinputs(inputs)) $ p_inputprice(inputs,t) ,
*              v_buy(inputs,t,nCur))
;
```

The production quantities are derived by summing the production
quantities of animal and crop production. Additionally, for milk
quantities reduction of yield for specific cows and phases is
considered:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /\sprods_.*?\.\./ /;/)
```GAMS
 prods_(prodsYearly,tCur(t),nCur) $ (sum(sameas(prodsYearly,curProds),1) $ t_n(t,nCur))   ..

       v_prods(prodsYearly,t,nCur)
         =e=
*
*        --- crop output
*
         sum( c_s_t_i(crops,plot,till,intens), v_cropHa(crops,plot,till,intens,t,nCur)
             * sum(plot_soil(plot,soil),p_OCoeffC(crops,soil,till,intens,prodsYearly,t)))

*
*        ---- removed residues
*
      +  sum( c_s_t_i(crops,plot,till,intens) $ (cropsResidueRemo(crops)
$iftheni.BWA "%branchMode%" == "BWA"
                          $ intensResRem(intens)
$endif.BWA
                          )
                                 ,  v_residuesRemoval(crops,plot,till,intens,t,nCur)
            *  sum(plot_soil(plot,soil), p_OCoeffResidues(crops,soil,till,intens,prodsyearly,t)) )
*
*  --- residues used for own Consumption
*
$iftheni.straw %strawManure% == true
      - v_residuesOwnConsum(prodsYearly,t,nCur) $ (sum(sameas (prodsYearly,prodsResidues),1))
$endif.straw
$iftheni.herd %herd% == true
*
*        --- animal output
*
      +  sum( (possHerds,breeds) $ (sum((feedRegime,m),actherds(possHerds,breeds,feedRegime,t,m))
                                        $ p_OCoeff(possHerds,prodsYearly,breeds,t)),
*
*             -- herd size in different month times output yearly coefficient (milk, young animals ..)
*
                           (    sum(actHerds(possHerds,Breeds,feedRegime,t,m),v_herdSize(possHerds,breeds,feedRegime,t,nCur,m))
                                       * ( 1/min(12,p_prodLength(possHerds,breeds))
                                            * ( (12/card(herdM)) $ (not sameas(possHerds,"fattners")) + 1 $ sameas(possHerds,"fattners")))
                                               $ ( (p_prodLength(possHerds,breeds) gt 1)
$ifi "%farmBranchFattners%" == "on"             or ((p_prodLength(possHerds,breeds) le 1) $ sameas(possHerds,"fattners"))
$ifi "%farmBranchSows%" == "on"                and (p_prodLength(possHerds,breeds) gt 2)
                                        )
                              + sum(m $ sum(feedRegime,actherds(possHerds,breeds,feedRegime,t,m)),  v_herdStart(possHerds,breeds,t,nCur,m))
                                               $ ( (p_prodLength(possHerds,breeds) le 1)

$ifi "%farmBranchFattners%" == "on"          and (not (sum((feedRegime,m),actHerds("Fattners","",feedRegime,tCur,m))))
$ifi "%farmBranchSows%" == "on"              or (p_prodLength(possHerds,breeds) le 2)
                                            )
                           )

                 * p_OCoeff(possHerds,prodsYearly,breeds,t)
           )
$endif.herd
      ;
```

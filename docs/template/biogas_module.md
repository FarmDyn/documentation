
# Biogas Module

!!! abstract
    The biogas module defines the economic and technological relations between components of a biogas plant with a monthly resolution, as well as links to the farm. Thereby, it includes the statutory payment structure and their respective restrictions according to the German Renewable Energy Acts (EEGs) from 2004 up to 2014. The biogas module differentiates between three different sizes of biogas plants and accounts for three different life spans of investments connected to the biogas plant. Data for the technological and economic parameters used in the model are derived from KTBL (2013) and FNR (2013). The equations within the template model related to the biogas module are presented in the following section.

## Biogas Economic Part

The economic part describes on the one hand the revenues stemming from
the heat and electricity production of the biogas plant, and on the
other hand investment and operation costs. The guaranteed feed-in tariff
paid to the electricity producer per kWh, *p\_priceElec*, and underlying
the revenues, is constructed as a sliding scale price and is exemplary
shown in the next equation.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/prices_eeg.gms GAMS /p_priceElec.*?\$.*?=.*?/ /;/)
```GAMS
p_priceElec(bhkw,eeg,tCur(t))$(eegRated(eeg)) = (p_priceElecBase("150kW",eeg) * (150/p_powRate(bhkw,eeg))
                                                          + p_priceElecBase(bhkw,eeg) * ((p_powRate(bhkw,eeg) - 150)/p_powRate(bhkw,eeg)))
                                                         ;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/prices_eeg.gms GAMS /p_priceElec.*?"E2004".*?= / /;/)
```GAMS
p_priceElecE2004("150kW","E2004")= 0.08;
```


*p\_priceElecBase*, used to calculate the guaranteed feed-in tariff
differentiated by size, includes the base rate and additional
bonuses [^5] according to the legislative texts of the EEGs. For the EEG
2012 it only contains the base rate. In addition, the guaranteed feed-in
tariff is subject to a degressive relative factor, *p\_priceElecDeg,*
which differs between EEGs and describes price reductions over time. The
*p\_priceElecBase* is then used to calculate the electricity based
revenue of the biogas operator by multiplying it with the produced
electricity, *v\_prodElec*. In order to assure a correct representation
of the EEG 2012 payment, the biogas module differentiates the
electricity output by input source *v\_prodElecCrop* and
*v\_prodElecManure* and multiplies it with its respective bonus tariffs
*p\_priceElecInputclass* which are added to the base rate.


[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/biogas_module.gms GAMS /bioGasObje_\(tCur[\S\s]*?\.\./ /;/)
```GAMS
bioGasObje_(tCur(t),nCur) $ t_n(t,nCur) ..
       v_salRevBioGas(t,nCur)

        =e=

*            --- Revenue stemming from electricity production with degression depending on EEG (excluding direct marketing)
                 sum( (curBhkw(bhkw),curEeg(eeg),m) $ (not(eegDM(eeg))),
                                    v_prodElec(bhkw,eeg,t,nCur,m) *  p_priceElec(bhkw,eeg,t)   )

*            --- Revenue stemming from electricity production for EEG E2012 differentiated by input class
               + sum( (curBhkw(bhkw),curEeg(eeg),m) $ (eegDif(eeg)) ,
                                        v_prodElecCrop(bhkw,eeg,t,nCur,m)   * p_priceElecInputclass(bhkw,eeg,"inputCl1")
                                      + v_prodElecManure(bhkw,eeg,t,nCur,m) * p_priceElecInputclass(bhkw,eeg,"inputCl2") )

*            --- Revenue stemming from heat
               + sum( curEeg(eeg),  v_sellHeat(eeg,t,nCur) * p_priceHeat(t) )

*            --- Revenue specification for EEG with direct marketing and flexible biogas production
               + sum( (curBhkw(bhkw),curEeg(eeg),m)$(eegDM(eeg)),
                                   + (v_prodElec(bhkw,eeg,t,nCur,m) * p_shareEPEX(bhkw) )
                                       * (p_dmMP(bhkw,eeg,t,m) + p_dmsellPriceHigh(m) )
                                   + (v_prodElec(bhkw,eeg,t,nCur,m) * (1 - p_shareEPEX(bhkw) ) )
                                       * (p_dmMP(bhkw,eeg,t,m) + p_dmsellPriceLow(m) )
                                   + (v_prodElec(bhkw,eeg,t,nCur,m) * p_flexPrem(bhkw,eeg) ) )

*            --- Revenue stemming from scenario premium
               + sum( (curBhkw(bhkw), curEeg(eeg),m)$(eegScen(eeg)),
                                      v_prodElec(bhkw,eeg,t,nCur,m) * p_scenPremium(eeg)$(eegScen(eeg)))
;
```

In addition to the *traditional* guaranteed feed-in tariff, the biogas
module comprises the payment structure for the so-called *direct
marketing option* which was implemented in the EEG 2012. The calculation
of the revenue with a direct marketing option is defined as the product
of the produced electricity, *v\_prodElec*, the sum of the market
premium, *p\_dmMP*, and the price at the electricity spot exchange EPEX
Spot, *p\_dmsellPriceHigh/Low.* The latter depends on the amount of
electricity sold during high and low stock market prices. Additionally,
it is accounted for a flexibility premium, *p\_flexPrem*.

Furthermore, the revenue stemming from heat is accounted for and is
included as the product of sold heat, *v\_sellHeat*, times the price of
heat, *p\_priceHeat*, which is set to two cents per kWh. The amount of
head sold is set exogenously and depends on the biogas plant type.

The detailed steps of the construction of prices can be seen in
*\\coeffgen\\prices\_eeg.gms.*

## Biogas Inventory

The biogas plant inventory differentiates biogas plants by size (set
*bhkw*), which determines the engine capacity, the investment costs and
the labour use. Three size classes are currently depicted.


[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ_decl.gms GAMS /set bhkw/ /;/)
```GAMS
set bhkw "different bhkw sizes" /
                                 150KW       "150kW engine"
                                 250kW       "250kW engine"
                                 500KW       "500kW engine"
                                /;
```


Moreover, in order to use a biogas plant, different components need to be present which differ by lifetime
(investment horizon *ih*). For example, in order to use the original
plant, the decision maker has to re-invest every seventh year in a new
engine but only every twentieth year in a new fermenter.


[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ_decl.gms GAMS /iH              "investment/ /twenty years"/)
```GAMS
iH              "investment horizon"       /
                                                  iH7      "reinvestment after seven years",
                                                  iH10     "reinvestment after ten years",
                                                  iH20     "reinvestment after twenty years"
```

The biogas plant and their respective parts can either be bought,
*v\_buyBiogasPlant(Parts)*, or an already existing biogas plant can be
used, *p\_iniBioGas*. Both define the size of the inventory of the
biogas plant, *v\_invBioGas(Parts).* The model currently limits the
number of biogas plants present on farm to unity.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/biogas_module.gms GAMS /invBioGasTot_[\S\s][^;]*?\.\./ /;/)
```GAMS
invBioGasTot_(tCur(t),nCur) $ t_n(t,nCur) ..

       sum( (curBhkw(bhkw),curEeg(eeg)), v_invBioGas(bhkw,eeg,t,nCur)) =L=  1;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/biogas_module.gms GAMS /invBioGas_[\S\s][^;]*?\.\./ /;/)
```GAMS
invBioGas_(curBhkw(bhkw),curEeg(eeg),ih,tFull(t),nCur) $ (ih20(ih) $ t_n(t,nCur))   ..

       v_invBioGas(bhkw,eeg,t,nCur)

           =L=
                 sum( (tCur(t1),n1)  $ (t_n(t1,n1) $ isNodeBefore(nCur,n1)
                       $  (p_year(t1) + p_ih(ih)+1 ge p_year(t)+1 )
                      and (p_year(t1)+1 le p_year(t)+1 ) ),

                                       v_buyBioGasPlant(bhkw,eeg,ih,t1,n1) )

                 + sum( tOld $ ( (p_year(tOld) + p_ih(ih) ge p_year(t) ) and (p_year(tOld) le p_year(t) ) ),

                                       p_iniBioGas(bhkw,eeg,ih,tOld) );
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/biogas_module.gms GAMS /invBioGasTotParts_[\S\s][^;]*?\.\./ /;/)
```GAMS
invBioGasTotParts_(curBhkw(bhkw),ih,tCur(t),nCur) $ (t_n(t,nCur) $ (not ih20(ih)))..

           v_invBioGasParts(bhkw,ih,t,nCur) =G= sum(curEeg(eeg), v_invBioGas(bhkw,eeg,t,nCur));
```
Furthermore, the inventory *v\_invBioGas* stores the information under
which EEG the plant was original erected, either by externally setting
the EEG for an existing biogas plant or the initial EEG is endogenously
determined by the year of investment. In addition, the module provides
the plant operator the option to switch from the EEG under which its
plant was original erected to newer EEGs endogenously, such that the
electricity and heat price of the newer legislation determines the
revenues of the plant. For this purpose, the variable *v\_switchBioGas*
transfers the current EEG from *v\_invBioGas* to the variable
*v\_useBioGasPlant*. Hence, the *v\_invBioGas* is used to represent the
inventory while *v\_useBioGasPlant* is used to determine the actual EEG
under which a plant is used, i.e. payment structures and feedstock
restrictions.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/biogas_module.gms GAMS /switchBioGas_\(curBhkw[\S\s]*?\.\./ /;/)
```GAMS
switchBioGas_(curBhkw(bhkw),curEeg(eeg1),tCur(t),nCur) $ t_n(t,nCur) ..

       v_invBioGas(bhkw,eeg1,t,nCur)

          =G= sum(newEeg_oldEeg(eeg,eeg1) $ curEeg(eeg), v_switchBioGas(bhkw,eeg1,eeg,t,nCur));
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/biogas_module.gms GAMS /useBioGas_[\S\s][^;]*?\.\./ /;/)
```GAMS
useBioGas_(curBhkw(bhkw),curEeg(eeg),tCur(t),nCur) $ t_n(t,nCur) ..

       v_useBioGasPlant(bhkw,eeg,t,nCur)

          =L= sum(newEeg_oldEeg(eeg,eeg1) $ curEeg(eeg1), v_switchBioGas(bhkw,eeg1,eeg,t,nCur));
```


## Production Technology

The production technology describes not only the production process, but
also defines the limitations set by technological components such as the
engine capacity, fermenter volume and fermentation process. As heat is
only a by-product of the electricity production and therefore the
production equations do not differ from those for electricity, the heat
production is not explicitly described.

The size of the engine restricts with *p\_fixElecMonth* the maximal
output of electricity in each month. According to the available size
classes, the maximal outputs are 150kW, 250kW and 500kW, respectively,
at 8.000 operating hours per year. This number of hours stems from the assumption that the biogas plant is not operating for 9% of the available time due to maintenance,
etc.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/biogas_module.gms GAMS /fixkWel_\(curBhkw[\S\s]*?\.\./ /;/)
```GAMS
fixkWel_(curBhkw(bhkw),curEeg(eeg),tCur(t),nCur,m) $ (t_n(t,nCur) and (v_prodElec.up(bhkw,eeg,t,nCur,m) ne 0)) ..

       v_prodElec(bhkw,eeg,t,nCur,m)

          =l= v_useBioGasPlant(bhkw,eeg,t,nCur) * p_fixElecMonth(bhkw,m) * p_scenRed(eeg);
```


The production process of electricity, *v\_prodElec,* is constructed in
a two-stage procedure. First, biogas [^6], *v\_methCrop/Manure,* is
produced in the fermenter as the product of crops and manure,
*v\_usedCrop/Manure,* and the amount of methane content per ton fresh
matter of the respective input. Second, the produced methane is
combusted in the engine in which the electricity-output,
*v\_prodElecCrop/Manure,* is calculated by the energy content of
methane, *p\_ch4Con,* and the conversion efficiency of the respective
engine, *p\_bhkwEffic*.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/biogas_module.gms GAMS /methCrop_\(curBhkw[\S\s]*?\.\./ /;/)
```GAMS
methCrop_(curBhkw(bhkw),curEeg(eeg),tCur(t),nCur,m) $ t_n(t,nCur) ..

       v_methCrop(bhkw,eeg,t,nCur,m)

          =e= sum(crM(biogasFeedM), v_usedCropBiogas(bhkw,eeg,crM,t,nCur,m) * p_crop(crM) );
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/biogas_module.gms GAMS /methManure_\(curBhkw[\S\s]*?\.\./ /;/)
```GAMS
methManure_(curBhkw(bhkw),curEeg(eeg),tCur(t),nCur,m) $ t_n(t,nCur) ..

       v_methManure(bhkw,eeg,t,nCur,m)

          =e= sum(curmaM,     v_usedManBiogas(bhkw,eeg,curmaM,t,nCur,m) * p_manure(curmaM) );
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/biogas_module.gms GAMS /kWel_\(curBhkw[\S\s]*?\.\./ /;/)
```GAMS
kWel_(curBhkw(bhkw),curEeg(eeg),tCur(t),nCur,m) $ (t_n(t,nCur) and (v_prodElec.up(bhkw,eeg,t,nCur,m) ne 0)) ..

       v_prodElec(bhkw,eeg,t,nCur,m)

          =l= v_useBioGasPlant(bhkw,eeg,t,nCur) * p_fixElecMonth(bhkw,m) * p_scenRed(eeg);
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/biogas_module.gms GAMS /kWelCrop_\(curBhkw[\S\s]*?\.\./ /;/)
```GAMS
kWelCrop_(curBhkw(bhkw),curEeg(eeg),tCur(t),nCur,m) $ t_n(t,nCur) ..

       v_prodElecCrop(bhkw,eeg,t,nCur,m)

         =e= v_methCrop(bhkw,eeg,t,nCur,m) * p_ch4Con * p_bhkwEffic(bhkw,"el") * p_transLosses;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/biogas_module.gms GAMS /kWelManure_\(curBhkw[\S\s]*?\.\./ /;/)
```GAMS
kWelManure_(curBhkw(bhkw),curEeg(eeg),tCur(t),nCur,m) $ t_n(t,nCur) ..

       v_prodElecManure(bhkw,eeg,t,nCur,m)

         =e= v_methManure(bhkw,eeg,t,nCur,m) * p_ch4Con * p_bhkwEffic(bhkw,"el") * p_transLosses;
```



The bonus structure of the EEG 2012 requires a differentiation between
the two input classes: crop and manure. Thus, the production process is
separated in methane produced from the *Crop* input class and the
*Manure* input class.

The production technology imposes a second bound by connecting a
specific fermenter volume, *p\_volFermMonthly,* to each engine size. The
fermenter volume is exogenously given under the assumption of a 90-day
hydraulic retention time and an input mix of 70% maize silage and
30% manure. Hence, the input quantity derived from crops,
*v\_usedCropBiogas,* and manure, *v\_usedManBiogas,* is bound by the
fermenter size, *v\_totVolFermMonthly.*

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/biogas_module.gms GAMS /fixKW_\(curBhkw[\S\s]*?\.\./ /;/)
```GAMS
fixKW_(curBhkw(bhkw),curEeg(eeg),tCur(t),nCur,m) $ t_n(t,nCur) ..

       v_totVolFermMonthly(bhkw,eeg,t,nCur,m)

         =l= v_useBioGasPlant(bhkw,eeg,t,nCur) *  p_volFermMonthly(bhkw) * p_scenred(eeg);
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/biogas_module.gms GAMS /totVolFerm_\(curBhkw[\S\s]*?\.\./ /;/)
```GAMS
totVolFerm_(curBhkw(bhkw),curEeg(eeg),tCur(t),nCur,m) $ t_n(t,nCur) ..

       v_totVolFermMonthly(bhkw,eeg,t,nCur,m)  =g=

                                          sum(crM(biogasFeedM), v_usedCropBiogas(bhkw,eeg,crM,t,nCur,m))

                                        + sum(curmaM, v_usedManBiogas(bhkw,eeg,curmaM,t,nCur,m) );
```
The inputs for the fermentation process can be either externally
purchased, *v\_purchCrop/Manure,* or produced on farm,
*v\_feedBiogas/v\_volManBiogas*. Additionally, the module accounts for
silage losses for purchased crops, as crops from own production already
includes silage losses in the production pattern of the farm. Currently,
the model includes only cattle manure, maize silage and grass silage as
possible inputs.


[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/biogas_module.gms GAMS /usedCropBioGas_\(curBhkw[\S\s]*?\.\./ /;/)
```GAMS
usedCropBioGas_(curBhkw(bhkw),curEeg(eeg),crM(biogasFeedM),tCur(t),nCur,m) $ t_n(t,nCur) ..

       v_usedCropBiogas(bhkw,eeg,crM,t,nCur,m)

          =e= (    v_purchCrop(bhkw,eeg,crM,t,nCur,m)  $ selPurchInputs(crM) * p_silageLoss)
                 + v_feedBioGas(bhkw,eeg,crM,t,nCur,m) $ SUM(sameas(curProds,crM),1);
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/biogas_module.gms GAMS /manureTot_\(curBhkw[\S\s]*?\.\./ /;/)
```GAMS
manureTot_(curBhkw(bhkw), curEeg(eeg),curmaM,tCur(t),nCur,m) $ t_n(t,nCur) ..

       v_usedManBiogas(bhkw,eeg,curmaM,t,nCur,m)
          =e=
               v_purchManure(bhkw,eeg,curmaM,t,nCur,m) $ selPurchInputs(curmaM)
$ifi %herd%==true            + sum(curmanchain $ (not sameas (curmanChain,"LiquidBiogas")) , v_volManBiogas(curmanchain,bhkw,eeg,curmaM,t,nCur,m))
    ;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/biogas_module.gms GAMS /volManBioGas_\(curma[\S\s]*?\.\./ /;/)
```GAMS
volManBioGas_(curmanchain, tCur(t),nCur) $ (t_n(t,nCur) $ (not sameas (curmanchain,"LiquidBiogas"))) ..

      v_manQuant(curManChain,t,nCur) $ (not sameas (curmanchain,"LiquidBiogas"))

          =G= sum( (manchain_mam(curmanchain,curmam),curbhkw(bhkw),curEeg(eeg),m) $(not sameas (curmanchain,"liquidBiogas")), v_volManBiogas(curmanchain,bhkw,eeg,curmaM,t,nCur,m)) ;
```

The third bound imposed by the production technology is the so called
digestion load (*Faulraumbelastung*). The digestion load, *p\_digLoad,*
restricts the amount of organic dry matter within the fermenter to
ensure a healthy bacteria culture. The recommended digestion load of the
three different fermenter sizes ranges from 2.5 to 3
$\frac{\text{kg oDM}}{m^3 \cdot d}$ [^7] and is converted into a monthly
limit.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/biogas_module.gms GAMS /fixdigLoad_\(curBhkw[\S\s]*?\.\./ /;/)
```GAMS
fixdigLoad_(curBhkw(bhkw),tCur(t),nCur,m) $ t_n(t,nCur) ..

      v_digLoad(bhkw,t,nCur,m)   =l= sum(curEeg(eeg),  v_useBioGasPlant(bhkw,eeg,t,nCur) * p_digLoad(bhkw,m))  ;
```
[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/biogas_module.gms GAMS /digLoad_\(curBhkw[\S\s]*?\.\./ /;/)
```GAMS
digLoad_(curBhkw(bhkw),tCur(t),nCur,m) $ t_n(t,nCur) ..

      v_digLoad(bhkw,t,nCur,m)   =l= sum(curEeg(eeg),  v_useBioGasPlant(bhkw,eeg,t,nCur) * p_digLoad(bhkw,m))  ;
```


The data used for the fermenter technology can be seen in
*\\coeffgen\\fermenter\_tech.gms*

## Restrictions Related to the Renewable Energy Act

Within the legislative text of the different Renewable Energy Acts
different restrictions were imposed in order to receive certain bonuses
or to receive any payment at all. In the biogas module most bonuses for
the EEG 2004 and EEG 2009 are inherently included such as the KWK-Bonus
and NawaRo-Bonus, i.e. the plant is already defined such that these
additional subsidies on top of the basic feed-in tariff can be claimed.
Additionally, the biogas operator has the option to receive the
Manure-Bonus, if he ensures that 30% of his input quantity is
manure based, as can be seen in the following code.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/biogas_module.gms GAMS /manureRes_\(curBhkw[\S\s]*?\.\./ /;/)
```GAMS
manureRes_(curBhkw(bhkw),eegMan(eeg),tCur(t),nCur,m) $ (t_n(t,nCur) $ curEeg(eeg)) ..

       sum(curmaM,  v_usedManBiogas(bhkw,eeg,curmaM,t,nCur,m)) =g= v_totVolFermMonthly(bhkw,eeg,t,nCur,m)*0.3 ;
```

Furthermore, the EEG 2012 imposes two requirements which have to be met
by the plant operator to receive any statutory payment at all. First,
the operator must ensure that not more than 60% of the used
fermenter volume, *v\_totVolFermMonthly,* is used for maize. Second,
under the assumption that the operator uses 25% of the heat
emitted by the combustion engine for the fermenter itself, he has to
sell at least 35% of the generated heat externally;

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/biogas_module.gms GAMS /maizeRes_\(curBhkw[\S\s]*?\.\./ /;/)
```GAMS
maizeRes_(curBhkw(bhkw),eegDif(eeg),biogasFeedM,tCur(t),nCur,m) $ (curEeg(eeg) $ t_n(t,nCur)) ..

       v_usedCropBiogas(bhkw,eeg,"maizSil",t,nCur,m) =l=  0.6 * v_totVolFermMonthly(bhkw,eeg,t,nCur,m);
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/biogas_module.gms GAMS /heatRes_\(curBhkw[\S\s]*?\.\./ /;/)
```GAMS
heatRes_(curBhkw(bhkw),eegDif(eeg),tCur(t),nCur,m) $ (curEeg(eeg) $ t_n(t,nCur)) ..

       v_sellHeat(eeg,t,nCur) =g= p_minHeatSold * v_prodHeat(eeg,t,nCur);
```

Changes made in EEG 2014 and the amendment of 2016 has not been included
in the model yet.


 [^5]: For the EEG 2004: NawaRo-Bonus, KWK-Bonus; For the EEG 2009:
    Nawaro-Bonus, KWK-Bonus **or** NawaRo-Bonus, KWK-Bonus and
    Manure-Bonus

 [^6]: Biogas is a mixture of methane (CH<sub>4</sub>), carbon dioxide (CO<sub>2</sub>),
    water vapor (H<sub>2</sub>O) and other minor gases. The gas component
    containing the energy content of biogas is methane. Thus, the code
    with respect to production refers to the methane production rather
    than the production of biogas.

 [^7]: oDM = organic dry matter; m<sup>3</sup> = cubic meter; d = day

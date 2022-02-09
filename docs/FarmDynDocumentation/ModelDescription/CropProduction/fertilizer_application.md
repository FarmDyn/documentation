# Fertiliser Application

> **_Abstract_**  
The nutrient demand by crops can be either met by synthetic or organic fertiliser. The implementation of synthetic fertiliser application accounts for only very few *N* and *P* fertiliser with related input costs and the respective labour need, and machinery use. In contrast, the application of organic fertiliser considers different application machinery with their linked emission levels, labour requirements, etc.. Further, multiple organic fertiliser types are accounted for with varying levels of nutrients. Both application types consider agronomic aspects such as minimum application levels (synthetic) or periods where application is not possible (manure).

## Synthetic Fertilisers

To meet the N and P demand of crops, synthetic fertiliser, *v\_syntDist*, can be applied besides manure. Synthetic fertiliser application enters equations with regard to the buying of inputs, *buy\_* and *varcost\_*, the labour need for application, *labCropSM\_*, the field work hours and machinery, *fieldWorkHours\_* and *machines\_*, and with regard to  plant nutrition. The equation *nMinMan\_* ensures that minimum amounts of mineral fertiliser are applied for certain crops. It represents the limitation meeting the plant need with nutrients from manure, e.g. fertilising short before harvest for baking wheat cannot be done with manure.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/general_cropping_module.gms GAMS /nMinMin\_\(c\_p\_t\_i/ /;/)
```GAMS
nMinMin_(c_p_t_i(curCrops(crops),plot,till,intens),nut,t_n(tCur(t),nCur))
        $ (  (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0)
                $ p_minChemFert(crops,nut) $ (not (sameas(till,"org") or lower(intens) or veryLow(intens))) ) ..

       sum ((curInputs(syntFertilizer),m),
                      v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)
                                                   * p_nutInSynt(syntFertilizer,nut))
              =G=

                v_cropHa(crops,plot,till,intens,t,nCur) * p_minChemFert(crops,nut)
                  *  sum(plot_soil(plot,soil),p_nutNeed(crops,soil,till,intens,nut,t));
```

## Organic Fertilisers

Different application procedures for manure N are implemented, *ManApplicType*, including broad spread, drag hose spreader, injection of manure, and solid manure spread.
The core variable is *v\_mandist* which represents the amount of manure in distributed cubic meter. The different techniques are related to different application costs, labour requirements as well as effects on different emissions. Furthermore, manure application is linked to the nutrient balance and the manure storage.

The application of manure links nutrient with volumes. The nutrient content of the manure is depending on the herd's excretion as well as on the losses during storage. The parameter *p\_nut2inMan* contains the amount of NTAN, Norg and P per cubic meter of manure applied. The parameter is differentiated for the manure types linked to the present herd. Relevant parameters are calculated in *coeffgen\\manure.gms*.

As a first step, the amount of different nutrients per cubic meter without losses is calculated in *p\_nut2inManNoLoss*. Here, the nutrient excretion of the animals is related to their volume excretion depending on the stables present on the farm.

In a second step, the nutrients per cubic meter are corrected for the storage losses in *p\_nut2inMan*. Varying storage time of manure, and hence varying nutrient content, can be taken into account by activating the "Nutrient loss depending on storage time" control in the graphical user interface. In this case, for the manure of every herd, two types of manure are calculated, representing the maximum and minimum possible amount of losses during one year. This allows a complete emptying of the storage in a linear programming setting.
In the default case, only the minimum losses are assumed.

The total manure distributed in cubic meter and in nutrients per month is summarised in the following equations according to:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/manure_module.gms GAMS /nut2ManApplied_[\S\s][^;]*?\.\./ /;/)
```GAMS
nut2ManApplied_(curCrops,curManChain(manChain),nut2,t_n(tCur(t),nCur),m) $ (v_volManApplied.up(manChain,t,nCur,m) ne 0) ..

       v_nut2ManApplied(curCrops,manChain,nut2,t,nCur,m) =e=
                                  sum( (plot,till,intens,manChain_applic(manChain,ManApplicType),curManType)
                                          $ (manApplicType_manType(ManApplicType,curManType)
                                          $ (v_manDist.up(curCrops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0)
                                          $ (not sameas (curCrops,"catchcrop")) $c_p_t_i(curCrops,plot,till,intens)),

                                         v_manDist(curCrops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                                                  * p_nut2inMan(nut2,curManType,manChain));
```

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/manure_module.gms GAMS /volManApplied_[\S\s][^;]*?\.\./ /;/)
```GAMS
volManApplied_(curManChain(manChain),t_n(tCur(t),nCur),m) $ (v_volManApplied.up(manChain,t,nCur,m) ne 0) ..

       v_volManApplied(manChain,t,nCur,m)
         =e= sum( (c_p_t_i(curCrops(crops),plot,till,intens),
                     manChain_applic(manChain,ManApplicType),curManType)
                                           $ (manApplicType_manType(ManApplicType,curManType)
                                           $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0)
                                           $ (not sameas (curCrops,"catchcrop")) ),
                     v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m));
```


There are several restrictions with regard to the application of manure. First of all, the application of manure is not possible in some crops in some months, e.g. in maize at certain height of growth.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/crops_de.gms GAMS /set doNotApplyManure/ /;/)
```GAMS
set doNotApplyManure(crops,m) /
                                 set.potatoes           .(Jun,Jul,Aug)
                                 set.maize              .(Jun,Jul,Aug)
                                 set.sugarbeet          .(Jun,Jul,Aug)
                                 set.rapeseed           .(May,Jun,Jul)
                                 set.summerCere         .(May,Jun,Jul)
                                 set.WinterCere         .(Apr,May,Jun,Jul)
                                /;
```

For these months, *v_manDist* is forced to be zero.

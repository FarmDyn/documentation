# CAP - First pillar payments

The current implementation of the CAP First Pillar measures in FarmDyn accounts only for the base payment and the payments related to greening, which are presented in the following.

## Base payments

As the de-coupled payments are related to the on-farm land, you can find them under the header "Land endowment" in the GUI as seen in the following figure.

![](../../media/Data/deCapPay.PNG){: style="width:100%"}
Figure 1: Decoupled payments in GUI
Source: Own illustration


## Greening Programme

Starting in 2013, subsidies stemming from the Common Agricultural Policy by the European Commission were linked to more environmental friendly farming practices, the so called "greening". In this small section, we present shortly the greening measures and their implementation in the model.

The greening measures can be summarised in three broad categories:

**1. Crop diversification**

**2. Preservation of permanent grassland**

**3. Designation of ecological focus areas (EFA)**

This section covers the crop diversification and designation of EFA measures. The allocation of land to grassland or arable land is exogenous in FarmDyn. Therefore, covering the conversion of grassland to arable land is not possible within the model and will not be further discussed in the documentation.

### Crop Diversification

Crop diversification mandates farmers to cultivate multiple crops from different crop groups within a season. The required share of each crop group in the diversification scheme is dependent on the total arable and grassland as well as on their relative share of agricultural land on-farm. The triggering size classes are captured by binary variables in the equation *trigger10ha\_* and *trigger30ha\_*.

The *trigger10Ha\_* tests if the arable land on farm is less than 10 ha, as it won't trigger any greening measures. Farms with more than 10 ha and less than 30 ha arable land have a crop diversification obligation where the most planted crop group is not allowed to exceed 75% of the arable land. Consequently, they have to cultivate at least 2 crops. This is shown in equation *green75\_*.   

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/greening_module.gms GAMS /trigger10Ha_\(t_n\(tCur\(t\),nCur\)\) \.\./ /;/)
```GAMS
trigger10Ha_(t_n(tCur(t),nCur)) ..
   sum((plot_landType(plot,"arab"),sys) $ p_plotSize(plot),v_croppedPlotLand(plot,sys,t,nCur))
         - (v_triggerGreening("10ha",tCur,nCur) * p_M) =l= 10;
```
[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/greening_module.gms GAMS /green75_\(cropGroups,t_n\(tCur\(t\),nCur\)\)/ /;/)
```GAMS
green75_(cropGroups,t_n(tCur(t),nCur))
            $ (sum(c_p_t_i(curCrops(crops),plot,till,intens) $ (plot_landType(plot,"arab")  $ (not grassCrops(crops))
                 $ p_cropGroups_to_crops(cropGroups,crops)),1)) ..

  v_haCropGroups(cropGroups,tCur,nCur)
     =l=    sum((plot_landType(plot,"arab"),sys),v_croppedPlotLand(plot,sys,t,nCur)) *0.75
              + ((1 - v_triggerGreening("10ha",tCur,nCur)) * p_M)
              + ((1 - v_triggerGreening("Idle",tCur,nCur)) * p_M)
              + ((1 - v_triggerGreening("Gras",tCur,nCur)) * p_M)
;
```

The *trigger30Ha\_* tests if the arable land on farm is more than 30 ha. Farms with more than 30 ha arable land have a crop diversification requirement where the sum of the two largest crop group shares is not allowed to exceed 95% of the total arable land, see *green95\_*. This results in at least 3 different crops simultaneously cultivated in a planting season.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/greening_module.gms GAMS /trigger30Ha_\(t_n\(tCur\(t\),nCur\)\) \.\./ /;/)
```GAMS
trigger30Ha_(t_n(tCur(t),nCur)) ..
   sum((plot_landType(plot,"arab"),sys) $ p_plotSize(plot),v_croppedPlotLand(plot,sys,t,nCur))
    - (v_triggerGreening("30ha",tCur,nCur) * p_M) =l= 30;
```

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/greening_module.gms GAMS /green95_\(cropGroups,cropGroups1,t_n\(tCur\(t\),nCur\)\)/ /;/)
```GAMS
green95_(cropGroups,cropGroups1,t_n(tCur(t),nCur))
               $ (   sum(c_p_t_i(curCrops(crops),plot,till,intens) $ (plot_landType(plot,"arab")  $ (not grassCrops(crops))
                        $ p_cropGroups_to_crops(cropGroups,crops)),1)

                   $ sum(c_p_t_i(curCrops(crops),plot,till,intens) $ (plot_landType(plot,"arab")  $ (not grassCrops(crops))
                        $ p_cropGroups_to_crops(cropGroups1,crops)),1)

                   $ (not sameas(cropGroups,cropGroups1)) ) ..

     v_haCropGroups(cropGroups,tCur,nCur) +  v_haCropGroups(cropGroups1,tCur,nCur)

        =l= sum((plot_landType(plot,"arab"),sys),v_croppedPlotLand(plot,sys,t,nCur))*0.95
               + ((1 - v_triggerGreening("30ha",tCur,nCur)) * p_M)
               + ((1 - v_triggerGreening("Idle",tCur,nCur)) * p_M)
               + ((1 - v_triggerGreening("Gras",tCur,nCur)) * p_M);
```


### Designation of Ecological Focus Areas

The designation of ecological focus areas (EFA) affects only farmers with more than 15 ha of arable land (*v_croppedPlotLand* in *trigger15Ha\_*), who have to ensure that a minimum of 5% of their arable land is managed as an EFA (*efa\_*). Each member state offers a list of potential candidates for EFA such as buffer
strips, group of trees, fallow land, and catch crops/ nitrogen fixing crops, whereas each type of EFA has a different weighting factor (*p_efa*) in the calculation of the total EFA area. For example, catch crops and nitrogen fixing crops have a weighting of 0.3, so that for each hectare planted on arable land they
account for only 0.3 ha to the required minimum of 5% arable land share.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/greening_module.gms GAMS /trigger15Ha_\(t_n\(tCur\(t\),nCur\)\) \.\./ /;/)
```GAMS
trigger15Ha_(t_n(tCur(t),nCur)) ..
  sum((plot_landType(plot,"arab"),sys) $ p_plotSize(plot),v_croppedPlotLand(plot,sys,t,nCur))
               - (v_triggerGreening("15ha",tCur,nCur) * p_M) =l= 15;
```

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/greening_module.gms GAMS / efa_\(t_n\(tCur\(t\),nCur\)\) \.\./ /;/)
```GAMS
 efa_(t_n(tCur(t),nCur)) ..

   sum(plot_landType(plot,"arab") $ p_plotSize(plot),
           sum(sys,v_croppedPlotLand(plot,sys,t,nCur))) * 0.05
         =l=

    sum(c_p_t_i(curCrops(crops),plot,till,intens) $ plot_landType(plot,"arab"),
          v_cropHa(crops,plot,till,intens,tCur,nCur)*p_efa(crops))
*
*  --- if one or several of these triggers is active, the EFA condition
*      cannot be binding
*
              + ((1 - v_triggerGreening("15ha",tCur,nCur)) * p_M)
              + ((1 - v_triggerGreening("Idle",tCur,nCur)) * p_M)
              + ((1 - v_triggerGreening("Gras",tCur,nCur)) * p_M)
 ;
```

### Grass Land Exemptions

The presented requirements for crop diversification and EFA have exemptions for farms with a high share of grass land and/ or fallow lying land as long as the arable land does not exceed 30 ha (*triggerRestlandGras\_* and *triggerRestlandIdle\_*). If the share of permanent/ rotational grass land or idle land on the total land is more than 75% and consequently the arable land is less than 25% (*triggerGras75\_*, *triggerIdle75\_*), the farm does not have to comply with any of the above measures (crop diversification and EFA) to receive the greening premium.

The following equations show this conditional for the case of grass land.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/greening_module.gms GAMS /triggerGras75_\(t_n\(tCur\(t\),nCur\)\) \.\./ /;/)
```GAMS
triggerGras75_(t_n(tCur(t),nCur)) ..
   sum((plot,sys) $ p_plotSize(plot),v_croppedPlotLand(plot,sys,t,nCur))
    - v_triggerGreening("Gras",tCur,nCur) * p_M =l=
             sum(c_p_t_i(curCrops(grasCrops),plot,till,intens),
                  v_cropHa(grasCrops,plot,till,intens,tCur,nCur))/0.75;
```
[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/greening_module.gms GAMS /triggerRestlandGras_\(t_n\(tCur\(t\),nCur\)\) \.\./ /;/)
```GAMS
triggerRestlandGras_(t_n(tCur(t),nCur)) ..
    sum((plot,sys) $ p_plotSize(plot),v_croppedPlotLand(plot,sys,t,nCur))
  - sum(c_p_t_i(curCrops(grasCrops),plot,till,intens), v_cropHa(grasCrops,plot,till,intens,tCur,nCur))
   - (v_triggerGreening("Gras",tCur,nCur) * p_M) =l= 30
;
```

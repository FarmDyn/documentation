# Agri-Environmental Schemes

Agri-environmental schemes (AES) are optional measures for farmers under the European Agricultural Fund for Rural Development as part of the Common Agricultural Policy. The specific design of the measures differs by member state or even at regional level. AES are introduced in FarmDyn in a modular structure, allowing the inclusion of case study specific measures and data. In the following, the measures of the German Federal State of North Rhine-Westphalia are presented, reflecting the prolonged funding period 2014 to 2020.

Sets and equations can be found in the file *model\\aes_module_DE.gms*, corresponding parameter values and the definition of specific sets are listed in *dat\\aes_de_nrw_2020.gms*. The equations are organized in line with existing measures.

To receive funding for a diverse crop rotation, minimum number of crops have to be grown on a farm and minimum and maximum crop shares of certain crops must be present. Binary triggers are introduced to capture all requirements, as for example for the obligation that every crop is not allowed to cover more than a maximum share of arable land. The binary trigger, *v\_triggerAes* equals one if the crop share is above maximum allowed share of arable land for a single crop.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/aes_module_DE.gms GAMS /triggerDivRotMaxcrop_\(curCrops\(arabCrops\),t_n\(tCur,nCur\)\) \$ \( \(not sameas\(arabCrops,"idle"\)\) \$ \(not catchcrops\(arabCrops\)\)  \)\.\./ /;/)
```GAMS
triggerDivRotMaxcrop_(curCrops(arabCrops),t_n(tCur,nCur)) $ ( (not sameas(arabCrops,"idle")) $ (not catchcrops(arabCrops))  )..

        sum( c_p_t_i(arabcrops,plot,till,intens), v_cropHa(arabcrops,plot,till,intens,tCur,nCur))
          -  v_triggerAes("DivRotMaxcrop",arabcrops,tCur,nCur) * p_nArabLand  =l=  p_nArabLand * p_DivRotMax;
```

Following the same concept, equations with binary triggers are needed for other requirements of the diverse crop rotation. Finally, all binary triggers are transferred into a single summary trigger. If one of the triggers is equal one, the summary trigger also has to be one and no payments are realized. This ensures that the payment only takes place if all requirements are fulfilled.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/aes_module_DE.gms GAMS /sumTriggerDivRot_\(t_n\(tCur,nCur\)\) \.\./ /;/)
```GAMS
sumTriggerDivRot_(t_n(tCur,nCur)) ..

    v_triggerAes("SumDivRot","",tCur,nCur) * 4  =g=   v_triggerAes("DivRotMax","",tCur,nCur)
                                                    + v_triggerAes("DivRotNum","",tCur,nCur)
                                                    + v_triggerAes("DivRotCropGroupMaxSingleT","",tCur,nCur)
                                                    + v_triggerAes("DivRotCropGroupMinSingleT","",tCur,nCur);
```

In the following equation, the payment for the diverse crop rotation is calculated. If the summary trigger equals one, the requirements are not fulfilled and the payment is zero.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/aes_module_DE.gms GAMS /aesPremDivRot_\(t_n\(tCur,nCur\)\)  \.\./ /;/)
```GAMS
aesPremDivRot_(t_n(tCur,nCur))  ..

    v_aesPremSchemes("DivRot",tCur,nCur)  =e=  p_nArabLand  *  p_aesPayDiVRot  *  ( 1 - v_triggerAes("sumDivRot","",tCur,nCur)) ;
```

Flower strips and areas are another common measure of AES. The only restriction is that flower strips are not allowed to exceed a certain share of the arable land.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/aes_module_DE.gms GAMS /FloStrMaxArabLand_\(t_n\(tCur,nCur\)\) \.\./ /;/)
```GAMS
FloStrMaxArabLand_(t_n(tCur,nCur)) ..

    sum(c_p_t_i(curCrops(flowerStrips),plot,till,intens), v_cropHa(flowerStrips,plot,till,intens,tCur,nCur)  )
                =l= p_maxFloStr * p_nArabLand ;
```
In the following equation, the payments for flower strips and areas are summarized. Payments are linked to the size for different flower strips and areas, represented by the variable v_cropha.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/aes_module_DE.gms GAMS /aesPremFloStr_\(t_n\(tCur,nCur\)\)  \.\./ /;/)
```GAMS
aesPremFloStr_(t_n(tCur,nCur))  ..

    v_aesPremSchemes("FlowerStrips",tCur,nCur) =e= sum(c_p_t_i(curCrops(flowerStrips),plot,till,intens),

                                                        v_cropHa(flowerStrips,plot,till,intens,tCur,nCur) *  p_aesPayFlowerStrips(flowerStrips)  )   ;
```
The catch crop cultivation during winter as another measure is only relevant in areas of the Water Framework Directive. Please note that this voluntary measure is not in place anymore as catch crop cultivation in nitrate polluted areas is obligatory under the Fertilization Ordinance 2020. To receive payments, minimum and maximum shares of catch crops have to be grown. As the equation for the minimum area exemplary illustrates, the binary trigger turns 0 if the required area is not present.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/aes_module_DE.gms GAMS /CCMinAES_\(t_n\(tCur,nCur\)\)  \.\./ /;/)
```GAMS
CCMinAES_(t_n(tCur,nCur))  ..

    sum(c_p_t_i(curCrops(aesCatchCrops),plot,till,intens), v_cropHa(aesCatchCrops,plot,till,intens,tCur,nCur) )

                 =g=      p_ShareLandWFD *  p_CCMinAES * p_nArabLand   *  v_TriggerAes("ShareCC","",tCur,nCur);
```

The payments for catch crops under the AES are then calculated in the following equation.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/aes_module_DE.gms GAMS /aesPremCC_\(t_n\(tCur,nCur\)\)  \.\./ /;/)
```GAMS
aesPremCC_(t_n(tCur,nCur))  ..

    v_aesPremSchemes("CatchCropsAES",tCur,nCur) =e=  sum(c_p_t_i(curCrops(aesCatchCrops),plot,till,intens),

                                                        v_cropHa(aesCatchCrops,plot,till,intens,tCur,nCur) * p_aesPayCC(curcrops)  )    ;
```
In addition, strips along surface waters are supported under AES. The length of boarders between farm land and surface waters has to be defined via the graphical user interface. The strips have to be in a predefined range of width, which is covered in two equations. The following equations exemplary illustrates how the minimum width is ensured.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/aes_module_DE.gms GAMS /SSWMinAES_\(t_n\(tCur,nCur\)\)  \.\./ /;/)
```GAMS
SSWMinAES_(t_n(tCur,nCur))  ..

    sum(c_p_t_i(curcrops(waterStrips),plot,till,intens), v_cropHa(waterStrips,plot,till,intens,tCur,nCur) )

                =g=     ( p_LandAlongSurfaceWaters *  p_SSWMinWidthAES  /10000 )        *  v_triggerAes("AreaSSW","",tCur,nCur)  ;
```

The payments for strips along surface waters are the calculated in the following equation.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/aes_module_DE.gms GAMS /aesPremSSW_\(t_n\(tCur,nCur\)\)  \.\./ /;/)
```GAMS
aesPremSSW_(t_n(tCur,nCur))  ..

    v_aesPremSchemes("StripsWaterAES",tCur,nCur) =e= sum(c_p_t_i(curCrops(waterStrips),plot,till,intens),

                                                          v_cropHa(waterStrips,plot,till,intens,tCur,nCur) * p_aesPaySSW(waterStrips) );
```

Finally, the payments for the different measures of the AES are summarized.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/aes_module_DE.gms GAMS /aesPrem_\(t_n\(tCur,nCur\)\)  \.\./ /;/)
```GAMS
aesPrem_(t_n(tCur,nCur))  ..

    v_aesPrem(tCur,nCur) =e= sum(aesSchemes, v_aesPremSchemes(aesSchemes,tCur,nCur) );
```

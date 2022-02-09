# Fertilisation Ordinance

The German Fertilisation Ordinance implements the EU Nitrates Directive in Germany together with other environmental regulations. It consists of numerous measures which prescribe how farmers are allowed to use nutrients from manure and chemical fertiliser along with further management specifications. The most prominent measures of the Fertilisation Ordinance are included in FarmDyn, being (1) nutrient balance restrictions, (2) an organic nitrogen application threshold, (3) binding fertiliser planning, (4) required manure storage capacities, (5) banning periods for fertiliser application, (6) restriction of fertiliser application in autumn, (7) low-emission manure application techniques, (8) obligatory catch crop cultivation.

The equations regarding the Fertilisation Ordinance are mainly found in the Fertilisation Ordinance module (*gams\\model\\fertord\_module\_DE.gms*). Measures with regard to the storage capacity are partly found in the Manure module (*gams\\model\\manure\_module.gms*). FarmDyn is used to asses the revision of the Fertilisation Ordinance in 2020. Therefore, the Ordinance from 2007, 2017 and 2020 can be directly selected in the Graphical User Interface (GUI) to activate the corresponding measures. In addition thresholds and requirements can be modified separately in the GUI.

## Nutrient Balance Restrictions

The German Fertilisation Ordinance requires that farms calculate a nutrient
balance on an annual basis for nitrogen and phosphate (DüV 2007, DüV 2017).
This balance combines nutrient inputs via manure and synthetic fertiliser with nutrient
removal via the harvested crops. The surplus, i.e. the balance, is not allowed to exceed a certain threshold.

Nutrient removal via harvested product is calculated depending on its yield level and nutrient content. The main harvested product, as well as straw from cereal production which can be sold in FarmDyn are covered.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/fertord_module_DE.gms GAMS /nutRemovalDuev_\(.*?\.\./ /;/)
```GAMS
nutRemovalDuev_(nut,tCur(t),nCur) $ t_n(t,nCur) ..

       v_nutRemovalDuev(nut,t,nCur)
             =e=

                sum( (c_p_t_i(curCrops,plot,till,intens)), v_cropHa(curCrops,plot,till,intens,t,nCur)
                            * sum( (plot_soil(plot,soil),curProds) $  p_OCoeffC%l%(curCrops,soil,till,intens,curProds,t),
                                                        p_OCoeffC(curCrops,soil,till,intens,curProds,t)/p_storageLoss(curCrops)
                                     * (  p_nutContent(curCrops,curProds,"conv",nut) $ (not sameas(till,"org"))
                                        + p_nutContent(curCrops,curProds,"org",nut)  $      sameas(till,"org"))
                                     *10 )   )

               +   sum( (c_p_t_i(curCrops,plot,till,intens)) $ cropsResidueRemo(curCrops),  v_residuesRemoval(curCrops,plot,till,intens,t,nCur)
                          *sum( (plot_soil(plot,soil),curProds),  p_OCoeffResidues(curCrops,soil,till,intens,curProds,t)
                                     *  (  p_nutContent(curCrops,curProds,"conv",nut)$ (not sameas(till,"org"))
                                         + p_nutContent(curCrops,curProds,"org",nut) $      sameas(till,"org"))
                                          * 10  )  )

                                                                      ;
```

Nutrient input via synthetic fertiliser is calculated.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/fertord_module_DE.gms GAMS /synthAppliedDueV_\(.*?\.\./ /;/)
```GAMS
synthAppliedDueV_(nut,tCur(t),nCur)  $ t_n(t,nCur)..

           v_synthAppliedDueV(nut,t,nCur)    =e=

                              sum( (c_p_t_i(curCrops(crops),plot,till,intens),curInputs(syntFertilizer),m),
                                 v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)
                                           * p_nutInSynt(syntFertilizer,nut) )      ;
```
Input via animal manure is calculated.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/fertord_module_DE.gms GAMS /nutExcrDueV_.*?\.\./ /;/)
```GAMS
nutExcrDueV_(nut,nType,tCur(t),nCur)  $ t_n(t,nCur)..

       v_nutExcrDuev(nut,nType,t,nCur) =e=

           sum((actHerds(possHerds,breeds,feedRegime,t,m)) $ (
                               $$ifi defined cattle               (cattle(possHerds)  and sameas(nType,"cattle")) or
                               $$ifi defined pigherds             (pigHerds(possHerds) and sameas(nType,"pig"))
                               $$ifi not defined pigherds         ( 1 eq 2)
                                                               ),
                v_herdSize(possHerds,breeds,feedRegime,t,nCur,m)

                             * ( 1 - 1   $ sameas(feedRegime,"fullGraz")
                                   - 0.5 $ sameas(feedRegime,"partGraz"))

                              * 1/card(m)   *  p_nutExcreDueV(possHerds,feedRegime,nut) );
```

Input via digestates from biogas production is calculated (only digestate from plant origin as for instance silage maize).

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/fertord_module_DE.gms GAMS /nutBiogasDuev_.*?\.\./ /;/)
```GAMS
nutBiogasDuev_(nut,tCur(t),nCur)  $ t_n(t,nCur)..

          v_nutBiogasDuev(nut,t,nCur) =e=

                sum( (curmanchain, m,nut2) $ (not sameas (nut2,"P")),
                    v_nutCropBiogasM(curmanchain,nut2,t,nCur,m)   + sum(curmaM, v_nut2ManurePurch(curmanchain,nut2,curmaM,t,nCur,m) ))  $ (sameas (nut,"N") $ sum(sameas(manchain,"LiquidBiogas"),1))

                     +  sum( (curmanchain,m) , v_nutCropBiogasM(curmanchain,"P",t,nCur,m) + sum(curmaM, v_nut2ManurePurch(curmanchain,"P",curmaM,t,nCur,m))) $ (sameas (nut,"P")  $ sum(sameas(manchain,"LiquidBiogas"),1))
              ;
```


In the equation *nutBalDuev\_*, nutrient inputs and outputs are combined. Manure nitrogen is accounted with
factors defined by the Fertilisation Ordinance. As a supplement to nutrient inputs
and outputs, the import and export of manure nutrients are included into the equation.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/fertord_module_DE.gms GAMS /nutBalDueV_\(.*?\.\./ /;/)
```GAMS
nutBalDueV_(nut,tCur(t),nCur) $ t_n(t,nCur) ..

   v_surplusDueV(t,nCur,nut)

         =e=

*   --- Nutrients excreted from animals in stable time specific loss factor

    $$ifi %herd% == true      sum(nType,v_nutExcrDuev(nut,nType,t,nCur))  *  p_nutEffectivDueVNv(nut)

*   --- Nutrients excreted during grazing

    $$iftheni.cattle "%cattle%" == "true"

            +  sum(m $(  sum(grasscrops $(p_grazMonth(grassCrops,m)>0),1)
                       $ sum(actHerds(possHerds,breeds,grazRegime,t,m),1) ),
                  v_nutExcrPast(nut,t,nCur,m)    *  p_nutEffectivDueVNv(nut))

    $$endif.cattle

*  --- Nutrients coming from biogas plant (including energy crops and purchased manure)

    $$ifi %biogas% == true + v_nutBiogasDuev(nut,t,nCur)  *  p_nutEffectivDueVNvBiogas(nut)

*  --- Applied synthetic fertilizer

         + v_synthAppliedDueV(nut,t,nCur)

*  --- Nutrient from N fixation from legumes in grassland
         + sum(  (c_p_t_i(crops,plot,till,intens)) ,
                   v_cropHa(crops,plot,till,intens,t,nCur) *   (   p_NfromLegumes(Crops,"org")   $ sameas(till,"org")
                                                                +  p_NfromLegumes(Crops,"conv")  $ (not sameas(till,"org"))
                                                                ))       $ (sameas (nut,"N") )
      $$iftheni.data "%database%" == "KTBL_database"
*
*     --- Nutrient from vegetables
*
         + sum(  (c_p_t_i(crops,plot,till,intens)) ,
                   v_cropHa(crops,plot,till,intens,t,nCur) *   (   p_NfromVegetables(Crops))
                                                                )       $ (sameas (nut,"N") )
      $$endif.data
*
* --- Import of manure
*
       $$iftheni.im "%AllowManureImport%" == "true"

         +   sum ( (nut2_nut(nut2,nut),m),   v_manImport(t,nCur,m) *    p_nut2inMan(nut2,"manImport","LiquidImport") )   * (1- (p_nutEffectivDueVAl("import") - p_nutEffectivDueVNv("N") ))   $ sameas (nut,"N")
         +   sum ( (nut2_nut(nut2,nut),m),   v_manImport(t,nCur,m) *    p_nut2inMan(nut2,"manImport","LiquidImport") )      $ sameas (nut,"P")

       $$endif.im

*  --- Crop output (nutrient removal)

         -   v_NutRemovalDuev(nut,t,nCur)

$iftheni.h %herd% == true

*   --- Nutrients exported from farm

      $$iftheni.ExMan %AllowManureExport%==true

        -  sum( (curManChain,m,nut2) $(not sameas (nut2,"P")), v_nut2export(curManChain,nut2,t,nCur,m) )   $ sameas (nut,"N")
        -  sum( (curManChain,m), v_nut2export(curManChain,"P",t,nCur,m) )                                 $ sameas (nut,"P")

      $$endif.ExMan

      $$iftheni.emissionRight not "%emissionRight%"==0

        -  sum( (curManChain,m,nut2) $(not sameas (nut2,"P")), v_nut2exportMER(curManChain,nut2,t,nCur,m) )  $ sameas (nut,"N")
        -  sum( (curManChain,m),                               v_nut2exportMER(curManChain,"P",t,nCur,m) )   $ sameas (nut,"P")

      $$endif.emissionRight

$endif.h
      ;
```

The surplus, *v\_surplusDueV,* is not allowed to exceed a certain
threshold, which changes from Fertilisation Ordinance 2007 to 2017. Under the Fertilisation Ordinance 2020, this restriction is not in place anymore.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/fertord_module_DE.gms GAMS /nutSurplusDueVRestr_.*?\.\./ /;/)
```GAMS
nutSurplusDueVRestr_ (tCur(t),nCur,nut)   $ (p_surPlusDueVMax(t,nut) $ t_n(t,nCur))  ..

       v_surplusDueV(t,nCur,nut)

         =L=  p_surplusDueVMax(t,nut) * v_croplandActive(t,nCur) *  ( 1 - p_soilShareNutEnriched $ sameas (nut,"P"));
```

## Organic Nitrogen Application Threshold

Farms have to calculate the application of manure N and, under the Fertilisation Ordinance 2017, N from biogas digestate. The derived value
is not allowed to exceed a threshold related to farm area in ha.

As input for manure N, animal excretion *v_nutExcrDuev(nut,t,nCur)\_* is included, and the input from biogas is calculated
separately in the following equation.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/fertord_module_DE.gms GAMS /nutBiogasDueVAccAL_.*?\.\./ /;/)
```GAMS
nutBiogasDueVAccAL_(tCur(t),nCur)  $ t_n(t,nCur)..

      v_nutBiogasDueVAccAL(t,nCur) =e=

           sum( (curmanchain,m,nut2N), v_nutCropBiogasM(curmanchain,nut2N,t,nCur,m)        * p_nutEffectivDueVAlBiogasPlantDig

                             *  p_NincludeBioDigest )

        +  sum ( (curBhkw(bhkw), curEeg(eeg),curmaM,m,nut2N),
                                 v_purchManure(bhkw,eeg,curmaM,t,nCur,m) * p_nut2manPurch("LiquidBiogas",nut2N,curmaM)
                                                                        *  p_nutEffectivDueVAlBiogasPurchMan(curmaM)  ) ;
```

The N input from manure and biogas digestate and manure import is summarized in the following equation. The export of manure
is substracted. The variable *v_DueVOrgN* returns the accordance of nitrogen from organic sources at a farm level.
The nitrogen has to be accounted with factors defined by the Fertilisation Ordinance.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/fertord_module_DE.gms GAMS /DuevOrgN_.*?\.\./ /;/)
```GAMS
DuevOrgN_(tCur(t),nCur) $ t_n(t,nCur) ..

        v_DueVOrgN (t,nCur)  =E=

*          --- Nutrients excreted in stable
           $$ifi "%herd%" == "true"  sum(nType,v_nutExcrDuev("N",nType,t,nCur)*   p_nutEffectivDueVAl(nType))

*          --- Nutrients excreted during grazing
           $$iftheni.cattle "%cattle%" == "true"

            +  sum(m $(  sum(grasscrops $(p_grazMonth(grassCrops,m)>0),1)
                       $ sum(actHerds(possHerds,breeds,grazRegime,t,m),1) ),
                  v_nutExcrPast("N",t,nCur,m) * p_nutEffectivDueVAlPast)
            $$endif.cattle

*           --- Nutrients imported to the farm

            $$ifi "%AllowManureImport%" == "true" +  sum ( (nut2N,m), v_manImport(t,nCur,m) * p_nut2inMan(nut2N,"manImport","LiquidImport") )

*           --- Nutrients exported from farm

            $$ifi "%AllowManureExport%"=="true"  -  sum( (curManChain,m,nut2N), v_nut2export(curManChain,nut2N,t,nCur,m) )
            $$ifi not "%emissionRight%"==0       -  sum( (curManChain,m,nut2N), v_nut2exportMER(curManChain,nut2N,t,nCur,m) )

*           --- Nutrients coming from biogas plant, included depending on FD, calculated in fermenter tech

           $$ifi %biogas% == true +  v_nutBiogasDueVAccAL(t,nCur)
;
```

The N input is not allowed to exceed a target value defined by the Fertilisation Ordinance, being 170 kg N/ha/a in most cases.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/fertord_module_DE.gms GAMS /DuevOrgNLimit_.*?\.\./ /;/)
```GAMS
DuevOrgNLimit_ (tCur(t),nCur) $ t_n(t,nCur) ..

      v_DueVOrgN (t,nCur)

            =L=

             sum(  (c_p_t_i(curCrops(crops),plot,till,intens))  $ ( not catchcrops(crops) )  ,
                       p_nutManApplLimit(crops,t) * v_cropHa(crops,plot,till,intens,t,nCur)) ;
```

Under the Fertilisation Ordinance 2020, the manure application is additionally restricted at crop level in so-called red zones:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/fertord_module_DE.gms GAMS /DuevOrgNLimitCrop\_\(curCrops\(crops\),tCur\(t\),nCur\)/ /;/)
```GAMS
DuevOrgNLimitCrop_(curCrops(crops),tCur(t),nCur) $ ( t_n(t,nCur) $ ( not catchcrops(crops) )  ) ..

      sum( (c_p_t_i(crops,plotInNO3zone(plot),till,intens),manApplicType_manType(ManApplicType,curManType),m,nut2N)
               $  ( v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0),

                     v_manDist(crops,plotInNO3zone,till,intens,manApplicType,curManType,t,nCur,m)
                         * sum(manChain_applic(manChain,ManApplicType), p_nut2inMan(nut2N,curManType,manChain)) )

      $$iftheni.dh "%cattle%" == "true"
*                --- excretion on pasture
              +  sum( (c_p_t_i(pastCrops(crops),plotInNO3zone(plot),till,intens),nut2N,m)
                          $ ((p_grazMonth(Crops,m)>0)
                                $ sum(actHerds(possHerds,breeds,grazRegime,t,m)  $ p_nutExcreDueV(possHerds,grazRegime,nut2N),1)),
                                              v_nut2ManurePast(crops,plot,till,intens,nut2N,t,nCur,m) )
      $$endif.dh

                    =L=

                     sum( (c_p_t_i(crops,plotInNO3zone(plot),till,intens))   ,
                               p_nutManApplLimit(crops,t)
                                   * v_cropHa(crops,plotInNO3zone,till,intens,t,nCur) * p_bigNumberFOAppLimCrop  )  ;
```

## Binding Fertiliser Planning

Under the Fertilisation Ordinance 2017 and 2020, farms have to do an obligatory fertiliser planning based on the expected yields.
The derived nutrient need with regard to nitrogen must not be exceeded. This allows to calculate a nitrogen
quota which farms have to meet. The fertiliser quota is always calculated if the Fertilisation Ordinance is switched on.
However, it only becomes binding for fertiliser application under the Fertilisation Ordinance 2017 and 2020.

The nutrient input is summarised in the equation *FertQuotaInput_*. Nutrients from chemical fertiliser, manure and mineralisation
from the soil are taken into account. Manure N is accounted with mineral fertiliser equivalents defined by the Ordinance.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/fertord_module_DE.gms GAMS /FertQuotaInput_.*?\.\./ /;/)
```GAMS
FertQuotaInput_(c_p_t_i(curCrops(crops),plot,till,intens),nut,t_n(tCur(t),nCur))    ..

     v_FertQuotaInput(crops,plot,till,intens,nut,t,nCur)

            =e=

                  sum (  (curInputs(syntFertilizer),m) $ (v_syntDist.up(crops,plot,till,intens,syntFertilizer,t,nCur,m) ne 0),
                              v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)     * p_nutInSynt(syntFertilizer,nut) )

*
*          --- note that the fertilizer ordinance already considers in the crop need (!)
*              nutrient excreted curing the grazing
*
$iftheni.man %manure% == true

               +  sum ( (manApplicType_manType(ManApplicType,curManType),m)
                                     $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0) ,

                          v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                              * sum( (nut2_nut(nut2,nut),manChain_applic(curManChain,ManApplicType)),
                                      p_nut2inMan(nut2,curManType,curManChain)*p_nutEffFOPlan(curManType,crops,m,nut)))
$endif.man

     ;
```

Furthermore, the plant nutrient need is calculated. It depends on the yield level and is precisely defined by the Fertilisation
Ordinance.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/fertord_module_DE.gms GAMS /FertQuotaNeed_\(c\_p\_t\_i/ /;/)
```GAMS
FertQuotaNeed_(c_p_t_i(curCrops(crops),plot,till,intens),nut,tCur(t),nCur) $ ( card(p_nNeedFerPlan)
         $ (not (catchCrops(crops) or sameas(crops,"idle") or sameas(crops,"idleGras")))) ..

     v_FertQuotaNeed(crops,plot,till,intens,nut,t,nCur)

                 =e=

                    v_cropHa(crops,plot,till,intens,t,nCur)
                          * sum(plot_soil(plot,soil),
*                           --- N need depending on yield level which is reflected in p_NneedFerPlan
                                  p_NneedFerPlan(crops,soil,till,intens,nut,t)
*                           --- Nmin in spring. For grassland, the value is always 30. Nmin of crop is accounted
*                               for the same crop as crop rotation is not reflected in the standard setting.
                              -   p_NutFromSoil(crops,soil,till,nut,t))
                            ;
```

The plant nutrient input is not allowed to exceed the estimated nutrient need. The restriction becomes only binding under the Fertilisation Ordinance
2017 and 2020. The parameter *p\_bigNumberFO* is a very large number under Fertiliser Ordinance 2007 which ensures that the nutrient need is extremely high and not binding.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/fertord_module_DE.gms GAMS /FertQuota_\(c\_p\_t\_i/ /;/)
```GAMS
FertQuota_(c_p_t_i(curCrops(crops),plot,till,intens),nut,t_n(tCur(t),nCur))
        $ (sum(plot_soil(plot,soil), p_NneedFerPlan(crops,soil,till,intens,nut,t))
             $ (not (catchcrops(crops) or sameas(crops,"idle") or sameas (crops,"idleGras")))) ..

       v_FertQuotaInput(crops,plot,till,intens,nut,t,nCur)  =l=    v_FertQuotaNeed(crops,plot,till,intens,nut,t,nCur)  * p_bigNumberFO  ;
```

Under the FO 2020, additional restrictions to the fertilising planning apply in so-called red zones:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/fertord_module_DE.gms GAMS /FertQuotaNZone_\(tCur\(t\),nCur\)/ /;/)
```GAMS
FertQuotaNZone_(tCur(t),nCur) $ ( t_n(t,nCur)) ..


     sum (c_p_t_i(curCrops(crops),plotInNO3zone,till,intens)
          $ (not (catchcrops(crops) or sameas(crops,"idle") or sameas (crops,"idleGras"))),
                  v_FertQuotaInput(crops,plotInNO3zone,till,intens,"N",t,nCur))

             =l=

    sum (c_p_t_i(curCrops(crops),plotInNO3zone,till,intens)
         $ (not (catchcrops(crops) or sameas(crops,"idle") or sameas(crops,"idleGras"))),
                 v_FertQuotaNeed(crops,plotInNO3zone,till,intens,"N",t,nCur) ) * p_FertQuotaRed ;
```

## Required Manure Storage Capacities

Farms are required to hold a minimum storage capacity to bridge the time in autumn and winter when manure application is not allowed. This storage
capacity was defined at federal state level under the Fertilisation Ordinance 2007. Under the Fertilisation Ordinance 2017 and 2020, it is defined at federal level in the Fertilisation Ordinance.

Generally, farms have to hold a manure storage capacity to gap the amount of manure excretion corresponding to a certain time period, e.g. 6 months.
Therefore, the required storage capacity is defined in the manure module. The parameter *p\_ManureStorageNeed* defines the required number of months and is linked to the selected Fertilisation Ordinance.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/manure_module.gms GAMS /manStorCapNeed_.*?\.\./ /;/)
```GAMS
manStorCapNeed_(curManChain(manChain),tCur(t),nCur) $ (t_n(t,nCur) $ p_ManureStorageNeed)   ..

          v_ManStorCapNeed(manChain,t,nCur)

            =e=  p_ManureStorageNeed   * (


    $$ifi %herd% == true      v_manQuant(manChain,t,nCur) $ (not sameas (manchain, "LiquidBiogas"))

*  --- required silo storage capacity for biogas plant digestate (including energy crops and purchased manure)

    $$ifi %biogas% == true    + sum((crM(biogasfeedM),m), v_voldigCrop(crM,t,nCur,m) + v_volDigMan(t,nCur,m)) $ sameas ("LiquidBiogas",manchain)

                                    );
```

Under the Fertilisation Ordinance 2017 and 2020, farms exceeding a stocking density of 3 livestock units per ha have to hold additional manure storage capacity.
This is implemented with a binary trigger in FarmDyn. The variable *v\_triggerStorageGVha* becomes one when the farm exceeds the livestock unit threshold.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/fertord_module_DE.gms GAMS /triggerStorageGVha_.*?\.\./ /;/)
```GAMS
triggerStorageGVha_(tCur(t),nCur) $t_n(t,nCur) ..

             (    v_sumGV(t,nCur)   /   sum(plot, p_plotSize(plot))  ) - 3  =l= v_triggerStorageGVha(t,nCur) *  200 ;
```

If the variable *v\_triggerStorageGVha* is 1, the restriction in the following equation becomes binding:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/fertord_module_DE.gms GAMS /manStorCapGVDepend_.*?\.\./ /;/)
```GAMS
manStorCapGVDepend_(curManChain(manChain),tCur(t),nCur) $ t_n(t,nCur) ..

            v_TotalManStorCap(manChain,t,nCur)
                     =g= v_manQuant(manChain,t,nCur) *  p_ManureStorageNeedGV
                                        - ( (1 -  v_triggerStorageGVha(t,nCur) ) * p_bigNumber ) ;
```

## Banning Periods for Fertiliser Application

During certain months of the year, the application of fertiliser is not allowed as there is no plant nutrient need and the risk of nitrate leaching is very high.
This is implemented in FarmDyn by setting the variable *v\_mandist* and *v\_syntdist* to zero for certain months which disables fertiliser application in the model.

Depending on the Fertilisation Ordinance selected, sets are defined which include the months in which fertiliser application is forbidden.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/fertord_duev2007.gms GAMS /set.*?monthApplicationForbidden/ /;/)
```GAMS
set monthApplicationForbidden(m)                    /Dec,Jan /  ;
```
[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/fertord_duev2007.gms GAMS /set.*?monthApplicationForbiddenArab/ /;/)
```GAMS
set monthApplicationForbiddenArab(m)            /Nov,Dec,Jan /  ;
```

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/fertord_duev2007.gms GAMS /set.*?monthApplicationForbiddenGrass/ /;/)
```GAMS
set monthApplicationForbiddenGrass(m)              / Dec,Jan /  ;
```


[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/fertord_duev2017.gms GAMS /set.*?monthApplicationForbidden/ /;/)
```GAMS
set  monthApplicationForbidden(m)              /Nov,Dec,Jan / ;
```
[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/fertord_duev2017.gms GAMS /set.*?monthApplicationForbiddenArab/ /;/)
```GAMS
set  monthApplicationForbiddenArab(m)      /Oct,Nov,Dec,Jan / ;
```

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/fertord_duev2017.gms GAMS /set.*?monthApplicationForbiddenGrass/ /;/)
```GAMS
set  monthApplicationForbiddenGrass(m)        / Nov,Dec,Jan / ;
```


[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/fertord_duev2020.gms GAMS /set.*?monthApplicationForbidden/ /;/)
```GAMS
set  monthApplicationForbidden(m)              /Nov,Dec,Jan / ;
```
[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/fertord_duev2020.gms GAMS /set.*?monthApplicationForbiddenArab/ /;/)
```GAMS
set  monthApplicationForbiddenArab(m)      /Oct,Nov,Dec,Jan / ;
```

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/fertord_duev2020.gms GAMS /set.*?monthApplicationForbiddenGrass/ /;/)
```GAMS
set  monthApplicationForbiddenGrass(m)        / Nov,Dec,Jan / ;
```

For the months which are defined in the described sets, the variables for fertiliser application are set to zero.
There are differences between the various fertiliser ordinances. The following part of code is an example of the Fertiliser Ordinance 2017. There are corresponding documents for the other fertiliser ordinances.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/fertord_duev2017.gms GAMS /set  monthApplicationForbidden\(m\)/ /\$\$endif\.v\_manDist/)
```GAMS
set  monthApplicationForbidden(m)              /Nov,Dec,Jan / ;
  set  monthApplicationForbiddenArab(m)      /Oct,Nov,Dec,Jan / ;
  set  monthApplicationForbiddenGrass(m)        / Nov,Dec,Jan / ;

  v_syntDist.up(arabCrops(crops),plot,till,intens,syntFertilizer,t,nCur,monthApplicationForbiddenArab(m))
                                                        $ ( t_n(t,nCur) $ c_p_t_i(crops,plot,till,intens) )  = 0 ;

  v_syntDist.up(grassCrops(crops),plot,till,intens,syntFertilizer,t,nCur,monthApplicationForbiddenGrass(m))
                                                        $ ( t_n(t,nCur) $ c_p_t_i(grassCrops,plot,till,intens) )  = 0 ;

$$iftheni.v_manDist declared v_manDist
   v_volManApplied.up(manChain,t,nCur,monthApplicationForbidden) $ t_n(t,nCur)  = 0;
   v_nut2ManApplied.up(crops,manChain,nut2,t,nCur,monthApplicationForbidden) $ t_n(t,nCur) = 0;
   v_manDist.up(crops,plot,till,intens,manApplicType_manType(manApplicType,curmanType),t,nCur,monthApplicationForbidden)
            $ (t_n(t,nCur) $  c_p_t_i(crops,plot,till,intens)) = 0;

   v_manDist.up(arabCrops(crops),plot,till,intens,manApplicType_manType(manApplicType,curManType),t,nCur,monthApplicationForbiddenArab)
        $ (t_n(t,nCur) $ c_p_t_i(crops,plot,till,intens)) = 0;

   v_manDist.up(grassCrops(crops),plot,till,intens,manApplicType_manType(manApplicType,curManType),t,nCur,monthApplicationForbiddenGrass)
        $ (t_n(t,nCur) $ c_p_t_i(crops,plot,till,intens)) = 0;
  $$endif.v_manDist
```



## Restriction of Fertiliser Application in Autumn

In addition to the fixed banning periods, the application of fertiliser in autumn is only legal for some crops and restricted
to a defined amount of nitrogen per ha. The parameter *p\_NLimitInAutumn* contains the allowed amount of N and is
defined depending on the Fertilisation Ordinance. Catch crops allow additional manure application in autumn.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/fertord_module_DE.gms GAMS /NLimitAutumn_.*?c_[\s\S]*?\.\./ /;/)
```GAMS
NLimitAutumn_ (c_p_t_i(curCrops(crops),plot,till,intens),t_n(tCur(t),nCur))
                              $ (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0) ..


$iftheni.man %manure% == true

                     sum( (manChain_type(curManChain,curManType),manApplicType_manType(ManApplicType,curManType),nut2N,m)
                          $ ((v_manDist.up(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m) ne 0)  $ monthHarvestBlock(crops,m)),
                                v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                                    *   p_nut2inMan(nut2N,curManType,curManChain) )

$endif.man

                     +    sum( (syntFertilizer,m) $ monthHarvestBlock(crops,m),
                              v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)
                                 *   p_nutInSynt(syntFertilizer,"N")  )

                      =l=       v_cropHa(crops,plot,till,intens,t,nCur)  *   p_NLimitInAutumn(crops,plot)

                       ;
```


## Low-Emission Manure Application Techniques

The Fertilisation Ordinance defines which manure application techniques are legally allowed. Under the Fertilisation Ordinance 2017, broadcast spreading
is banned except on fallow land followed by direct incorporation. This measure is introduced in FarmDyn by setting the variable
*v\_mandist* to zero for certain months and not allowed application techniques.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/fertord_duev2017.gms GAMS /\$\$iftheni\.v\_manDist/ /\$\$endif\.v\_manDist/)
```GAMS
$$iftheni.v_manDist declared v_manDist
   v_volManApplied.up(manChain,t,nCur,monthApplicationForbidden) $ t_n(t,nCur)  = 0;
   v_nut2ManApplied.up(crops,manChain,nut2,t,nCur,monthApplicationForbidden) $ t_n(t,nCur) = 0;
   v_manDist.up(crops,plot,till,intens,manApplicType_manType(manApplicType,curmanType),t,nCur,monthApplicationForbidden)
            $ (t_n(t,nCur) $  c_p_t_i(crops,plot,till,intens)) = 0;

   v_manDist.up(arabCrops(crops),plot,till,intens,manApplicType_manType(manApplicType,curManType),t,nCur,monthApplicationForbiddenArab)
        $ (t_n(t,nCur) $ c_p_t_i(crops,plot,till,intens)) = 0;

   v_manDist.up(grassCrops(crops),plot,till,intens,manApplicType_manType(manApplicType,curManType),t,nCur,monthApplicationForbiddenGrass)
        $ (t_n(t,nCur) $ c_p_t_i(crops,plot,till,intens)) = 0;
  $$endif.v_manDist
```


## Obligatory Catch Crop Cultivation

Under the Fertilisation Ordinance 2020, the cultivation of catch crops is obligatory in so-called red zones:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/fertord_module_DE.gms GAMS /CatchCropRequiredFO_\(tCur\(t\),nCur\)/ /;/)
```GAMS
CatchCropRequiredFO_(tCur(t),nCur) $t_n(t,nCur) ..

      sum(c_p_t_i(curCrops(Crops),plotInNO3zone,till,intens)
                 $catchcrops(crops), v_cropHa(crops,plotInNO3zone,till,intens,t,nCur))
            =g=

         sum( c_p_t_i(curCrops(crops),plotInNO3zone,till,intens) $ summerHarvest(Crops),
                                           v_cropHa(crops,plotInNO3zone,till,intens,t,nCur) ) * p_CatchCropRequFO ;
```


# References

DüV (2007): Verordnung über die Anwendung von Düngemitteln, Bodenhilfsstoffen, Kultursubstraten und Pflanzenhilfsmitteln nach den Grundsätzen der guten fachlichen Praxis beim Düngen. "Düngeverordnung in der Fassung der Bekanntmachung vom 27. Februar 2007 (BGBl. I S. 221), die zuletzt durch Artikel 18 des Gesetzes vom 31. Juli 2009 (BGBl. I S. 2585) geändert worden ist".

DüV (2017): Verordnung über die Anwendung von Düngemitteln, Bodenhilfsstoffen, Kultursubstraten und Pflanzenhilfsmitteln nach den Grundsätzen der guten fachlichen Praxis beim Düngen. "Düngeverordnung vom 26. Mai 2017 (BGBl. I S. 1305), die zuletzt durch Artikel 97 des Gesetzes vom 10. August 2021 (BGBl. I S. 3436) geändert worden ist".

DüV (2020): Verordnung über die Anwendung von Düngemitteln, Bodenhilfsstoffen, Kultursubstraten und Pflanzenhilfsmitteln nach den Grundsätzen der guten fachlichen Praxis beim Düngen. "Düngeverordnung vom 26. Mai 2017 (BGBl. I S. 1305), die zuletzt durch Artikel 97 des Gesetzes vom 10. August 2021 (BGBl. I S. 3436) geändert worden ist".

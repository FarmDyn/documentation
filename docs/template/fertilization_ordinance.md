
# Fertilization Ordinance

!!! abstract
    The German Fertilization Ordinance implements the EU Nitrates Directive
    in Germany together with other environmental regulations. It consists of numerous measures
    which prescribe how farmers are allowed to use nutrients from manure and chemical
    fertilizer along with further management specifications. The most prominent measures of the
    Fertilization Ordinance are included in FarmDyn, being (1) nutrient balance restrictions,
    (2) an organic nitrogen application threshold, (3) required manure storage capacities,
    (4) banning periods for fertilizer application, (5) restrictions of fertilizer application in autumn,
    (6) a binding fertilizer planning, (7) compulsory low-emission manure application techniques.

 The equations regarding the Fertilization Ordinace are mainly found in the Fertilization Ordinance
 module (duev_module.gms). Measures with regard to the storage capacity are partly found in the
 manure module. FarmDyn is used to asses the revision of the Fertilization Ordinance in 2017. Therefore,
 the Ordinance from 2007 and 2017 can be directly selected in the GUI to activate the corresponding measues. In addition,
 thresholds and requirements can be modified seperatly in the GUI.

## Nutrient balance restrictions

  The German Fertilization Ordinance requires that farms calculate a nutrient
  balance on an annual basis for nitrogen and phosphate (DüV 2007;DüV 2007).
  This balance combines nutrient inputs via manure and synthetic fertilizer with nutrient
  removal via the harvested crops. The surplus, i.e. the balance, is not allowed to exceed a certain
  threshold.

Nutrient removal via harvested product is calculated, depending on its yield level and nutrient
content. The main harvested product as well as straw from cereal production which can be sold in FarmDyn are covered.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/duev_module.gms GAMS /nutRemovalDuev_\(.*?\.\./ /;/)
```GAMS
nutRemovalDuev_(nut,tCur(t),nCur) $ t_n(t,nCur) ..

       v_nutRemovalDuev(nut,t,nCur)
            =e=

                sum( (c_s_t_i(crops,plot,till,intens)), v_cropHa(crops,plot,till,intens,t,nCur)
                            * sum( (plot_soil(plot,soil),curProds), p_OCoeffC(crops,soil,till,intens,curProds,t)
                                     * p_nutContent(crops,curProds,nut)*10 )   )


               +   sum( (c_s_t_i(crops,plot,till,intens)) $ cropsResidueRemo(crops),  v_residuesRemoval(crops,plot,till,intens,t,nCur)
                          *sum( (plot_soil(plot,soil),curProds),  p_OCoeffResidues(crops,soil,till,intens,curProds,t)
                                     *  p_nutContent(crops,curProds,nut) * 10  )  )

                                                                      ;
```

Nutrient input via synthetic fertilizer is calculated.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/duev_module.gms GAMS /synthAppliedDueV_\(.*?\.\./ /;/)
```GAMS
synthAppliedDueV_(nut,tCur(t),nCur)  $ t_n(t,nCur)..

           v_synthAppliedDueV(nut,t,nCur)    =e=

                              sum( (c_s_t_i(crops,plot,till,intens),syntFertilizer,m),
                                 v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)
                                           * p_nutInSynt(syntFertilizer,nut) )      ;
```
Input via animal manure is calculated.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/duev_module.gms GAMS /nutExcrDueV_.*?\.\./ /;/)
```GAMS
nutExcrDueV_(nut,tCur(t),nCur)  $ t_n(t,nCur)..

       v_nutExcrDuev(nut,t,nCur) =e=

                       sum((actHerds(possHerds,breeds,feedRegime,t,m)),
                                 v_herdSize(possHerds,breeds,feedRegime,t,nCur,m)
                                   * ( 1 - 1   $ sameas(feedRegime,"fullGraz")
                                         - 0.5 $ sameas(feedRegime,"partGraz"))
                    * 1/card(herdM)

                    *  p_nutExcreDueV(possHerds,feedRegime,nut) );
```

Input via digestates from biogas production is calculated (only digestate from plant origin as for instance
silag maize).

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/duev_module.gms GAMS /nutBiogasDuev_.*?\.\./ /;/)
```GAMS
nutBiogasDuev_(nut,tCur(t),nCur)  $ t_n(t,nCur)..

     v_nutBiogasDuev(nut,t,nCur) =e=


           sum( (curmanchain, m,nut2) $ (not sameas (nut2,"P")),
                 v_nutCropBiogasM(curmanchain,nut2,t,nCur,m)   + sum(curmaM, v_nut2ManurePurch(curmanchain,nut2,curmaM,t,nCur,m) ))  $ (sameas (nut,"N") $ sum(sameas(manchain,"LiquidBiogas"),1))

        +  sum( (curmanchain,m) , v_nutCropBiogasM(curmanchain,"P",t,nCur,m) + sum(curmaM, v_nut2ManurePurch(curmanchain,"P",curmaM,t,nCur,m))) $ (sameas (nut,"P")  $ sum(sameas(manchain,"LiquidBiogas"),1))
 ;
```


In the equation *nutBalDuev\_*, nutrient inputs and outputs are combined. Manure N is accounted with
factors defined by the Fertilization Ordinance. As a supplement to nutrient inputs
and outputs, the import and export of manure nutrients are included into the equation.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/duev_module.gms GAMS /nutBalDueV_\(.*?\.\./ /;/)
```GAMS
nutBalDueV_(nut,tCur(t),nCur) $ t_n(t,nCur) ..

$iftheni.h %herd% == true

*   --- Nutrients excreted from animals time specific loss factor

           v_nutExcrDuev(nut,t,nCur)  *  p_nutEffectivDueVNv(nut)
$endif.h

*  --- Nutrients coming from biogas plant (including energy crops and purchased manure)

$iftheni.b %biogas% == true
         + v_nutBiogasDuev(nut,t,nCur)  *  p_nutEffectivDueVNvBiogas(nut)

$endif.b

*  --- Applied synthetic fertilizer

         + v_synthAppliedDueV(nut,t,nCur)


*  --- Nutrient from N fixation from legumes in grassland
         + sum(  (c_s_t_i(crops,plot,till,intens)) ,
                   v_cropHa(crops,plot,till,intens,t,nCur) *   p_NfromLegumes(Crops)  )       $ sameas (nut,"N")


* --- Import of manure
*     [TK][TO DO] add coefficient for accounting for imported manure

       $$iftheni.im "%AllowManureImport%" == "true"

         +   sum ( (nut2_nut(nut2,nut),m),   v_manImport(t,nCur,m) *    p_nut2inMan(nut2,"manImport","LiquidImport") )

       $$endif.im

*  --- Crop output (nutrient removal)

         -   v_NutRemovalDuev(nut,t,nCur)

$iftheni.h %herd% == true

*   --- Nutrients exported from farm

      $$iftheni.ExMan %AllowManureExport%==true

        -  sum( (curManChain,m,nut2) $(not sameas (nut2,"P")), v_nut2export(curManChain,nut2,t,nCur,m) )  $ sameas (nut,"N")
        -  sum( (curManChain,m), v_nut2export(curManChain,"P",t,nCur,m) )                                 $ sameas (nut,"P")

      $$endif.ExMan

      $$iftheni.emissionRight not "%emissionRight%"==0

        -  sum( (curManChain,m,nut2) $(not sameas (nut2,"P")), v_nut2exportMER(curManChain,nut2,t,nCur,m) )  $ sameas (nut,"N")
        -  sum( (curManChain,m),                               v_nut2exportMER(curManChain,"P",t,nCur,m) )   $ sameas (nut,"P")

      $$endif.emissionRight

$endif.h

         =e=

             v_surplusDueV(t,nCur,nut)      ;
```

The surplus, *v\_surplusDueV,* is not allowed to exceed a certain
threshold, which changes from Fertilization Ordinance 2007 to 2017 and, in addition, can be defined in the GUI.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/duev_module.gms GAMS /nutSurplusDueVRestr_.*?\.\./ /;/)
```GAMS
nutSurplusDueVRestr_ (tCur(t),nCur,nut)   $ (p_surPlusDueVMax(t,nut) $ t_n(t,nCur))  ..

       v_surplusDueV(t,nCur,nut)

         =L=
               p_surplusDueVMax(t,nut) *    v_croplandActive(t,nCur) *  ( 1 - p_soilShareNutEnriched)  $ sameas (nut,"P")

                  +     p_surplusDueVMax(t,nut) *    v_croplandActive(t,nCur)     $ sameas (nut,"N")

                  ;
```

## Organic nitrogen application threshold

Farms have to calculate the application of manure N and, under the Fertilization Ordinance 17, N from biogas digestate. The derived value
is not allowed to exceed a threshold related to farm area in ha.

As input for manure N, animal excretion *v_nutExcrDuev(nut,t,nCur)\_*  is included, and the input from biogas is calculated
seperatly in the following equation.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/duev_module.gms GAMS /nutBiogasDueVAccAL_.*?\.\./ /;/)
```GAMS
nutBiogasDueVAccAL_(tCur(t),nCur)  $ t_n(t,nCur)..

      v_nutBiogasDueVAccAL(t,nCur) =e=

           sum( (curmanchain,m,nut2) $ (not sameas (nut2,"P")), v_nutCropBiogasM(curmanchain,nut2,t,nCur,m)        * p_nutEffectivDueVAlBiogasPlantDig

* --- Depending of the Fertilizer Ordinance, the inclusion of digestate N from plant origin can be switched on/off (GUI=optional, FO07 = off, FO17 = on)

                             *  p_NincludeBioDigest )

        +  sum ( (curBhkw(bhkw), curEeg(eeg),curmaM,m,nut2)  $ (not sameas(nut2,"P")),
                                 v_purchManure(bhkw,eeg,curmaM,t,nCur,m) * p_nut2manPurch("LiquidBiogas",nut2,curmaM) *  p_nutEffectivDueVAlBiogasPurchMan(curmaM)  ) ;
```

The N input from manure and biogas digestate as well as manure import is summarized in the following equation. The export of manure
is substracted in the equation. The variable *v_DueVOrgN* returns the accourance of nitrogen from organic sources at a farm level.
The nitrogen has to be accounted with factors defined by the Fertilization Ordinance.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/duev_module.gms GAMS /DuevOrgN_.*?\.\./ /;/)
```GAMS
DuevOrgN_(tCur(t),nCur) $ t_n(t,nCur) ..

        v_DueVOrgN (t,nCur)  =E=

$iftheni.h %herd% == true

             v_nutExcrDuev("N",t,nCur)      *   p_nutEffectivDueVAl
$endif.h
$iftheni.dh %daidyherd% == true

             v_nutExcrPast("N",t,nCur)    *   p_nutEffectivDueVAlPast
$endif.dh


* --- Nutrients imported to the farm
*     [TK][TO DO] add coefficient for accounting for imported manure

$iftheni.im "%AllowManureImport%" == "true"

      +   sum ( (nut2,m) $ (not sameas (nut2,"P")),   v_manImport(t,nCur,m) *    p_nut2inMan(nut2,"manImport","LiquidImport") )

$endif.im

*   --- Nutrients exported from farm

$iftheni.ExMan %AllowManureExport%==true

         -  sum( (curManChain,m,nut2) $(not sameas (nut2,"P")), v_nut2export(curManChain,nut2,t,nCur,m) )

$endif.ExMan


$iftheni.emissionRight not "%emissionRight%"==0

          -  sum( (curManChain,m,nut2) $(not sameas (nut2,"P")), v_nut2exportMER(curManChain,nut2,t,nCur,m) )
$endif.emissionRight

*  --- Nutrients coming from biogas plant, included depending on FD, calculated in fermenter tech

$iftheni.b %biogas% == true

          +  v_nutBiogasDueVAccAL(t,nCur)
$endif.b

;
```

The N input is not allowed to exceed a target value defined by the Fertilizations Ordinace, being 170 kg N/ha/a in most cases.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/duev_module.gms GAMS /DuevOrgNLimit_.*?\.\./ /;/)
```GAMS
DuevOrgNLimit_ (tCur(t),nCur) $ t_n(t,nCur) ..

      v_DueVOrgN (t,nCur)

            =L=

             sum(  (c_s_t_i(curCrops(crops),plot,till,intens))  $ ( not (sameas(crops,"idle") or sameas (crops,"idlegras") or sameas (crops,"catchCrop") )  ),
                       p_nutManApplLimit(crops,t)
                                   * v_cropHa(crops,plot,till,intens,t,nCur)) ;
```


## Binding fertilizer planning

Under the Fertilization Ordinance 2017, farms have to do an obligatory fertilizer planning based on the expected yields.
The derived nutrient need with regard to nitrogen must not be exceeded. This allows to calculate a nitrogen
quota which farms have to meet. The fertilizer quota is always calculated, if the Fertilization Ordinance is switched on.
However, it only becomes binding for fertilizer application under the Fertilization Ordinance 2017.

The nutrient input is summarized in the equation *FertQuotaInput_*. Nutrients from chemical fertilizer, manure and mineralization
from the soil are taken into account. Manure N is accounted with mineral fertilizer equivalents defined by the Ordinace.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/duev_module.gms GAMS /FertQuotaInput_.*?\.\./ /;/)
```GAMS
FertQuotaInput_(tCur(t),nCur)   $ t_n(t,nCur)  ..

          v_FertQuotaInput(t,nCur)

            =e=

* --- Input of chemical N fertilizer which is fully accounted in the fertilizer quota

                  sum (  (c_s_t_i(curCrops(crops),plot,till,intens),syntFertilizer,m)  $( (not sameas (crops,"catchCrop")) $ ( not sameas (crops,"idle") ) $ (not sameas (crops,"idleGras") )  ),
                              v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)     * p_nutInSynt(syntFertilizer,"N") )

* --- Input of manure N which is accounted with prescribed mineral fertilizer equivalents

$iftheni.man %manure% == true

                +  sum( (  c_s_t_i(curCrops(crops),plot,till,intens),manApplicType_manType(ManApplicType,curManType),nut2,manChain_type(manChain,curManType),m)
                                $ (  ( not sameas (nut2,"P"))  $ (not sameas (crops,"catchCrop")) $ ( not sameas (crops,"idle") ) $ (not sameas (crops,"idleGras") )
                                $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0)   ),
                                 v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                                       * p_nut2inMan(nut2,curManType,manChain) * p_nutEffFOPlan(curManType)    )

$endif.man


                         ;
```

Furtermore, the plant nutrient need is calculated. It depends on the yield level and is precisley defined by the Fertilization
Ordinance.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/duev_module.gms GAMS /FertQuotaNeed_.*?\.\./ /;/)
```GAMS
FertQuotaNeed_(tCur(t),nCur) ..


         v_FertQuotaNeed(t,nCur)

                 =e=

* --- N need is derived from FO 17, depending on yield level which is reflected in p_NneedFerPlan

                   sum (  ( c_s_t_i(curCrops(crops),plot,till,intens) )  $( (not sameas (crops,"catchCrop")) $ ( not sameas (crops,"idle") ) $ (not sameas (crops,"idleGras") )  )
                               ,  v_cropHa(crops,plot,till,intens,t,nCur)
                                         * sum(plot_soil(plot,soil), p_NneedFerPlan(crops,plot,soil,till,intens,t) )   )

* --- Assumption that N min provided in spring is always 50;
```

The plant nutrient input is not allowed to exceed the estimated nutrient need. The restriction becomes only binding under the Fertilization Ordiance
2017. p_bigNumberFO, being a very large number if the Fertilization Ordinance 2017 is not activated, ensures that the nutrient need is extremly high under the Fertilization Ordinance
2007 and not binding.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/duev_module.gms GAMS /FertQuota_.*?\.\./ /;/)
```GAMS
FertQuota_(tCur(t),nCur) $ t_n(t,nCur)  ..

                  v_FertQuotaInput(t,nCur)  =l=    v_FertQuotaNeed(t,nCur)  * p_bigNumberFO  ;
```

## Required manure storage capacities

Farms are required to hold a minimum storage capacity to bridge the time in autumn and winter when manure application is not allowed. This storage
capacity was defined at federal state level under the Fertilization Ordinance 2007. Under the Fertilization Ordinance 2017, it is defined at federal level.

Generally, farms have to hold a manure storage capacity to gap the amount of manure excretion corresponding to a certain time period, e.g. 6 months.
Therefore, the required storage capacity is defined in the manure module. The parameter *p_ManureStorageNeed* defines the required amount of months
and is linked to the selected Fertilization Ordinance or can be defined in the GUI.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/manure_module.gms GAMS /manStorCapNeed_.*?\.\./ /;/)
```GAMS
manStorCapNeed_(curManChain(manChain),tCur(t),nCur) $ (t_n(t,nCur) $ p_ManureStorageNeed)   ..

          v_ManStorCapNeed(manChain,t,nCur) =e=  p_ManureStorageNeed   * (

    $$ifi %herd% == true                  v_manQuant(manChain,t,nCur) $ (not sameas (manchain, "LiquidBiogas"))

*  --- required silo storage capacity for biogas plant digestate (including energy crops and purchased manure)

    $$ifi %biogas% == true              + sum((crM(biogasfeedM),m), v_voldigCrop(crM,t,nCur,m) + v_volDigMan(t,nCur,m)) $ sameas ("LiquidBiogas",manchain)

                                    );
```

Under the Fertilization Ordinance 2017, farms exceeding a stocking density of 3 livestock units per ha have to hold additional manure storage capacity.
This is implemented with a binary trigger in FarmDyn. The variable *v_triggerStorageGVha* becomes one when the farm exceeds the livestock unit
threshold.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/duev_module.gms GAMS /triggerStorageGVha_.*?\.\./ /;/)
```GAMS
triggerStorageGVha_(tCur(t),nCur) $t_n(t,nCur) ..

          (    v_sumGV(t,nCur)   /   sum(plot, p_plotSize(plot))  ) - 3  =l= v_triggerStorageGVha(t,nCur) *  16 ;
```

If the variable *v_triggerStorageGVha* is one, the restriction in the following equation becomes binding.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/duev_module.gms GAMS /manStorCapGVDepend_.*?\.\./ /;/)
```GAMS
manStorCapGVDepend_(curManChain(manChain),tCur(t),nCur) $ t_n(t,nCur) ..

         v_TotalManStorCap(manChain,t,nCur)
                  =g= v_manQuant(manChain,t,nCur) *  p_ManureStorageNeedGV
                                     - ( (1 -  v_triggerStorageGVha(t,nCur) ) * p_bigNumber ) ;
```

## Banning periods for fertilizer application

During certain months of the year, the application of fertilizer is not allowed as there is no plant nutrient need and the risk of nitrate leaching is very high.
This is implemented in FarmDyn by setting the variable *v_mandist* and *v_syntdist* to zero for certain months which disables fertilizer application in the model.

Depending on the Fertilization Ordinance selected, sets are defined which include the months in which fertilizer application is forbidden (can also be defined
via the GUI which is not shown here).

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/fertilizing.gms GAMS /\$\$elseifi.*?==\sFD_2007/ /\$\$endif.fertGui/)
```GAMS
$$elseifi.fertGui %RegulationFert% == FD_2007

*      --- (2) Depending on regulation of FO 07

       set  monthApplicationForbidden(m)                    /Dec,Jan /  ;
       set  monthApplicationForbiddenArab(m)            /Nov,Dec,Jan /  ;
       set  monthApplicationForbiddenGrass(m)              / Dec,Jan /  ;


   $$elseifi.fertGui %RegulationFert% == FD_2017

*      --- (3) Depending on regulation of FO 17
       set  monthApplicationForbidden(m)              /Nov,Dec,Jan / ;
       set  monthApplicationForbiddenArab(m)      /Oct,Nov,Dec,Jan / ;
       set  monthApplicationForbiddenGrass(m)        / Nov,Dec,Jan / ;

   $$endif.fertGui
```

For the months which are defined in the described sets, the varialbes for fertilizer application are set to zero.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/fertilizing.gms GAMS /v_syntDist.up.*?\(arabCrops.*?till/ /\$\$endif\.v_manDist/)
```GAMS
v_syntDist.up(arabCrops(crops),plot,till,intens,syntFertilizer,t,n,monthApplicationForbiddenArab(m))
                                                      $ ( t_n(t,n) $ c_s_t_i(crops,plot,till,intens) )  = 0 ;

     v_syntDist.up(grassCrops(crops),plot,till,intens,syntFertilizer,t,n,monthApplicationForbiddenGrass(m))
                                                      $ ( t_n(t,n) $ c_s_t_i(grassCrops,plot,till,intens) )  = 0 ;



   $$iftheni.v_manDist declared v_manDist

     v_volManApplied.up(manChain,t,n,monthApplicationForbidden) $ t_n(t,n)  = 0;
     v_nut2ManApplied.up(manChain,nut2,t,n,monthApplicationForbidden) $ t_n(t,n) = 0;
     v_manDist.up(crops,plot,till,intens,manApplicType,manType,t,n,monthApplicationForbidden)
        $ (t_n(t,n) $  c_s_t_i(crops,plot,till,intens)) = 0;

     v_manDist.up(arabCrops(crops),plot,till,intens,manApplicType,manType,t,n,monthApplicationForbiddenArab)
        $ (t_n(t,n) $ c_s_t_i(crops,plot,till,intens)) = 0;

     v_manDist.up(grassCrops(crops),plot,till,intens,manApplicType,manType,t,n,monthApplicationForbiddenGrass)
        $ (t_n(t,n) $ c_s_t_i(crops,plot,till,intens)) = 0;

   $$endif.v_manDist
```


## Restriction of fertilizer application in autumn

In addition to the fixed banning periods, the application of fertilizer in autumn is only legal for some crops and restricted
to a defined amount of nitrogen per ha. The parameter *p_NLimitInAutumn* contains the allowed amount of N and is
defined depending on the Fertilization Ordinance. Catch crops allow additional manure application in autumn.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/duev_module.gms GAMS /NLimitAutumn_.*?c_[\s\S]*?\.\./ /;/)
```GAMS
NLimitAutumn_ (c_s_t_i(curCrops(arablecrops),plot,till,intens),tCur(t),nCur)
                              $ ( (v_cropHa.up(arableCrops,plot,till,intens,t,nCur) ne 0) $ t_n(t,nCur)   ) ..


$iftheni.man %manure% == true

                     sum( (manChain_type(manChain,curManType),manApplicType_manType(ManApplicType,curManType),nut2,m) $ monthHarvestBlock(arableCrops,m),
                                                                     v_manDist(arablecrops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                                                                             *   p_nut2inMan(nut2,curManType,manChain)   $ (not sameas (nut2,"P"))   )

$endif.man

                     +    sum( (syntFertilizer,m) $ monthHarvestBlock(arableCrops,m),  v_syntDist(arableCrops,plot,till,intens,syntFertilizer,t,nCur,m)

                                 *   p_nutInSynt(syntFertilizer,"N")  )

                      =l=       v_cropHa(arableCrops,plot,till,intens,t,nCur)  *   p_NLimitInAutumn(arablecrops)

* --- Catch crop allow also the application of manure in autumn. Interpreted as possibility to get rid of manure in autumn as there is no nutrient need for catch crops. The nutrient of applied manure
*     to catch crops is provided to the following main crop. Therefore, catch crops are not included into the nutrient need calculation but allows to "move the nutrient need of the main crops"
*     to autumn. Note that this inclusion of catch crops makes them always listed under v_cropha.
*


                           +   v_cropHa("catchCrop",plot,till,intens,t,nCur)    * p_NLimitInAutumn("catchCrop")    $ curCrops("catchCrop")
                             ;
```


## Low-emission manure application techniques

The Fertilization Ordinance defines which manure application techniques are legally allowed. Under the Fertilization Ordinance 2017, broadcast spreading
is banned except on fallow land followed by direct incorporation. This measures is introduced in FarmDyn by setting the variable
*v_mandist* to zero for certain months and not allowed application techniques.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/manure.gms GAMS /\* \-\-\- Broadcast spreader/ /\$\$endif\.dh/)
```GAMS
* --- Broadcast spreader are banned on grassland

   $$iftheni.dh %cattle%==true
      v_manDist.up(grassCrops(crops),plot,till,intens,"applSpreadPig",manType,t,nCur,m) $ t_n(t,Ncur)   = 0   ;
      v_manDist.up(grassCrops(crops),plot,till,intens,"applSpreadCattle",manType,t,nCur,m) $ t_n(t,Ncur)   = 0   ;
   $$endif.dh
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/manure.gms GAMS /\* \-\-\- Broadcast spreader.*?crop/ /applSpreadCattle".*?;/)
```GAMS
* --- Broadcast spreader are generally banned on arable land, except when there is no crop

   v_manDist.up(arabCrops(crops),plot,till,intens,"applSpreadPig",manType,t,nCur,m) $ (t_n(t,Ncur) $ monthGrowthCrops(crops,m))    = 0   ;
   v_manDist.up(arabCrops(crops),plot,till,intens,"applSpreadCattle",manType,t,nCur,m) $ (t_n(t,Ncur) $ monthGrowthCrops(crops,m))    = 0   ;
```


# Manure


!!! abstract
    Manure excretion from animals is calculated based on fixed factors, differentiated by animal type, yield level and feeding practice. For biogas production, the composition of different feed stock is taken into account. Manure is stored subfloor in stables and in silos. Application of manure has to follow legal obligations and interacts with plant nutrient need from the cropping module. Different N losses are accounted for in stable, storage and during application.

## Manure Excretion

With regard to excretion of animals, relevant equations and variables
can be found in the *general\_herd\_module.gms*. *v\_manQuantM* is the
monthly volume in cubic meter of manure produced. It is computed by
summing the monthly manure for the herd with considering the amount
excreted while grazing, shown in the following equation:

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/model/general_herd_module.gms GAMS /manQuantM_[\S\s][^;]*?\.\./ /;/)
```GAMS
manQuantM_(curManChain(manChain),tCur(t),nCur,m) $ t_n(t,nCur) ..

         v_manQuantM(manChain,t,nCur,m) =e=
               sum( actherds(herds,breeds,feedRegime,t,m1) $ manChain_herd(manChain,herds),
                   p_manQuantMonth(herds) * ( 1 - 1   $ sameas(feedRegime,"fullGraz")
                                                - 0.5 $ sameas(feedRegime,"partGraz"))

                    * sum(m_to_herdm(m,m1), v_herdSize(herds,breeds,feedRegime,t,nCur,m1)));
```

Furthermore, the monthly excretion of nutrients, NTAN, Norg and P is
calculated, multiplying *v\_herdsize* and *p\_nut2ManMonth*. For cows,
excretion rate depends on animal category, feeding regime and yield
level. For fatteners and sows, excretion depends on animal category and
feeding regime. Corresponding parameters can be found in
*coeffgen\\manure.gms* (not shown here). For dairy cows, excretion on
pasture is subtracted.

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/model/general_herd_module.gms GAMS /nut2ManureM_[\S\s][^;]*?\.\./ /;/)
```GAMS
nut2ManureM_(curManChain(manChain),nut2,tCur(t),nCur,m) $ t_n(t,nCur) ..

    v_nut2ManureM(manChain,nut2,t,nCur,m) =e=
          sum((manChain_herd(manChain,possHerds),actherds(possHerds,breeds,feedRegime,t,m1))
             $ (not sameas(feedRegime,"fullGraz")),
                   p_nut2ManMonth(possHerds,feedRegime,nut2)
                        * ( 1 - 1   $ sameas(feedRegime,"fullGraz")
                              - 0.5 $ sameas(feedRegime,"partGraz"))
                    * sum(m_to_herdm(m,m1), v_herdSize(possHerds,breeds,feedRegime,t,nCur,m1)))
    ;
```


Biogas production involves the production of digestates. Four sources
can be differentiated depending on the origin of the feed crop: use of
manure produced on farm, manure imported to the farm, crops grown on
farm and crops imported on farm. Manure produced on farm is treated like
not fermented manure, as though it is not entering the biogas plant.

For digestates from imported manure and from crops, volume of digestates
in cubic meter is calculated in the *biogas\_module.gms* by multiplying
amount of used feed stock, *v\_usedCropBiogas* and *v\_purchManure*, and
a fugal factor. The latter represents the decrease of volume during the
fermentation process.

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/model/biogas_module.gms GAMS /biogasVolCropDigestate_[\S\s][^;]*?\.\./ /;/)
```GAMS
biogasVolCropDigestate_(crm(biogasfeedM),tCur(t),nCur,m) $ t_n(t,nCur) ..

        v_volDigCrop(crM,t,nCur,m) =E= sum( (curBhkw(bhkw), curEeg(eeg)),
                                        v_usedCropBiogas(bhkw,eeg,crM,t,nCur,m)* p_fugCrop(crM));
```

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/model/biogas_module.gms GAMS /biogasVolManDigestate_[\S\s][^;]*?\.\./ /;/)
```GAMS
biogasVolManDigestate_(tCur(t),nCur,m) $ t_n(t,nCur) ..

        v_volDigMan(t,nCur,m) =E= sum( (curBhkw(bhkw), curEeg(eeg), maM) ,
                                        v_purchManure(bhkw,eeg,maM,t,nCur,m) $ selPurchInputs(maM)   * p_fugMan);
```


The amount of nutrients produced in the biogas plant and entering the
manure storage is computed by multiplying the amount of feed stock and
the corresponding nutrient content. It is assumed, that N and P is not
lost during fermentation. Furthermore, nutrients from crop inputs are
calculated as an annual average since no short term changes are common.

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/model/biogas_module.gms GAMS /nutCropBiogasY_[\S\s][^;]*?\.\./ /;/)
```GAMS
nutCropBiogasY_(nut2,tCur(t),nCur) $ t_n(t,nCur) ..

        v_nutCropBiogasY(nut2,t,nCur) =E=
             sum( ( crM(biogasFeedM),m,curBhkw(bhkw), curEeg(eeg) ),
                                         v_usedCropBiogas(bhkw,eeg,crM,t,nCur,m)
                                               * p_nutDigCrop(nut2,crM));
```

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/model/biogas_module.gms GAMS /nutCropBiogasM_[\S\s][^;]*?\.\./ /;/)
```GAMS
nutCropBiogasM_(nut2,tCur(t),nCur,m) $ t_n(t,nCur)..

        v_nutCropBiogasM(nut2,t,nCur,m) =E=  v_nutCropBiogasY(nut2,t,nCur) / card(m);
```

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/model/biogas_module.gms GAMS /nut2ManurePurch_[\S\s][^;]*?\.\./ /;/)
```GAMS
nut2ManurePurch_(nut2,maM,tCur(t),nCur,m) $ t_n(t,nCur)..

         v_nut2ManurePurch(nut2,maM,t,nCur,m)
            =E=    sum ( (curBhkw(bhkw), curEeg(eeg)),
                        v_purchManure(bhkw,eeg,maM,t,nCur,m) * p_nut2manPurch(nut2,maM)  )    ;
```


## Manure Storage

Equations related to manure storage serve mainly for the calculation of
the needed storage capacity, linked to investment, and for the
calculation of emissions during storage. The *manure\_module.gms* is
activated when fattners, sows, dairy and/or biogas is activated in the
GUI.

The amount of manure in the storage in cubic meter is described in the
following equation. Manure is emptied by field application,
*v\_volManApplied*. When activated in the GUI, manure can also be
exported from the farm.

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/model/manure_module.gms GAMS /volInStorage_[\S\s][^;]*?\.\./ /;/)
```GAMS
volInStorage_(curManChain(manChain),tCur(t),nCur,m) $ t_n(t,nCur) ..

       v_volInStorage(manChain,t,nCur,m) =e= [sum(t_n(t-1,nCur1) $ anc(nCur,nCur1),
                                  v_volInStorage(manChain,t-1,nCur1,"Dec")) $ (sameas(m,"Jan") $ tCur(t-1))
                                + v_volInStorage(manChain,t,nCur,m-1)     $ (not sameas(m,"Jan"))]


* ---- in comparative static setting, manure in Jan includes manure from Dec, assuming steady flow

$iftheni.cs "%dynamics%" == "comparative-static"
                                + v_volInStorage(manChain,t,nCur,"Dec")     $ sameas(m,"Jan")
$endif.cs


$iftheni.herd %herd% == true
*
*                               --- m3 excreted per year divied by # of month: monthly inflow
*
                                + v_manQuantM(manChain,t,nCur,m)
$endif.herd

*                               --- m3 coming from biogas plant s energy crops and purchased manure
$iftheni.b %biogas% == true

*                               --- Diogas digestate based on energy crops

                                +  sum(crm(biogasfeedM), v_volDigCrop(crM,t,nCur,m))

*                               --- Biogas digestate based on manure

                                +  v_volDigMan(t,nCur,m)
$endif.b
*
*                               --- m3 taken out of storage type for application to crops
*
                                - v_volManApplied(manChain,t,nCur,m)

$iftheni.ExMan %AllowManureExport%==true

*                               --- m3 exported from farm

                                - sum (manChain_Type(manChain,curManType), v_manExport(manChain,curManType,t,nCur,m))
$endif.ExMan

$iftheni.emissionRight not "%emissionRight%"==0
*                               --- m3 exported through manure emission rights

                                - sum (manChain_Type(manChain,curManType), v_manExportMER(manChain,curManType,t,nCur,m))
$endif.emissionRight
                             ;
```

Following the same structure as the equation above, there is a nutrient
pool for NTAN, Norg and P in the storage. Losses of NTAN and Norg during
storage are subtracted. When environmental accounting is switched off,
standard loss factors are subtracted directly in the equation.

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/model/manure_module.gms GAMS /nutPoolInStorage_[\S\s][^;]*?\.\./ /;/)
```GAMS
nutPoolInStorage_(curManChain(manChain),nut2,tCur(t),nCur,m) $ t_n(t,nCur) ..

            v_nutPoolInStorage(manChain,nut2,t,nCur,m)

              =e=  [sum(t_n(t-1,nCur1) $ anc(nCur,nCur1),
                          v_nutPoolInStorage(manChain,nut2,t-1,nCur1,"Dec")) $ (sameas(m,"Jan") $ tCur(t-1))
                        + v_nutPoolInStorage(manChain,nut2,t,nCur,m-1)       $ (not sameas(m,"Jan"))]


* ---- in comparative static setting, nutrient pool in Jan includes nutrient pool from Dec, assuming steady flow

$iftheni.cs "%dynamics%" == "comparative-static"

                        + v_nutPoolInStorage(manChain,nut2,t,nCur,"Dec")       $ sameas(m,"Jan")

$endif.cs



$iftheni.herd %herd% == true

                 + v_nut2ManureM(manChain,nut2,t,nCur,m)

$endif.herd

$iftheni.biogas %biogas% == true

                 +  sum( (curBhkw(bhkw),curEeg(eeg),maM),   v_nut2ManurePurch(nut2,maM,t,nCur,m)  )

                 +  v_nutCropBiogasM(nut2,t,nCur,m)
$endif.biogas


$iftheni.envAcc %envAcc% == true

* --- When environmental accounting is switched on, storage losses are calculated in envir_acc_module.gms

                - v_nutLossInStorage(manChain,nut2,t,nCur,m)

$else.envAcc

* --- When environmental accounting is switched off, only standard losses for NH3 are substracted from NTAN

                $$iftheni.herd %herd% ==true

                         - v_nut2ManureM(manChain,nut2,t,nCur,m) * p_nutLossFacNoEnvAcc   $ ( not sameas(nut2,"P") )

                $$endif.herd

                $$iftheni.biogas %biogas% == true

                        -  sum( (curBhkw(bhkw),curEeg(eeg),maM),   v_nut2ManurePurch(nut2,maM,t,nCur,m)
                                                      * (1 -  p_nutEffectivDueVAlBiogasPurchMan(maM)  ))  $ ( not sameas(nut2,"P") )

                        -  v_nutCropBiogasM(nut2,t,nCur,m)  * (1 -  p_nutEffectivDueVAlBiogasPlantDig)    $ ( not sameas(nut2,"P") )

                $$endif.biogas

$endif.envAcc

* --- Nutrients applied

                 - v_nut2ManApplied(manChain,nut2,t,nCur,m)

* --- Nutrients exported from farm

$iftheni.ExMan %AllowManureExport%==true

                 - v_nut2export(manChain,nut2,t,nCur,m)

$endif.ExMan
$iftheni.emissionRight not "%emissionRight%"==0

* --- Nutrient exported via manure emission rights

                -  v_nut2ExportMER(manChain,nut2,t,nCur,m)

$endif.emissionRight
 ;
```

When environmental accounting is switched on, losses are calculated in
the equation *nutLossInStorage\_*, using emission factors from the
environmental impact accounting module (see chapter 2.12).


[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/model/manure_module.gms GAMS /nutLossInStorage_[\S\s][^;]*?\.\./ /;/)
```GAMS
nutLossInStorage_(curManChain(manChain),nut2,tCur(t),nCur,m) $ t_n(t,nCur) ..

       v_nutLossInStorage(manChain,nut2,t,nCur,m) =E=

* --- NH3 losses in stable and storage, only related to N TAN

                   + v_emStabSto(manChain,"NH3",t,nCur,m) $ sameas(nut2,"NTAN")

            $$iftheni.herd %herd% == true

* --- N2O, N2 and NO losses in stable and storage, related to NTAN and Norg

                   + v_nut2ManureM(manChain,"NTAN",t,nCur,m) * ( p_EFStaSto("N2O") +  p_EFStaSto("NOx") + p_EFStaSto("N2") )   $ sameas(nut2,"NTAN")

                   + v_nut2ManureM(manChain,"NOrg",t,nCur,m) * ( p_EFStaSto("N2O") +  p_EFStaSto("NOx") + p_EFStaSto("N2") )   $ sameas(nut2,"NOrg")

            $$endif.herd

* --- N2O, N2 and NO losses from storage from digestate, related to NTAN and Norg

            $$iftheni.biogas %biogas% == true

                   + [ ( v_nutCropBiogasM("NTAN",t,nCur,m)   + sum (maM, v_nut2ManurePurch("NTAN",maM,t,nCur,m)  ) )
                                          * p_EFStaSto("N2O")   * p_EFStaSto("NOx")  * p_EFStaSto("N2") ]  $ sameas(nut2,"NTAN")

                   + [ ( v_nutCropBiogasM("NOrg",t,nCur,m)   + sum (maM, v_nut2ManurePurch("NOrg",maM, t,nCur,m) ) )
                                          * p_EFStaSto("N2O")   * p_EFStaSto("NOx")  * p_EFStaSto("N2") ]  $ sameas(nut2,"NOrg")

           $$endif.biogas
        ;
```


The amount of manure in the storage needs to fit to the available
storage capacity which is calculated in the equation
*totalManStorCap\_*. The total storage capacity is the sum of the sub
floor storage in stables, silos and silos for digestates from biogas
production. Note: when the biogas branch is active without herds, the
storage concept is simplified.

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/model/manure_module.gms GAMS /totalManStorCap_[\S\s][^;]*?\.\./ /;/)
```GAMS
totalManStorCap_(curManChain(manChain),tCur(T),nCur) $ t_n(t,nCur) ..

       v_TotalManStorCap(manChain,t,nCur) =e=

$iftheni.herd %herd%  == true
                              v_SubManStorCap(manChain,t,nCur)
                            + v_SiloManStorCap(manChain,t,nCur)
$endif.herd
$ifi %biogas% == true       + v_siloBiogasStorCap(t,nCur)
    ;
```

The storage capacity of silos *v\_SiloManStorCap* is derived by
multiplying the silo inventory with parameters characterizing the
corresponding storage capacity.

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/model/manure_module.gms GAMS /siloManStorCap_[\S\s][^;]*?\.\./ /;/)
```GAMS
siloManStorCap_(curManChain(manChain),tCur(t),nCur) $ t_n(t,nCur) ..

       v_SiloManStorCap(manChain,t,nCur)

          =e= sum(silos $ (    sum(t_n(t1,nCur1) $ isNodeBefore(nCur,nCur1), v_buySilos.up(manChain,silos,t1,nCur1))
                            or sum(tOld, p_iniSilos(manChain,silos,tOld))),
                               v_SiloInv(manChain,silos,t,nCur) * p_ManStorCapSi(silos))    ;
```

The subfloor storage capacity of stables *v\_SubManStorCap* is
calculated in the *general\_herd\_module.gms*. The stable inventory is
multiplied with parameters characterizing the corresponding subfloor
storage capacity. The amount of manure which can be stored in the stable
building, *p\_ManStorCap*, depends on the stable system. Slurry based
systems with a plane floor normally only have small cesspits which
demand the addition of manure silo capacities. The manure storage
capacity of stables with slatted floor depends on the size of the
stable, where a storage capacity for manure of three month in a fully
occupied stable is assumed. A set of different dimensioned liquid manure
reservoirs is depicted in the code, *p\_ManStorCapSi*, from 500 to 4000
m³.

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/model/general_herd_module.gms GAMS /subManStorCap_[\S\s][^;]*?\.\./ /;/)
```GAMS
subManStorCap_(curManChain(manChain),tCur(t),nCur) $ t_n(t,nCur) ..

       v_SubManStorCap(manChain,t,nCur) =e= sum(stables $ (      sum( (t_n(t1,nCur1),hor) $ isNodeBefore(nCur,nCur1),
                                                             v_buyStables.up(stables,hor,t1,nCur1))
                                                    or (sum( (tOld,hor), p_iniStables(stables,hor,tOld)))),

                                             v_StableInv(stables,"long",t,nCur)*p_ManStorCap(manChain,stables));
```


The storage capacity for digestates from biogas plants,
*v\_siloBiogasStorCap*, is linked to the size of the biogas plant and
calculated in the *biogas\_module.gms*.

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/model/biogas_module.gms GAMS /invSiloBiogas_[\S\s][^;]*?\.\./ /;/)
```GAMS
invSiloBiogas_(tCur(t), nCur) $ t_n(t,nCur) ..

        v_siloBiogasStorCap(t,nCur) =E= sum((curbhkw(bhkw), curEeg(eeg)), v_invBiogas(bhkw,eeg,t,ncur) * p_siloBiogas(bhkw));
```

The total volume is distributed to the different storage type based on
the following equations.

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/model/manure_module.gms GAMS /storageDistr_[\S\s][^;]*?\.\./ /;/)
```GAMS
storageDistr_(curManChain(manChain),tCur(t),nCur,m) $ t_n(t,nCur) ..

       v_volInStorage(manChain,t,nCur,m) =e=

              sum (manStorage,v_volInStorageType(manChain,ManStorage,t,nCur,m)) ;
```

For the silos related to animal husbandry, different coverage of silos
can be applied. The type of silo cover used for a certain type of silo,
*v\_siCovComb*, is a binary variable, i.e. one type of silo must be
fully covered or not.

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/model/manure_module.gms GAMS /siloCoverInv_[\S\s][^;]*?\.\./ /;/)
```GAMS
siloCoverInv_(curManChain(manChain),silos,tCur(t),nCur)
       $ ( (    sum(t_n(t1,nCur1) $ isNodeBefore(nCur,nCur1), v_buySilos.up(manChain,silos,t1,nCur1))
             or sum(tOld, p_iniSilos(manChain,silos,tOld))) $ t_n(t,nCur)) ..

       v_siloInv(manChain,silos,t,nCur) =e=  sum(siloCover, v_siCovComb(manChain,silos,t,nCur,siloCover));
```

The amount of storage capacity is prescribed by environmental law.
FARMDYN allows applying different regulations with regard to required
storage capacity, changed in the GUI. The necessary silo capacity can be
set (1) to 6 month, i.e. 50 % of annual manure excretion, or to (2)
amount of month when manure application is forbidden in winter. For (2),
there is a differentiation for arable land and grassland.

![](../media/image102.png)
-> only first equation is the same

The total manure storage capacity *v\_TotalManStorCap* must be greater
than the required storage capacity *v\_ManStorCapNeed*.

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/model/manure_module.gms GAMS /manStorCap_[\S\s][^;]*?\.\./ /;/)
```GAMS
manStorCap_(curManChain(manChain),tCur(t),nCur) $ t_n(t,nCur) ..

       v_TotalManStorCap(manChain,t,nCur) =g= v_ManStorCapNeed(manChain,t,nCur);
```

Besides requirement with regard to the storage capacity, there are
equations which make sure that the storage is emptied in certain points
of time. Every spring, the storage has to be emptied completely with
regard to nutrients and volume, what is made sure of in the equations
*emptyStorageVol\_* and *emptyStorageNut\_*. On the one hand, this
represents typical manure management of farms. On the other hand, the
restriction is necessary to make sure that the storage can be emptied
when relation between nutrients and volume changes due to nutrient
losses during storage (see chapter 2.9.3).

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/model/manure_module.gms GAMS /emptyStorageVol_[\S\s][^;]*?sameas[\S\s]*?\.\./ /;/)
```GAMS
emptyStorageVol_(curManChain(manChain),tCur(t),nCur,m) $(sameas(m,"apr") $ t_n(t,nCur)) ..

             v_volInStorage(manChain,t,nCur,m) =L= 0;
```

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/model/manure_module.gms GAMS /emptyStorageNut_[\S\s][^;]*?sameas[\S\s]*?\.\./ /;/)
```GAMS
emptyStorageNut_(curManChain(manChain),nut2,tCur(t),nCur,m) $(sameas(m,"apr") $ t_n(t,nCur)) ..


            v_nutPoolInStorage(manChain,nut2,t,nCur,m) =L= 0;
```


Furthermore, at the end of the time period modelled, only 1/3 of the
annual excreted manure is allowed to remain in the storage, to avoid
unrealistic behaviour in the last year modelled. This is made sure in
the following equations.

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/model/manure_module.gms GAMS /maxManVolStorLastMonth_[\S\s][^;]*?\.\./ /;/)
```GAMS
maxManVolStorLastMonth_(curManChain(manChain),"%lastYear%",nCur,"Dec") $ t_n("%lastYear%",nCur)  ..

                        (

$ifi %herd% == true         v_manQuant(manChain,"%lastYearCalc%",nCur)

$ifi %biogas% == true     + sum((crm(biogasFeedM),m), v_voldigCrop(crM,"%lastYearCalc%",nCur,m)+ v_volDigMan("%lastYearCalc%",nCur,m) )

                         ) * 8/12

                       =G=  v_volInStorage(manChain,"%lastYear%",nCur,"Dec");
```

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/model/manure_module.gms GAMS /maxManNutStorLastMonth_[\S\s][^;]*?\.\./ /;/)
```GAMS
maxManNutStorLastMonth_(curManChain(manChain),nut2,"%lastYear%",nCur,"Dec") $ t_n("%lastYear%",nCur) ..

                        (

$ifi %herd% ==true          sum(m, v_nut2ManureM(manChain,nut2,"%lastYear%",nCur,m))

$ifi %biogas% == true     + sum((maM,m), + v_nut2ManurePurch(nut2,maM,"%lastYearCalc%",nCur,m))

                         ) * 8/12

                      =G=  v_nutPoolInStorage(manChain,nut2,"%lastYear%",nCur,"Dec");
```


## Manure Application

Different application procedures for manure N are implemented,
*ManApplicType*, including broad spread, drag hose spreader and
injection of manure. The core variable is *v\_mandist* that represents
the amount of manure in cubic meter. The different techniques are
related to different application costs, labour requirements as well as
effects on different emissions. Furthermore, manure application is
linked to the nutrient balance (see chapter 2.11.2 and 2.11.3) and the
manure storage (see chapter 2.9.2).

The application of manure links nutrient with volumes. The nutrient
content of the manure is depending on the herd's excretion as well as on
the losses during storage. The parameter *p\_nut2inMan* contains the
amount of NTAN, Norg and P per cubic meter of manure applied. Relevant
parameters are calculated in *coeffgen\\manure.gms*. There are two
approaches to calculate the parameter, (1) environmental accounting not
activated and (2) environmental accounting activated.

For both systems, the amount of different nutrients per cubic meter is
calculated without losses, *p\_nut2inManNoLoss*. In the following
equation, *p\_nut2inMan* is calculated when the environmental accounting
is not active. In this case, only a fixed factor for NH<sub>3</sub> emissions is
subtracted from NTAN contained in the manure. The parameter is
calculated for the types of manure from different herds, *mantype.* The
herds and types of manure are linked via the cross set *herds\_mantype*.
This calculation implies that there is one type of manure for every herd
activated in FARMDYN.

![](../media/image106.png)
-> couldn't find this parameters

If environmental accounting is active, the calculation of *p\_nut2inMan*
differs. It is taken into account, the storage time of manure varies
and, therefore, losses during storage vary. For the manure of every
herd, two types of manure are calculated, representing the maximum and
minimum possible amount of losses during one year. This allows a
complete emptying of the storage in a linear programming setting.

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/coeffgen/manure.gms GAMS /p_nut2inMan\("NTAN"[\S\s]*?"low"[\S\s]*?[=][\S\s]*?highRedNP/ /;/)
```GAMS
p_nut2inMan("NTAN",manType)  $ manuretype_nutConMan("low",mantype)
                                 =  p_nut2inManNoLoss("NTAN","highRedNP",mantype) * (1 - p_lossFactorSto("low",mantype,"NTAN")  );
```

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/coeffgen/manure.gms GAMS /p_nut2inMan\("NOrg"[\S\s]*?"low"[\S\s]*?[=][\S\s]*?highRedNP/ /;/)
```GAMS
p_nut2inMan("NOrg",manType)  $ manuretype_nutConMan("low",mantype)
                                 =  p_nut2inManNoLoss("NOrg","highRedNP",mantype) * (1 -  p_lossFactorSto("low",mantype,"Norg") );
```

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/coeffgen/manure.gms GAMS /p_nut2inMan\("P"[\S\s]*?"low"[\S\s]*?[=][\S\s]*?highRedNP/ /;/)
```GAMS
p_nut2inMan("P",manType)     $ manuretype_nutConMan("low",mantype)
                                 =  p_nut2inManNoLoss("P","highRedNP",mantype);
```

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/coeffgen/manure.gms GAMS /p_nut2inMan\("NTAN"[\S\s]*?"high"[\S\s]*?[=][\S\s]*?normFeed/ /;/)
```GAMS
p_nut2inMan("NTAN",manType)  $ manuretype_nutConMan("low",mantype)
                                 =  p_nut2inManNoLoss("NTAN","highRedNP",mantype) * (1 - p_lossFactorSto("low",mantype,"NTAN")  );
```

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/coeffgen/manure.gms GAMS /p_nut2inMan\("NOrg"[\S\s]*?"high"[\S\s]*?[=][\S\s]*?normFeed/ /;/)
```GAMS
p_nut2inMan("NOrg",manType)  $ manuretype_nutConMan("low",mantype)
                                 =  p_nut2inManNoLoss("NOrg","highRedNP",mantype) * (1 -  p_lossFactorSto("low",mantype,"Norg") );
```

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/coeffgen/manure.gms GAMS /p_nut2inMan\("P"[\S\s]*?"high"[\S\s]*?[=][\S\s]*?normFeed/ /;/)
```GAMS
p_nut2inMan("P",manType)     $ manuretype_nutConMan("low",mantype)
                                 =  p_nut2inManNoLoss("P","highRedNP",mantype);
```

The total manure distributed in cubic meter and in nutrients per month
is summarized in the following equations according to:

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/model/manure_module.gms GAMS /nut2ManApplied_[\S\s][^;]*?\.\./ /;/)
```GAMS
nut2ManApplied_(curManChain(manChain),nut2,tCur(t),nCur,m) $ ((v_volManApplied.up(manChain,t,nCur,m) ne 0) $ t_n(t,nCur)) ..

       v_nut2ManApplied(manChain,nut2,t,nCur,m) =e= sum( (c_s_t_i(curCrops(crops),plot,till,intens),
                                                             manChain_applic(manChain,ManApplicType),curManType)
                                      $ (manApplicType_manType(ManApplicType,curManType)
                                          $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0)),

                                         v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                                                  * p_nut2inMan(nut2,curManType));
```

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/model/manure_module.gms GAMS /volManApplied_[\S\s][^;]*?\.\./ /;/)
```GAMS
volManApplied_(curManChain(manChain),tCur(t),nCur,m) $ ((v_volManApplied.up(manChain,t,nCur,m) ne 0) $  t_n(t,nCur)) ..

       v_volManApplied(manChain,t,nCur,m) =e= sum( (c_s_t_i(curCrops(crops),plot,till,intens),
                                                         manChain_applic(manChain,ManApplicType),curManType)
                                      $ (manApplicType_manType(ManApplicType,curManType)
                                           $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0)),
                                           v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m));
```


There are several restrictions with regard to the application of manure.
First of all, the application of manure is not possible in some crops in
some month, e.g. in maize at certain height of growth.

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/coeffgen/fertilizing.gms GAMS /set doNotApplyManure/ /;/)
```GAMS
set doNotApplyManure(crops,m) /
                                 (potatoes,sugarbeet,maizSil)           .(Jun,Jul,Aug,Sep)
                                 (WinterWheat,WinterBarley,SummerBeans) .(May,Jun,Jul,Aug)
                                 (SummerPeas,SummerCere,WinterRape)     .(May,Jun,Jul)
                                 (WheatGPS)                             .(May,Jun)
                                 (MaizCorn, MaizCCM)                    .(Jul,Aug,Sep,Oct)
                                /;
```
[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/coeffgen/fertilizing.gms GAMS / v_manDist.up\(crop[\S\s]*?,m\)/ /;/)
```GAMS
 v_manDist.up(crops,plot,till,intens,manApplicType,manType,t,n,m)
     $ ( t_n(t,n) $ c_s_t_i(crops,plot,till,intens) $ doNotApplyManure(crops,m) ) = 0  ;
```

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/coeffgen/manure.gms GAMS / v_manDist.up\(arable[\S\s]*?"applTShoePig"/ /;/)
```GAMS
 v_manDist.up(arableCrops(crops),plot,till,intens, "applTShoePig",manType,t,n,m)
          $ (t_n(t,n) $ c_s_t_i(crops,plot,till,intens)) = 0 ;
```

[embedmd]:# (N:/agpo/work1/FarmDyn_QM/gams/coeffgen/manure.gms GAMS / v_manDist.up\(arab.*?"applTShoeCattle"/ /;/)
```GAMS
 v_manDist.up(arableCrops(crops),plot,till,intens, "applTShoeCattle",manType,t,n,m)
          $ (t_n(t,n) $ c_s_t_i(crops,plot,till,intens)) = 0 ;
```


![](../media/image110.png)

There are restrictions with the timing and the quantity of applied
manure coming from the German fertilizer directive. Generally, the
application of manure is forbidden during winter. Depending on settings
in the GUI, manure application can be forbidden only three month during
winter or more restrictive regulations apply.

![](../media/image111.png)

Furthermore, there is the option to ban certain manure application
techniques to represent technical requirements given by the German
fertilizer directive. These requirements can be activated in the GUI.
The sets *tNotLowAppA(t)* and *tLowAppA(t)* represents the years with
certain technical requirements.

![](../media/image112.png)

In the German fertilizer directive, the total amount of Nitrogen from
manure is restricted to 170 kilogram N per ha and year in farm average.
For grassland, there is the possibility to apply 230 kilogram. The
restrictions can be switched on or off in the GUI. In the following
equations, *v\_DueVOrgN* represent the amount of organic nutrients
excreted by animals minus nutrient exports from the farm.
*v\_nutExcrDueV* is calculated in the *general\_herd\_module.gms and*
*v\_nutBiogasDueV* in the *biogas\_module.gms* (equations not shown
here).

![](../media/image113.png)

The applied N is not allowed to exceed the given threshold,
*p\_nutManApplLimit*, as stated in the following equation. In current
legislation, organic N from digestates of plant origin is excluded in
the calculation of this threshold. Note that the organic N application
according to the fertilizer directive is always calculated in FARMDYN.
The restrictive threshold can be switched on and off in the GUI.

![](../media/image114.png)

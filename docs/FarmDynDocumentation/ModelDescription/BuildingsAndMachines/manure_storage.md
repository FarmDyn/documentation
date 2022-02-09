# Manure Storage

> **_Abstract_**  
Manure can be stored subfloor in stables and in different types of silos. The manure management is described in detail and takes into account, for example, storage losses, residues and emptying periods. Storage capacities depend on the environmental law predefined in FarmDyn's graphical user interface.

The manure silo inventory (*v\_siloInv*) for each type of silo (*silos*) is defined as seen in the following equation *siloInv\_*. *p\_iniSilos* is the initial endowment of manure silos in the construction year, *p\_lifeTimeSi* is the maximal physical lifetime of the silo, and *v\_buyilosF* are newly constructed silos.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/manure_module.gms GAMS /siloInv_\(c/ /;/)
```GAMS
siloInv_(curManChain(manChain),silos,tCur(t),nCur)
          $ (  (p_ManStorCapSi(silos) gt eps)
               $(   sum(t_n(t1,nCur1) $ isNodeBefore(nCur,nCur1), (v_buySilos.up(manChain,silos,t1,nCur1) ne 0))
               or sum(tOld, p_iniSilos(manChain,silos,tOld))) $ t_n(t,nCur) ) ..

       v_siloInv(manChain,silos,t,nCur)

            =L=
*
*         --- Old silo according to building date and lifetime
*             (will drop out of equation if too old)
*
           sum(tOld $ (   ((p_year(tOld) + p_lifeTimeSi(silos)) gt p_year(t))
                        $ ( p_year(told)                        le p_year(t))),
                           p_iniSilos(manChain,silos,tOld))

*
*         --- Plus (old) investments - de-investments
*
           +  sum(t_n(t1,nCur1) $ (tcur(t1) $ isNodeBefore(nCur,nCur1)
                                 and (   ((p_year(t1)  + p_lifeTimeSi(silos)) gt p_year(t))
                                       $ ( p_year(t1)                         le p_year(t)))),
                                           v_buysilosF(manChain,silos,t1,nCur1));
```

The manure silos are linked to the manure storage needs, which are described in the following.
Equations related to manure storage serve mainly for the calculation of the needed storage capacity, linked to investment, and for the
calculation of emissions during storage. The equations related to manure storage in *manure\_module.gms* are activated when fatteners, sows, dairy and/or biogas braches are activated in the graphical user interface (GUI).

The amount of manure in the storage in cubic meter is described in the following equation. Sources for manure are monthly animal excretion, biogas differentiated by input, and purchased manure. Manure silos are  emptied by field application, *v\_volManApplied*. When activated in the GUI, manure can also be exported from the farm.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/manure_module.gms GAMS /volInStorage_[\S\s][^;]*?\.\./ /;/)
```GAMS
volInStorage_(curManChain(manChain),tCur(t),nCur,m) $ ( t_n(t,nCur)$ ( not sameas (manchain,"LiquidImport"))  ) ..

       v_volInStorage(manChain,t,nCur,m) =e= [sum(t_n(t-1,nCur1) $ anc(nCur,nCur1),
                                  v_volInStorage(manChain,t-1,nCur1,"Dec")) $ (sameas(m,"Jan") $ tCur(t-1))
                                + v_volInStorage(manChain,t,nCur,m-1)     $ (not sameas(m,"Jan"))]


* ---- in comparative static setting, manure in Jan includes manure from Dec, assuming steady flow

                   $$iftheni.cs "%dynamics%" == "comparative-static"
                                + v_volInStorage(manChain,t,nCur,"Dec")     $ sameas(m,"Jan")
                   $$endif.cs


                   $$iftheni.herd %herd% == true
*
*                               --- m3 excreted per year divied by # of month: monthly inflow
*
                                + v_manQuantM(manChain,t,nCur,m) $ (not sameas(manchain,"LiquidBiogas"))
                   $$endif.herd

*                               --- m3 coming from biogas plant s energy crops and purchased manure
                   $$iftheni.b %biogas% == true

*                               --- Diogas digestate based on energy crops

                                +  sum(crm(biogasfeedM), v_volDigCrop(crM,t,nCur,m)) $ sameas(manchain,"LiquidBiogas")

*                               --- Biogas digestate based on manure

                                +  v_volDigMan(t,nCur,m) $ sameas(manchain,"LiquidBiogas")
                   $$endif.b
*
*                               --- m3 taken out of storage type for application to crops
*
                                - v_volManApplied(manChain,t,nCur,m)

                   $$iftheni.ExMan "%AllowManureExport%"=="true"

*                               --- m3 exported from farm

                                - sum (manChain_Type(manChain,curManType), v_manExport(manChain,curManType,t,nCur,m))
                   $$endif.ExMan

                   $$iftheni.emissionRight not "%emissionRight%"==0
*                               --- m3 exported through manure emission rights

                                - sum (manChain_Type(manChain,curManType), v_manExportMER(manChain,curManType,t,nCur,m))
                   $$endif.emissionRight
                             ;
```

Following the same structure as the equation above, there is a nutrient pool for NTAN, Norg and P in the storage. Losses of NTAN and Norg during storage are calculated in the environmental accounting and subtracted from the respective pool.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/manure_module.gms GAMS /nutPoolInStorage_[\S\s][^;]*?\.\./ /;/)
```GAMS
nutPoolInStorage_(curManChain(manChain),nut2,tCur(t),nCur,m) $ ( t_n(t,nCur)$ ( not sameas (manchain,"LiquidImport"))  ) ..

            v_nutPoolInStorage(manChain,nut2,t,nCur,m)

              =e=  [sum(t_n(t-1,nCur1) $ anc(nCur,nCur1),
                          v_nutPoolInStorage(manChain,nut2,t-1,nCur1,"Dec")) $ (sameas(m,"Jan") $ tCur(t-1))
                        + v_nutPoolInStorage(manChain,nut2,t,nCur,m-1)       $ (not sameas(m,"Jan"))]


* ---- in comparative static setting, nutrient pool in Jan includes nutrient pool from Dec, assuming steady flow

              $$iftheni.cs "%dynamics%" == "comparative-static"

                   + v_nutPoolInStorage(manChain,nut2,t,nCur,"Dec")       $ sameas(m,"Jan")

               $$endif.cs

               $$iftheni.herd %herd% == true

                 + v_nut2ManureM(manChain,nut2,t,nCur,m) $ (not sameas(manchain,"LiquidBiogas"))

               $$endif.herd

               $$iftheni.biogas %biogas% == true

                 +  sum( (curBhkw(bhkw),curEeg(eeg),curmaM),   v_nut2ManurePurch("LiquidBiogas",nut2,curmaM,t,nCur,m)  ) $ sameas(manchain,"LiquidBiogas")

                 +  v_nutCropBiogasM("LiquidBiogas",nut2,t,nCur,m) $ sameas(manchain,"LiquidBiogas")

               $$endif.biogas

*               --- storage losses

                - v_nutLossInStorage(manChain,nut2,t,nCur,m)

*               --- Nutrients applied

                 - sum(curCrops, v_nut2ManApplied(curCrops,manChain,nut2,t,nCur,m))

*               --- Nutrients exported from farm

               $$iftheni.ExMan "%AllowManureExport%"=="true"

                 - v_nut2export(manChain,nut2,t,nCur,m)

               $$endif.ExMan

               $$iftheni.emissionRight not "%emissionRight%"==0

*               --- Nutrient exported via manure emission rights

                -  v_nut2ExportMER(manChain,nut2,t,nCur,m)

                $$endif.emissionRight
 ;
```

Storage losses of reactive nitrogen are calculated in the equation *nutLossInStorage\_*, using emission factors from the environmental impact accounting module.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/manure_module.gms GAMS /nutLossInStorage_[\S\s][^;]*?\.\./ /;/)
```GAMS
nutLossInStorage_(curManChain(manChain),nut2,tCur(t),nCur,m) $ t_n(t,nCur)  ..

       v_nutLossInStorage(manChain,nut2,t,nCur,m) =E=

*             --- NH3 losses in stable and storage, only related to N TAN

            $$iftheni.herd %herd% == true
              [
                   + v_nut2ManureM(manChain,"NTAN",t,nCur,m) * (p_EFSta("NH3",manChain) + p_EFSto("NH3",manChain) ) $ sameas(nut2,"NTAN")

*             --- N2O, N2 and NO losses in stable and storage, related to NTAN and Norg

                   + v_nut2ManureM(manChain,"NTAN",t,nCur,m)
                    * ( p_EFStaSto("N2O",curManChain) + p_EFStaSto("NOx",curManChain) + p_EFStaSto("N2",curManChain) ) $ sameas(nut2,"NTAN")

                   + v_nut2ManureM(manChain,"NOrg",t,nCur,m)
                    * ( p_EFStaSto("N2O",curManChain) + p_EFStaSto("NOx",curManChain) + p_EFStaSto("N2",curManChain) ) $ sameas(nut2,"NOrg")

               ] $ (not sameas(manchain,"LiquidBiogas"))
            $$endif.herd

*             --- N2O, N2 and NO losses from storage from digestate, related to NTAN and Norg

            $$iftheni.biogas %biogas% == true

             + {
                     [ ( v_nutCropBiogasM(manchain,"NTAN",t,nCur,m)
                          + sum (curmaM(mam), v_nut2ManurePurch(manchain,"NTAN",curmaM,t,nCur,m)  ) )

                           *  (p_EFStaSto("N2O",curManChain) + p_EFStaSto("NOx",curManChain) + p_EFStaSto("N2",curManChain))

                      ]  $ sameas(nut2,"NTAN")

                   + [ ( v_nutCropBiogasM(manchain,"NOrg",t,nCur,m)   + sum (curmaM(mam), v_nut2ManurePurch(manchain,"NOrg",curmaM, t,nCur,m) ) )
                            *( p_EFStaSto("N2O",curManChain)   + p_EFStaSto("NOx",curManChain)  + p_EFStaSto("N2",curManChain))
                      ]  $ sameas(nut2,"NOrg")

               } $ sameas(manchain,"LiquidBiogas")

           $$endif.biogas
        ;
```

The amount of manure in the storage needs to fit to the available storage capacity which is calculated in the equation
*totalManStorCap\_*. The total storage capacity is the sum of the sub floor storage in stables, silos and silos for digestates from biogasproduction.
Note: when the biogas branch is active without herds, thesto rage concept is simplified.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/manure_module.gms GAMS /totalManStorCap_[\S\s][^;]*?\.\./ /;/)
```GAMS
totalManStorCap_(curManChain(manChain),tCur(T),nCur) $ t_n(t,nCur) ..

       v_TotalManStorCap(manChain,t,nCur) =e=

$iftheni.herd %herd%  == true
                              v_SubManStorCap(manChain,t,nCur)  $ (not sameas ("LiquidBiogas",manchain))
                            + v_SiloManStorCap(manChain,t,nCur) $ (not sameas ("LiquidBiogas",manchain))
$endif.herd
$ifi %biogas% == true       + v_siloBiogasStorCap(t,nCur) $ sameas ("LiquidBiogas",manchain)
    ;
```

The storage capacity of silos *v\_SiloManStorCap* is derived by multiplying the silo inventory with parameters characterising the
corresponding storage capacity.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/manure_module.gms GAMS /siloManStorCap_[\S\s][^;]*?\.\./ /;/)
```GAMS
siloManStorCap_(curManChain(manChain),tCur(t),nCur) $ t_n(t,nCur) ..

       v_SiloManStorCap(manChain,t,nCur)

          =e= sum(silos $ (    sum(t_n(t1,nCur1) $ isNodeBefore(nCur,nCur1), (v_buySilos.up(manChain,silos,t1,nCur1) ne 0))
                            or sum(tOld, p_iniSilos(manChain,silos,tOld))),
                               v_SiloInv(manChain,silos,t,nCur) * p_ManStorCapSi(silos))    ;
```

The subfloor storage capacity of stables *v\_SubManStorCap* is calculated in the *general\_herd\_module.gms*. The stable inventory is
multiplied with parameters characterising the corresponding subfloor storage capacity. The amount of manure which can be stored in the stable building, *p\_ManStorCap*, depends on the stable system. Slurry based systems with a plane floor normally only have small cesspits which demand the addition of manure silo capacities. The manure storage capacity of stables with slatted floor depends on the size of the stable, where a storage capacity for manure of three month in a fully occupied stable is assumed. A set of different dimensioned liquid manure reservoirs is depicted in the parameter, *p\_ManStorCapSi*, ranging from 500 to 4000 m³.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/general_herd_module.gms GAMS /subManStorCap_[\S\s][^;]*?\.\./ /;/)
```GAMS
subManStorCap_(curManChain(manChain),tCur(t),nCur) $(t_n(t,nCur)$(not sameas(curManChain,"LiquidBiogas"))) ..

       v_SubManStorCap(manChain,t,nCur) =e=
       sum(stables $ (     [ sum( (t_n(t1,nCur1),hor) $ ( (isNodeBefore(nCur,nCur1) or sameas(nCur,nCur1)) and (p_year(t1) le p_year(t))),
                                                             (v_buyStables.up(stables,hor,t1,nCur1) ne 0))
                                                    or (sum( (tOld,hor), p_iniStables(stables,hor,tOld)))
                                                   ]  $ (p_ManStorCap(manChain,stables) gt eps)
                                                    ),

                                             v_StableInv(stables,"long",t,nCur)*p_ManStorCap(manChain,stables));
```

The storage capacity for digestates from biogas plants, *v\_siloBiogasStorCap*, is linked to the size of the biogas plant and
calculated in the *biogas\_module.gms*.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/biogas_module.gms GAMS /invSiloBiogas_[\S\s][^;]*?\.\./ /;/)
```GAMS
invSiloBiogas_(tCur(t), nCur) $ t_n(t,nCur) ..

        v_siloBiogasStorCap(t,nCur) =E= sum((curbhkw(bhkw), curEeg(eeg)), v_invBiogas(bhkw,eeg,t,ncur) * p_siloBiogas(bhkw));
```

The total volume is distributed to the different storage types based on the following equations.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/manure_module.gms GAMS /storageDistr_[\S\s][^;]*?\.\./ /;/)
```GAMS
storageDistr_(curManChain(manChain),t_n(tCur(t),nCur),m) ..

       v_volInStorage(manChain,t,nCur,m) =e=

              sum (manStorage,v_volInStorageType(manChain,ManStorage,t,nCur,m)) ;
```

For the silos related to animal husbandry, different coverage of silos can be applied. The type of silo cover used for a certain type of silo, *v\_siCovComb*, is a binary variable, i.e. one type of silo must be fully covered or not.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/manure_module.gms GAMS /siloCoverInv_[\S\s][^;]*?\.\./ /;/)
```GAMS
siloCoverInv_(curManChain(manChain),silos,tCur(t),nCur)
       $ ( (    sum(t_n(t1,nCur1) $ isNodeBefore(nCur,nCur1), (v_buySilos.up(manChain,silos,t1,nCur1) ne 0))
             or sum(tOld, p_iniSilos(manChain,silos,tOld))) $ t_n(t,nCur)) ..

       v_siloInv(manChain,silos,t,nCur) =e=  sum(siloCover, v_siCovComb(manChain,silos,t,nCur,siloCover));
```

The amount of storage capacity is prescribed by environmental law FarmDyn allows applying different regulations with regard to the required storage capacity, changed in the GUI. Thereby FarmDyn allows to precisely capture the requirements of the German Fertilisation Ordinance 2007,2017 and 2020, which is further specified in the fertilisation ordinance section.

The total manure storage capacity *v\_TotalManStorCap* must be greater than the required storage capacity *v\_ManStorCapNeed*.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/manure_module.gms GAMS /manStorCap_[\S\s][^;]*?\.\./ /;/)
```GAMS
manStorCap_(curManChain(manChain),t_n(tCur(t),nCur)) ..

       v_TotalManStorCap(manChain,t,nCur) =g= v_ManStorCapNeed(manChain,t,nCur);
```

Besides legal requirements for the storage capacity, there are equations which make sure that the storage is emptied in certain points
of time. Every spring, the storage has to be emptied completely with regard to nutrients and volume, which is ensured by the equations
*emptyStorageVol\_* and *emptyStorageNut\_*. On the one hand, this represents typical manure management of farms. On the other hand, the restriction is necessary to make sure that the correct relation between mass and nutrients is maintained when nutrients and volume changes due to nutrient losses during storage.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/manure_module.gms GAMS /emptyStorageVol_[\S\s][^;]*?sameas[\S\s]*?\.\./ /;/)
```GAMS
emptyStorageVol_(curManChain(manChain),t_n(tCur(t),nCur),m) $ sameas(m,"apr") ..

             v_volInStorage(manChain,t,nCur,m) =L= 0;
```

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/manure_module.gms GAMS /emptyStorageNut_[\S\s][^;]*?sameas[\S\s]*?\.\./ /;/)
```GAMS
emptyStorageNut_(curManChain(manChain),nut2,t_n(tCur(t),nCur),m) $ sameas(m,"apr") ..

            v_nutPoolInStorage(manChain,nut2,t,nCur,m) =L= 0;
```

Furthermore, at the end of the time period modelled, only 1/3 of the annual excreted manure is allowed to remain in the storage, to avoid unrealistic behaviour in the last year modelled. This is ensured with the following equations.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/manure_module.gms GAMS /maxManVolStorLastMonth_[\S\s][^;]*?\.\./ /;/)
```GAMS
maxManVolStorLastMonth_(curManChain(manChain),t_n("%lastYear%",nCur),"Dec")  ..

                        (

$ifi %herd% == true         v_manQuant(manChain,"%lastYearCalc%",nCur)$ (not sameas(manchain,"LiquidBiogas"))

$ifi %biogas% == true     + sum((crm(biogasFeedM),m), v_voldigCrop(crM,"%lastYearCalc%",nCur,m)+ v_volDigMan("%lastYearCalc%",nCur,m) ) $ sameas(manchain,"LiquidBiogas")

                         ) * 8/12

                       =G=  v_volInStorage(manChain,"%lastYear%",nCur,"Dec");
```

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/manure_module.gms GAMS /maxManNutStorLastMonth_[\S\s][^;]*?\.\./ /;/)
```GAMS
maxManNutStorLastMonth_(curManChain(manChain),nut2,"%lastYear%",nCur,"Dec") $ t_n("%lastYear%",nCur) ..

                       (

$ifi %herd% ==true          sum(m, v_nut2ManureM(manChain,nut2,"%lastYear%",nCur,m) $ (not sameas(manchain,"LiquidBiogas")))

                         $$iftheni.biogas %biogas% == true

                          + sum((curmaM,m), v_nut2ManurePurch(manchain,nut2,curmaM,"%lastYear%",nCur,m) ) $ sameas(manchain,"LiquidBiogas")

                          + sum(m, v_nutCropBiogasM("LiquidBiogas",nut2,"%lastYear%",nCur,m))             $ sameas(manchain,"LiquidBiogas")

                         $$endif.biogas

                       ) * 8/12

                      =G=  v_nutPoolInStorage(manChain,nut2,"%lastYear%",nCur,"Dec");
```

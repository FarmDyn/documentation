
# Other Type of Buildings


Besides stables the model currently includes silos for more manure,
bunker silos for maize or grass silage and storages for potatoes.

Each type of manure silo is linked to an inventory equation:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/manure_module.gms GAMS /siloInv_\(c/ /;/)
```GAMS
siloInv_(curManChain(manChain),silos,tCur(t),nCur)
          $ ( (   sum(t_n(t1,nCur1) $ isNodeBefore(nCur,nCur1), v_buySilos.up(manChain,silos,t1,nCur1))
               or sum(tOld, p_iniSilos(manChain,silos,tOld))) $ t_n(t,nCur) ) ..

       v_siloInv(manChain,silos,t,nCur)

            =e=
*
*         --- Old silo according to building date and lifetime
*             (will drop out of equation if too old)
*
           sum(tOld $ (   ((p_year(tOld) + p_lifeTimeSi(silos)) ge p_year(t))
                        $ ( p_year(told)                        le p_year(t))),
                           p_iniSilos(manChain,silos,tOld))

*
*         --- Plus (old) investments - de-investments
*
           +  sum(t_n(t1,nCur1) $ (tcur(t1) $ isNodeBefore(nCur,nCur1)
                                 and (   ((p_year(t1)  + p_lifeTimeSi(silos)) ge p_year(t))
                                       $ ( p_year(t1)                         le p_year(t)))),
                                           v_buysilos(manChain,silos,t1,nCur1));
```

The manure silos are linked to the manure storage needs, which are
described in chapter Manure. A similar inventory equation as for manure
silos is implemented for the other buildings:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /buildingInv_\(.*?nCur/ /;/)
```GAMS
buildingInv_(curBuildings(buildings),tCur(t),nCur)
        $ ( (    sum(t_n(t1,nCur1) $ isNodeBefore(nCur,nCur1), v_buyBuildings.up(buildings,t1,nCur1))
                 or (sum(tOld, p_iniBuildings(buildings,tOld)))) $ t_n(t,nCur) ) ..

       v_buildingsInv(buildings,t,nCur)

            =e=
*
*         --- old silo according to building date and lifetime
*             (will drop out of equation if too old)
*
           sum(tOld $ (   ((p_year(tOld) + p_lifeTimeBuild(buildings)) ge p_year(t))
                        $ ( p_year(told)                               le p_year(t))),
                           p_iniBuildings(buildings,tOld))

*
*         --- plus (old) investments - de-investments
*
           +  sum(t_n(t1,nCur1) $ (      ((p_year(t1)  + p_lifeTimeBuild(buildings)) ge p_year(t))
                                       $ ( p_year(t1)                         le p_year(t))
                                       $ tcur(t1) $ isNodeBefore(nCur,nCur1)),
                                           v_buyBuildings(buildings,t1,nCur1));
```

The buildings included in the model are:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/TEMPL_DECL.gms GAMS /set\ss_bunkerSilos/ /;/)
```GAMS
set s_bunkerSilos /
                   bunkerSilo450
                   bunkerSilo900
                   bunkerSilo1620
                   bunkerSilo2640
                   bunkerSilo3630
                   bunkerSilo4620
                   bunkerSilo8580
                   bunkerSilo11870
                   bunkerSilo26550
                 /;
```
[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/TEMPL_DECL.gms GAMS /set\sbuildings/ /;/)
```GAMS
set buildings  / potaStore500t
                     set.s_bunkerSilos
                   /;
```

The attributes of the buildings are defined in
*coeffgen\\buildings.gms*:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/buildings.gms GAMS /table\sp_building/ /;/)
```GAMS
table p_building(buildings,buildAttr)
                     invSum   capac_t  capac_m3   lifeTime    varCost

   potaStore500t    195850      500                 12          323
*
*  --- KTBL 2014/15 p.144
*
  bunkerSilo450      34176               450        20
  bunkerSilo900      60900               900        20
  bunkerSilo1620     84490              1620        20
  bunkerSilo2640    115770              2640        20
  bunkerSilo3630    127110              3630        20
  bunkerSilo4620    138450              4620        20
  bunkerSilo8580    218250              8580        20
  bunkerSilo11870   284970             11870        20
  bunkerSilo26550   482000             26550        20
   ;
```

The inventory of the buildings is linked to building needs of certain
activities:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /buildingNeed_\(c/ /;/)
```GAMS
buildingNeed_(curBuildType(buildType),buildCapac,tCur(t),nCur)
         $ (sum(curProds(prods),p_buildingNeed(prods,buildType,buildCapac)) $ t_n(t,nCur) ) ..

       sum(buildType_buildings(buildType,buildings)
               $ (  (     sum(t_n(t1,nCur1) $ isNodebefore(nCur,nCur1), v_buyBuildings.up(buildings,t1,nCur1))
                      or  sum(tOld, p_iniBuildings(buildings,tOld)))
                       $ curBuildings(buildings)),

            v_buildingsInv(buildings,t,nCur) * p_building(buildings,buildCapac))

                 =G= v_buildIngNeed(buildType,t,nCur);
```

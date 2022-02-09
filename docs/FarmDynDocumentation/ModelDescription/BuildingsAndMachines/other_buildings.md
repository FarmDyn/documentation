# Other Type of Buildings

> **_Abstract_**  
Other buildings in Farmdyn comprise bunker silos for maize or grass silage and potatoe storage. The actual size and corresponding costs and labour requirements are presented in the *investment and financing* section.

## Bunker Silos and Storages

The inventories for the other buildings (bunker silos for maize or grass silage and potatoe storages) are combined into one equation. The structure is similar to the inventory equation of manure silos and stables:

<!-- This embedmd was asked for in the word -->
[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/templ.gms GAMS /buildingInv\_\(curBuildings/ /;/)
```GAMS
buildingInv_(curBuildings(buildings),tCur(t),nCur)
        $ ( (    sum(t_n(t1,nCur1) $ isNodeBefore(nCur,nCur1), (v_buyBuildings.up(buildings,t1,nCur1) ne 0))
                 or (sum(tOld, p_iniBuildings(buildings,tOld)))) $ t_n(t,nCur) ) ..

       v_buildingsInv(buildings,t,nCur)

            =L=
*
*         --- old building / silo according to building date and lifetime
*             (will drop out of year is too far in the past)
*
           sum(tOld $ (   ((p_year(tOld) + p_lifeTimeBuild(buildings)) gt p_year(t))
                        $ ( p_year(told)                               le p_year(t))),
                           p_iniBuildings(buildings,tOld))
*
*         --- plus (old) investments - de-investments
*
        + sum(t_n(t1,nCur1) $ (   ((p_year(t1)  + p_lifeTimeBuild(buildings)) gt p_year(t))
                                $ ( p_year(t1)                         le p_year(t))
                                $ tcur(t1) $ isNodeBefore(nCur,nCur1)),
                                  + v_buyBuildingsF(buildings,t1,nCur1));
```

The buildings included in the model are:

<!-- Keep? -->
[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/buildings_de.gms GAMS /set s_bunkerSilos/ /;/)
```GAMS
set s_bunkerSilos /
                   bunkerSilo0
                   bunkerSilo450
*                   bunkerSilo900
*                   bunkerSilo1620
*                   bunkerSilo2640
*                   bunkerSilo3630
*                   bunkerSilo4620
*                   bunkerSilo8580
*                   bunkerSilo11870
                   bunkerSilo26550
                 /;
```

<!-- Keep? -->
[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/buildings_de.gms GAMS /set buildings/ /;/)
```GAMS
set buildings  /
                     set.s_potaStores
                     set.s_bunkerSilos
                   /;
```

The attributes of the buildings are defined in
*dat\\buildings_de.gms*:

<!-- Keep? -->
[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/dat/buildings_de.gms GAMS /table p_building/ /;/)
```GAMS
table p_building(buildings,buildAttr)
                     invSum   capac_t  capac_m3   lifeTime    varCost

  potaStore0                   eps                 12
  potaStore100t     80000      100                 12          323
  potaStore500t    195850      500                 12          323
  potaStore11250t 1740000    11250                 12          323
*
*  --- KTBL 2014/15 p.144
*
  bunkerSilo0                            eps        20
  bunkerSilo450      34176               450        20
*  bunkerSilo900      60900               900        20
*  bunkerSilo1620     84490              1620        20
*  bunkerSilo2640    115770              2640        20
*  bunkerSilo3630    127110              3630        20
*  bunkerSilo4620    138450              4620        20
*  bunkerSilo8580    218250              8580        20
*  bunkerSilo11870   284970             11870        20
  bunkerSilo26550   482000             26550        20
   ;
```

The inventory of the buildings is linked to building needs of certain activities:

<!-- This embedmd was asked for in the word -->
[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/templ.gms GAMS /buildingNeed_\(c/ /;/)
```GAMS
buildingNeed_(curBuildType(buildType),buildCapac,tCur(t),nCur)
         $ (sum(curProds(prods),p_buildingNeed(prods,buildType,buildCapac)) $ t_n(t,nCur) ) ..

       sum(buildType_buildings(buildType,buildings)
               $ (  (     sum(t_n(t1,nCur1) $ isNodebefore(nCur,nCur1), (v_buyBuildings.up(buildings,t1,nCur1) ne 0))
                      or  sum(tOld, p_iniBuildings(buildings,tOld)))
                       $ curBuildings(buildings)),

            v_buildingsInv(buildings,t,nCur) * p_building(buildings,buildCapac))

                 =G= v_buildIngNeed(buildType,t,nCur);
```

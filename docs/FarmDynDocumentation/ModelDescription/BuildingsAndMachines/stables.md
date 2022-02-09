# Stables

> **_Abstract_**  
Stables in FarmDyn are differentiated by size and animal type. The stable size present in the inventory is determined by the  number of animals set in the GUI. The investment decision and final size of the stable is described in the *investment and financing* section. Based on the actual stable size, aspects such as labour requirements and variable costs are set. Eventually, cattle stables differentiate between different type of flooring and manure management systems.






Different types of stables are implemented in FarmDyn. In general, stables are differentiated between calf, cow, mother cow, young cattle (including beef fattening), piglet, fattener, and sow stables.
These stables are available in different sizes. For more information on investment decision in different stable sizes please refer to the section *investment and financing*.
The requirement of an animal for a certain stable type is defined by the parameter *p\_stableNeed*. Through this approach, it is possible for some herds to share a stables place, e.g. calves and heifers, or bulls and heifers by assigning their stable need to the same stable type.
Stable types can further be specified through their manure management system, depicted by the set *stableStyle*.
As a default, all stable types will employ slatted floor manure handling, resulting in only liquid manure handling on the farm.
Choosing a straw stable for a herd will consequently affects costs, manure handling, and labour requirement.

The stable inventory (*v\_stableInv*) for each type of stable, (*stables*), is defined as seen in the following equation *stableInv\_*. *p\_iniStables* is the initial endowment of stables in the construction year, *p\_lifeTimeS* is the maximal physical lifetime of the stables, and *v\_buyStablesF* are newly constructed stables.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/general_herd_module.gms GAMS /stableInv_[\S\s][^;]*?\.\./ /;/)
```GAMS
stableInv_(stables,hor,tFull(t),nCur)
       $ (   (p_priceStables(stables,hor,t) gt eps)
               $ (      sum( (t_n(t1,nCur1),hor1) $ ((isNodeBefore(nCur,nCur1) or sameas(nCur,nCur1)) and (p_year(t1) le p_year(t))),
                         (v_buyStables.up(stables,hor1,t1,nCur1) ne 0))
                    or  sum( tOld, p_iniStables(stables,hor,tOld)))
                     $ (sum(stableTypes,p_stableSize(stables,StableTypes)) gt eps)
                     $ t_n(t,nCur) ) ..

       v_stableInv(stables,hor,t,nCur)

          =L=
*
*         --- old stables according to building date and lifetime
*             (will drop out of equation if too old)
*
          sum( tOld $ (   ((p_year(tOld) + p_lifeTimeS(stables,hor)) gt p_year(t))
                              $ ( p_year(told)                       le p_year(t))),
                           p_iniStables(stables,hor,tOld))

*
*         --- plus (old) investments - de-investments
*
       +  sum( t_n(t1,nCur1) $ ( isNodeBefore(nCur,nCur1)
                                   $  (   ((p_year(t1)  + p_lifeTimeS(stables,hor) ) gt p_year(t))
                                   $ (      p_year(t1)                               le p_year(t)))),
                                                    v_buyStablesF(stables,hor,t1,nCur1));
```


The variable *v\_stableUsed* is defined as the size of a herd multiplied with the herds requirement for stable places in a particular stable type.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/general_herd_module.gms GAMS /stables_[\S\s][^;]*?\.\./ /;/)
```GAMS
stables_(stableTypes,tCur(t),nCur,m)
          $ (sum(actHerds(sumHerds,breeds,feedRegime,t,m) $ ((not sameas(feedRegime,"fullGraz"))
                  $ v_herdSize.up(sumHerds,breeds,feedRegime,t,nCur,m)), p_stableNeed(sumHerds,breeds,stableTypes))
                  $ t_n(t,nCur) )  ..
*
       v_stableNeed(stableTypes,t,nCur)

          =L=
*
*         --- must be covered by current stable inventory (not fully depreciated building),
*             mutiplied with the stable places they offer
*
       sum(stables $ (    sum( (t_n(t1,nCur1),hor) $ ((isNodeBefore(nCur,nCur1) or sameas(nCur,nCur1)) and (p_year(t1) le p_year(t))),
                               (v_buyStables.up(stables,hor,t1,nCur1) ne 0))
                       or sum( (tOld,hor), p_iniStables(stables,hor,tOld))),
           v_stableUsed(stables,t,nCur) * p_stableSize(stables,stableTypes));
```


Eventually, the utilised stable places (*v_stableUsed*), need to be covered by the available stable inventory (*v_stableInv*):

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/general_herd_module.gms GAMS /stableUsed_[\S\s][^;]*?\.\./ /;/)
```GAMS
stableUsed_(stables,hor,tFull(t),nCur,m)
       $ ( (p_priceStables(stables,hor,t) gt eps)
           $  (       sum( (t_n(t1,nCur1),hor1) $ ((isNodeBefore(nCur,nCur1) or sameas(nCur,nCur1)) and (p_year(t1) le p_year(t))),
                               (v_buyStables.up(stables,hor1,t1,nCur1) ne 0))
                or  sum( (tOld,hor1), p_iniStables(stables,hor1,tOld)))
                     $ (sum(stableTypes,p_stableSize(stables,StableTypes)) gt eps) $  t_n(t,nCur)) ..

       v_stableInv(stables,hor,t,nCur) =G= [v_stableUsed(stables,t,nCur) + v_stableNotUsed(stables,t,nCur,m)] $ tCur(t)

                                         + [   sum( (t1,nCur1) $ ( isNodeBefore(nCur,nCur1) $ sameas(t1,"%lastYear%") $ t_n(t1,nCur1) $ (not sameas(t,t1))),
                                                                    v_stableUsed(stables,t1,nCur1)+ v_stableNotUsed(stables,t1,nCur1,m))
                                           ]  $ ( (not tCur(t)) and p_prolongCalc);
```


The investment horizon set *hor* differentiates between the initial investment into the building, assumed to last for 30 years, and certain equipment for which maintenance investments are necessary after 10 or 15 years for cow stables.

A stable can only be used, if short and middle term maintenance investments are done. The different stable attributes are defined in "*coeffgen\\stables.gms*".

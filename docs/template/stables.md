# Stables

Different types of stables are implemented in FarmDyn. In general, stables are differentiated between calf, cow, mother cow, youngCattle, piglet, fattener, and sow stables.
These stables are available in differing sizes.
The requirement of an animal for a certain stable type is defined by the parameter *p_stableNeed*. Through this approach, it is possible for some herds to share a stables place, e.g. calves and heifers, or bulls and heifers by assigning their stable need to the same stable type.
Stable types can further be specified through their manure management system, depicted by the set *stableStyle*. 
As a default, all stable types will employ slatted floor manure handling, resulting in only liquid manure handling on the farm. 
Chosing a straw stable for a herd will consequently affect costs, manure handling, and labour requirement.

The stable inventory (*v\_stableInv*) for each type of stable,
(*stables*) is defined as seen in the following equation *stableInv\_*. *p\_iniStables*
is the initial endowment of stables by the construction year,
*p\_lifeTimeS* is the maximal physical lifetime of the stables, and
*v\_buyStables* are newly constructed stables.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/general_herd_module.gms GAMS /stableInv_[\S\s][^;]*?\.\./ /;/)
```GAMS
stableInv_(stables,hor,tFull(t),nCur)
       $ (   (p_priceStables(stables,hor,t) gt eps)
               $ (      sum( t_n(t1,nCur1) $ (isNodeBefore(nCur,nCur1) or sameas(nCur,nCur1)),
                         v_buyStables.up(stables,hor,t1,nCur1))
                    or  sum( tOld, p_iniStables(stables,hor,tOld))) $ t_n(t,nCur) ) ..

       v_stableInv(stables,hor,t,nCur)

          =L=
*
*         --- old stables according to building date and lifetime
*             (will drop out of equation if too old)
*
          sum( tOld $ (   ((p_year(tOld) + p_lifeTimeS(stables,hor)) ge p_year(t))
                              $ ( p_year(told)                       le p_year(t))),
                           p_iniStables(stables,hor,tOld))

*
*         --- plus (old) investments - de-investments
*
       +  sum( t_n(t1,nCur1) $ ( isNodeBefore(nCur,nCur1)
                                   $  (   ((p_year(t1)  + p_lifeTimeS(stables,hor) ) ge p_year(t))
                                   $ (      p_year(t1)                               le p_year(t)))),
                                                    v_buyStables(stables,hor,t1,nCur1));
```


The variable *v_stableUsed* is defined as the size of a herd mutliplied with the herds requirement for stable places in a particular stable type.
[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/general_herd_module.gms GAMS /stables_[\S\s][^;]*?\.\./ /;/)
```GAMS
stables_(stableTypes,tFull(t),nCur,m)
          $ (sum(actHerds(sumHerds,breeds,feedRegime,t,m) $ ((not sameas(feedRegime,"fullGraz"))
                  $ v_herdSize.up(sumHerds,breeds,feedRegime,t,nCur,m)), p_stableNeed(sumHerds,breeds,stableTypes))
                  $ t_n(t,nCur) )  ..
*
*      --- herd sizes times their request for specific stable "types" (cow, calves, young cattle)
*

       sum(actHerds(sumHerds,breeds,feedRegime,t,m) $ (not sameas(feedRegime,"fullGraz")),
             v_herdSize(sumHerds,breeds,feedRegime,t,nCur,m)
                      * p_stableNeed(sumHerds,breeds,stableTypes))
          =L=
*
*         --- must be covered by current stable inventory (not fully depreciated building),
*             mutiplied with the stable places they offer
*
       sum(stables $ (    sum( (t_n(t1,nCur1),hor) $ (isNodeBefore(nCur,nCur1) or sameas(nCur,nCur1)),
                               v_buyStables.up(stables,hor,t1,nCur1))
                       or sum( (tOld,hor), p_iniStables(stables,hor,tOld))),
           v_stableUsed(stables,t,nCur) * p_stableSize(stables,stableTypes));
```


Eventually, the utilized stable places (*v_stableUsed*), need to be covered by the available stable inventory (*v_stableInv*):
[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/general_herd_module.gms GAMS /stableUsed_[\S\s][^;]*?\.\./ /;/)
```GAMS
stableUsed_(stables,hor,tFull(t),nCur) $ ( (      sum( t_n(t1,nCur1) $ (isNodeBefore(nCur,nCur1) or sameas(nCur,nCur1)),
                                                                   v_buyStables.up(stables,hor,t1,nCur1))
                                                  or  sum( (tOld), p_iniStables(stables,hor,tOld))) $ t_n(t,nCur)) ..

       v_stableUsed(stables,t,nCur) =L= v_stableInv(stables,hor,t,nCur);
```


For cow stables a differentiation is introduced between the initial
investment into the building, assumed to last for 30 years, and certain
equipment for which maintenance investments are necessary after 10 or 15
years, as defined by the investment horizon set *hor*.

A stable can only be used, if short and middle term maintenance
investment is done.

As certain maintenance costs are linked to stables, the share of the
used stable is restricted to minimum 75%, which assumes that maximal 25%
of the maintenance costs can be saved when the stable is not fully used:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/general_herd_module.gms GAMS /stableCostLo_[\S\s][^;]*?\.\./ /;/)
```GAMS
stableCostLo_(stables,hor,tFull(t),nCur)
       $ ((       sum( t_n(t1,nCur1) $ (isNodeBefore(nCur,nCur1) or sameas(nCur,nCur1)),
                               v_buyStables.up(stables,hor,t1,nCur1))
              or  sum( (tOld), p_iniStables(stables,hor,tOld))) $  t_n(t,nCur)  )  ..

       v_stableShareCost(stables,t,nCur) =G= v_stableInv(stables,hor,t,nCur) * 0.75;
```



The different stable attributes are defined in
"*coeffgen\\stables.gms*".

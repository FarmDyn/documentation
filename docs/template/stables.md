
# Stables


The template applies a vintage based model for different stable types in
addition to other buildings and selected machinery, and a physical use
based depreciation for the majority of the machinery park. Under the
vintage based model stables, other buildings and machinery become
unusable after a fixed number of years. In the case of physical
depreciation machinery becomes inoperative when its maximum number of
operating hours or another measurement of use (e.g. the amount handled)
is reached. Investments in stable, buildings and machinery are
implemented as binary variables. In order to keep the possible branching
trees at an acceptable size, the re-investment points can be restricted
to specific years. For longer planning horizon covering several decades,
investment could e.g. only be allowed every fourth or fifth year.

The stable inventory, *v\_stableInv,* for each type of stable,
*stables,* is defined as can be seen in *stableInv\_*. *p\_iniStables*
is the initial endowment of stables by the construction year,
*p\_lifeTimeS* is the maximal physical life time of the stables and
*v\_buyStables* are newly constructed stables.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/EMV.gms GAMS /stableInv_\(.*?\.\./ /;/)
```GAMS
stableInv_(stables,t)   ..

         v_stableInv(stables,t) =E=
*
*         --- old stables according to building date and lifetime
*
            sum(tOld $ (     ((p_year(tOld) + p_lifeTimeS(stables)) ge p_year(t))
                         and ( p_year(told)                        le p_year(t))),
             p_iniStables(stables,tOld))
*
*         --- plus (old) investments
*
         +  sum(t1   $ (     ((p_year(t1)  + p_lifeTimeS(stables) ) ge p_year(t))
                         and ( p_year(t1)                          le p_year(t))),
                               v_buyStables(stables,t1));
```


For cow stables a differentiation is introduced between the initial
investment into the building, assumed to last for 30 years, and certain
equipment for which maintenance investments are necessary after 10 or 15
years, as defined by the investment horizon set *hor*:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ_decl.gms GAMS /set\shor/ /;/)
```GAMS
set hor "Investment horizons"/
       short   "10 years lifetime"
       middle  "15 years lifetime"
       long    "30 years lifetime"
 /;
```

A stable can only be used, if short and middle term maintenance
investment is done.

The model distinguishes between several stable types for cattle, shown
in the following list). They differ in capacity, cattle type, investment
cost and labour need per stable place.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ_decl.gms GAMS /set\sset_cowStables/ /;/)
```GAMS
set set_cowStables "Stable for dairy cows"  /
                     milk30, milk40, milk50, milk60, milk70, milk80, milk90,milk100,milk110,milk120,
                     milk130,milk140,milk150,milk160,milk170,milk180,milk190,milk200,milk210,milk220,
                     milk230,milk240
       /;
```

For pigs the following stable sizes are available:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ_decl.gms GAMS /set\sset_youngStables/ /;/)
```GAMS
set set_youngStables "Stable for cattle older than 6 months"
             / youngCattle15
               youngCattle30
               youngCattle45
               youngCattle60
               youngCattle75
               youngCattle90
               youngCattle120
               youngCattle150
               youngCattle180
               youngCattle210
               youngCattle240
            /;
```

The used part of the stable inventory (a fractional variable) must cover
the stable place needs for the herd:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ_decl.gms GAMS /set\sset_calvStables/ /;/)
```GAMS
set set_calvStables  "Stable for calves up to 6 months"
            / calves15
              calves30
              calves45
              calves60
              calves75
              calves90
              calves120
              calves150
           /;
```

The used part cannot exceed the current inventory (a binary variable):

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/stables.gms GAMS /\$iftheni\.fat/ /\$endif\.fat/)
```GAMS
$iftheni.fat "%FarmBranchFattners%" == on

     fat400                          400
     fat500                          500
     fat800                          800
     fat1000                        1000
     fat1200                        1200
     fat1500                        1500
     fat1800                        1800
     fat2000                        2000
     fat2500                        2500
     fat3000                        3000
$endif.fat
```

As certain maintenance costs are linked to stables, the share of the
used stable is restricted to minimum 75%, which assumes that maximal 25%
of the maintenance costs can be saved when the stable is not fully used:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/stables.gms GAMS /\$iftheni\.sows/ /\$endif\.sows/)
```GAMS
$iftheni.sows "%FarmBranchSows%" == on

     sows120            120
     sows200            200
     sows250            250
     sows300            300
     sows400            400
     sows500            500

     piglet500                                     500
     piglet750                                     750
     piglet1000                                   1000
     piglet1500                                   1500
     piglet2000                                   2000
$endif.sows
```

The different stable attributes are defined in
"*coeffgen\\stables.gms*".

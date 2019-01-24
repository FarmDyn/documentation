
# Labour


!!! abstract
    The labour module optimises work use on- and off-farm with a monthly resolution, depicting detailed labour needs for different farm operations, herds and stables, management requirements for each farm branch, and the farm as a whole. Off-farm work distinguishes between half- and full-time work (binaries) and working flexibly for a low wage rate.

## General Concept

The template differentiates between three types of labour on farm:

1.  **General management and further activities for the whole farm,**
    *p\_labManag("farm","const"*), which are needed as long as the farm
    is not abandoned ,*v\_hasFarm* = 1, *binary variable*, and not
    depending on the level of individual farm activities.

2.  **Management activities and further activities depending on the size
    of farm branches** such as arable cropping, dairying, beef fattening, pig fattening, and piglet production. The necessary working hours are broken down into a base need, *const* which is linked to having the respective farm branch, *v\_hasBranch*, *integer*, and a linear term depending on its size, *slope*.

3.  **Labour needs for certain farm operations** (aggregated to
    *v\_totLab*).

The sum of total labour needs cannot exceed total yearly available
labour (see following equation). As discussed below, there are further
restrictions with regard to monthly labour and available field working
days.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /LabTot_\(tC/ /;/)
```GAMS
LabTot_(tCur(t),nCur) $ t_n(t,nCur) ..

        sum(m, v_labTot(t,nCur,m)) =L= p_yearlyLabH(t);
```

The maximal yearly working hours, *p\_yearlyLabH,* are defined in the
statement shown below. The maximal labour hours for the first, second
and further labour units can be entered via the GUI.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/farm_constructor.gms GAMS /p_yearlyLabH\(t\).*?=/ /;/)
```GAMS
p_yearlyLabH(t)   =  %AkhFirst%   * min(1,%Aks%)
                      + %AkhSecond%  * min(1,%Aks%-1) $ (%Aks% > 1)
                      + %AkhFurther% * (%Aks%-2)      $ (%Aks% > 2);
```

The maximaum work hours per month is defined in the following statement,
represented by the parameter *p\_monthlyLabH*:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/farm_constructor.gms GAMS /p_monthlyLabH\(t,m\).*?=/ /;/)
```GAMS
p_monthlyLabH(t,m) =  max(p_yearlyLabH(t) / 365 * p_daysPerMonth(m)*1.2,  %Aks% * 12 * p_daysPerMonth(m) * 5/7);
```

The template considers the sum of labour needs for each month, *m,* and each SON, *s*. Farm labour needs are related to certain farm activities on
field and in stable. The labour need for work on-farm and flexibly off-farm is defined by the following equation. The variables that enter in
the equation are explained in the next section of the labour section.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /labTotSM_\(tCur/ /;/)
```GAMS
labTotSM_(tCur(t),nCur,m) $ t_n(t,nCur)  ..
*
*        --- sum of work in hours in current month
*
       v_LabTot(t,nCur,m) =e=
*
*      --- leisure time
*
           v_leisure(t,nCur,m)
*
*      --- labour use for crops and herds
*
        +  v_labCropSM(t,nCur,m)

$ifi %herd%==true  + v_labHerdM(t,nCur,m)
*
*      --- Management
*
       + v_labManag(t,nCur)/card(m)
*
*        --- off farm labour - per month: p_workTime are weekly hours,
*            p_commTime is the commuting time in weekly hours, assumption of
*            46 weeks work in each year (binary variables)
*
       + v_labOffFixed(t,nCur)/card(m)
*
*        --- small scale work on a hourly basis (continous)
*
       + v_labOffHourly(t,nCur)
*
*        --- labour use for biogas plant
*
$ifi %biogas%== true + sum((curBhkw(bhkw)), v_labBioGas(bhkw,t,nCur,m))
       ;
```

## Labour Need for Farm Branches

FarmDyn comprises currently five different farm branches: cropping,
cattle, fatteners, sows and biogas. The (management) labour needs for
the biogas branch is accounted for in the biogas module. For the other
branches, their size *v\_branchSize*, is endogenously defined from
activity levels mapped to it:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /branchSize_\(.*?\$/ /;/)
```GAMS
branchSize_(branches,tCur(t),nCur) $ ( (sum(branches_to_acts(branches,possActs) ,1) $ t_n(t,nCur))
                                          $$ifi %biogas%==true  or sum(sameas(branches,"biogas"),1) $ t_n(t,nCur)
                                           )  ..

       v_branchSize(branches,t,nCur) =E= sum((branches_to_acts(branches,curCrops(crops)),plot,till,intens)
                                          $( c_s_t_i(crops,plot,till,intens)$( not sameas (crops,"catchCrop"))),
                                             v_cropHa(crops,plot,till,intens,t,nCur))

$iftheni %herd% == true
                                  + sum( (branches_to_acts(branches,possHerds),breeds,feedRegime,m)
                                       $ (actHerds(possHerds,breeds,feedRegime,t,m) $ p_prodLength(possHerds,breeds)),
                                           v_herdSize(possHerds,breeds,feedRegime,t,nCur,m)
                                              * 1/min(12,p_prodLength(possHerds,breeds))
                                           * ( (12/card(herdM)) $ (not sameas(branches,"fatPig")) + 1 $ sameas(branches,"fatPig"))
                                           )
$endif

$iftheni %biogas% == true
                                  + [sum( (curBhkw,curEeg,t_n(tCur,nCur),m),  v_prodElec(Curbhkw,curEeg,tCur,nCur,m))/100000]
                                                $ sameas(branches,"biogas")
$endif
    ;
```

Where the cross-set, *branches\_to\_acts,* defines which activities
count to a certain branch:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ_decl.gms GAMS /set\sbranches_to_acts/ /;/)
```GAMS
set branches_to_acts(branches,acts) /
       cashCrops.(winterWheat,winterBarley,summerCere,winterRape,summerBeans,summerPeas,
                  MaizCorn,potatoes,sugarBeet,MaizCCM,
       $$ifthen.cattle not %cattle%==true
                  MaizSil,WheatGPS,
       $$endif.cattle
                  CatchCrop)
       dairy.cows
       motherCows.motherCow
       sowPig.sows
       fatPig.fattners
       beef.bulls
   /;
```

The binary variable *v\_hasBranch* which relates to the general
management need for branch is triggered as follows:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /hasBranch_\(.*?\$/ /;/)
```GAMS
hasBranch_(branches,tCur(t),nCur)  $ (sum(branches_to_acts(branches,acts) ,1) $ t_n(t,nCur)
                                          $$ifi %biogas%==true  or sum(sameas(branches,"biogas"),1) $ t_n(t,nCur)
                                           )  ..
       v_branchSize(branches,t,nCur) =l= v_hasBranch(branches,t,nCur) * p_maxBranch(branches);
```

The *hasFarm* trigger depends on the trigger for the individual
branches:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /hasFarm_\(.*?\$/ /;/)
```GAMS
hasFarm_(branches,tCur(t),nCur) $ ((not sameas(branches,"farm")) $ (v_hasBranch.range(branches,t,nCur) ne 0) $ t_n(t,nCur)) ..

       v_hasBranch(branches,t,nCur)  =l= v_hasFarm(t,nCur);
```

The hours needed for yearly farm management are defined using a
constant and the branch specific values:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /labManag_\(tCur.*?\$/ /;/)
```GAMS
labManag_(tCur(t),nCur) $ t_n(t,nCur) ..

       v_labManag(t,nCur) =e=
*
*       -- two hundredth hours independent from number of branches or farm size
*
        + v_hasFarm(t,nCur) * p_labManag("Farm","const")

        + sum(branches $ sum(branches_to_acts(branches,acts), 1),
                v_hasBranch(branches,t,nCur)  * p_labManag(branches,"const")
             +  v_branchSize(branches,t,nCur) * p_labManag(branches,"slope"));
```

## Labour Need for Herd, Cropping, Operations and Off-Farm Work

### Herd Activities and Cropping

The labour need for animals, *v\_herdLabM,* is defined by an animal type
specific requirement parameter, *p\_herdLab,* in hours per animal and
month (see in the next equation, working hours per animal and month) and by the time requirement per stable place, which differs with the stable type. This formulation allows labour saving
scale effects related to the stable size:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/general_herd_module.gms GAMS /labHerdM_\(tCur.*?\$/ /;/)
```GAMS
labHerdM_(tCur(t),nCur,m) $ t_n(t,nCur) ..
       v_labHerdM(t,nCur,m) =e=
*
*        --- labour for animal activities, expressed per animal and month
*            of standing herd
*
        sum(actHerds(sumHerds,breeds,feedRegime,t,m1) $ m_to_herdm(m,m1),
              v_herdSize(sumHerds,breeds,feedRegime,t,nCur,m1) * p_herdLab(sumHerds,feedRegime,m))
*
*        --- labour for animal activities, per starting animal (hours for giving birth and similar)
*
      +  sum( (sumHerds,breeds,m1) $ (sum(feedRegime, actHerds(sumHerds,breeds,feedRegime,t,m1)) $ m_to_herdm(m,m1)),
                v_herdStart(sumHerds,breeds,t,nCur,m1)* p_herdLabStart(sumHerds,m))
*
*        --- fixed amount of hours for stables (maintenance, cleansing),
*            captures also labour saving effects of large stables
*
      + sum(stables $ v_stableInv.up(stables,"long",t,nCur),
                                v_stableShareCost(stables,t,nCur) * p_stableLab(stables,m) );
```

A similar equation exists for crops. The parameter *p\_cropLab* defines the labour hours per hectare and month for each crop. In addition, the parameters *p\_manDistLab* and *p\_syntDistLab* multiplied by the *N type* applied to each crop are added to the overall crop labour demand for the application of synthetic fertiliser and manure:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /labCropSM_\(tCur.*?\$/ /;/)
```GAMS
labCropSM_(tCur(t),nCur,m) $ t_n(t,nCur) ..

       v_labCropSM(t,nCur,m) =e=
*
*        --- labour need for crops, expressed per ha of land
*            (will probably change to specific acticities later)
*
         sum( c_s_t_i(curCrops(crops),plot,till,intens),
                v_cropHa(crops,plot,till,intens,t,nCur) * p_cropLab(crops,till,intens,m))

*        --- labour need for application of N (fertilizer and manure N)

$iftheni.man %manure% == true
       + sum((c_s_t_i(curCrops(crops),plot,till,intens),manApplicType_manType(ManApplicType,curManType))
              $ ((v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0)
              $ ( v_manDist.up(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m) ne 0)),
               v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m) * p_manDistLab(ManApplicType))
$endif.man

       + sum((c_s_t_i(crops,plot,till,intens),syntFertilizer),
               v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m) * p_syntDistLab(syntFertilizer));
```

### Farm Operations

Field working days define the number of days available in a labour
period of half a month, *labPeriod,* during which soil conditions allow
specific types of operations, *labReqLevl*:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /fieldWorkHours_\(p.*?nCur/ /;/)
```GAMS
fieldWorkHours_(plot,labReqLevl,labPerSum,tCur(t),nCur)
                $ (p_plotSize(plot) $ plot_landType(plot,"arab") $ t_n(t,nCur) ) ..

       v_fieldWorkHours(plot,labReqLevl,labPerSum,t,nCur)

         =e=
*
       sum(labPerSum_ori(labPerSum,LabPeriod),
*
*       --- operations requiring a tractor, with the exemption top of
*           fertilizer dsitribution
*
        sum( c_s_t_i(curCrops(crops),plot,till,intens),
             v_cropHa(crops,plot,till,intens,t,nCur)
                 * p_fieldWorkHourNeed(crops,till,intens,labPeriod,labReqLevl)
*
*       --- distribution of synthetic fertilizer

       +   sum( (syntFertilizer,labPeriod_to_month(labPeriod,m)),
                  v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)
                    * p_machNeed(syntFertilizer,"plough","normal","tractor","hour") ) * sameas(labReqLevl,"rf3")
           )
        );
```

The number of field working hours cannot exceed a limit which is defined by
the available field working days, *p\_fieldWorkingDays.* Field working
days depend on climate zone, soil type (*light, middle, heavy*) and
distribution of available tractors to the soil type, *v\_tracDist*. It
is assumed that farm staff will be willing to work up to 15 hours a day,
still with the total work load per month being restricted:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /tracRestr.*?_\(.*?nCur\)/ /;/)
```GAMS
tracRestrFieldWorkHours_(plot,labReqLevl,labPerSum,tCur(t),nCur)
       $ (p_plotSize(plot) $ plot_landType(plot,"arab") $ t_n(t,nCur)) ..

       v_fieldWorkHours(plot,labReqLevl,labPerSum,t,nCur)

        =L=
             sum(labPerSum_ori(labPerSum,LabPeriod),
               sum(plot_soil(plot,soil),
                      sum(curClimateZone, p_fieldWorkingDays(labReqLevl,labPeriod,curClimateZone,soil)) * 12)
                              * v_tracDist(plot,labPerSum,t,nCur));
```

Furthermore, the distribution of tractors is determined endogenously:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /tracDistr.*?\.\./ /;/)
```GAMS
tracDistribution_(labPerSum,tCur(t),nCur) $ t_n(t,nCur) ..

       sum(plot $ p_plotSize(plot), v_tracDist(plot,labPerSum,t,nCur)) =L= ceil(%Aks%);
```

It implicitly assumes that farm family members are willing to spend
hours for on-farm work even if working off-farm, e.g. by taking days
off.

### Off-Farm Work

Farm family members can optionally work half- or full-time, *v\_workoff*,
or on an hourly basis off-farm, *v\_workHourly*. Half- and full-time work
are realised as integer variables. In the normal setting the wage per
hour for working half time exceeds the wage of short time hourly work.
Moreover, the wage per hour of full time work is higher than of working
half time. For half- and full-time work commuting time can be
considered:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /offFarmHoursPerYearFixed_\(tCur/ /;/)
```GAMS
offFarmHoursPerYearFixed_(tCur(t),nCur) $ (t_n(t,nCur) $ sum(workOpps(workType), v_labOff.up(t,nCur,workType)))  ..

       v_labOffFixed(t,nCur) =e=
*
*        --- off farm labour - per month: does not fit with the actual hours worked,
*                                         but assumes the actual willingness to work on farm
*                                         is reduced (typically farm more compared to what is worked!)

         + sum( workOpps(workType),
              v_labOff(t,nCur,workType) * p_workTimeLost(workType));
```

The set *workType* lists the possible combinations:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/labour.gms GAMS /p_workTime\(w.*?\=/ /;/)
```GAMS
p_workTime(workType) =   (p_workT("Half")+p_workT("Full")*floor(workType.pos/2))  $ ( mod(workType.pos,2) eq 1)
                          +  p_workT("Full")*(workType.pos/2 )                       $ ( mod(workType.pos,2) eq 0);
```

It is assumed that decisions about how much to work flexibly on an
hourly basis are taken on a yearly basis (i.e. the same number of hours
is inputted in each month).

The total number of hours worked off-farm is defined as:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /offFarmWorkTot_\(tCur/ /;/)
```GAMS
offFarmWorkTot_(tCur(t),nCur) $ t_n(t,nCur) ..
*
       v_labOffTot(t,nCur) =e=

       v_labOffHourly(t,nCur) * card(m)

     + v_labOffFixed(t,nCur) $ sum(workOpps(workType), v_labOff.up(t,nCur,workType));
```

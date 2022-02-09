# Labour

> **_Abstract_**  
The labour module optimises work use on- and off-farm with a monthly resolution, depicting detailed labour needs for different farm operations, herds and stables, management requirements for each farm branch, and the farm as a whole. Off-farm work distinguishes between half- and full-time work (binaries) and working flexibly for a low wage rate.

## General Concept

The template differentiates between three types of labour on farm:

1.  **General management and further activities for the whole farm,**
    *p\_labManag("farm","const"*) - needed as long as the farm is not abandoned;
    *v\_hasFarm* = 1 - *binary variable* and not depending on the level of individual farm activities.

2.  **Management activities and further activities depending on the size**
    Of farm branches such as arable cropping, dairying, beef fattening, pig fattening, and piglet production.
    The necessary working hours are broken down into a base need, *const* which is linked to having the respective farm branch, *v\_hasBranch* (integer) and a linear term depending on its size, *slope*.

3.  **Labour needs for certain farm operations** (aggregated to
    *v\_labTot*).

The sum of total labour needs cannot exceed total yearly available labour from on-farm sources plus hired workers (see following equation). It is further assumed that household members which work off-farm require more leisure time than members who work on-farm. As discussed below, there are further restrictions with regard to monthly labour and available field working days.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/labour_module.gms GAMS /TimeTot\_\(t\_n\(tCur\(t\),nCur\)\)/ /;/)
```GAMS
TimeTot_(t_n(tCur(t),nCur)) ..
*
*       --- total on- and off-farm labour
*
        v_labTot(t,nCur)

         =L=
*
*                         ---- max work time if all family members work on the farm
*
                          p_yearlyLabH(t)
*
*                         ---- Difference between maximal willingness to work on farm and what is required for off-farm work
*                              Assumes that family members working off-farm want more leisure
*
                          - v_labOnFarmLost(t,nCur) $ sum(workOpps(workType), (v_labOff.up(t,nCur,workType) ne 0))
*
*                         ---- labour hours of hired farm workers
*
                          $$ifi "%allowHiring%"=="true" + v_hireWorkers(tcur,nCur) * %workHoursHired%
        ;
```

The maximal yearly working hours, <i>p_yearlyLabH</i> are defined in the statement shown below. The maximal labour hours for the first, second and further labour units can be entered via the graphical user interface.  

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/farm_constructor.gms GAMS /p_yearlyLabH\(t\).*?=/ /;/)
```GAMS
p_yearlyLabH(t)   =  %AkhFirst%   * min(1,%Aks%)
                      + %AkhSecond%  * min(1,%Aks%-1) $ (%Aks% > 1)
                      + %AkhFurther% * (%Aks%-2)      $ (%Aks% > 2);
```

The maximum work hours per month is defined in the following statement represented by the parameter <i>p_monthlyLabH</i>:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/farm_constructor.gms GAMS /p_monthlyLabH\(t,m\).*?=/ /;/)
```GAMS
p_monthlyLabH(t,m) =  p_yearlyLabH(t) / 365 * p_daysPerMonth(m) * (1+%flexHoursFamily%/100);
```

The template considers the sum of labour needs <i>v_labTotM</i> for each month <i>m</i>. On-farm labour needs are related to certain farm activities on field and in stable. Off-farm labour hours distinguish between contracts for full-time or part-time jobs, and off-farm work on an hourly basis. The variables which enter in the equation <i>labTotM_</i> are explained in the next sub-section starting with the fixed labour requirements related to the farm branches.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/labour_module.gms GAMS /labTotM\_\(t\_n\(tCur\(t\),nCur\),m\)/ /;/)
```GAMS
labTotM_(t_n(tCur(t),nCur),m)  ..
*
*        --- sum of work in hours in current month
*
       v_LabTotM(t,nCur,m) =e=
*
*      --- labour use for crops
*
        +  v_labCropSM(t,nCur,m)
*
*      --- labour use for herds
*
$ifi %herd%==true  + v_labHerdM(t,nCur,m)
*
*      --- Management hours (for total farm and the different brenaches)
*
       + v_labManag(t,nCur)/card(m)
*
*        --- off farm labour - per month: p_workTime are weekly hours,
*            p_commTime is the commuting time in weekly hours, assumption of
*            44 weeks work in each year (binary variables)
*
       + v_labOffFixed(t,nCur)/card(m)
*
*        --- small scale work on a hourly basis (continous)
*
       + v_labOffHourly(t,nCur)/card(m)
*
*        --- labour use for biogas plant
*
$ifi %biogas%== true + sum((curBhkw(bhkw)), v_labBioGas(bhkw,t,nCur,m))
       ;
```


## Labour Need for the Farm Branches and General Management

FarmDyn accounts for labour needs farm branch specific management and general management. This includes organization of purchasing and selling activities, required documentation for administrative bodies etc. The following equation <i>labManag_</i> shows the calculation of the total labour management on-farm. It accounts for the general management by multiplying the binary variable <i>v_hasFarm</i> and a predefined parameter, irrespective of the size of the farm. In addition, management related to one of the seven farm branches in FarmDyn (arable cropping, dairy, beef fattening, mother cow, fatteners, sows, and biogas) is considered to be linearly dependent on the size of that specific branch <i>v_branchSize</i>, e.g. in the case of dairy cows on the number of cows on farm. The variables <i>v_hasFarm</i> and <i>v_hasBranch</i> are determined by the activities mapped to the branch.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/labour_module.gms GAMS /labManag\_\(t\_n\(tCur\(t\),nCur\)\)/ /;/)
```GAMS
labManag_(t_n(tCur(t),nCur)) ..

       v_labManag(t,nCur) =e=
*
*       -- hours independent from number of branches or farm size
*
        + v_hasFarm(t,nCur) * p_labManag("Farm","const")
*
*       --- hours required for branches: block load plus
*           hours increasing in branch size
*
        + sum(branches $ sum(branches_to_acts(branches,acts), 1),
                v_hasBranch(branches,t,nCur)  * p_labManag(branches,"const")
             +  v_branchSize(branches,t,nCur) * p_labManag(branches,"slope"));
```


## Labour Need for Herd, Cropping, Operations and Off-Farm Work

### Herd Activities and Cropping

The labour need for animals, <i>v_herdLabM,</i> is defined by an animal type specific requirement parameter, <i>p_herdLab,</i> in hours per animal and month (see in the next equation, working hours per animal and month) and by the time requirement per stable place, which differs with the stable type. This formulation allows labour saving scale effects related to the stable size:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/labour_module.gms GAMS /labHerdM_\(tCur.*?\$/ /;/)
```GAMS
labHerdM_(tCur(t),nCur,m) $ t_n(t,nCur) ..
       v_labHerdM(t,nCur,m) =e=
*
*        --- labour for animal activities, expressed per animal and month
*            of standing herd
*
        sum(actHerds(sumHerds,breeds,feedRegime,t,m),
              v_herdSize(sumHerds,breeds,feedRegime,t,nCur,m) * p_herdLab(sumHerds,feedRegime,m))
*
*        --- labour for animal activities, per starting animal (hours for giving birth and similar)
*
      +  sum( (sumHerds,breeds) $ sum(feedRegime, actHerds(sumHerds,breeds,feedRegime,t,m)),
                v_herdStart(sumHerds,breeds,t,nCur,m)* p_herdLabStart(sumHerds,m))
*
*        --- fixed amount of hours for stables (maintenance, cleansing),
*            captures also labour saving effects of large stables
*
     + sum(stables $ (    sum( (t_n(t1,nCur1),hor) $ ((isNodeBefore(nCur,nCur1) or sameas(nCur,nCur1))  and (p_year(t1) le p_year(t))),
                               (v_buyStables.up(stables,hor,t1,nCur1) ne 0))
                       or sum( (tOld,hor), p_iniStables(stables,hor,tOld))),
                                (v_stableUsed(stables,t,nCur)-v_stableNotUsed(stables,t,nCur,m)) * p_stableLab(stables,m) $ (p_stableLab(stables,m) gt eps) );
```

A similar equation exists for crops. The parameter <i>p_cropLab</i> defines the labour hours per hectare and month for each crop.
In addition, the parameters <i>p_manDistLab</i> and <i>p_syntDistLab</i> multiplied by the <i>N type</i> applied to each crop
are added to the overall crop labour demand for the application of synthetic fertiliser and manure:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/labour_module.gms GAMS /labCropSM\_\(t\_n\(tCur\(t\),nCur\),m\)/ /;/)
```GAMS
labCropSM_(t_n(tCur(t),nCur),m) ..

       v_labCropSM(t,nCur,m) =e=
*
*        --- labour need for crops, expressed per ha of land
*                                                                                +
         sum( c_p_t_i(curCrops(crops),plot,till,intens),
                v_cropHa(crops,plot,till,intens,t,nCur) * p_cropLab(crops,till,intens,m))


$iftheni.man %manure% == true
*
*        --- labour need for application of manure
*            (considers all field operations not out-sourced as contract work,
*             with the exemption of manure and synt fertizer application)
*
       + sum((c_p_t_i(curCrops(crops),plot,till,intens),manApplicType_manType(ManApplicType,curManType))
              $ ((v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0)
              $ ( v_manDist.up(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m) ne 0)),
               v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m) * p_manDistLab(ManApplicType))
$endif.man
*
*        --- labour need for spreading synthetic fertilizer
*
       + sum((c_p_t_i(crops,plot,till,intens),curInputs(syntFertilizer)),
               v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m) * p_syntDistLab(syntFertilizer));
```


### Farm Operations

Field working days define the number of days available in a labour period of half a month, <i>labPeriod,</i> during which soil conditions allow specific types of operations, <i>labReqLevl</i>:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/labour_module.gms GAMS /fieldWorkHours_\(p.*?nCur/ /;/)
```GAMS
fieldWorkHours_(plot,labReqLevl,labPerSum,t_n(tCur(t),nCur)) $ (p_plotSize(plot) $ plot_landType(plot,"arab")) ..

       v_fieldWorkHours(plot,labReqLevl,labPerSum,t,nCur)

         =e=
*
       sum(labPerSum_ori(labPerSum,LabPeriod),
*
*       --- operations requiring a tractor, with the exemption top of
*           fertilizer dsitribution
*
        sum( c_p_t_i(curCrops(crops),plot,till,intens),
             v_cropHa(crops,plot,till,intens,t,nCur)
                 * p_fieldWorkHourNeed(crops,till,intens,labPeriod,labReqLevl)
*
*       --- distribution of synthetic fertilizer

       +   sum( (curInputs(syntFertilizer),labPeriod_to_month(labPeriod,m)),
                  v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)
                    * p_machNeed(syntFertilizer,till,"normal","tractor","hour") ) * sameas(labReqLevl,"rf3")
           )
        );
```

The number of field working hours cannot exceed a limit which is defined by the available field working days, <i>p_fieldWorkingDays.</i> Field working days depend on climate zone, soil type (<i>light, middle, heavy</i>) and distribution of available tractors to the soil type, <i>v_tracDist</i>. It is assumed that farm staff will be willing to work up to 15 hours a day, still with the total work load per month being restricted:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/templ.gms GAMS /tracRestr.*?_\(.*?nCur\)/ /;/)
```GAMS
tracRestrFieldWorkHours_(plot,labReqLevl,labPerSum,t_n(tCur(t),nCur)) $ (p_plotSize(plot) $ plot_landType(plot,"arab")) ..

       v_fieldWorkHours(plot,labReqLevl,labPerSum,t,nCur)

        =L=
             sum(labPerSum_ori(labPerSum,LabPeriod),
               sum(plot_soil(plot,soil),
                      sum(curClimateZone, p_fieldWorkingDays(labReqLevl,labPeriod,curClimateZone,soil)) * 12)
                              * v_tracDist(plot,labPerSum,t,nCur));
```


### Off-Farm Work

Farm family members can optionally work half- or full-time, <i>v_workoff</i>, or on an hourly basis off-farm, <i>v_workHourly</i>. Half- and full-time work are realised as integer variables. In the normal setting the wage per hour for working half time exceeds the wage of short time hourly work. Moreover, the wage per hour of full time work is higher than of working half time. For half- and full-time work commuting time can be considered:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/labour_module.gms GAMS /  offFarmHoursPerYearFixed\_\(t\_n\(tCur\(t\),nCur\)\)/ /;/)
```GAMS
  offFarmHoursPerYearFixed_(t_n(tCur(t),nCur)) $  sum(workOpps(workType), (v_labOff.up(t,nCur,workType) ne 0)) ..

       v_labOffFixed(t,nCur) =e=
*
*        --- off farm labour - per month: considers the work time (flexible contracts up to 40 hours a week)
*                                         plus the commuting time (3 days for contract up to 20 hours, 5 days above)

         + sum( workOpps(workType),
              v_labOffF(t,nCur,workType) + v_labOff(t,nCur,workType)*p_commTime(workType)*44);
```

The set <i>workType</i> lists the possible combinations:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/coeffgen/labour.gms GAMS /p_workTime\(w.*?\=/ /;/)
```GAMS
p_workTime(workType) =   (p_workT("Half")+p_workT("Full")*floor(workType.pos/2))  $ ( mod(workType.pos,2) eq 1)
                         +  p_workT("Full")*(workType.pos/2 )                       $ ( mod(workType.pos,2) eq 0);
```

It is assumed that decisions about how much to work flexibly on an hourly basis are taken on a yearly basis (i.e. the same number of hours is inputted in each month).

The total number of hours worked off-farm is defined as:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/labour_module.gms GAMS /offFarmWorkTot\_\(t\_n\(tCur\(t\),nCur\)\)/ /;/)
```GAMS
offFarmWorkTot_(t_n(tCur(t),nCur)) ..
*
       v_labOffTot(t,nCur) =e=
*
*         --- some hours at a very low wage rate
*
          v_labOffHourly(t,nCur)
*
*         --- contract between 20 and 40 hours a week, including commuting time
*
        + v_labOffFixed(t,nCur) $ sum(workOpps(workType), (v_labOff.up(t,nCur,workType) ne 0));
```

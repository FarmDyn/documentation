# Herd Dynamics

> **_Abstract_**  
The herd dynamics describe the dynamic character of the stock of a certain
animal herd. This includes economic activities of selling and buying and natural
dynamics such as birth or moving into another age-stage within the same animal group.
Further, herds are differentiated by gender, breeds, production
objectives and month in each year.

The model uses two different variables to describe herds: *v\_herdStart* describes the number of animals by type which enter a production process at a certain time, while *v\_herdSize* describes the number of animals by type at the farm at a specific time. More precisely the standing herd, *v\_herdSize*, can be described as animals which joint the herd since the beginning of the production process, *v\_herdStart,* minus sold and slaughtered ones, as can be seen in the following equation. The parameter *p\_mDist* in this equation describes the difference in months between two time points defined by year, *t, t1*, and month, *m, m1*. The parameter *p\_prodLength* depicts the length of the production process in months.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/general_herd_module.gms GAMS /herdSize_[\S\s][^;]*?\.\./ /;/)
```GAMS
herdSize_(herds,breeds,tCur(t),nCur,m)
    $ (sum(FeedRegime,actHerds(herds,breeds,feedRegime,t,m))
    $  sum((t_n(t1,nCur1),feedRegime,m1)
            $ (((-p_mDist(t,m,t1,m1) le (p_prodLength(herds,breeds)-1) $ (p_mDist(t,m,t1,m1) le 0))
               or
               ((abs(p_mDist(t,m,t1,m1)-12) le (p_prodLength(herds,breeds)-1)) $ (p_mDist(t,m,t1,m1)-12 le 0)) $ p_compStatHerd
               )
              $ actHerds(herds,breeds,feedRegime,t1,m1)
              $ (balherds(herds)
              $$ifi defined remonte or remonte(herds) or sameas("remonte",herds)
              )
              $ t_n(t,nCur) $ isNodeBefore(nCur,nCur1)),
        1)
     ) ..

  sum(feedRegime $ actHerds(herds,breeds,feedRegime,t,m),
    v_herdSize(herds,breeds,feedRegime,t,nCur,m))
  =E=
*
*         --- herds which started in the months before the production length, in case for piglets a separate construct is used
*
  sum((t_n(t1,nCur1),m1)
    $ ((((-p_mDist(t,m,t1,m1) le (p_prodLength(herds,breeds)-1))
        $ (p_mDist(t,m,t1,m1) le 0))
        or
        ((abs(p_mDist(t,m,t1,m1)-12) le (p_prodLength(herds,breeds)-1))
        $ (p_mDist(t,m,t1,m1)-12 le 0)) $ p_compStatHerd
       )
       $ sum(feedRegime,actHerds(herds,breeds,feedRegime,t1,m1))
       $ isNodeBefore(nCur,nCur1)
       $$iftheni.sows "%farmBranchSows%" == "on"
         $(not sameas(herds,"piglets"))
       $$endif.sows
     ),
      v_herdStart(herds,breeds,t1,nCur1,m1)

      $$iftheni.ch %cowHerd%==true
*
*       --- minus, in case of cows, slaughtered before reaching the final age
*
        -sum( (slgtCows,cows)
          $ (sum(feedRegime, actHerds(slgtCows,breeds,feedRegime,t1,m1))
            $ sameas(cows,herds) $ (slgtCows.pos eq cows.pos)),
          v_herdStart(slgtCows,breeds,t1,nCur,m1))
      $$endif.ch
    )
*
*  --- add herds multiple times if their process length is longer than 12
*

  +  sum((t_n(t1,nCur1),m1)
      $ (((-p_mDist(t,m,t1,m1) le (p_prodLength(herds,breeds)-1))
          $
          (   (abs(p_mDist(t,m,t1,m1)-12) le (p_prodLength(herds,breeds)-1))$ (p_mDist(t,m,t1,m1) le 0)
          or  (abs(p_mDist(t,m,t1,m1)-24) le (p_prodLength(herds,breeds)-1))$ (p_mDist(t,m,t1,m1) ge 0)
          ) $ p_compStatHerd $
                                  $$ifi defined cows (not cows(herds) $ (p_prodLength(herds,breeds) gt 12))
                                  $$ifi not defined cows (1 eq 1)
         )
         $ sum(feedRegime,actHerds(herds,breeds,feedRegime,t1,m1))
         $ isNodeBefore(nCur,nCur1)
         $$iftheni.sows "%farmBranchSows%" == "on"
           $(not sameas(herds,"piglets"))
         $$endif.sows
      ),
         v_herdStart(herds,breeds,t1,nCur1,m1)
*
*       --- minus, in case of cows, slaughtered before reaching the final age
*
      $$iftheni.ch %cowHerd%==true
        -sum( (slgtCows,cows)
          $ (sum(feedRegime, actHerds(slgtCows,breeds,feedRegime,t1,m1))
            $ sameas(cows,herds) $ (slgtCows.pos eq cows.pos)),
          v_herdStart(slgtCows,breeds,t1,nCur,m1))
      $$endif.ch
         )
*
*         --- Herd size dynamic for piglets separately to depict a correct transfer from year t to year t1 as well as account for temporal resolution adjustments
*

  $$iftheni.sows "%farmBranchSows%" == "on"
    +  sum( (t_n(t1,nCur1),m1)
      $ ((abs(p_mDist(t,m,t1,m1)) le (p_prodLengthB(herds,breeds) -1
        $ (p_prodLengthB(herds,breeds) eq 1)))
      $ (p_mDist(t,m,t1,m1) le 0)
      $ isNodeBefore(nCur,nCur1)
      $ sum(feedRegime,actHerds(herds,breeds,feedRegime,t1,m1))
      $ (sameas(herds,"youngPiglets") or sameas(herds,"piglets"))
      $ {
        (sameas(t,t1) $ (not sameas(m  - p_prodLengthB(herds,breeds),m1)))
        or ((not sameas(t,t1)) $ (sameas("Jan",m))$ (sameas( m + 11, m1)))
      }
      ),
         v_herdStart(herds,"",t1,nCur1,m1))
  $$endif.sows
;
```

The definition of the number of animals being added to the herd, *v\_herdStart*, is described in the equation *herdBal\_*. In the
simplest case, where a 1:1 relation between a delivery and a use process exists, the number of new animals entering the different use processes *balherds* is equal to the number of new animals of the delivery process *herds*. This relation is depicted by the set *herds\_from\_herds*.

One possible extension is that animals entering the herd can be alternatively bought from the market, defined by the set
*bought\_to\_herds*. The symmetric case is when the raised/fattened animals are sold which is described by the *sold\_from\_herds* set.

For the case where several delivering processes are available, for example heifers of a different process length replacing cows, the set *herds\_from\_herds* describes a 1:n relation. A similar case exists if one type of animal, say a raised female calve, can be used for different processes such as replacement or slaughter. In this case, the expression turns into a n:1 relation captured by the second additive expression in the equation *herdBal\_*.

In comparative static mode *p\_compStatHerd*, all lags are removed such that a steady-state herd model is described.

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/general_herd_module.gms GAMS /herdsBal_[\S\s][^;]*?\.\./ /;/)
```GAMS
herdsBal_(balHerds,breeds,tCur(t),nCur,m) $ (  sum(feedRegime,actherds(balHerds,breeds,feedRegime,t,m)) $ t_n(t,nCur)
*
     $ (p_Year(t) le p_year("%lastYear%"))
     $ (sum( (herds_from_herds(balHerds,herds,breeds),t1,m1)
                   $ (( -p_mDist(t,m,t1,m1) eq round(p_prodLengthB(herds,breeds)))
                           $  sum(feedRegime,actHerds(herds,breeds,feedRegime,t1,m1))),1)
       $$iftheni.compStat "%dynamics%" == "comparative-static"
         or (sum( (herds_from_herds(balHerds,herds,breeds),t1,m1)
                   $ (( -p_mDist(t,m,t1,m1)+12 eq round(p_prodLengthB(herds,breeds)))
                           $  sum(feedRegime,actHerds(herds,breeds,feedRegime,t1,m1))),1))
       $$endif.compStat
                           or sum((bought_to_herds(herds,breeds,balherds),feedRegime) $ actherds(herds,breeds,feedRegime,t,m),1)
                           or sum((sold_comp_herds(herds,breeds,balherds),feedRegime) $ actherds(herds,breeds,feedRegime,t,m),1)  )
                        ) ..
*
*      --- herd starting at current time point
*
          v_herdStart(balHerds,breeds,t,nCur,m)/p_herdYearScaler(balHerds,breeds)
*
*      --- plus herd starting at current time point which compete for the same input herds
*
     + sum( herds1 $ [ (sum(herds_from_herds(herds1,herds,breeds)
                                      $ herds_from_herds(balHerds,herds,breeds),1)
                    or sum(bought_to_herds(herds,breeds,herds1)
                            $ bought_to_herds(herds,breeds,balherds),1))
                    $ (not sameas(balHerds,herds1)) $  sum(feedRegime,actherds(herds1,breeds,feedRegime,t,m))],
          v_herdStart(herds1,breeds,t,nCur,m)/p_herdYearScaler(herds1,breeds))

         =e=
*
*      --- equal to the starting herd of the process wich generates these herds
*
     + sum( (herds_from_herds(balHerds,herds,breeds),t_n(t1,nCur1),m1)
                   $ ( (  (-p_mDist(t,m,t1,m1)    eq round(p_prodLengthB(herds,breeds)) )
                $$iftheni.compStat "%dynamics%" == "comparative-static"
                     or (-p_mDist(t,m,t1,m1)+12 eq round(p_prodLengthB(herds,breeds)) )
                $$endif.compStat
                       )   $  sum(feedRegime,actHerds(herds,breeds,feedRegime,t1,m1)) $ isNodeBefore(nCur,nCur1)),
                                    v_herdStart(herds,breeds,t1,nCur1,m1))
*
*      --- bought to herd (e.g. heifers bought from market)
*
     + sum( (bought_to_herds(herds,breeds,balherds))
           $ sum(feedRegime,actherds(herds,breeds,feedRegime,t,m)), v_herdStart(herds,breeds,t,nCur,m))
*
*      --- sold animals from the competing process for these herds (e.g. using heifer for remonte or selling heifer)
*
     - sum( sold_comp_herds(herds,breeds,balherds) $ sum(feedRegime,actherds(herds,breeds,feedRegime,t,m)),
            v_herdStart(herds,breeds,t,nCur,m));
```

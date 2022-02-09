# Objective Function

> **_Abstract_**  
  FarmDyn's objective function determines the average yearly net present value. It further accounts for different risk and dynamic options. 

The objective function in FarmDyn accounts for model characteristics such as risk and dynamics. To do so, the objective function is structured in three separate equations. The function <i>objeN_</i> is the equation directly linked to the farm management program in FarmDyn, whereas the other two equations <i>objeMean_</i> and <i>OBJE_</i> are capturing different technical aspects of risk and dynamics. The <i>objeN_</i> calculates the average yearly net present value (NPV) as the discounted household income <i>v_hhldsIncome</i> plus the value of leisure in money terms <i>v_leisureVal</i>. The equation <i>objeMean_</i> uses this information to calculate the mean objective based on the probability for each existing node (<i>nCur</i>). This information flows in the uppermost and final objective function <i>OBJE_</i> which accounts for penalties for negative deviations from the mean NPV (similar to a MOTAD (Minimum of total absolute deviations) approach).


[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/model/templ.gms GAMS /\*   --- net present value of cash/ /card\(tFull\)         ;/)
```GAMS
*   --- net present value of cash balance in average per year
*       over the simulation horizon
*
*
    OBJE_           ..
*
       v_obje =L=
                v_objeMean
*
*       --- penalty for negative deviation from mean NPV (similar MOTAD) or target MOTAD / ES
*
      + [ 0

$ifi %stochProg%==true - v_expNegDevNPV * p_negDevPen  $ (not p_expShortFall)
$ifi %stochProg%==true - v_expShortFall * p_negDevPen  $ (not p_expShortFall)
$ifi %stochProg%==true + v_expShortFall * p_negDevPen  $ p_expShortFall
        ] $ sum(t_n(tCur,nCur) $  (v_hasFarm.up(tCur,nCur) ne 0),1)
    ;
*
*   --- mean of yearly average discount household withdrawals (plus money value of leisure)
*       (= equal to simulated value for deterministic version)
*
    objeMean_ ..

         v_objeMean =E= sum(t_n("%lastYearCalc%",nCur), v_objeN(nCur)*p_probN(nCur));
*
*   --- discounted household withdrawals (plus money value of leisure), per average year
*
    objeN_(nCur) $ t_n("%lastYearCalc%",nCur) ..

         v_objeN(nCur)  =E=
*
                                [  sum(t_n(tFull,nCur1) $ isNodeBefore(nCur,nCur1),
                                            [    v_hhsldIncome(tFull,nCur1)
                                              +  v_leisureVal(tFull,nCur1) $ sum(leisLevl,p_leisureVal(LeisLevl))
                                            ] * 1/(1+p_discountRate/100)**tFull.pos)
*
*                                --- minus initial liquidity
*
                                 - sum(t_n("%lastOldYear%",n),v_liquid("%lastOldYear%",n))
                 ]
*
*        --- divived by the number of years
*
             /card(tFull)         ;
```

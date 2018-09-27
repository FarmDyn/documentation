
# Plant Nutrition


The equations related to the plant nutrition make sure that the nutrient
need of crops is met. Nutrient need can be derived from N response
functions or from planning data for fixed yield levels. Needed nutrients
are provided by manure and synthetic fertilizer. There are two
approaches to model the nutrient need and supply of crops, a fixed
factor approach and detailed nutrient fate model.

## Calculation of plant need

The template supports two differently detailed ways to account for plant
nutrition need.

1.  A **fixed factor approach** with yearly nutrient balances per crop

    a.  Using N response curves

    b.  Using planning data

2.  A detailed **flow model** with a monthly resolution by soil depth
    (deprecated).

    c.  Using N response curves

*p\_nutNeed* is the nutrient need for different crops and enters the
equation for fixed factor approach and the flow model. For the fixed
factor approach, nutrient need can be calculated based on N response
curves and alternatively based on planning data. In the detailed flow
model, nutrient need needs to be calculated based on N response curves.
All relevant calculation can be found in *coeffgen\\cropping.gms*.

## N response curves

The yield level of different crops is chosen in the GUI. The following
equations show, at the example of winter cereals, that the yield,
*p\_OCoeffC*, equals the yield given by the GUI, *p\_cropYieldInt* , and
takes a growth rate given by the GUI into account.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/regionalData/yields.gms GAMS /p_OCoeffC\("winterCere"/ /;/)
```GAMS
p_OCoeffC("winterCere",soil,till,intens,"winterCere",t)     $ sum(soil_plot(soil,plot),c_s_t_i("winterCere",plot,till,intens))       =  8   * (1.00 + p_cropYieldInt("winterCere","GrowthRateY")/100) **t.pos;
```

In the next step, the nutrient need for crops are linked to the
different cropping intensities. There are five different intensity
levels with regard the amount of N fertilizer applied:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ_decl.gms GAMS /set\sintens/ /;/)
```GAMS
set intens      / normal   "Full N fertilization"
                    fert80p  "80 % N"
                    fert60p  "60 % N"
                    fert40p  "40 % N"
                    fert20p  "20 % N"
                    /;
```


These nutrient needs for the different intensities are based on nitrogen
response functions from field trials. The intensity can be reduced from
100 % to an N fertilizer application of 80 %, 60 %, 40 % and 20 %. The
yield level is reduced to 96 %, 90 %, 82 % and 73 %, respectively. These
steps reflect the diminishing yield increases from increased N
fertilizer application.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_OCoeffC.*?"fert80p"/ /0\.53;/)
```GAMS
p_OCoeffC(arabCrops,soil,till,"fert80p",prods,t)    = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.96;
    p_OCoeffC(arabCrops,soil,till,"fert60p",prods,t)    = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.90;
    p_OCoeffC(arabCrops,soil,till,"fert40p",prods,t)    = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.82;
    p_OCoeffC(arabCrops,soil,till,"fert20p",prods,t)    = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.73;

    p_OCoeffC(arabCrops,soil,till,"fert80p",prods,t)    = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.95;
    p_OCoeffC(arabCrops,soil,till,"fert60p",prods,t)    = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.85;
    p_OCoeffC(arabCrops,soil,till,"fert40p",prods,t)    = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.71;
    p_OCoeffC(arabCrops,soil,till,"fert20p",prods,t)    = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.53;
```


The output coefficients, *p\_OCoeffC*, represents the yields per hectar.
They are used to define the nutrient uptake by the crops, *p\_nutNeed,*
based on the nutrient content, *p\_nutContent*. Values for
*p\_nutContent* are taken from the German fertilizer directive
(DüV 2007, Appendix 1).

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /\s\sp_nutNeed\(c.*?nut.*?\$/ /;/)
```GAMS

 p_nutNeed(crops,soil,till,intens,nut,t) $ sum(soil_plot(soil,plot), c_s_t_i(crops,plot,till,intens))
        = sum( prods, p_OCoeffC(crops,soil,till,intens,prods,t) * (p_nutContent(crops,prods,nut)*10));
```

For different intensities, the corresponding amount of nutrient applied
has to be determined to fulfil the need *p\_nutNeed*.

The parameter *p\_basNut* defines the amount of nutrients coming from
other sources than directly applied fertilizer. The curve suggests that
for a 53%-level of yield, only 20% of the N dose at full yield is
necessary. Assuming a minimum nutrient loss factor that allows defining
how much N a crop takes up from other sources (mineralisation,
atmospheric deposition):

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_basNut\(crops.*?nut.*?\$.*?\$/ /;/)
```GAMS
p_basNut(crops,soil,till,nut,t) $ (sum(prods, p_OCoeffC(crops,soil,till,"normal",prods,t)) $ sameas(nut,"N"))
       = smax( (soil_plot(soil,plot),c_s_t_i(crops,plot,till,"normal"),intens),
           sum(prods, p_OCoeffC(crops,soil,till,intens,prods,t) * (p_nutContent(crops,prods,nut)*10))
             - p_nutNeed(crops,soil,till,"normal",nut,t)*(1 + p_FracGaseF + p_FracLeach) * (  0.2 $ sameas(intens,"fert20p")
                                                                                            + 0.4 $ sameas(intens,"fert40p")
                                                                                            + 0.6 $ sameas(intens,"fert60p")
                                                                                            + 0.8 $ sameas(intens,"fert80p")
                                                                                            + 1.0 $ sameas(intens,"normal")) );
```

The amount of nutrient applied, *p\_nutApplied,* is estimated as shown
in the following equation, it is assumed that at least 20% of the
default leaching and NH<sub>3</sub> losses will occur.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_nutApplied.*?"fert20p"/ /;/)
```GAMS
p_nutApplied(crops,soil,till,"fert20p","N",t) $ sum(soil_plot(soil,plot),c_s_t_i(crops,plot,till,"fert20p"))
    = p_nutNeed(crops,soil,till,"normal","N",t)*(1 + p_FracGaseF + p_FracLeach)*0.2;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_nutApplied.*?"fert40p"/ /;/)
```GAMS
p_nutApplied(crops,soil,till,"fert40p","N",t) $ sum(soil_plot(soil,plot),c_s_t_i(crops,plot,till,"fert40p"))
    = p_nutNeed(crops,soil,till,"normal","N",t)*(1 + p_FracGaseF + p_FracLeach)*0.2 * 1.5;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_nutApplied.*?"fert60p"/ /;/)
```GAMS
p_nutApplied(crops,soil,till,"fert60p","N",t) $ sum(soil_plot(soil,plot),c_s_t_i(crops,plot,till,"fert60p"))
    = p_nutNeed(crops,soil,till,"normal","N",t)*(1 + p_FracGaseF + p_FracLeach)*0.2 * 2;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_nutApplied.*?"fert80p"/ /;/)
```GAMS
p_nutApplied(crops,soil,till,"fert80p","N",t) $ sum(soil_plot(soil,plot),c_s_t_i(crops,plot,till,"fert80p"))
    = p_nutNeed(crops,soil,till,"normal","N",t)*(1 + p_FracGaseF + p_FracLeach)*0.2 * 2.5;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_nutApplied.*?"normal"/ /;/)
```GAMS
p_nutApplied(crops,soil,till,"normal","N",t)  $ sum(soil_plot(soil,plot),c_s_t_i(crops,plot,till,"normal") )
    = p_nutNeed(crops,soil,till,"normal","N",t)*(1 + p_FracGaseF + p_FracLeach)*0.2 * 3;
```

The nutrient application, *p\_nutApplied,* in combination with the basis
delivery from soil and air, *p\_basNut,* allows defining the loss rates
for each intensity level, *p\_nutLossUnavoidable,* as the difference
between the deliveries and the nutrient uptake, *p\_nutNeed,* by the
plants:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /\s\sp_nutLossUnavoidable\(s.*?nut/ /;/)
```GAMS
  p_nutLossUnavoidable(soil,till,intens,nut)
     $ (sum( (crops,t) $ p_nutNeed(crops,soil,till,intens,nut,t), 1))
      =  sum( (crops,t) $ p_nutNeed(crops,soil,till,intens,nut,t),
           max(0,Min(50, p_nutApplied(crops,soil,till,intens,nut,t)
                 + p_basNut(crops,soil,till,nut,t) - p_nutNeed(crops,soil,till,intens,nut,t)))
              / p_nutNeed(crops,soil,till,intens,nut,t))

        /sum( (crops,t) $ p_nutNeed(crops,soil,till,intens,nut,t), 1);
```

*p\_nutLossUnavoidable* enters the Standard Nutrient Fate Model (see
chapter 2.11.2). It represents the factor that has to be applied over
the plant removal, *p\_nutNeed*, to reach a certain yield level. It
indicates the nutrient efficiency of the fertilizer management.

## Planning Data

The nutrient need can also derived from planning data from the revised
Fertilizer directive (BMEL 2015). The proposed directive includes
compulsory fertilizer planning to increase N use efficiency on farms.
This measure is included in FARMDYN. When fertilizer management follows
the planning data, different intensities do not exist and yield levels
are fixed, i.e. cannot be changed by the GUI.

The yield level *p\_OCoeffC* is fixed in the following equation, showing
the example of winter cereals.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /\s\s[^\n]\sp_OCoeffC\("winterW/ /;/)
```GAMS

   p_OCoeffC("winterWheat",soil,till,intens,"winterWheat",t)   $ sum(soil_plot(soil,plot),c_s_t_i("winterWheat",plot,till,intens))      =  8   ;
```

The yield corresponds to a certain amount of needed N, *p\_nutNeed*,
given by the directive.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_nutNeed\("winter/ /;/)
```GAMS
p_nutNeed("winterWheat",soil,till,intens,"N",t)   $ sum(soil_plot(soil,plot), c_s_t_i("winterWheat",plot,till,intens))  =   230 - p_basNut("winterWheat",soil,till,"N",t)   ;
```

In the case of P, it is assumed that the nutrients need correspond to
the nutrients removed by the harvested product.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /\s\sp_nutNeed\(c.*?"P"/ /;/)
```GAMS
  p_nutNeed(crops,soil,till,intens,"P",t) $ sum(soil_plot(soil,plot), c_s_t_i(crops,plot,till,intens))
        = sum( prods, p_OCoeffC(crops,soil,till,intens,prods,t) * (p_nutContent(crops,prods,"P")*10));
```

The directive prescribes that nutrients delivered from soil and air have
to be taken into account. This reduces the amount of fertilizer that
needs to be applied. The parameter, *p\_basNut*, enters the Standard
Nutrient Fate Model (see chapter 2.11.2). We assume a fixed amount of 30
kg N per hectar and year for every crop.

Text passt nicht zum code

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /\s\sp_basNut\(c.*?"P"/ /;/)
```GAMS
  p_basNut(crops,soil,till,"P",t)  =  0 ;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /\s[^\n]\sp_basNut\(c.*?[^\$]"N"/ /p_NfromLegumes\(crops\);/)
```GAMS
   p_basNut(crops,soil,till,"N",t) $ arableCrops(crops) =  50 ;
   p_basNut(crops,soil,till,"N",t) $ grassCrops(crops)  =  10 + p_NfromLegumes(crops);
```

The directive does not allow applying more nutrients than required
following the planning data. Unavoidable losses are already reflected in
*p\_nutNeed*. In the GUI, a factor for *over fertilization* can be
activated. In this case, the N need for plant increases. This feature
can be used to assess the impact of inefficient N management of farms.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_nutLossUnavoidable\(.*?"P"/ /;/)
```GAMS
p_nutLossUnavoidable(soil,till,intens,"P")   = 0 ;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_nutLossUnavoidable\(.*?"N"/ /;/)
```GAMS
p_nutLossUnavoidable(soil,till,intens,"N")   = %NOverNeedValue% ;
```

Furthermore, the directive prescribes the share of N from organic
sources that has to be accounted for in the fertilizing management. The
requirements of the directive can be activated in the GUI and enter the
Standard Nutrient Fate Model (see chapter 2.11.2).

## Standard Nutrient Fate Model

The standard nutrient fate model defines the necessary fertilizer
applications based on yearly nutrient balances for each crop category,
*NutBalCrop\_*. In the equation below, the left hand side defines the
nutrient need plus the application of manure over plant need. The right
hand side captures the net deliveries from mineral and manure
application plus deliveries from soil and air.

FARMDYN allows different ways to account for N from manure. Organic N
can be accounted for based on (1) requirements from the Fertilizer
Directive, (2) a given factor by the interface and (3) exogenous
calculated losses. Losses are calculated using the environmental
accounting module (see chapter 2.12). If the environmental accounting
module is switched off, calculated losses are derived using standard
loss factors from the Fertilizer directive. Different elements of the
equation *NutBalCrop\_* are explained below.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /NutBalCrop_\(c_/ /\.\./)
```GAMS
NutBalCrop_(c_s_t_i(curCrops(crops),plot,till,intens),nut,tCur(t),nCur)
       $ ((v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0) $ t_n(t,nCur) $( not sameas (crops,"catchCrop")) ) ..
```

The crop need is derived from *p\_nutneed*. In the case of using N
response functions, the needed nutrients increase by unavoidable losses,
*p\_nutLossUnavoidable*. In the case of using planning data, unavoidable
losses are already included in *p\_nutNeed* and, therefore,
*p\_nutLossUnavoidable* is set to 0 (see chapter 2.11.1.2).

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /\*.*?crop\sneed/ /\)\)\)/)
```GAMS
*               ---  crop need based on plant uptake and calculated further need

                sum(plot_soil(plot,soil),
                         p_nutNeed(crops,soil,till,intens,nut,t) * v_cropHa(crops,plot,till,intens,t,nCur)
                                * (1 + p_nutLossUnavoidable(soil,till,intens,nut)))
```

When activated in the GUI, more organic N and P than needed for plant
nutrition can be applied.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /\*.*?application\sover/ /\)/)
```GAMS
*               ---  application over plant need of organic fertilizer is possible
                + v_nutOrganicOverNeed(crops,plot,till,intens,nut,t,nCur)
```

The plant need (including over application of manure) has to equal the
offered nutrients. For pasture, there is a special accounting needed
since loss factors differ from stable. Furthermore, nutrients excreted
during grazing are only available on the pasture. As stated above, there
are different ways to account for N from manure.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /\$\$iftheni.dh\s/ /\$\$endif.dh/)
```GAMS
$$iftheni.dh "%cattle%" == "true"
*
*                 --- manure excreted during grazing on pasture: N , different calculation of losses [TK 01.03.16 revised]
*
                 [sum( (nut2,m) $ ( sameas(nut2,"norg") or sameas(nut2,"ntan") ),
*
*                        --- excretion by herds which graze only for a part of the year
*
                         v_nut2ManurePast(crops,plot,till,intens,nut2,t,nCur,m)
                     )
                  $$iftheni.NorgAcc "%NorgAccounting%" == "Interface"
                                     *   %NOrgAccountedInt%
                  $$elseifi.NorgAcc "%NorgAccounting%" == "PlanningDueV16"
                                      *  0.8
                  $$else.NorgAcc
*
*                           WB: here, something needs to change ... cannot work with several pasture options
                            - v_niEmissionsPast(crops,plot,till,intens,t,nCur)

                      $$ontext
                               *  p_nutEffectivPastDueVNv
                      $$offtext
                  $$endif.NorgAcc

                  ] $  (past(crops) and sameas(nut,"N"))

*                  --- manure excreted during grazing pasture: P [TK 01.03.16 revised]

                   + sum(m,v_nut2ManurePast(crops,plot,till,intens,"P",t,nCur,m)) $ (past(Crops) and sameas(nut,"P"))

              $$endif.dh
```

The following elements determine the amount of N and P entering the
nutrient balance with applied manure. Again, different ways to account
for organic N are represented in the equation.

Losses can be calculated representing exogenous estimated N emissions.
The reader should note that nutrients applied from manure are net of
losses during storage.

![](../media/image132.png)
->?

The amount of organic N accounted for in fertilizing can be chosen in
the GUI.

![](../media/image133.png)
->?

Furthermore, the requirements of the fertilizer planning from the German
fertilizer directive can be followed.

![](../media/image134.png)
->?

For P from manure, no losses are taken into account.

![](../media/image135.png)
->?

Nutrients from mineral fertilizer application are added. No losses are
taken into account since they are already included in the calculation of
*p\_nutLossUnavoidable* (see chapter 2.11.1).

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /\*.*?mineral N application\s\s/ /\)\s\)/)
```GAMS
*               -- mineral N application

                + sum ((syntFertilizer,m),
                      v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)
                                                       * p_nutInSynt(syntFertilizer,nut) )
```

Delivery of nutrients from soil and air are included.

![](../media/image137.png)
->?

In the equation *nutSurplusMax\_*, the application of nutrients from
manure over plant need is restricted for each crop type:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /nutSurplusMax_\(\sc_s/ /;/)
```GAMS
nutSurplusMax_( c_s_t_i(curCrops(crops),plot,till,intens),nut,tCur(t),nCur)
        $ ( (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0) $ t_n(t,nCur)) ..

          p_nutSurplusMax(crops,plot,till,intens,nut,t) * v_cropHa(crops,plot,till,intens,t,nCur)
               =G=  v_nutOrganicOverNeed(crops,plot,till,intens,nut,t,nCur);
```

*p\_nutSurplusMax* is calculated in *coeffgen\\cropping.gms*.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/cropping.gms GAMS /p_nutSurplusMax\(/ /;/)
```GAMS
p_nutSurplusMax(crops,plot,till,intens,nut,t) $ c_s_t_i(crops,plot,till,intens)
            = min(200,sum(plot_soil(plot,soil),p_nutNeed(crops,soil,till,intens,nut,t) * 0.5));
```

In the standard nutrient fate model the reductions in soil nutrient can
be managed by:

1.  reducing unnecessary manure applications which decrease
    *v\_nutSurplusField*

2.  lowering cropping intensity (when nutrient need is derived using N
    response curves). It reduces not only the overall nutrient needs and
    therefore the losses, but also reduces the loss rates per kg of
    synthetic fertilizer

3.  switching between mineral and organic fertilization

4.  changing the cropping pattern

## Deprecated: Detailed Nutrient Fate Model by Crop, Month, Soil Depth and Plot

The detailed soil accounting module considers nutrient flows both from
month to month and between different soil layers (top, middle, deep). It
replaces the equations used in the standard nutrient fate model shown in
the section above. The central equation is the following:

![](../media/image140.png)

The detailed nutrient fate model considers as input flows:

-   Application of organic and mineral fertilizers net of NH3 and other
    gas losses from application, they are brought to the top layer,

-   atmospheric deposition (to the top layer),

-   net mineralisation and

-   nutrient leaching from the layer above.

The considered output flows are:

-   Uptake by crops and

-   leaching to the layer below.

The difference between the variables updates next month's stock based on
current month's stock. Monthly leaching to the next deeper soil layer,
*v\_nutLeaching,* is determined as a fraction of plant available
nutrients (starting stock plus inflows):

![](../media/image141.png)

The leaching losses below the root zone in combination with ammonia,
other gas losses from mineral and organic fertilizer applications define
the total nutrient losses at farm level in each month:

![](../media/image142.png)

The approach requires defining the nutrient needs of each crop per
month, which is currently estimated:

![](../media/image143.png)

Similarly, the nutrient uptake by the crop from different soil layers is
determined:

![](../media/image144.png)

A weakness of this approach is how changes of cropping patterns are
handled between years. It would be favourable to define the transition
of nutrient pools from year to year based on a "crop after crop"
variable in hectares for each soil type. However, this leads to
quadratic constraints which failed to be solved by the industry QIP
solvers [^4]. Instead, the pool is simply redistributed across crops and
a maximum content of 50 kg of nutrient per soil depth layer is fixed:

![](../media/image145.png)

If the user switches on crop rotations a further restriction is added:

![](../media/image146.png)

## Nutrient Balance According to the Fertilizer directive

The German fertilizer directive requires that farms calculate a nutrient
balance on an annual basis (DüV 2007). It combines nutrients input via
manure and synthetic fertilizer with nutrients removal via the harvested
crops. The surplus, i.e. the balance, is not allowed to exceed a certain
threshold. In FARMDYN, the nutrient balance is always calculated. The
threshold can be switched on and off in the GUI. Relevant equations can
be found in *model\\templ.gms*.

Nutrient removal via harvested product is calculated.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/duev_module.gms GAMS /nutRemovalDuev_\(.*?\.\./ /;/)
```GAMS
nutRemovalDuev_(nut,tCur(t),nCur) $ t_n(t,nCur) ..

       v_nutRemovalDuev(nut,t,nCur)
            =e=

                sum( (c_s_t_i(crops,plot,till,intens)), v_cropHa(crops,plot,till,intens,t,nCur)
                            * sum( (plot_soil(plot,soil),curProds), p_OCoeffC(crops,soil,till,intens,curProds,t)
                                     * p_nutContent(crops,curProds,nut)*10 )   )


               +   sum( (c_s_t_i(crops,plot,till,intens)) $ cropsResidueRemo(crops),  v_residuesRemoval(crops,plot,till,intens,t,nCur)
                          *sum( (plot_soil(plot,soil),curProds),  p_OCoeffResidues(crops,soil,till,intens,curProds,t)
                                     *  p_nutContent(crops,curProds,nut) * 10  )  )

                                                                      ;
```

Nutrient input via synthetic fertilizer is calculated.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/duev_module.gms GAMS /synthAppliedDueV_\(.*?\.\./ /;/)
```GAMS
synthAppliedDueV_(nut,tCur(t),nCur)  $ t_n(t,nCur)..

           v_synthAppliedDueV(nut,t,nCur)    =e=

                              sum( (c_s_t_i(crops,plot,till,intens),syntFertilizer,m),
                                 v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)
                                           * p_nutInSynt(syntFertilizer,nut) )      ;
```

In the equation *nutBalDuev\_*, nutrient input and output are combined.
Input from organic sources, *v\_nutExcrDuev* and *v\_nutBiogasDuev,* are
calculated in the *manure\_module.gms* and the *biogas\_module.gms*
(equations not shown here). Furthermore, nutrients export via manure
export is taken into account. *v\_surplusDueV* is the surplus of the
nutrient balance.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/duev_module.gms GAMS /nutBalDueV_\(.*?\.\./ /;/)
```GAMS
nutBalDueV_(nut,tCur(t),nCur) $ t_n(t,nCur) ..

$iftheni.h %herd% == true

*   --- Nutrients excreted from animals time specific loss factor

           v_nutExcrDuev(nut,t,nCur)  *  p_nutEffectivDueVNv(nut)
$endif.h

*  --- Nutrients coming from biogas plant (including energy crops and purchased manure)

$iftheni.b %biogas% == true
         + v_nutBiogasDuev(nut,t,nCur)  *  p_nutEffectivDueVNvBiogas(nut)

$endif.b

*  --- Applied synthetic fertilizer

         + v_synthAppliedDueV(nut,t,nCur)


*  --- Nutrient from N fixation from legumes in grassland
         + sum(  (c_s_t_i(crops,plot,till,intens)) ,
                   v_cropHa(crops,plot,till,intens,t,nCur) *   p_NfromLegumes(Crops)  )       $ sameas (nut,"N")


* --- Import of manure
*     [TK][TO DO] add coefficient for accounting for imported manure

       $$iftheni.im "%AllowManureImport%" == "true"

         +   sum ( (nut2_nut(nut2,nut),m),   v_manImport(t,nCur,m) *    p_nut2inMan(nut2,"manImport","LiquidImport") )

       $$endif.im

*  --- Crop output (nutrient removal)

         -   v_NutRemovalDuev(nut,t,nCur)

$iftheni.h %herd% == true

*   --- Nutrients exported from farm

      $$iftheni.ExMan %AllowManureExport%==true

        -  sum( (curManChain,m,nut2) $(not sameas (nut2,"P")), v_nut2export(curManChain,nut2,t,nCur,m) )  $ sameas (nut,"N")
        -  sum( (curManChain,m), v_nut2export(curManChain,"P",t,nCur,m) )                                 $ sameas (nut,"P")

      $$endif.ExMan

      $$iftheni.emissionRight not "%emissionRight%"==0

        -  sum( (curManChain,m,nut2) $(not sameas (nut2,"P")), v_nut2exportMER(curManChain,nut2,t,nCur,m) )  $ sameas (nut,"N")
        -  sum( (curManChain,m),                               v_nut2exportMER(curManChain,"P",t,nCur,m) )   $ sameas (nut,"P")

      $$endif.emissionRight

$endif.h

         =e=

             v_surplusDueV(t,nCur,nut)      ;
```

The surplus, *v\_surplusDueV,* is not allowed to exceed a certain
threshold given by the GUI.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/duev_module.gms GAMS /nutSurplusDueVRestr_.*?\.\./ /;/)
```GAMS
nutSurplusDueVRestr_ (tCur(t),nCur,nut)   $ (p_surPlusDueVMax(t,nut) $ t_n(t,nCur))  ..

       v_surplusDueV(t,nCur,nut)

         =L=
               p_surplusDueVMax(t,nut) *    v_croplandActive(t,nCur) *  ( 1 - p_soilShareNutEnriched)  $ sameas (nut,"P")

                  +     p_surplusDueVMax(t,nut) *    v_croplandActive(t,nCur)     $ sameas (nut,"N")

                  ;
```

[^4]: QIP solvers do not allow for equality conditions which are by
   definition non-convex


# Synthetic Fertilizers


To meet the N and P demand of crops, synthetic fertilizer can be applied
besides manure, *v\_syntDist*. Synthetic fertilizer application enters
equations with regard to the buying of inputs, *buy\_* and *varcost\_*,
the labour need for application, *labCropSM\_*, the field work hours and
machinery, *fieldWorkHours\_* and *machines\_*, and with regard to plant
nutrition (see chapter 2.11). The equation *nMinMan\_* makes sure that
minimum amounts of mineral fertilizer are applied for certain crops. It
represents the limitation meeting the plant need with nutrients from
manure, e.g. fertilizing short before harvest for baking wheat cannot be
done with manure.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /nMinMin_\(c_/ /;/)
```GAMS
nMinMin_(c_s_t_i(curCrops(crops),plot,till,intens),nut,tCur(t),nCur)
        $ (  (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0)
                $ p_minChemFert(crops,nut) $ t_n(t,nCur) ) ..

       sum ((syntFertilizer,m),
                      v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)
                                                   * p_nutInSynt(syntFertilizer,nut))
              =G=

*         sum(plot_soil(plot,soil),
*                      p_nutNeed(crops,soil,till,intens,nut,t))
                v_cropHa(crops,plot,till,intens,t,nCur) * p_minChemFert(crops,nut);
```

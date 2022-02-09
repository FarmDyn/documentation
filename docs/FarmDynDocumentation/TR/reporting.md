# Reporting

FarmDyn's GUI allows the exploitation of model results, also comparing different model runs. For more information, please refer to the section *Working with FarmDyn* and then *Graphical User Interface*.
The result exploitation via the GUI requires that all results are stored in one multi-dimensional cube. Accordingly, after the model is solved, its variables are copied to a result parameter, as shown in the following example:

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/exploiter/store_res.gms GAMS / p_res.*?liquid/ /;/)
```GAMS
 p_res(%1,%2,"liquid","sum","",tCur)         = sum(t_n(tCur,nCur), p_probn(nCur) * v_liquid.l(tCur,nCur));
```

[embedmd]:# (N:/em/work1/Pahmeyer/FarmDyn/FarmDynDoku/FarmDyn_Docu/gams/exploiter/store_res.gms GAMS / p_res.*?liquid","sum","","mean"/ /;/)
```GAMS
 p_res(%1,%2,"liquid","sum","","mean")       = sum(tCur,p_res(%1,%2,"liquid","sum","",tCur)   )/p_cardTCur;
```


# Cropping, Land and Land Use


!!! abstract
    The cropping module optimizes the cropping pattern subject to land availability, reflecting yields, prices, machinery and fertilizing needs and other variable costs for a selectable longer list of arable crops. The crops can be differentiated by production system (plough, minimal tillage, no tillage, organic) and intensity level (normal and reduced fertilization in 20% steps). Machinery use is linked to field working days requirements depicted with a bi-weekly resolution during the relevant months. Crop rotational constraints can be either depicted by introducing crop rotations or by simple maximal shares. The model can capture plots which are differentiated by soil and land (gras, arable) type and size.

Crop activities are differentiated by crop, *crops*, soil types, *soil,*
management intensity, *intens*, and tillage type, *till*. Use of
different management intensities and tillage types is optional.
Management intensities impact yield levels (see chapter 2.11.1.1).
Necessary field operations and thus variable costs, machinery and labour
needs reflect intensity and tillage type as well.

## Cropping Activities in the Model

Crop activities are defined with a yearly resolution and can be adjusted
to the state of nature in the partially stochastic version. The farmer
is assumed to be able to adjust on a yearly basis its land use to a
specific state of nature as long as the labour, machinery and further
restrictions allow for it. Land is differentiated between arable and
permanent grass land, *landType*, the latter is not suitable for arable
cropping. Land use decisions can be restricted by maximal rotational
shares for the individual crops. The set *plot* differentiates the land
with regard to plot size, soil type and climate zone. The attributes of
plots, as well as the number of plots from 1 to 20, is defined in the
GUI.

The total land endowment is calculated in the equation *totPlotLand\_*
as the sum of the initial endowment, *p\_plotSize(plot)*, and land
purchased, *v\_buyLand*, in the past or current year.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /totPlotLand_\(.*?\$.*?\.\./ /;/)
```GAMS
totPlotLand_(plot,tCur(t),nCur) $ (p_plotSize(plot) $ t_n(t,nCur)) ..

       v_totPlotLand(plot,t,nCur)

            =E=
*
*            --- initialize of plots
*
             p_plotSize(plot)
*
*            --- plus bought adjacent plots (= merged)
*
$ifi %landBuy% == true + sum(t_n(t1,nCur1) $ (tcur(t1) $ isNodeBefore(nCur,nCur1) $ (ord(t1) le ord(t))), v_buyPlot(plot,t1,nCur1))
             ;
```

Total cropped land is defined by the land occupied by the different
crops, *v\_cropH*a. The *c\_s\_t\_i* set defines the active possible
combinations of crops, soil type, tillage type and management intensity.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /croppedLand_\(.*?\$.*?\.\./ /;/)
```GAMS
croppedLand_(landType,soil,tCur(t),nCur)  $ t_n(t,nCur) ..

       v_croppedLand(landType,soil,t,nCur)
          =e= sum( (curCrops(crops),plot_lt_soil(plot,landType,soil),till,intens)
                    $ c_s_t_i(crops,plot,till,intens), v_cropHa(crops,plot,till,intens,t,nCur)
                             $( not sameas (crops,"catchCrop")));
```

The total land *v\_totPlotLand* can be either used for cropping
(including permanent grassland), *v\_croppedLand*, or rented out,
v*\_rentOutLand*, on a yearly basis. The option to rent out land can be
activated in the GUI:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /\splotland_\(.*?\$.*?\.\./ /;/)
```GAMS
 plotland_(plot,tCur(t),nCur) $ (p_plotSize(plot) $ t_n(t,nCur)) ..
*
           v_croppedPlotLand(plot,t,nCur)
*
$ifi %landLease% == true + v_rentOutPlot(plot,t,nCur)*p_plotSize(plot)
*
              =L= v_totPlotLand(plot,t,nCur);
```

Maximum rotational shares, *p\_maxRotShare*, enter *cropRot\_*, which is
only active if no crop rotations are used (see chapter 2.3.2).

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /cropRot_\(.*?,nCur/ /;/)
```GAMS
cropRot_(landType,curCrops(crops),plot,tCur(t),nCur)
        $ (  sum(c_s_t_i(crops,plot,till,intens)
                                 $ (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0),1)
                        $ (sum(plot_soil(plot,soil), p_maxRotShare(Crops,soil)) lt 1)
                        $  crops_t_landType(crops,landType)
                        $ t_n(t,nCur)  ) ..
          sum( c_s_t_i(crops,plot,till,intens), v_cropHa(crops,plot,till,intens,t,nCur))
               =l= v_croppedPlotLand(plot,t,nCur) * sum(plot_soil(plot,soil),p_maxRotShare(crops,soil));
```

That a farm stays within a maximum stocking rate ceiling, expressed in
livestock units per ha, is ensured by the following equation. The
maximal allowed stocking rate can be adjusted in the GUI:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/general_herd_module.gms GAMS /luLand_.*?\.\./ /;/)
```GAMS
luLand_(tCur(t),nCur) $ t_n(t,nCur)    ..

      sum( plot $ p_plotSize(plot), v_totPlotLand(plot,t,nCur)
$ifi %landLease% == true            -v_rentOutPlot(plot,t,nCur) * p_plotSize(plot)
           ) * p_maxStockRate =G=

             sum(actHerds(possHerds,breeds,feedRegime,t,m) $ p_prodLength(possHerds,breeds),
                v_herdSize(possHerds,breeds,feedRegime,t,nCur,m)

              $$iftheni.branchF not "%farmBranchFattners%" == "on"
                 * 1/min(12,p_prodLength(possHerds,breeds)) * 12/card(herdM)
              $$endif.branchF

                 * p_lu(possHerds));
```


## Optional Crop Rotational Module

Alternatively to the use of maximum rotational shares (see previous
section) the model offers an option of a three year crop rotation
system. The rotation names (shown in the following list, see
*model\\templ\_decl.gms*), set *rot*, show the order of the crops in the
rotations. Each line depict a sequence of three crop types (do not have
to be different) in a rotation with only the order being differently.
This avoids unnecessary rigidities in the model.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ_decl.gms GAMS /set.*?rot.*?PO,WC/ /;/)
```GAMS
set rot "Rotations" / WC_WC_PO,WC_PO_WC,PO_WC_WC
                          WC_WC_SC,WC_SC_WC,SC_WC_WC
                          WC_WC_SU,WC_SU_WC,SU_WC_WC
                          WC_WC_OT,WC_OT_WC,OT_WC_WC
                          WC_WC_ID,WC_ID_WC,ID_WC_WC

                          WC_SC_PO,SC_PO_WC,PO_WC_SC
                          WC_SC_SU,SC_SU_WC,SU_WC_SC
                          WC_SC_OT,SC_OT_WC,OT_WC_SC
                          WC_SC_ID,SC_ID_WC,ID_WC_SC

                          SC_WC_SC,SC_SC_WC,WC_SC_SC
                          SC_SC_ID,SC_ID_SC,ID_SC_SC
                          SC_SC_PO,SC_SC_SU,SC_SC_OT
                          WC_PO_ID,WC_SU_ID,WC_OT_ID
                          SC_PO_ID,SC_SU_ID,SC_OT_ID
                          WC_ID_ID,ID_WC_ID,ID_ID_WC
                          SC_ID_ID,ID_SC_ID,ID_ID_SC
                          PO_ID_ID,SU_ID_ID,OT_ID_ID
                          ID_ID_ID
                          PO_OT_WC,OT_WC_PO,WC_PO_OT
                          SU_OT_WC,OT_WC_SU,WC_SU_OT
                          PO_OT_SC,OT_SC_PO,SC_PO_OT
                          SU_OT_SC,OT_SC_SU,SC_SU_OT
                          SU_OT_PO,OT_PO_SU,PO_SU_OT
                        /;
```

Remark: WC: winter cereals, SC: summer cereals, PO: potatoes, SU: sugar
beets, ID: idling land, OT: other

The *rotations* are linked to groups of crops in the first, second and
third year of the rotation as can be seen in the following equation
(only cross-set definitions *rot\_cropTypes* for the first rotation are
shown).

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ_decl.gms GAMS /set.*?rot_cropTypes/ /;/)
```GAMS
set rot_cropTypes(rot,cropTypes,cropTypes,cropTypes)  "Rotation, first / second / third year crop type"
                                         /
                                           WC_WC_PO.WinterCere.WinterCere.potatoes
                                           WC_PO_WC.WinterCere.potatoes.WinterCere
                                           PO_WC_WC.potatoes.WinterCere.WinterCere

                                           WC_WC_OT.WinterCere.WinterCere.other
                                           WC_OT_WC.WinterCere.other.WinterCere
                                           OT_WC_WC.other.WinterCere.WinterCere

                                           WC_WC_ID.WinterCere.WinterCere.idle
                                           WC_ID_WC.WinterCere.idle.WinterCere
                                           ID_WC_WC.idle.WinterCere.WinterCere

                                           WC_WC_SU.WinterCere.WinterCere.sugarBeet
                                           WC_SU_WC.WinterCere.sugarBeet.WinterCere
                                           SU_WC_WC.sugarBeet.WinterCere.WinterCere

                                           WC_WC_SC.WinterCere.WinterCere.summerCere
                                           WC_SC_WC.WinterCere.summerCere.WinterCere
                                           SC_WC_WC.summerCere.WinterCere.WinterCere

                                           WC_SC_PO.WinterCere.summerCere.potatoes
                                           SC_PO_WC.summerCere.potatoes.WinterCere
                                           PO_WC_SC.potatoes.WinterCere.summerCere

                                           WC_SC_SU.WinterCere.summerCere.sugarBeet
                                           SC_SU_WC.summerCere.sugarBeet.WinterCere
                                           SU_WC_SC.sugarBeet.WinterCere.summerCere

                                           WC_SC_ID.WinterCere.summerCere.idle
                                           SC_ID_WC.summerCere.idle.WinterCere
                                           ID_WC_SC.idle.WinterCere.summerCere

                                           WC_SC_OT.WinterCere.summerCere.other
                                           SC_OT_WC.summerCere.other.WinterCere
                                           OT_WC_SC.other.WinterCere.summerCere


                                           SC_WC_SC.summerCere.WinterCere.summerCere
                                           WC_SC_SC.WinterCere.summerCere.summerCere
                                           SC_SC_WC.summerCere.summerCere.WinterCere

                                           WC_ID_ID.WinterCere.idle.idle
                                           ID_WC_ID.idle.WinterCere.idle
                                           ID_ID_WC.idle.idle.WinterCere

                                           SC_ID_ID.summerCere.idle.idle
                                           ID_SC_ID.idle.summerCere.idle
                                           ID_ID_SC.idle.idle.summerCere

                                           SC_SC_ID.summerCere.summerCere.idle
                                           SC_ID_SC.summerCere.idle.summerCere
                                           ID_SC_SC.idle.summerCere.summerCere

                                           SC_SC_PO.summerCere.summerCere.potatoes
                                           WC_PO_ID.WinterCere.potatoes.idle
                                           SC_PO_ID.summerCere.potatoes.idle
                                           ID_ID_ID.idle.idle.idle
                                           PO_ID_ID.potatoes.idle.idle

                                           SC_SC_SU.summerCere.summerCere.sugarBeet
                                           WC_SU_ID.WinterCere.sugarBeet.idle
                                           SC_SU_ID.summerCere.SugarBeet.idle
                                           SU_ID_ID.sugarBeet.idle.idle



                                           SC_SC_OT.summerCere.summerCere.other
                                           WC_OT_ID.WinterCere.other.idle
                                           SC_OT_ID.summerCere.other.idle
                                           OT_ID_ID.other.idle.idle

                                           PO_OT_WC.potatoes.other.WinterCere
                                           OT_WC_PO.other.WinterCere.potatoes
                                           WC_PO_OT.WinterCere.potatoes.other

                                           PO_OT_SC.potatoes.other.summerCere
                                           SU_OT_WC.SugarBeet.other.WinterCere
                                           OT_WC_SU.other.WinterCere.SugarBeet
                                           WC_SU_OT.WinterCere.SugarBeet.other

                                           SU_OT_SC.SugarBeet.other.summerCere
                                           OT_SC_SU.other.summerCere.SugarBeet
                                           SC_SU_OT.summerCere.SugarBeet.other

                                           SU_OT_PO.SugarBeet.other.potatoes
                                           OT_PO_SU.other.potatoes.SugarBeet
                                           PO_SU_OT.potatoes.SugarBeet.other

                                         /;
```

The link between individual crops and crop types used in the rotation
definitions is as follows:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ_decl.gms GAMS /set\scropTypes_/ /;/)
```GAMS
set cropTypes_crops(cropTypes,crops) / winterCere.(winterWheat,winterBarley)
                                         summerCere.(summerCere,maizCorn,maizCCM,WheatGPS)
                                         other.(winterrape,summerBeans,summerPeas,CatchCrop)
                                         potatoes.potatoes
                                         sugarbeet.sugarbeet
                                         idle.idle
                      /;
```

In order to use the crop rotations in the model equations, three cross
sets are generated which define the crop type in the first, second and
third year for each rotation:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ_decl.gms GAMS /set\scropType0/ /YES;/)
```GAMS
set cropType0_rot(cropTypes,rot);cropType0_rot(cropTypes,rot) $ sum(rot_cropTypes(rot,cropTypes,cropTypes1,cropTypes2),1) = YES;
```
[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ_decl.gms GAMS /set\scropType1/ /YES;/)
```GAMS
set cropType1_rot(cropTypes,rot);cropType1_rot(cropTypes,rot) $ sum(rot_cropTypes(rot,cropTypes1,cropTypes,cropTypes2),1) = YES;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ_decl.gms GAMS /set\scropType2/ /YES;/)
```GAMS
set cropType2_rot(cropTypes,rot);cropType2_rot(cropTypes,rot) $ sum(rot_cropTypes(rot,cropTypes1,cropTypes2,cropTypes),1) = YES;
```

For each simulation, crops can be selected that are cultivated on farm,
therefore, it can be the case that not all rotations are operational.
Accordingly, in *coeffgen\\coeffgen.gms*, the set of available crop
rotations is defined:

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/coeffgen.gms GAMS /cropType0.*?Type0/ /NO;/)
```GAMS
cropType0_rot(cropTypes,rot) $ (not sum( (cropType0_rot(cropTypes1,rot),curCrops) $ cropTypes_crops(cropTypes1,curCrops),1)) = NO;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/coeffgen.gms GAMS /\scropType0.*?Type1/ /NO;/)
```GAMS
 cropType0_rot(cropTypes,rot) $ (not sum( (cropType1_rot(cropTypes1,rot),curCrops) $ cropTypes_crops(cropTypes1,curCrops),1)) = NO;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/coeffgen.gms GAMS /\scropType0.*?Type2/ /NO;/)
```GAMS
 cropType0_rot(cropTypes,rot) $ (not sum( (cropType2_rot(cropTypes1,rot),curCrops) $ cropTypes_crops(cropTypes1,curCrops),1)) = NO;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/coeffgen.gms GAMS /\scropType1.*?Type1/ /NO;/)
```GAMS
 cropType1_rot(cropTypes,rot) $ (not sum( (cropType1_rot(cropTypes1,rot),curCrops) $ cropTypes_crops(cropTypes1,curCrops),1)) = NO;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/coeffgen.gms GAMS /\scropType1.*?Type0/ /NO;/)
```GAMS
 cropType1_rot(cropTypes,rot) $ (not sum( (cropType0_rot(cropTypes1,rot),curCrops) $ cropTypes_crops(cropTypes1,curCrops),1)) = NO;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/coeffgen.gms GAMS /\scropType1.*?Type2/ /NO;/)
```GAMS
 cropType1_rot(cropTypes,rot) $ (not sum( (cropType2_rot(cropTypes1,rot),curCrops) $ cropTypes_crops(cropTypes1,curCrops),1)) = NO;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/coeffgen.gms GAMS /\scropType2.*?Type2/ /NO;/)
```GAMS
 cropType2_rot(cropTypes,rot) $ (not sum( (cropType2_rot(cropTypes1,rot),curCrops) $ cropTypes_crops(cropTypes1,curCrops),1)) = NO;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/coeffgen.gms GAMS /\scropType2.*?Type0/ /NO;/)
```GAMS
 cropType2_rot(cropTypes,rot) $ (not sum( (cropType0_rot(cropTypes1,rot),curCrops) $ cropTypes_crops(cropTypes1,curCrops),1)) = NO;
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/coeffgen/coeffgen.gms GAMS /\scropType2.*?Type1/ /NO;/)
```GAMS
 cropType2_rot(cropTypes,rot) $ (not sum( (cropType1_rot(cropTypes1,rot),curCrops) $ cropTypes_crops(cropTypes1,curCrops),1)) = NO;
```


The rotations enter the model via three constraints (*see
model\\templ.gms*). The right hand side sums up the crop hectares of a
certain crop type in the current year in all four constraints, while the
left hand side exhausts these hectares in the current, next and after
next year based on the rotations grown in these years.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /rotHa0_\(.*?"g/ /;/)
```GAMS
rotHa0_(cropTypes,plot,tCur(t),nCur) $ ( (not sum(plot_lt_soil(plot,"gras",soil),1) $ t_n(t,nCur))

            $ (sum(cropType0_rot(cropTypes,curRot(rot)),1)
               $ sum( (cropTypes_crops(cropTypes,crops),c_s_t_i(crops,plot,till,intens))
                           $ (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0),1))) ..

        sum( (cropTypes_crops(cropTypes,crops),c_s_t_i(crops,plot,till,intens)), v_cropHa(crops,plot,till,intens,t,nCur))

            =E=   sum(cropType0_rot(cropTypes,curRot(rot)), v_rotHa(rot,plot,t,nCur));
```
[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /rotHa1_\(.*?"g/ /;/)
```GAMS
rotHa1_(cropTypes,plot,tCur(t),nCur) $ ((not sum(plot_lt_soil(plot,"gras",soil),1) )

            $ (sum(cropType1_rot(cropTypes,curRot(rot)),1)
               $ sum( (cropTypes_crops(cropTypes,crops),c_s_t_i(crops,plot,till,intens))
                           $ (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0),1)
                           $ tCur(t+1)) $ t_n(t,nCur)  ) ..

        sum( (cropTypes_crops(cropTypes,crops),c_s_t_i(crops,plot,till,intens)), v_cropHa(crops,plot,till,intens,t,nCur))

            =E=   sum((cropType1_rot(cropTypes,curRot(rot)),t_n(t+1,nCur1)), v_rotHa(rot,plot,t+1,nCur1));
```

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/templ.gms GAMS /rotHa2_\(.*?"g/ /;/)
```GAMS
rotHa2_(cropTypes,plot,tCur(t),nCur) $ ((not sum(plot_lt_soil(plot,"gras",soil),1))

            $ (sum(cropType2_rot(cropTypes,curRot(rot)),1)
               $ sum( (cropTypes_crops(cropTypes,crops),c_s_t_i(crops,plot,till,intens))
                           $ (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0),1)
                           $ tCur(t+2)) $ t_n(t,nCur) ) ..

        sum( (cropTypes_crops(cropTypes,crops),c_s_t_i(crops,plot,till,intens)), v_cropHa(crops,plot,till,intens,t,nCur))

            =E=   sum((cropType2_rot(cropTypes,curRot(rot)),t_n(t+2,nCur1)), v_rotHa(rot,plot,t+2,nCur1));
```

The rotations restrict the combination of crops and enter into the
optional soil pool balancing approach.

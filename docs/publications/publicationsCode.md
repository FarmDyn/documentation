# Special Code Lines of Individual Publications

There are individual FarmDyn extensions which were used exclusively for publications and cannot be found on the head revision of FarmDyn. These code parts are therefore not explained in the model description, but below under the respective authors and year.

<!--
## PhD Theses
SCHÄFER, DAVID MATTHIAS (2021):
KUHN, TILL (2019):
GABERT, JOHANNA (2013):
LENGERS, BERND (2013):
-->


## Journal publications

<!--
BRITZ, W., CIAIAN, P., GOCHT, A., KANELLOPOULOS, A., KREMMYDAS, D., MÜLLER, M., PETSAKOS, A., REIDSMA, P. (2021):
HEINRICHS, J., JOUAN, J., PAHMEYER, C., BRITZ, W. (2021):
HEINRICHS, J., KUHN, T., PAHMEYER, C., BRITZ, W. (2021):
KUHN, T., ENDERS, A., GAISER, T., SCHÄFER, D., SRIVASTAVA, A., BRITZ, W. (2020):
PAHMEYER, C., BRITZ, W. (2020):
-->

### KUHN, T., SCHÄFER, D., HOLM-MÜLLER, K., BRITZ, W. (2019):

FarmDyn is loosely connected to the crop modeling framework [SIMPLACE](http://www.simplace.net/Joomla/index.php). This crop model provides cropping activities consisting of different managements and corresponding yields and externalities. They are provided as a gdx file and loaded into FarmDyn. The parameter *p\_simres* contains all information from the crop model for different crops, crop rotations (represented in the set *till*) and intensities. Intensities represent a whole range of management, consisting of different amounts of fertiliser, straw removal and catch crop growing. The elements of the set contain the information on yields and externalities for the different cropping activities.

The use of the SIMPLACE data is activated in the GUI by selecting the BWA mode. It requires to choose specific farm types and their location in different soil-climate regions. Currently, SIMPLACE data are available for the German Federal State of North Rhine-Westphalia.

First, the shares of different crops in FarmDyn have to equal the crop rotation represented in the SIMPLACE data. Crop rotations can be selected at the GUI.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/simplace_module.gms GAMS /SimplaceRot_\(c_/ /;/)
```GAMS
SimplaceRot_(c_s_t_i(curCrops(crops),plot,curRotTill(till),intens),tCur(t),nCur)
                     $ ( (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0) $ t_n(t,nCur)
                     $ (not sameas (crops,"idle") )
                     $ (not sameas (crops,"catchcrop") )  ) ..

       v_cropHa(crops,plot,till,intens,t,nCur)

           =e=

             sum ( crops1 $  (c_s_t_i(crops1,plot,till,intens) $ (curCrops(crops1)
                              $ (not sameas(crops1,"idle"))
                              $ (not sameas(crops1,"catchcrop")))),
                     v_cropHa(crops1,plot,till,intens,t,nCur))    *   p_cropShare(till,crops);
```


The synthetic fertiliser need linked to cropping activities in the SIMPLACE data has to be provided by synthetic fertiliser distribution in FarmDyn.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/simplace_module.gms GAMS /NMineralSim_\(c_/ /;/)
```GAMS
NMineralSim_(c_s_t_i(curCrops(crops),plot,curRotTill(till),intens),"N",tCur(t),nCur)
                     $ ((v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0) $ t_n(t,nCur)   $   (not sameas (curCrops,"catchcrop") ) $ (not sameas (curCrops,"idle") )    ) ..

           sum ( (syntFertilizer,m) , v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)  * p_nutInSynt(syntFertilizer,"N")
                           * (1 - p_EFApplMinNH3(syntFertilizer) -  p_EFApplMin("N2O") - p_EFApplMin("NOx") ) )

           =e=

               v_cropHa(crops,plot,till,intens,t,nCur) *  p_SimRes(till,crops,intens,"Nchem")
;
```

The cropping activities in the SIMPLACE data correspond to the month January to June. Accordingly, manure application has to be conducted in those months. Note that other restrictions such as the Fertilisation Ordinance may restrict application in certain months.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/simplace_module.gms GAMS /NOrgSpringSim_\(c_/ /;/)
```GAMS
NOrgSpringSim_(c_s_t_i(curCrops(crops),plot,curRotTill(till),intens),"N",tCur(t),nCur)
                  $ ((v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0) $ t_n(t,nCur)  $ (not sameas (curCrops,"catchcrop") ) $ (not sameas (curCrops,"idle") )  ) ..


*                --- NOrg Applied

                  sum( (manApplicType_manType(ManApplicType,curManType),m_spring(m) )
                   $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m_spring) ne 0),
                       v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m_spring )
                          * sum(manChain_applic(manChain,ManApplicType), p_nut2inMan("NOrg",curManType,manChain)) * (1 - ( p_EFApplMin("N2O") + p_EFApplMin("NOx")))  )

*               -- NTAN applied minus losses with application

                + sum( (manApplicType_manType(ManApplicType,curManType),m_spring(m) )
                    $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m_spring) ne 0),
                       v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m_spring)
                           * sum(manChain_applic(manChain,ManApplicType), p_nut2inMan("NTan",curManType,manChain))
                               * (p_nut2UsableShare(crops,curManType,ManApplicType,"NTAN",m) - ( p_EFApplMin("N2O") + p_EFApplMin("NOx")) )
                                   )
                   =e=

                       v_cropHa(crops,plot,till,intens,t,nCur) *   p_SimRes(till,crops,intens,"NOrgS")

                                        ;
```

In line with manure application in spring, the manure application in autumn linked to cropping activities in the SIMPLACE data has to be provided
by manure application in FarmDyn in the months July to December.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/simplace_module.gms GAMS /NOrgAutumnSim_\(c_/ /;/)
```GAMS
NOrgAutumnSim_(c_s_t_i(curCrops(crops),plot,curRotTill(till),intens),"N",tCur(t),nCur)
                  $ ((v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0) $ t_n(t,nCur)
                   $ (not sameas (crops,"catchcrop") ) $ (not sameas (crops,"idle") )  ) ..


*                --- NOrg Applied

                  sum( ( manApplicType_manType(ManApplicType,curManType),m_autumn(m) )
                   $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m_autumn) ne 0),
                       v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m_autumn )
                          * sum(manChain_applic(manChain,ManApplicType), p_nut2inMan("NOrg",curManType,manChain)) * (1 - ( p_EFApplMin("N2O") + p_EFApplMin("NOx")))   )

*               -- NTAN applied minus losses with application

                + sum(  ( manApplicType_manType(ManApplicType,curManType),m_autumn(m) )
                    $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m_autumn) ne 0),
                       v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m_autumn)
                           * sum(manChain_applic(manChain,ManApplicType), p_nut2inMan("NTan",curManType,manChain))
                               * ( p_nut2UsableShare(crops,curManType,ManApplicType,"NTAN",m)  - ( p_EFApplMin("N2O") + p_EFApplMin("NOx"))  )
                                     )

                  =e=

                       v_cropHa(crops,plot,till,intens,t,nCur) *  p_SimRes(till,crops,intens,"NOrgA") ;
```

The cropping activities provided by SIMPLACE do not contain information on P<sub>2</sub>O<sub>5</sub> fertiliser need. Therefore, the following equation ensures that P<sub>2</sub>O<sub>5</sub> removal with the harvested product has to be meet by P<sub>2</sub>O<sub>5</sub> from manure and chemical fertiliser.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/simplace_module.gms GAMS /PFertilizingSim_.*?\.\./ /;/)
```GAMS
PFertilizingSim_("P",tCur(t),nCur)  $ t_n(t,nCur)  ..

                sum( (prods,c_s_t_i(curcrops(crops),plot,till,intens))   $ (  ( not sameas (prods,"WCresidues")) $ ( not sameas (prods,"WBresidues")) $ (not sameas (prods,"SCresidues"))
                                                                             $ (not sameas (curCrops,"catchcrop") )  $ (not sameas (curCrops,"idle") )   )
                            ,  p_SimRes(till,crops,intens,"yield")  * p_nutContent(crops,prods,"P") * 10/1000
                                                                            * v_cropHa(crops,plot,till,intens,t,nCur)   )

                     =l=

$iftheni.man %manure% == true

                      sum( (manApplicType_manType(ManApplicType,curManType),m,c_s_t_i(curCrops(crops),plot,till,intens))  $ (  (not sameas (curCrops,"catchcrop") )  $ (not sameas (curCrops,"idle") )
                         $ (   v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0)     ),
                            v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                              * sum(manChain_applic(manChain,ManApplicType), p_nut2inMan("P",curManType,manChain))

                             )

                            +

$endif.man

                       sum ( (syntFertilizer,m,c_s_t_i(curcrops(crops),plot,till,intens) ) $(  (not sameas (curCrops,"catchcrop") )  $ (not sameas (curCrops,"idle") )  )
                                   , v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)  * p_nutInSynt(syntFertilizer,"P")  )
                                                           ;
```

Some crops require minimum chemical fertiliser doses such as the starter fertilisation of maize. For N, minimum chemical fertiliser needs are reflected in the SIMPLACE results. For P<sub>2</sub>O<sub>5</sub>, the following equations ensures that the minimum chemical fertiliser needs is met.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/simplace_module.gms GAMS /MinChemFertSimplace_.*?\.\./ /;/)
```GAMS
MinChemFertSimplace_(tCur(t),nCur)    $ t_n(t,nCur)  ..

                sum( (c_s_t_i(curcrops(crops),plot,till,intens))   $ (  (not sameas (curCrops,"catchcrop") )  $ (not sameas (curCrops,"idle") )  )
                            ,   v_cropHa(crops,plot,till,intens,t,nCur) * p_minChemFert(crops,"P")
                                         )

                                    =l=

                 sum ( (syntFertilizer,m,c_s_t_i(curcrops(crops),plot,till,intens) )  $ (  (not sameas (curCrops,"catchcrop") )  $ (not sameas (curCrops,"idle") )  )
                                   , v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)   * p_nutInSynt(syntFertilizer,"P")  )
                                                     ;
```

The SIMPLACE results contain scenarios, captured in the set intensities, with and without residue removal. Thereby, it is assumed that straw from cereal production can be sold. The following equation maps the cropping activities on the variable *v\_residuesRemoval* which is used in other parts of FarmDyn to calculate the costs and revenues related to residue removal.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/simplace_module.gms GAMS /ResidRemovalSim_\(cu/ /;/)
```GAMS
ResidRemovalSim_(curCrops(crops),plot,till,intens,tCur(t),nCur)
                 $ ( t_n(t,nCur) $  c_s_t_i(crops,plot,till,intens)  $ (not sameas (curCrops,"catchcrop") )  $ (not sameas (curCrops,"idle"))
                                $ intensResRem(intens)   $ cropsResidueRemo(crops)  ) ..

                     v_residuesRemoval(crops,plot,till,intens,t,nCur)    =e=          v_cropHa(crops,plot,till,intens,t,nCur)  ;
```

The SIMPLACE results contain scenarios, captured in the set intensities, with and without catch crops.
They are linked to the catch crop growing represented in *v\_cropHa*.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/simplace_module.gms GAMS /CatchCropsSimHa_\(p.*?r\)/ /;/)
```GAMS
CatchCropsSimHa_(plot,curRotTill(till),intens,tCur(t),nCur)
                $ ( t_n(t,nCur) $ (sum (crops, c_s_t_i(crops,plot,till,intens)))     ) ..

            sum (c_s_t_i("catchCrop",plot,till,intens), v_cropHa("catchCrop",plot,till,intens,t,nCur)    )

                                   =e=
                                         sum( c_s_t_i(curCrops(crops),plot,till,intens) $ intensCatchCro(intens),
                                                           v_cropHa(crops,plot,till,intens,t,nCur)
                                                               *  p_SimRes(till,crops,intens,"catCroShare")   )
                                           ;
```

The SIMPLACE results contain nitrate leaching for the different cropping activities. This externality is
summarised in the following equation for the environmental accounting in FarmDyn.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/simplace_module.gms GAMS /NleachSim_\(cu/ /;/)
```GAMS
NleachSim_(curCrops(crops),tCur(t),nCur)
                 $ ( t_n(t,nCur) $ sum ( (plot,till,intens), c_s_t_i(crops,plot,till,intens)) $ (not sameas (curCrops,"catchcrop") )  $ (not sameas (curCrops,"idle") )  ) ..


                 v_NleachSim(crops,t,nCur)

                       =e=

                          sum( c_s_t_i(curCrops,plot,curRotTill,intens),  v_cropHa(crops,plot,curRotTill,intens,t,nCur)
                                                                              * p_SimRes(curRotTill,crops,intens,"Nleach")  )  ;
```

Furthermore, the SIMPLACE results contain a N balance which is summarised in the following equation. Please note
that the calculation of this balance differs from the balance calculation under the Fertilisation Ordinance.

[embedmd]:# (N:/em/work1/FarmDyn/FarmDyn_QM/gams/model/simplace_module.gms GAMS /NSurplusSim_\(cu/ /;/)
```GAMS
NSurplusSim_(curCrops(crops),tCur(t),nCur)
                    $ ( t_n(t,nCur) $ sum ( (plot,till,intens), c_s_t_i(crops,plot,till,intens))  $ (not sameas (curCrops,"catchcrop") ) $ (not sameas (curCrops,"idle") )  ) ..


                 v_NSurplusSim(crops,t,nCur)

                       =e=

                     sum(  c_s_t_i(curCrops,plot,curRotTill,intens),  v_cropHa(crops,plot,curRotTill,intens,t,nCur)
                                                                             * p_SimRes(curRotTill,crops,intens,"NSur") ) ;
```


<!--
SCHÄFER, D., BRITZ, W., KUHN, T. (2017):
LENGERS, B., BRITZ, W., HOLM-MÜLLER, K. (2014):
LENGERS, B., SCHIEFLER, I. & BÜSCHER,  W. (2013):
LENGERS, B.,  BRITZ, W., HOLM-MÜLLER, K. (2013):
LENGERS, B.,  BRITZ, W. (2012):
-->

<!--
## Contributions to conferences and lecture series
HEINRICHS, J., KUHN, T., PAHMEYER, C., BRITZ, W. (2021):
HEINRICHS, J., KUHN, T., PAHMEYER, C., BRITZ, W. (2020):
KOKEMOHR, L., KUHN, T., ESCOBAR, N., BRITZ, W. (2020):
JOUAN, J., HEINRICHS, J., BRITZ, W., PAHMEYER, C. (2019):
ZENG, W., GAISER, T., ENDERS, A., KUHN, T., SCHÄFER, D., BRITZ, W. (2018):
KUHN, T., SCHÄFER, D., BRITZ, W. (2017):
SCHÄFER, D., BRITZ, W. (2017):
SEIDEL, C., BRITZ, W. (2017):
SCHÄFER, D., SEIDEL, C., BRITZ, W. (2016):
REMBLE, A., BRITZ, W., KEENEY, R. (2013):
LENGERS, B., BRITZ, W., HOLM-MÜLLER, K. (2013):
BRITZ, W., LENGERS, B. (2012):
BRITZ, W., LENGERS, B. (2011):
-->

<!--
## Discussion and technical papers
LENGERS, B., BRITZ, W., HOLM-MÜLLER, K. (2013):
LENGERS, B.(2012):
LENGERS, B. (2012):
LENGERS, B. (2011):
-->

 

clear *
insheet using "Study_4_data.csv", clear
gen study=4
destring *, replace
save tmp, replace

insheet using "Study_3_data.csv", clear
gen study=3
destring *, replace
append using tmp, force


gen id=_n

gen accheadline = "real"
replace accheadline ="fake" if neufakeimp==1

gen didnt_finish=socialmedia_chk==.


///////////////
// Descriptive statistics
table study
table didnt_finish fb study
drop if didnt_finish==1 | fb==2
bysort study: sum id age 
table study sex
table study if sex==.

table socialmedia_chk study
bysort study: sum id age if socialmedia_chk ==1
table study sex if socialmedia_chk ==1
table study if sex==. & socialmedia_chk ==1
/////////////////

////////////////////
// Creat variable indicating whether they report ever sharing political content on social media
gen socialmedia_chk1 = socialmedia_chk==1
replace socialmedia_chk1=. if socialmedia_chk==.
//////////////////////

///////////////////
// Treatment effect on perceived importance of accuracy?

// no treatment effect on accuracy importance qs
bysort study: ttest accimp if socialmedia_chk ==1, by(condition)
ttest accimp if socialmedia_chk ==1, by(condition)
ttest accimp_friends if socialmedia_chk ==1, by(condition)

// interesting sidenote: people think that they care more about accuracy than their friends do
ttest accimp==accimp_friends
////////////////////////

/////////////////////////
// reshape data to long format & do other pre-processing
drop *_sm
drop *_rt_1
drop *_rt_2
drop *_rt_4
rename real_rt_3 real1_rt_3
rename fake*_rt_3 fake*_sm_rt
rename real*_rt_3 real*_sm_rt
rename fake*_3 fake_sm*
rename real*_3 real_sm*
rename fake*_sm_rt fake_sm_rt*
rename real*_sm_rt real_sm_rt*
reshape long fake_sm real_sm fake_sm_rt real_sm_rt   fakeC_sm realC_sm , i(id) j(item_num)
replace fake_sm = fakeC_sm if fake_sm==.
replace real_sm = realC_sm if real_sm==.
rename fake_sm sm1
rename real_sm sm2
rename fake_sm_rt rt1
rename real_sm_rt rt2
gen uniqueI = id*1000+item_num
reshape long sm acc rt , i(unique) j(real)
replace real=real-1
drop fake
gen fake=1-real
replace sm=(sm-1)/5
gen politically_concordant = (item_num<=6 & demrep==2) | (item_num>6 & demrep==1)
replace item_num=item_num+(real)*12				
replace item_num=item_num+24 if study==3
replace condition=condition-1

// create binary "likely to share" variable for plots
gen Bsm=round(sm)


label define bla1x 0 "Control" 1 "Treatment"
label values condition bla1x

label define bla2x 0 "False" 1 "True"
label values real bla2x

label define bla5x 1 "Democrat" 2 "Republican"
label values demrep bla5x

label define bla3xx 0 "Discordant" 1 "Concordant"
label values politically_concordant  bla3xx
///////////////////////////




///////////////////
// Visualizations

// for Figure 2a,b
xi: bysort study condition real: cluster2 Bsm if socialmedia_chk==1, tcluster(id) fcluster(item_num)

// for Extended Data Figure 2
table sm  condition real if socialmedia_chk==1 & study==3
table sm  condition real if socialmedia_chk==1 & study==4
////////////////////////


////////////////
// ANALYSIS - Table S2

// study 3 - main analysis (only subjects who sometimes share political news)
xi: cluster2 sm i.condition*real if socialmedia_chk==1 & study==3, tcluster(id) fcluster(item_num)
//     look at simple effects
test real=0 // simple effect of real in control
disp _b[real]
test real+_IconXreal_1 =0 // simple effect of real in treatment
disp _b[real]+_b[_IconXreal_1]
test _Icondition_1=0 // simple effect of condition for false
disp _b[_Icondition_1]
test _Icondition_1+_IconXreal_1 =0 // simple effect of condition for real
disp _b[_Icondition_1]+_b[_IconXreal_1]
test _IconXreal_1 =0

// study 4 - main analysis (only subjects who sometimes share political news)
xi: cluster2 sm i.condition*real if socialmedia_chk==1 & study==4, tcluster(id) fcluster(item_num)
//     look at simple effects
test real=0 // simple effect of real in control
disp _b[real]
test real+_IconXreal_1 =0 // simple effect of real in treatment
disp _b[real]+_b[_IconXreal_1]
test _Icondition_1=0 // simple effect of condition for false
disp _b[_Icondition_1]
test _Icondition_1+_IconXreal_1 =0 // simple effect of condition for real
disp _b[_Icondition_1]+_b[_IconXreal_1]
test _IconXreal_1 =0

// study3+4 with politics moderation - main analysis (only subjects who sometimes share political news)
preserve
keep if socialmedia_chk==1
//  z-score party
egen z_demrep=std(demrep)
replace z_demrep=0 if demrep==.
egen z_concordant=std(politically_conc)
// create interactions
gen conditionXreal=condition*real
gen conditionXdr=condition*z_demrep
gen drXreal=z_demrep*real
gen conditionXdrXreal=condition*z_demrep*real
gen realXconcordant=real*z_concordant
gen conditionXrealXconcordant=condition*real*z_concordant
gen conditionXconcordant=condition*z_concordant
gen concordantXdr=z_concordant*z_demrep
gen concordantXconditionXdr=z_concordant*condition*z_demrep
gen concordantXdrXreal=z_concordant*z_demrep*real
gen concordantXconditionXdrXreal=z_concordant*condition*z_demrep*real
// regression
xi: cluster2 sm  condition real z_demrep conditionXreal drXreal conditionXdr conditionXdrXreal z_concordant realXconcordant conditionXconcordant conditionXrealXconcordant concordantXdr concordantXconditionXdr concordantXdrXreal concordantXconditionXdrXreal, tcluster(id) fcluster(item_num)
test conditionXrealXconcordant=0
// separately for Dems v Reps
xi: cluster2 sm  condition real conditionXreal z_concordant realXconcordant conditionXconcordant conditionXrealXconcordant if demrep==1, tcluster(id) fcluster(item_num)
test conditionXreal=0
xi: cluster2 sm  condition real conditionXreal z_concordant realXconcordant conditionXconcordant conditionXrealXconcordant if demrep==2, tcluster(id) fcluster(item_num)
test conditionXreal=0
restore


// study 3 - all subjects
xi: cluster2 sm i.condition*real if study==3, tcluster(id) fcluster(item_num)
//     look at simple effects
test real=0 // simple effect of real in control
disp _b[real]
test real+_IconXreal_1 =0 // simple effect of real in treatment
disp _b[real]+_b[_IconXreal_1]
test _Icondition_1=0 // simple effect of condition for false
disp _b[_Icondition_1]
test _Icondition_1+_IconXreal_1 =0 // simple effect of condition for real
disp _b[_Icondition_1]+_b[_IconXreal_1]
test _IconXreal_1 =0

// study 4 - all subjects
xi: cluster2 sm i.condition*real if study==4, tcluster(id) fcluster(item_num)
//     look at simple effects
test real=0 // simple effect of real in control
disp _b[real]
test real+_IconXreal_1 =0 // simple effect of real in treatment
disp _b[real]+_b[_IconXreal_1]
test _Icondition_1=0 // simple effect of condition for false
disp _b[_Icondition_1]
test _Icondition_1+_IconXreal_1 =0 // simple effect of condition for real
disp _b[_Icondition_1]+_b[_IconXreal_1]
test _IconXreal_1 =0

// study3+4 with politics moderation - all subjects
preserve
//  z-score party
egen z_demrep=std(demrep)
replace z_demrep=0 if demrep==.
egen z_concordant=std(politically_conc)
// create interactions
gen conditionXreal=condition*real
gen conditionXdr=condition*z_demrep
gen drXreal=z_demrep*real
gen conditionXdrXreal=condition*z_demrep*real
gen realXconcordant=real*z_concordant
gen conditionXrealXconcordant=condition*real*z_concordant
gen conditionXconcordant=condition*z_concordant
gen concordantXdr=z_concordant*z_demrep
gen concordantXconditionXdr=z_concordant*condition*z_demrep
gen concordantXdrXreal=z_concordant*z_demrep*real
gen concordantXconditionXdrXreal=z_concordant*condition*z_demrep*real
// regression
xi: cluster2 sm  condition real z_demrep conditionXreal drXreal conditionXdr conditionXdrXreal z_concordant realXconcordant conditionXconcordant conditionXrealXconcordant concordantXdr concordantXconditionXdr concordantXdrXreal concordantXconditionXdrXreal, tcluster(id) fcluster(item_num)
test conditionXrealXconcordant=0
// separately for Dems v Reps
xi: cluster2 sm  condition real conditionXreal z_concordant realXconcordant conditionXconcordant conditionXrealXconcordant if demrep==1, tcluster(id) fcluster(item_num)
test conditionXreal=0
xi: cluster2 sm  condition real conditionXreal z_concordant realXconcordant conditionXconcordant conditionXrealXconcordant if demrep==2, tcluster(id) fcluster(item_num)
test conditionXreal=0
restore
//////////////////







/////////////////////
// define pre-test ratings for each headline
gen familiarity=.
gen likelihood=.
gen politic =.				

replace item_num=item_num-24 if study==3

replace politic = 	3.822916667	if item_num==	13	& study==3
replace politic = 	3.510416667	if item_num==	14	& study==3
replace politic = 	3.21875	if item_num==	15	& study==3
replace politic = 	3.65625	if item_num==	16	& study==3
replace politic = 	3.822916667	if item_num==	17	& study==3
replace politic = 	3.557894737	if item_num==	18	& study==3
replace politic = 	2.604166667	if item_num==	19	& study==3
replace politic = 	2.75	if item_num==	20	& study==3
replace politic = 	2.302083333	if item_num==	21	& study==3
replace politic = 	2.71875	if item_num==	22	& study==3
replace politic = 	2.135416667	if item_num==	23	& study==3
replace politic = 	2.239583333	if item_num==	24	& study==3
replace politic = 	3.676767677	if item_num==	1	& study==3
replace politic = 	4.060606061	if item_num==	2	& study==3
replace politic = 	3.757575758	if item_num==	3	& study==3
replace politic = 	3.666666667	if item_num==	4	& study==3
replace politic = 	3.929292929	if item_num==	5	& study==3
replace politic = 	3.908163265	if item_num==	6	& study==3
replace politic = 	2.454545455	if item_num==	7	& study==3
replace politic = 	2.171717172	if item_num==	8	& study==3
replace politic = 	2.535353535	if item_num==	9	& study==3
replace politic = 	2.474747475	if item_num==	10	& study==3
replace politic = 	1.616161616	if item_num==	11	& study==3
replace politic = 	2.303030303	if item_num==	12	& study==3

replace likelihood = 	4.979166667	if item_num==	13	& study==3
replace likelihood = 	3.96875	if item_num==	14	& study==3
replace likelihood = 	4.135416667	if item_num==	15	& study==3
replace likelihood = 	4.572916667	if item_num==	16	& study==3
replace likelihood = 	4.489583333	if item_num==	17	& study==3
replace likelihood = 	4.5625	if item_num==	18	& study==3
replace likelihood = 	4.614583333	if item_num==	19	& study==3
replace likelihood = 	4.114583333	if item_num==	20	& study==3
replace likelihood = 	4.53125	if item_num==	21	& study==3
replace likelihood = 	4.708333333	if item_num==	22	& study==3
replace likelihood = 	4.197916667	if item_num==	23	& study==3
replace likelihood = 	5	if item_num==	24	& study==3
replace likelihood = 	2.777777778	if item_num==	1	& study==3
replace likelihood = 	1.939393939	if item_num==	2	& study==3
replace likelihood = 	3.373737374	if item_num==	3	& study==3
replace likelihood = 	3.363636364	if item_num==	4	& study==3
replace likelihood = 	1.909090909	if item_num==	5	& study==3
replace likelihood = 	2.402061856	if item_num==	6	& study==3
replace likelihood = 	3.282828283	if item_num==	7	& study==3
replace likelihood = 	3.242424242	if item_num==	8	& study==3
replace likelihood = 	2.01010101	if item_num==	9	& study==3
replace likelihood = 	2.357142857	if item_num==	10	& study==3
replace likelihood = 	2.333333333	if item_num==	11	& study==3
replace likelihood = 	3.581632653	if item_num==	12	& study==3

replace familiarity=	2.115789474	if item_num==	13	& study==3
replace familiarity=	2.697916667	if item_num==	14	& study==3
replace familiarity=	2.75	if item_num==	15	& study==3
replace familiarity=	2.75	if item_num==	16	& study==3
replace familiarity=	2.604166667	if item_num==	17	& study==3
replace familiarity=	2.260416667	if item_num==	18	& study==3
replace familiarity=	2.583333333	if item_num==	19	& study==3
replace familiarity=	2.5	if item_num==	20	& study==3
replace familiarity=	2.604166667	if item_num==	21	& study==3
replace familiarity=	2.583333333	if item_num==	22	& study==3
replace familiarity=	2.410526316	if item_num==	23	& study==3
replace familiarity=	2.635416667	if item_num==	24	& study==3
replace familiarity=	2.757575758	if item_num==	1	& study==3
replace familiarity=	2.919191919	if item_num==	2	& study==3
replace familiarity=	2.969387755	if item_num==	3	& study==3
replace familiarity=	2.767676768	if item_num==	4	& study==3
replace familiarity=	2.897959184	if item_num==	5	& study==3
replace familiarity=	2.848484848	if item_num==	6	& study==3
replace familiarity=	2.919191919	if item_num==	7	& study==3
replace familiarity=	2.828282828	if item_num==	8	& study==3
replace familiarity=	2.887755102	if item_num==	9	& study==3
replace familiarity=	2.484848485	if item_num==	10	& study==3
replace familiarity=	2.616161616	if item_num==	11	& study==3
replace familiarity=	2.581632653	if item_num==	12	& study==3
				
				
replace politic = 	4.05	if item_num==	1	& study==4
replace politic = 	4.36	if item_num==	2	& study==4
replace politic = 	3.92	if item_num==	3	& study==4
replace politic = 	4.25	if item_num==	4	& study==4
replace politic = 	3.73	if item_num==	5	& study==4
replace politic = 	3.99	if item_num==	6	& study==4
replace politic = 	1.91	if item_num==	7	& study==4
replace politic = 	2.15	if item_num==	8	& study==4
replace politic = 	1.8	if item_num==	9	& study==4
replace politic = 	1.67	if item_num==	10	& study==4
replace politic = 	2.08	if item_num==	11	& study==4
replace politic = 	2.22	if item_num==	12	& study==4
replace politic = 	4.11	if item_num==	13	& study==4
replace politic = 	4.1	if item_num==	14	& study==4
replace politic = 	4.14	if item_num==	15	& study==4
replace politic = 	3.76	if item_num==	16	& study==4
replace politic = 	4.15	if item_num==	17	& study==4
replace politic = 	3.98	if item_num==	18	& study==4
replace politic = 	1.88	if item_num==	19	& study==4
replace politic = 	1.92	if item_num==	20	& study==4
replace politic = 	1.93	if item_num==	21	& study==4
replace politic = 	1.95	if item_num==	22	& study==4
replace politic = 	2.07	if item_num==	23	& study==4
replace politic = 	2.02	if item_num==	24	& study==4
replace likelihood = 	1.61	if item_num==	1	& study==4
replace likelihood = 	3.06	if item_num==	2	& study==4
replace likelihood = 	2.25	if item_num==	3	& study==4
replace likelihood = 	3.68	if item_num==	4	& study==4
replace likelihood = 	2.7	if item_num==	5	& study==4
replace likelihood = 	3.65	if item_num==	6	& study==4
replace likelihood = 	3.29	if item_num==	7	& study==4
replace likelihood = 	2.72	if item_num==	8	& study==4
replace likelihood = 	2.68	if item_num==	9	& study==4
replace likelihood = 	4.37	if item_num==	10	& study==4
replace likelihood = 	2.67	if item_num==	11	& study==4
replace likelihood = 	2.28	if item_num==	12	& study==4
replace likelihood = 	4.41	if item_num==	13	& study==4
replace likelihood = 	4.46	if item_num==	14	& study==4
replace likelihood = 	4.29	if item_num==	15	& study==4
replace likelihood = 	5.07	if item_num==	16	& study==4
replace likelihood = 	5.07	if item_num==	17	& study==4
replace likelihood = 	5.18	if item_num==	18	& study==4
replace likelihood = 	5.18	if item_num==	19	& study==4
replace likelihood = 	5.24	if item_num==	20	& study==4
replace likelihood = 	5.16	if item_num==	21	& study==4
replace likelihood = 	3.63	if item_num==	22	& study==4
replace likelihood = 	4.98	if item_num==	23	& study==4
replace likelihood = 	4.66	if item_num==	24	& study==4
replace familiarity=	2.89	if item_num==	1	& study==4
replace familiarity=	2.76	if item_num==	2	& study==4
replace familiarity=	2.94	if item_num==	3	& study==4
replace familiarity=	2.86	if item_num==	4	& study==4
replace familiarity=	2.9	if item_num==	5	& study==4
replace familiarity=	2.64	if item_num==	6	& study==4
replace familiarity=	2.83	if item_num==	7	& study==4
replace familiarity=	2.93	if item_num==	8	& study==4
replace familiarity=	2.86	if item_num==	9	& study==4
replace familiarity=	2.85	if item_num==	10	& study==4
replace familiarity=	2.89	if item_num==	11	& study==4
replace familiarity=	2.93	if item_num==	12	& study==4
replace familiarity=	2.87	if item_num==	13	& study==4
replace familiarity=	2.78	if item_num==	14	& study==4
replace familiarity=	2.83	if item_num==	15	& study==4
replace familiarity=	2.64	if item_num==	16	& study==4
replace familiarity=	2.19	if item_num==	17	& study==4
replace familiarity=	2.26	if item_num==	18	& study==4
replace familiarity=	2.79	if item_num==	19	& study==4
replace familiarity=	2.41	if item_num==	20	& study==4
replace familiarity=	2.65	if item_num==	21	& study==4
replace familiarity=	2.75	if item_num==	22	& study==4
replace familiarity=	2.56	if item_num==	23	& study==4
replace familiarity=	2.66	if item_num==	24	& study==4
gen funny=.				
replace funny=	1.86	if item_num==	1	& study==4
replace funny=	1.98	if item_num==	2	& study==4
replace funny=	2.13	if item_num==	3	& study==4
replace funny=	2.76	if item_num==	4	& study==4
replace funny=	2.83	if item_num==	5	& study==4
replace funny=	2.68	if item_num==	6	& study==4
replace funny=	2.28	if item_num==	7	& study==4
replace funny=	1.99	if item_num==	8	& study==4
replace funny=	2.14	if item_num==	9	& study==4
replace funny=	2.37	if item_num==	10	& study==4
replace funny=	3.55	if item_num==	11	& study==4
replace funny=	4.77	if item_num==	12	& study==4
replace funny=	3.82	if item_num==	13	& study==4
replace funny=	3.36	if item_num==	14	& study==4
replace funny=	3.38	if item_num==	15	& study==4
replace funny=	2.86	if item_num==	16	& study==4
replace funny=	3.28	if item_num==	17	& study==4
replace funny=	3.07	if item_num==	18	& study==4
replace funny=	2.71	if item_num==	19	& study==4
replace funny=	2.9	if item_num==	20	& study==4
replace funny=	3.11	if item_num==	21	& study==4
replace funny=	3.22	if item_num==	22	& study==4
replace funny=	2.79	if item_num==	23	& study==4
replace funny=	2.83	if item_num==	24	& study==4



gen funnyDR=.
replace funnyDR=2.71910112359551 if demrep==1 & item_num==1 & study==4
replace funnyDR=1.56179775280899 if demrep==1 & item_num==2 & study==4
replace funnyDR=2 if demrep==1 & item_num==3 & study==4
replace funnyDR=2.55056179775281 if demrep==1 & item_num==4 & study==4
replace funnyDR=1.87640449438202 if demrep==1 & item_num==5 & study==4
replace funnyDR=2.70786516853933 if demrep==1 & item_num==6 & study==4
replace funnyDR=3.71910112359551 if demrep==1 & item_num==7 & study==4
replace funnyDR=3.57954545454545 if demrep==1 & item_num==8 & study==4
replace funnyDR=3.71910112359551 if demrep==1 & item_num==9 & study==4
replace funnyDR=1.98876404494382 if demrep==1 & item_num==10 & study==4
replace funnyDR=2.04494382022472 if demrep==1 & item_num==11 & study==4
replace funnyDR=2.60674157303371 if demrep==1 & item_num==12 & study==4
replace funnyDR=2.65151515151515 if demrep==1 & item_num==13 & study==4
replace funnyDR=2.56060606060606 if demrep==1 & item_num==14 & study==4
replace funnyDR=3.06060606060606 if demrep==1 & item_num==15 & study==4
replace funnyDR=3.90909090909091 if demrep==1 & item_num==16 & study==4
replace funnyDR=3.3030303030303 if demrep==1 & item_num==17 & study==4
replace funnyDR=3.31818181818182 if demrep==1 & item_num==18 & study==4
replace funnyDR=2.54545454545454 if demrep==1 & item_num==19 & study==4
replace funnyDR=2.93939393939394 if demrep==1 & item_num==20 & study==4
replace funnyDR=2.93939393939394 if demrep==1 & item_num==21 & study==4
replace funnyDR=3.24242424242424 if demrep==1 & item_num==22 & study==4
replace funnyDR=2.8030303030303 if demrep==1 & item_num==23 & study==4
replace funnyDR=2.51515151515152 if demrep==1 & item_num==24 & study==4
replace funnyDR=3.04545454545454 if demrep==2 & item_num==1 & study==4
replace funnyDR=2.45454545454546 if demrep==2 & item_num==2 & study==4
replace funnyDR=2.38636363636364 if demrep==2 & item_num==3 & study==4
replace funnyDR=3.18181818181818 if demrep==2 & item_num==4 & study==4
replace funnyDR=2.2093023255814 if demrep==2 & item_num==5 & study==4
replace funnyDR=3.72727272727273 if demrep==2 & item_num==6 & study==4
replace funnyDR=2.86046511627907 if demrep==2 & item_num==7 & study==4
replace funnyDR=3.59090909090909 if demrep==2 & item_num==8 & study==4
replace funnyDR=2.97727272727273 if demrep==2 & item_num==9 & study==4
replace funnyDR=2.43181818181818 if demrep==2 & item_num==10 & study==4
replace funnyDR=2.76744186046512 if demrep==2 & item_num==11 & study==4
replace funnyDR=2.59090909090909 if demrep==2 & item_num==12 & study==4
replace funnyDR=3.11428571428571 if demrep==2 & item_num==13 & study==4
replace funnyDR=3.14285714285714 if demrep==2 & item_num==14 & study==4
replace funnyDR=3.08695652173913 if demrep==2 & item_num==15 & study==4
replace funnyDR=3.72857142857143 if demrep==2 & item_num==16 & study==4
replace funnyDR=3.41428571428571 if demrep==2 & item_num==17 & study==4
replace funnyDR=3.24285714285714 if demrep==2 & item_num==18 & study==4
replace funnyDR=2.9 if demrep==2 & item_num==19 & study==4
replace funnyDR=2.85714285714286 if demrep==2 & item_num==20 & study==4
replace funnyDR=3.27142857142857 if demrep==2 & item_num==21 & study==4
replace funnyDR=3.20289855072464 if demrep==2 & item_num==22 & study==4
replace funnyDR=2.77142857142857 if demrep==2 & item_num==23 & study==4
replace funnyDR=2.9 if demrep==2 & item_num==24 & study==4

gen plausible=-99

gen plausibleDR=.
replace plausibleDR=1.97752808988764 if demrep==1 & item_num==1 & study==4
replace plausibleDR=1.51685393258427 if demrep==1 & item_num==2 & study==4
replace plausibleDR=2.44943820224719 if demrep==1 & item_num==3 & study==4
replace plausibleDR=3.57303370786517 if demrep==1 & item_num==4 & study==4
replace plausibleDR=3.07865168539326 if demrep==1 & item_num==5 & study==4
replace plausibleDR=1.49438202247191 if demrep==1 & item_num==6 & study==4
replace plausibleDR=1.59550561797753 if demrep==1 & item_num==7 & study==4
replace plausibleDR=1.94318181818182 if demrep==1 & item_num==8 & study==4
replace plausibleDR=2.34090909090909 if demrep==1 & item_num==9 & study==4
replace plausibleDR=3.59090909090909 if demrep==1 & item_num==10 & study==4
replace plausibleDR=3.74157303370787 if demrep==1 & item_num==11 & study==4
replace plausibleDR=2.66292134831461 if demrep==1 & item_num==12 & study==4
replace plausibleDR=5.57575757575758 if demrep==1 & item_num==13 & study==4
replace plausibleDR=5.40909090909091 if demrep==1 & item_num==14 & study==4
replace plausibleDR=5.33846153846154 if demrep==1 & item_num==15 & study==4
replace plausibleDR=4.6969696969697 if demrep==1 & item_num==16 & study==4
replace plausibleDR=4.33333333333333 if demrep==1 & item_num==17 & study==4
replace plausibleDR=4.59090909090909 if demrep==1 & item_num==18 & study==4
replace plausibleDR=5.5 if demrep==1 & item_num==19 & study==4
replace plausibleDR=5.63636363636364 if demrep==1 & item_num==20 & study==4
replace plausibleDR=5.78461538461538 if demrep==1 & item_num==21 & study==4
replace plausibleDR=4.72727272727273 if demrep==1 & item_num==22 & study==4
replace plausibleDR=5.25757575757576 if demrep==1 & item_num==23 & study==4
replace plausibleDR=5.16923076923077 if demrep==1 & item_num==24 & study==4
replace plausibleDR=2.76744186046512 if demrep==2 & item_num==1 & study==4
replace plausibleDR=1.52272727272727 if demrep==2 & item_num==2 & study==4
replace plausibleDR=2.52272727272727 if demrep==2 & item_num==3 & study==4
replace plausibleDR=3.6046511627907 if demrep==2 & item_num==4 & study==4
replace plausibleDR=3.61363636363636 if demrep==2 & item_num==5 & study==4
replace plausibleDR=2.02272727272727 if demrep==2 & item_num==6 & study==4
replace plausibleDR=1.45454545454545 if demrep==2 & item_num==7 & study==4
replace plausibleDR=1.70454545454545 if demrep==2 & item_num==8 & study==4
replace plausibleDR=1.45454545454545 if demrep==2 & item_num==9 & study==4
replace plausibleDR=2.27272727272727 if demrep==2 & item_num==10 & study==4
replace plausibleDR=2.52272727272727 if demrep==2 & item_num==11 & study==4
replace plausibleDR=2 if demrep==2 & item_num==12 & study==4
replace plausibleDR=5.6231884057971 if demrep==2 & item_num==13 & study==4
replace plausibleDR=4.98571428571429 if demrep==2 & item_num==14 & study==4
replace plausibleDR=5.71428571428572 if demrep==2 & item_num==15 & study==4
replace plausibleDR=4.88571428571429 if demrep==2 & item_num==16 & study==4
replace plausibleDR=4.91428571428571 if demrep==2 & item_num==17 & study==4
replace plausibleDR=6.04285714285714 if demrep==2 & item_num==18 & study==4
replace plausibleDR=4.92857142857143 if demrep==2 & item_num==19 & study==4
replace plausibleDR=5.34285714285714 if demrep==2 & item_num==20 & study==4
replace plausibleDR=4.5 if demrep==2 & item_num==21 & study==4
replace plausibleDR=3.3768115942029 if demrep==2 & item_num==22 & study==4
replace plausibleDR=4.8 if demrep==2 & item_num==23 & study==4
replace plausibleDR=4.78571428571429 if demrep==2 & item_num==24 & study==4

gen concordant=-99

gen concordantDR=.
replace concordantDR=2.26966292134831 if demrep==1 & item_num==1 & study==4
replace concordantDR=1.90909090909091 if demrep==1 & item_num==2 & study==4
replace concordantDR=1.77528089887641 if demrep==1 & item_num==3 & study==4
replace concordantDR=1.84090909090909 if demrep==1 & item_num==4 & study==4
replace concordantDR=1.67045454545455 if demrep==1 & item_num==5 & study==4
replace concordantDR=1.55056179775281 if demrep==1 & item_num==6 & study==4
replace concordantDR=4.34090909090909 if demrep==1 & item_num==7 & study==4
replace concordantDR=4.20224719101124 if demrep==1 & item_num==8 & study==4
replace concordantDR=3.97752808988764 if demrep==1 & item_num==9 & study==4
replace concordantDR=4.02247191011236 if demrep==1 & item_num==10 & study==4
replace concordantDR=3.9438202247191 if demrep==1 & item_num==11 & study==4
replace concordantDR=3.79775280898876 if demrep==1 & item_num==12 & study==4
replace concordantDR=2.75757575757576 if demrep==1 & item_num==13 & study==4
replace concordantDR=2.13636363636364 if demrep==1 & item_num==14 & study==4
replace concordantDR=2 if demrep==1 & item_num==15 & study==4
replace concordantDR=1.78787878787879 if demrep==1 & item_num==16 & study==4
replace concordantDR=1.68181818181818 if demrep==1 & item_num==17 & study==4
replace concordantDR=1.6969696969697 if demrep==1 & item_num==18 & study==4
replace concordantDR=4.07575757575758 if demrep==1 & item_num==19 & study==4
replace concordantDR=4.22727272727273 if demrep==1 & item_num==20 & study==4
replace concordantDR=4.16923076923077 if demrep==1 & item_num==21 & study==4
replace concordantDR=4.06060606060606 if demrep==1 & item_num==22 & study==4
replace concordantDR=3.92424242424242 if demrep==1 & item_num==23 & study==4
replace concordantDR=3.92424242424242 if demrep==1 & item_num==24 & study==4
replace concordantDR=3.52272727272727 if demrep==2 & item_num==1 & study==4
replace concordantDR=3.88636363636364 if demrep==2 & item_num==2 & study==4
replace concordantDR=3.68181818181818 if demrep==2 & item_num==3 & study==4
replace concordantDR=3.81818181818182 if demrep==2 & item_num==4 & study==4
replace concordantDR=4.15909090909091 if demrep==2 & item_num==5 & study==4
replace concordantDR=3.97727272727273 if demrep==2 & item_num==6 & study==4
replace concordantDR=1.65909090909091 if demrep==2 & item_num==7 & study==4
replace concordantDR=1.65909090909091 if demrep==2 & item_num==8 & study==4
replace concordantDR=1.88636363636364 if demrep==2 & item_num==9 & study==4
replace concordantDR=2.15909090909091 if demrep==2 & item_num==10 & study==4
replace concordantDR=2.20930232558139 if demrep==2 & item_num==11 & study==4
replace concordantDR=2 if demrep==2 & item_num==12 & study==4
replace concordantDR=3.57142857142857 if demrep==2 & item_num==13 & study==4
replace concordantDR=3.68571428571429 if demrep==2 & item_num==14 & study==4
replace concordantDR=3.9 if demrep==2 & item_num==15 & study==4
replace concordantDR=4.1 if demrep==2 & item_num==16 & study==4
replace concordantDR=4.05714285714286 if demrep==2 & item_num==17 & study==4
replace concordantDR=4.34285714285714 if demrep==2 & item_num==18 & study==4
replace concordantDR=1.87142857142857 if demrep==2 & item_num==19 & study==4
replace concordantDR=2.01428571428572 if demrep==2 & item_num==20 & study==4
replace concordantDR=2.05797101449275 if demrep==2 & item_num==21 & study==4
replace concordantDR=1.98571428571429 if demrep==2 & item_num==22 & study==4
replace concordantDR=2.04285714285714 if demrep==2 & item_num==23 & study==4
replace concordantDR=2.21428571428571 if demrep==2 & item_num==24 & study==4

gen familiar=-99

gen familiarDR=.
replace familiarDR=0.897727272727272 if demrep==1 & item_num==1 & study==4
replace familiarDR=0.921348314606741 if demrep==1 & item_num==2 & study==4
replace familiarDR=0.898876404494382 if demrep==1 & item_num==3 & study==4
replace familiarDR=0.820224719101124 if demrep==1 & item_num==4 & study==4
replace familiarDR=0.842696629213483 if demrep==1 & item_num==5 & study==4
replace familiarDR=0.98876404494382 if demrep==1 & item_num==6 & study==4
replace familiarDR=0.943181818181818 if demrep==1 & item_num==7 & study==4
replace familiarDR=0.943820224719101 if demrep==1 & item_num==8 & study==4
replace familiarDR=0.955056179775281 if demrep==1 & item_num==9 & study==4
replace familiarDR=0.853932584269663 if demrep==1 & item_num==10 & study==4
replace familiarDR=0.786516853932584 if demrep==1 & item_num==11 & study==4
replace familiarDR=0.943820224719101 if demrep==1 & item_num==12 & study==4
replace familiarDR=0.666666666666667 if demrep==1 & item_num==13 & study==4
replace familiarDR=0.646153846153846 if demrep==1 & item_num==14 & study==4
replace familiarDR=0.409090909090909 if demrep==1 & item_num==15 & study==4
replace familiarDR=0.742424242424242 if demrep==1 & item_num==16 & study==4
replace familiarDR=0.924242424242424 if demrep==1 & item_num==17 & study==4
replace familiarDR=0.545454545454545 if demrep==1 & item_num==18 & study==4
replace familiarDR=0.409090909090909 if demrep==1 & item_num==19 & study==4
replace familiarDR=0.484848484848485 if demrep==1 & item_num==20 & study==4
replace familiarDR=0.553846153846154 if demrep==1 & item_num==21 & study==4
replace familiarDR=0.727272727272727 if demrep==1 & item_num==22 & study==4
replace familiarDR=0.569230769230769 if demrep==1 & item_num==23 & study==4
replace familiarDR=0.712121212121212 if demrep==1 & item_num==24 & study==4
replace familiarDR=0.840909090909091 if demrep==2 & item_num==1 & study==4
replace familiarDR=0.931818181818181 if demrep==2 & item_num==2 & study==4
replace familiarDR=0.909090909090909 if demrep==2 & item_num==3 & study==4
replace familiarDR=0.818181818181818 if demrep==2 & item_num==4 & study==4
replace familiarDR=0.720930232558139 if demrep==2 & item_num==5 & study==4
replace familiarDR=0.840909090909091 if demrep==2 & item_num==6 & study==4
replace familiarDR=0.863636363636364 if demrep==2 & item_num==7 & study==4
replace familiarDR=0.863636363636364 if demrep==2 & item_num==8 & study==4
replace familiarDR=0.886363636363636 if demrep==2 & item_num==9 & study==4
replace familiarDR=0.840909090909091 if demrep==2 & item_num==10 & study==4
replace familiarDR=0.837209302325581 if demrep==2 & item_num==11 & study==4
replace familiarDR=0.886363636363636 if demrep==2 & item_num==12 & study==4
replace familiarDR=0.514285714285714 if demrep==2 & item_num==13 & study==4
replace familiarDR=0.671428571428572 if demrep==2 & item_num==14 & study==4
replace familiarDR=0.371428571428571 if demrep==2 & item_num==15 & study==4
replace familiarDR=0.785714285714286 if demrep==2 & item_num==16 & study==4
replace familiarDR=0.642857142857143 if demrep==2 & item_num==17 & study==4
replace familiarDR=0.428571428571429 if demrep==2 & item_num==18 & study==4
replace familiarDR=0.442857142857143 if demrep==2 & item_num==19 & study==4
replace familiarDR=0.485714285714286 if demrep==2 & item_num==20 & study==4
replace familiarDR=0.742857142857143 if demrep==2 & item_num==21 & study==4
replace familiarDR=0.826086956521739 if demrep==2 & item_num==22 & study==4
replace familiarDR=0.714285714285714 if demrep==2 & item_num==23 & study==4
replace familiarDR=0.742857142857143 if demrep==2 & item_num==24 & study==4


replace item_num=item_num+24 if study==3

gen concordance =  politic
replace concordance =  6-politic if demrep==1
gen novelty = 6 - familiarity
///////////////////////////





///////////////////////
// ITEM LEVEL ANALYSIS - FIGURE 3a,b
preserve
keep if socialmedia_chk==1
collapse (mean) sm likelihood study, by(item_num condition)
reshape wide sm, i(item_num) j(condition)
gen treatmentEffect=sm1-sm0
scatter treatmentEffect likelihood if study==3, name(s3)
scatter treatmentEffect likelihood if study==4, name(s4)
bysort study: pwcorr treatmentEffect likelihood, sig
restore
//////////////




//////
// EXPORT DATA FOR UTILITY MODEL FITTING IN MATLAB 
preserve
keep if socialmedia_chk==1
keep if study ==4
drop if demrep==.
egen tmp=count(sm), by(id)
drop if tmp<24
drop tmp
replace condition=(condition*2)+1
table condition
keep real id item_num condition sm demrep funny funnyDR plausible plausibleDR familiarity familiarDR concordance concordantDR
 export delimited using "dataS4_for_matlab_fit_bootstrap_long.csv", nolabel replace
 restore
///////////////////////
clear *
insheet using "Study_5_data.csv", clear
destring *, replace
gen id=_n
gen didnt_finish=socialmedia_chk==.
rename gender sex

///////////////
// DESCRIPTIVES
sum id
table didnt_finish fb 
drop if didnt_finish==1 | fb==2
sum id age 
table sex
sum id if sex==.

table socialmedia_chk 
sum id age if socialmedia_chk ==1
table sex if socialmedia_chk ==1
sum id if sex==. & socialmedia_chk ==1
/////////////////

// create binary dem/rep variable out of 6-point scale
gen demrep=1+(demrep_c>3)
replace demrep=. if demrep_c==.

// no treatment differences in socialmedia chk (the item indicating whether they ever share political content)
gen socialmedia_chk1 = socialmedia_chk==1
replace socialmedia_chk1=. if socialmedia_chk==.
tabulate socialmedia_chk1 condition, chi2 


// reshape data long
rename fake*_3 fake_sm*
rename real*_3 real_sm*
reshape long fake_sm real_sm  , i(id) j(item_num)
gen prorep=item_num<=5
gen politically_concordant = (prorep==1 & demrep==2) | (prorep==0 & demrep==1)
rename fake_sm sm1
rename real_sm sm2
gen uniqueI = id*1000+item_num
reshape long sm  , i(unique) j(real)
replace real=real-1
replace sm=(sm-1)/5
replace item_num=item_num+(real)*10				

// create binary "likely to share" variable for plots
gen Bsm=round(sm)


label define bla1x 1 "Passive Control" 2 "Active Control" 3 "Treatment" 4 "Importance Treatment"
label values condition bla1x

label define bla2x 0 "Fake" 1 "Real"
label values real bla2x

label define bla5x 1 "Democrat" 2 "Republican"
label values demrep bla5x


// treatment dummies
gen treatment=condition==3
gen importance=condition==4



////////////////////
// Visualization

// for Figure 2c
xi: bysort condition real: cluster2 Bsm if socialmedia_chk==1, tcluster(id) fcluster(item_num)

// for Extended Data Figure 3
tabulate sm condition if real==0 & socialmedia_chk==1
tabulate sm condition if real==1 & socialmedia_chk==1
/////////////////////


////////////////
// ANALYSIS - Table S4

// passive v active control - main analysis (only subjects who sometimes share political news)
xi: cluster2 sm i.condition*real if condition<3 & socialmedia_chk==1, tcluster(id) fcluster(item_num)

// treatments v pooled control - main analysis (only subjects who sometimes share political news)
xi: cluster2 sm i.treatment*real i.importance*real if socialmedia_chk==1, tcluster(id) fcluster(item_num)
//          simple effects
test real=0 // simple effect of real in control
disp _b[real]
test real+_ItreXreal_1 =0 // simple effect of real in treatment 
disp _b[real]+_b[_ItreXreal_1]
test _Itreatment_1=0 // simple effect of treatment  for false
disp _b[_Itreatment_1]
test _Itreatment_1+_ItreXreal_1 =0 // simple effect of treatment  for real
disp _b[_Itreatment_1]+_b[_ItreXreal_1]
test _ItreXreal_1=0
test real+_IimpXreal_1=0 // simple effect of real in importance treatment
disp _b[real]+_b[_IimpXreal_1]
test _Iimportanc_1=0 // simple effect of importance treatment for false
disp _b[_Iimportanc_1]
test _Iimportanc_1+_IimpXreal_1 =0 // simple effect of importance treatment for real
disp _b[_Iimportanc_1]+_b[_IimpXreal_1]
test _IimpXreal_1=0

// passive v active control - all subjects
xi: cluster2 sm i.condition*real if condition<3 , tcluster(id) fcluster(item_num)

// treatments v pooled control - all subjects
xi: cluster2 sm i.treatment*real i.importance*real , tcluster(id) fcluster(item_num)
//          simple effects
test real=0 // simple effect of real in control
disp _b[real]
test real+_ItreXreal_1 =0 // simple effect of real in treatment 
disp _b[real]+_b[_ItreXreal_1]
test _Itreatment_1=0 // simple effect of treatment  for false
disp _b[_Itreatment_1]
test _Itreatment_1+_ItreXreal_1 =0 // simple effect of treatment  for real
disp _b[_Itreatment_1]+_b[_ItreXreal_1]
test _ItreXreal_1=0
test real+_IimpXreal_1=0 // simple effect of real in importance treatment
disp _b[real]+_b[_IimpXreal_1]
test _Iimportanc_1=0 // simple effect of importance treatment for false
disp _b[_Iimportanc_1]
test _Iimportanc_1+_IimpXreal_1 =0 // simple effect of importance treatment for real
disp _b[_Iimportanc_1]+_b[_IimpXreal_1]
test _IimpXreal_1=0
 

////////////////////////// 
 
 
 
 
 
 
 
 
 
 
 
 




/////////////////////
// define pre-test ratings for each headline

drop funny

// load in pre-test data
gen funny=.
replace funny=2.790909 if item_num==1
replace funny=2.941748 if item_num==2
replace funny=2.849558 if item_num==3
replace funny=2.268519 if item_num==4
replace funny=3.823009 if item_num==5
replace funny=3.954955 if item_num==6
replace funny=3.564815 if item_num==7
replace funny=3.103774 if item_num==8
replace funny=4.160377 if item_num==9
replace funny=3.235294 if item_num==10
replace funny=2.61165 if item_num==11
replace funny=2.781818 if item_num==12
replace funny=3.311321 if item_num==13
replace funny=2.690909 if item_num==14
replace funny=3.46729 if item_num==15
replace funny=3.698113 if item_num==16
replace funny=2.90566 if item_num==17
replace funny=2.245283 if item_num==18
replace funny=2.839286 if item_num==19
replace funny=2.56 if item_num==20

gen funnyDR=.
replace funnyDR=2.68 if item_num==1 & demrep==1
replace funnyDR=2.771429 if item_num==2 & demrep==1
replace funnyDR=2.822785 if item_num==3 & demrep==1
replace funnyDR=2.191781 if item_num==4 & demrep==1
replace funnyDR=3.47561 if item_num==5 & demrep==1
replace funnyDR=3.8125 if item_num==6 & demrep==1
replace funnyDR=3.739726 if item_num==7 & demrep==1
replace funnyDR=3.239437 if item_num==8 & demrep==1
replace funnyDR=4.066667 if item_num==9 & demrep==1
replace funnyDR=3.442857 if item_num==10 & demrep==1
replace funnyDR=2.552632 if item_num==11 & demrep==1
replace funnyDR=2.820896 if item_num==12 & demrep==1
replace funnyDR=3.162162 if item_num==13 & demrep==1
replace funnyDR=2.540541 if item_num==14 & demrep==1
replace funnyDR=3.447368 if item_num==15 & demrep==1
replace funnyDR=3.768116 if item_num==16 & demrep==1
replace funnyDR=2.944444 if item_num==17 & demrep==1
replace funnyDR=2.078947 if item_num==18 & demrep==1
replace funnyDR=2.972603 if item_num==19 & demrep==1
replace funnyDR=2.542857 if item_num==20 & demrep==1
replace funnyDR=3.028571 if item_num==1 & demrep==2
replace funnyDR=3.30303 if item_num==2 & demrep==2
replace funnyDR=2.911765 if item_num==3 & demrep==2
replace funnyDR=2.428571 if item_num==4 & demrep==2
replace funnyDR=4.741935 if item_num==5 & demrep==2
replace funnyDR=4.322581 if item_num==6 & demrep==2
replace funnyDR=3.2 if item_num==7 & demrep==2
replace funnyDR=2.828571 if item_num==8 & demrep==2
replace funnyDR=4.387097 if item_num==9 & demrep==2
replace funnyDR=2.78125 if item_num==10 & demrep==2
replace funnyDR=2.777778 if item_num==11 & demrep==2
replace funnyDR=2.72093 if item_num==12 & demrep==2
replace funnyDR=3.65625 if item_num==13 & demrep==2
replace funnyDR=3 if item_num==14 & demrep==2
replace funnyDR=3.516129 if item_num==15 & demrep==2
replace funnyDR=3.567568 if item_num==16 & demrep==2
replace funnyDR=2.823529 if item_num==17 & demrep==2
replace funnyDR=2.666667 if item_num==18 & demrep==2
replace funnyDR=2.589744 if item_num==19 & demrep==2
replace funnyDR=2.6 if item_num==20 & demrep==2


gen plausible=.
replace plausible=2.372727 if item_num==1
replace plausible=2.271845 if item_num==2
replace plausible=1.646018 if item_num==3
replace plausible=2.046296 if item_num==4
replace plausible=2.20354 if item_num==5
replace plausible=1.603604 if item_num==6
replace plausible=2.268519 if item_num==7
replace plausible=2.09434 if item_num==8
replace plausible=2.084906 if item_num==9
replace plausible=3.588235 if item_num==10
replace plausible=4.902913 if item_num==11
replace plausible=4.872727 if item_num==12
replace plausible=5.377358 if item_num==13
replace plausible=5.8 if item_num==14
replace plausible=4.682243 if item_num==15
replace plausible=4.962264 if item_num==16
replace plausible=4.528302 if item_num==17
replace plausible=5.377358 if item_num==18
replace plausible=5.044643 if item_num==19
replace plausible=5.44 if item_num==20

gen plausibleDR=.
replace plausibleDR=2.133333 if item_num==1 & demrep==1
replace plausibleDR=1.771429 if item_num==2 & demrep==1
replace plausibleDR=1.56962 if item_num==3 & demrep==1
replace plausibleDR=1.684932 if item_num==4 & demrep==1
replace plausibleDR=2.195122 if item_num==5 & demrep==1
replace plausibleDR=1.7875 if item_num==6 & demrep==1
replace plausibleDR=2.315068 if item_num==7 & demrep==1
replace plausibleDR=2.28169 if item_num==8 & demrep==1
replace plausibleDR=2.266667 if item_num==9 & demrep==1
replace plausibleDR=3.9 if item_num==10 & demrep==1
replace plausibleDR=4.894737 if item_num==11 & demrep==1
replace plausibleDR=4.716418 if item_num==12 & demrep==1
replace plausibleDR=5.27027 if item_num==13 & demrep==1
replace plausibleDR=5.756757 if item_num==14 & demrep==1
replace plausibleDR=4.394737 if item_num==15 & demrep==1
replace plausibleDR=5.333333 if item_num==16 & demrep==1
replace plausibleDR=4.972222 if item_num==17 & demrep==1
replace plausibleDR=5.5 if item_num==18 & demrep==1
replace plausibleDR=5.452055 if item_num==19 & demrep==1
replace plausibleDR=5.671429 if item_num==20 & demrep==1
replace plausibleDR=2.885714 if item_num==1 & demrep==2
replace plausibleDR=3.333333 if item_num==2 & demrep==2
replace plausibleDR=1.823529 if item_num==3 & demrep==2
replace plausibleDR=2.8 if item_num==4 & demrep==2
replace plausibleDR=2.225806 if item_num==5 & demrep==2
replace plausibleDR=1.129032 if item_num==6 & demrep==2
replace plausibleDR=2.171429 if item_num==7 & demrep==2
replace plausibleDR=1.714286 if item_num==8 & demrep==2
replace plausibleDR=1.645161 if item_num==9 & demrep==2
replace plausibleDR=2.90625 if item_num==10 & demrep==2
replace plausibleDR=4.925926 if item_num==11 & demrep==2
replace plausibleDR=5.116279 if item_num==12 & demrep==2
replace plausibleDR=5.625 if item_num==13 & demrep==2
replace plausibleDR=5.888889 if item_num==14 & demrep==2
replace plausibleDR=5.387097 if item_num==15 & demrep==2
replace plausibleDR=4.27027 if item_num==16 & demrep==2
replace plausibleDR=3.588235 if item_num==17 & demrep==2
replace plausibleDR=5.066667 if item_num==18 & demrep==2
replace plausibleDR=4.282051 if item_num==19 & demrep==2
replace plausibleDR=4.9 if item_num==20 & demrep==2


gen goodrep=.
replace goodrep=4.081818 if item_num==1
replace goodrep=4.067961 if item_num==2
replace goodrep=4.19469 if item_num==3
replace goodrep=4.222222 if item_num==4
replace goodrep=3.99115 if item_num==5
replace goodrep=1.711712 if item_num==6
replace goodrep=1.722222 if item_num==7
replace goodrep=2.226415 if item_num==8
replace goodrep=1.933962 if item_num==9
replace goodrep=1.813725 if item_num==10
replace goodrep=3.951456 if item_num==11
replace goodrep=3.754545 if item_num==12
replace goodrep=3.754717 if item_num==13
replace goodrep=4.063636 if item_num==14
replace goodrep=3.831776 if item_num==15
replace goodrep=2.09434 if item_num==16
replace goodrep=1.858491 if item_num==17
replace goodrep=2.113208 if item_num==18
replace goodrep=2.017857 if item_num==19
replace goodrep=2.15 if item_num==20

gen goodrepDR=.
replace goodrepDR=4 if item_num==1 & demrep==1
replace goodrepDR=4.142857 if item_num==2 & demrep==1
replace goodrepDR=4.265823 if item_num==3 & demrep==1
replace goodrepDR=4.30137 if item_num==4 & demrep==1
replace goodrepDR=3.914634 if item_num==5 & demrep==1
replace goodrepDR=1.7 if item_num==6 & demrep==1
replace goodrepDR=1.780822 if item_num==7 & demrep==1
replace goodrepDR=2.267606 if item_num==8 & demrep==1
replace goodrepDR=2.04 if item_num==9 & demrep==1
replace goodrepDR=1.857143 if item_num==10 & demrep==1
replace goodrepDR=3.947368 if item_num==11 & demrep==1
replace goodrepDR=3.641791 if item_num==12 & demrep==1
replace goodrepDR=3.635135 if item_num==13 & demrep==1
replace goodrepDR=4.013514 if item_num==14 & demrep==1
replace goodrepDR=3.723684 if item_num==15 & demrep==1
replace goodrepDR=2.028986 if item_num==16 & demrep==1
replace goodrepDR=1.847222 if item_num==17 & demrep==1
replace goodrepDR=1.947368 if item_num==18 & demrep==1
replace goodrepDR=2.013699 if item_num==19 & demrep==1
replace goodrepDR=2.1 if item_num==20 & demrep==1
replace goodrepDR=4.257143 if item_num==1 & demrep==2
replace goodrepDR=3.909091 if item_num==2 & demrep==2
replace goodrepDR=4.029412 if item_num==3 & demrep==2
replace goodrepDR=4.057143 if item_num==4 & demrep==2
replace goodrepDR=4.193548 if item_num==5 & demrep==2
replace goodrepDR=1.741935 if item_num==6 & demrep==2
replace goodrepDR=1.6 if item_num==7 & demrep==2
replace goodrepDR=2.142857 if item_num==8 & demrep==2
replace goodrepDR=1.677419 if item_num==9 & demrep==2
replace goodrepDR=1.71875 if item_num==10 & demrep==2
replace goodrepDR=3.962963 if item_num==11 & demrep==2
replace goodrepDR=3.930233 if item_num==12 & demrep==2
replace goodrepDR=4.03125 if item_num==13 & demrep==2
replace goodrepDR=4.166667 if item_num==14 & demrep==2
replace goodrepDR=4.096774 if item_num==15 & demrep==2
replace goodrepDR=2.216216 if item_num==16 & demrep==2
replace goodrepDR=1.882353 if item_num==17 & demrep==2
replace goodrepDR=2.533333 if item_num==18 & demrep==2
replace goodrepDR=2.025641 if item_num==19 & demrep==2
replace goodrepDR=2.266667 if item_num==20 & demrep==2


gen familiar=.
replace familiar=2.890909 if item_num==1
replace familiar=2.834951 if item_num==2
replace familiar=2.955752 if item_num==3
replace familiar=2.851852 if item_num==4
replace familiar=2.840708 if item_num==5
replace familiar=2.936937 if item_num==6
replace familiar=2.87037 if item_num==7
replace familiar=2.801887 if item_num==8
replace familiar=2.820755 if item_num==9
replace familiar=2.882353 if item_num==10
replace familiar=2.873786 if item_num==11
replace familiar=2.8 if item_num==12
replace familiar=2.320755 if item_num==13
replace familiar=2.263636 if item_num==14
replace familiar=2.663551 if item_num==15
replace familiar=2.509434 if item_num==16
replace familiar=2.698113 if item_num==17
replace familiar=2.584906 if item_num==18
replace familiar=2.6875 if item_num==19
replace familiar=2.46 if item_num==20

gen familiarDR=.
replace familiarDR=2.88 if item_num==1 & demrep==1
replace familiarDR=2.842857 if item_num==2 & demrep==1
replace familiarDR=2.974684 if item_num==3 & demrep==1
replace familiarDR=2.876712 if item_num==4 & demrep==1
replace familiarDR=2.829268 if item_num==5 & demrep==1
replace familiarDR=2.95 if item_num==6 & demrep==1
replace familiarDR=2.90411 if item_num==7 & demrep==1
replace familiarDR=2.830986 if item_num==8 & demrep==1
replace familiarDR=2.813333 if item_num==9 & demrep==1
replace familiarDR=2.914286 if item_num==10 & demrep==1
replace familiarDR=2.868421 if item_num==11 & demrep==1
replace familiarDR=2.910448 if item_num==12 & demrep==1
replace familiarDR=2.418919 if item_num==13 & demrep==1
replace familiarDR=2.297297 if item_num==14 & demrep==1
replace familiarDR=2.736842 if item_num==15 & demrep==1
replace familiarDR=2.434783 if item_num==16 & demrep==1
replace familiarDR=2.680556 if item_num==17 & demrep==1
replace familiarDR=2.592105 if item_num==18 & demrep==1
replace familiarDR=2.657534 if item_num==19 & demrep==1
replace familiarDR=2.442857 if item_num==20 & demrep==1
replace familiarDR=2.914286 if item_num==1 & demrep==2
replace familiarDR=2.818182 if item_num==2 & demrep==2
replace familiarDR=2.911765 if item_num==3 & demrep==2
replace familiarDR=2.8 if item_num==4 & demrep==2
replace familiarDR=2.870968 if item_num==5 & demrep==2
replace familiarDR=2.903226 if item_num==6 & demrep==2
replace familiarDR=2.8 if item_num==7 & demrep==2
replace familiarDR=2.742857 if item_num==8 & demrep==2
replace familiarDR=2.83871 if item_num==9 & demrep==2
replace familiarDR=2.8125 if item_num==10 & demrep==2
replace familiarDR=2.888889 if item_num==11 & demrep==2
replace familiarDR=2.627907 if item_num==12 & demrep==2
replace familiarDR=2.09375 if item_num==13 & demrep==2
replace familiarDR=2.194444 if item_num==14 & demrep==2
replace familiarDR=2.483871 if item_num==15 & demrep==2
replace familiarDR=2.648649 if item_num==16 & demrep==2
replace familiarDR=2.735294 if item_num==17 & demrep==2
replace familiarDR=2.566667 if item_num==18 & demrep==2
replace familiarDR=2.74359 if item_num==19 & demrep==2
replace familiarDR=2.5 if item_num==20 & demrep==2


gen concordant=goodrep*(demrep==2) + (6-goodrep)*(demrep==1)
gen concordantDR=goodrepDR*(demrep==2) + (6-goodrepDR)*(demrep==1)
///////////////





///////////////////////
// ITEM LEVEL ANALYSIS 
preserve
keep if socialmedia_chk==1
collapse (mean) sm funny plausible real, by(item_num condition)
reshape wide sm, i(item_num) j(condition)
gen EActive=sm2-sm1
gen ETreatment=sm3-sm1
gen EImportance=sm4-sm1

// Figure 3c
pwcorr ETreatment plausible, sig
scatter ETreatment plausible, name(fig3c)

// for extended data figure 4
pwcorr EActive ETreatment EImportance plausible funny, sig

restore
//////////////





//////
// CREATE DATA FOR MODEL FITTING IN MATLAB 
preserve
keep if socialmedia_chk==1
drop if demrep==.
egen tmp=count(sm), by(id)
drop if tmp<20
drop tmp
table condition
keep real id item_num condition sm demrep funny funnyDR plausible plausibleDR familiar familiarDR concordant concordantDR
 export delimited using "dataS5_for_matlab_fit_bootstrap_long.csv", nolabel replace
 restore

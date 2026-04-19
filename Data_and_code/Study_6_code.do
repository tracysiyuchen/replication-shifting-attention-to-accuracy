label drop _all
insheet using "Study_6_b2_data.csv", clear
destring *, replace
gen batch=2
save tmp, replace
insheet using "Study_6_b1_data.csv", clear
destring *, replace
gen batch=1
append using tmp


gen id=_n
gen didnt_finish=socialmedia_chk==.

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



// no treatment effect on socialmedia_chk (item indicating whether they ever share political news)
tabulate socialmedia_chk condition , chi2

// no treatment effect on importance of accuracy q
ttest accimp, by(condition)
ttest accimp if socialmedia_chk==1, by(condition)


//////////////////
// Reshape long
drop *rt*
drop *_sm
rename fake*_2 fake_acc*
rename real*_2 real_acc*
rename fake*_3 fake_sm*
rename real*_3 real_sm*
rename fake*_30 fakeC_sm*
rename real*_30 realC_sm*
reshape long fake_acc real_acc fake_sm real_sm  fakeC_sm realC_sm , i(id) j(item_num)
replace fake_sm = fakeC_sm if fake_sm==.
replace real_sm = realC_sm if real_sm==.
rename fake_sm sm1
rename real_sm sm2
rename fake_acc acc1
rename real_acc acc2
gen uniqueI = id*1000+item_num
reshape long sm acc , i(unique) j(real)

replace real=real-1
replace item_num=item_num+real*12
replace condition=condition-1

drop if sm==.
replace sm=(sm-1)/5
// make binary versions of sharing and accuracy rating
gen smB=sm>0.5
gen accB=acc>2
replace accB=. if acc==.


label define bla1x 0 "Control" 1 "Treatment"
label values condition bla1x

label define bla2x 0 "Fake" 1 "Real"
label values real bla2x

label define bla4x 1 "Clinton" 2 "Trump"
label values clintontr bla4x




//////////////////
// Pre-registered analysis (not reported in paper for brevity, but results are consistent with Studies 3-5)
gen conditionXreal =condition*real 
xi: cluster2 sm condition real conditionXreal if socialmedia_chk ==1 , tcluster(id) fcluster(item_num)
xi: cluster2 sm condition real conditionXreal , tcluster(id) fcluster(item_num)



////////////////////
// For Figure 3c
//    sharing in control:
tabulate smB real if socialmedia_chk ==1 & condition==0
//    sharing in treatment by accuracy rating
table accB smB real if socialmedia_chk ==1 & condition==1

//////////////////


clear *
insheet using "Study_1_data.csv", clear


///////////////
// SUMMARY STATS
sum id
gen noFBTwitter=(socialmedia_1==. & socialmedia_2==.)
gen noshare=sharingtype_1==.
table didnt_finish noFBTwitter noshare
table noFBTwitter noshare
drop if didnt_finish==1 
sum id
sum id age 
table sex
/////////////////






/////////////////////////////
// Extended data figure 1 - importance placed on accuracy
label define bla1x 0 "Accuracy" 1 "Sharing"
label values condition bla1x
histogram accimp, by(condition)
// does importance of only sharing accurate content differ by condition?
ttest accimp, by(condition)
//////////////////////////


////////////////////////////
// Reshape data into long format
// get all the ratings for a given item into the same column
forval j = 1/9 {
 replace fake`j'=fake`j'1 if fake`j'1~=.
 replace fake`j'=fake`j'2 if fake`j'2~=.
 replace fake`j'=fake`j'0 if fake`j'0~=.
 drop fake`j'0 fake`j'1 fake`j'2
 
 replace real`j'=real`j'1 if real`j'1~=.
 replace real`j'=real`j'2 if real`j'2~=.
 replace real`j'=real`j'0 if real`j'0~=.
 drop real`j'0 real`j'1 real`j'2
 }
 
 rename v129 fake10
 rename v138 fake11
 rename v147 fake12
 rename v291 real10
 rename v300 real11
 rename v309 real12

 forval j = 10/18 {
 replace fake`j'=fake`j'1 if fake`j'1~=.
 replace fake`j'=fake`j'2 if fake`j'2~=.
 replace fake`j'=fake`j'0 if fake`j'0~=.
 drop fake`j'0 fake`j'1 fake`j'2
 
 replace real`j'=real`j'1 if real`j'1~=.
 replace real`j'=real`j'2 if real`j'2~=.
 replace real`j'=real`j'0 if real`j'0~=.
 drop real`j'0 real`j'1 real`j'2
 }
 

drop *_rt_*

reshape long fake real , i(id) j(item_num)
gen uniqueI = id*1000+item_num

rename fake rating1
rename real rating2

reshape long rating, i(unique) j(real)

gen politically_concordant = (item_num<=9 & demrep==2) | (item_num>9 & demrep==1)
gen rep_leaning=item_num<=9
replace real=real-1
replace item_num=item_num+(1-real)*18				

label define bla2x 0 "False" 1 "True"
label values real bla2x

label define bla3 0 "Discordant" 1 "Concordant"
label values politically_concordant  bla3
///////////////////


/////////////////
// Figure 1a,b
graph bar (mean) rating, over(real) over(politically_concordant) over(condition)
// for CIs
bysort condition real politically_conc: cluster2 rating, tcluster(id) fcluster(item_num)
//////////////


/////////////////
// Main analysis - Table S1
// z-score rating
egen mean_rating=mean(rating), by(condition)
egen sd_rating=sd(rating), by(condition)
gen z_rating=(rating-mean_rating)/sd_rating
drop mean_rating sd_rating
// center variables
replace real=real-.5
replace politically_conc=politically_conc-.5
replace condition=condition-.5
// generate interaction terms
gen conditionXreal=condition*real
gen conditionXconc=condition*politically_conc
gen realXconc=real*politically_conc
gen conditionXrealXconc=politically_conc*real*condition


// Main model
xi: cluster2 rating condition real politically_conc conditionXreal conditionXconc realXconc conditionXrealXconc , tcluster(id) fcluster(item_num)
// effect of veracity is significant in acc condition
disp (_b[real]+_b[conditionXreal]*-.5)
test real+conditionXreal*-.5=0
// effect of concordance is sig in acc condition
disp (_b[politically_concordant ]+_b[conditionXconc]*-.5)
test politically_concordant +conditionXconc*-0.5=0
// veracity has bigger effect than concordance in acc condition
test real+conditionXreal*-.5=politically_concordant +conditionXconc*-0.5
// effect of veracity is significant in sharing condition
disp (_b[real]+_b[conditionXreal]*.5)
test real+conditionXreal*.5=0
// effect of concordance is sig in acc condition
disp (_b[politically_concordant ]+_b[conditionXconc]*.5)
test politically_concordant +conditionXconc*0.5=0
// veracity has bigger effect than concordance in acc condition
test real+conditionXreal*.5=politically_concordant +conditionXconc*0.5
// effect of veracity differs across conditions
test conditionXreal
// effect of concordance differs across conditions
test conditionXconc


// robustness check using logistic regression
xi: logit2 rating condition real politically_conc conditionXreal conditionXconc realXconc conditionXrealXconc, tcluster(id) fcluster(item_num)
// robustness check using z-scored DV
xi: cluster2 z_rating condition real politically_conc conditionXreal conditionXconc realXconc conditionXrealXconc , tcluster(id) fcluster(item_num)
outreg2 using "C:\users\drand\desktop\bla3", append excel alpha(.001, .01, .05) stats(coef se pval)




// higher accimp people are more discerning in their sharing
xi: cluster2 rating i.real*accimp if condition==.5, fcluster(id) tcluster(item_num )
test _IreaXaccim_2=0
test accimp+_IreaXaccim_2=0
xi: bysort real: cluster2 rating accimp if condition==.5, fcluster(id) tcluster(item_num )

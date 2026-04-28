clear * 
insheet using "Study_2_data.csv"

// For Figure 1c
tabulate imp_surprising
tabulate imp_politics
tabulate imp_funny
tabulate imp_intersting
tabulate imp_accurate

// accuracy more important than other categories
ttest imp_accurate ==imp_surprising
ttest imp_accurate ==imp_intersting
ttest imp_accurate ==imp_politics
ttest imp_accurate ==imp_funny

// side-note (not discussed in the paper): no significant difference in importance of accuracy based on partisanship or ideology
pwcorr imp_accurate social_conserv econ_conserv political_preference, sig
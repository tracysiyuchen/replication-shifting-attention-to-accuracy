# Study 1 — Stata Code Audit Report

**Paper:** Pennycook, G., Epstein, Z., Mosleh, M., Arechar, A. A., Eckles, D., & Rand, D. G. (2021). Shifting attention to accuracy can reduce misinformation online. *Nature*, 592, 590–595.

**Stata file audited:** `Study_1_code.do` (155 lines)
**Data file:** `study_1_data.csv` (1,825 rows × 477 columns)
**Note:** This document was produced by reading the `.do` file and the published paper. No Stata execution was performed. It serves as the reference specification for the Python replication.

---

## 0. Six-Block Workflow Overview

The `.do` file executes in six sequential blocks. Each block has one clear purpose. The diagram below shows the flow, the lines it covers, and where each output lands in the paper.

```
RAW CSV (1,825 rows × 477 cols)
        │
        ▼
┌─────────────────────────────────────────────────────┐
│ BLOCK 1 — Load & Filter          (lines 1–16)       │
│                                                     │
│  • Load study_1_data.csv                            │
│  • Create diagnostic flags: noFBTwitter, noshare   │
│  • Drop didnt_finish == 1  →  1,005 participants    │
│  • Print: n, age, sex                               │
└─────────────────────┬───────────────────────────────┘
                      │  participant-level data (1,005 rows)
                      ▼
┌─────────────────────────────────────────────────────┐
│ BLOCK 2 — Extended Data Figure 1  (lines 24–30)     │
│                                                     │
│  • Histogram of accimp by condition                 │
│  • t-test: does accimp differ by condition?         │
│    → t(1003) = 1.83, p = 0.067                      │
│  OUTPUT: Extended Data Fig. 1                       │
└─────────────────────┬───────────────────────────────┘
                      │  still participant-level
                      ▼
┌─────────────────────────────────────────────────────┐
│ BLOCK 3 — Wide-to-Long Reshape    (lines 34–88)     │
│                                                     │
│  Stage 1: Consolidate Qualtrics branch variants     │
│           (fake10 collision — see § 1.3)            │
│  Stage 2: Rename v129/v138/v147 → fake10/11/12      │
│  Stage 3: Consolidate variants for items 10–18      │
│  Stage 4: Drop reaction-time columns                │
│  Stage 5: reshape wide → long (two passes)          │
│  Stage 6: Generate politically_concordant,          │
│           recode item_num (true 1–18, false 19–36)  │
│                                                     │
│  INPUT:  1,005 rows × ~200 cols                     │
│  OUTPUT: ~36,180 rows × 8 cols                      │
│          (1 row = 1 participant × 1 headline)        │
└─────────────────────┬───────────────────────────────┘
                      │  long-format data (~36,180 rows)
                      ▼
┌─────────────────────────────────────────────────────┐
│ BLOCK 4 — Figure 1a & 1b          (lines 92–96)     │
│                                                     │
│  • Bar chart: mean rating by                        │
│    veracity × concordance × condition               │
│  • Clustered analytic SEs for CIs (cluster2)        │
│  OUTPUT: Fig. 1a (accuracy), Fig. 1b (sharing)      │
└─────────────────────┬───────────────────────────────┘
                      │  same long-format data
                      ▼
┌─────────────────────────────────────────────────────┐
│ BLOCK 5 — Main Analysis / Table S1  (lines 100–144) │
│                                                     │
│  • Z-score rating within condition                  │
│  • Center predictors at 0.5                         │
│  • OLS: rating ~ condition + real + concordant      │
│         + all 2-way & 3-way interactions            │
│  • Two-way clustered SEs (CGM 2011)                 │
│  • 8 Wald F-tests (key paper statistics)            │
│  • Robustness: logit, z-scored DV                   │
│                                                     │
│  KEY OUTPUTS:                                       │
│    55.9pp veracity gap (accuracy), F = 375.05       │
│    5.9pp veracity gap (sharing)                     │
│    Condition × veracity interaction, F = 260.68     │
└─────────────────────┬───────────────────────────────┘
                      │  sharing condition subset only
                      ▼
┌─────────────────────────────────────────────────────┐
│ BLOCK 6 — Accuracy Importance Moderation (151–154)  │
│                                                     │
│  • Subset: sharing condition only                   │
│  • OLS: rating ~ real × accimp                      │
│  • Tests: does caring about accuracy make           │
│    people more discerning when sharing?             │
│  OUTPUT: Supplementary information                  │
└─────────────────────────────────────────────────────┘
```

### What each block produces

| Block | Lines | Primary output | Paper location |
|-------|-------|---------------|----------------|
| 1 — Load & Filter | 1–16 | 1,005-participant dataset | Methods: Participants |
| 2 — Ext. Data Fig. 1 | 24–30 | Histogram + t-test (accimp) | Extended Data Fig. 1 |
| 3 — Reshape | 34–88 | ~36,180-row long-format dataset | Methods: Analysis plan |
| 4 — Figure 1 | 92–96 | Fig. 1a and Fig. 1b bar charts | Fig. 1 (p. 590) |
| 5 — Main analysis | 100–144 | All F-statistics, Table S1 | Results (p. 590–591) |
| 6 — Moderation | 151–154 | accimp × veracity interaction | Supplementary |

> The detailed documentation for each block, including exact Stata code, paper references, and discrepancies, is in **Section 1** below.

---

## 1. Block-by-Block Documentation

### Block 1 — Data Loading & Exclusion Flags (Lines 1–16)

**What it does:**

```stata
clear *
insheet using "Study_1_data.csv", clear
sum id
gen noFBTwitter=(socialmedia_1==. & socialmedia_2==.)
gen noshare=sharingtype_1==.
table didnt_finish noFBTwitter noshare
table noFBTwitter noshare
drop if didnt_finish==1
sum id
sum id age
table sex
```

Creates two diagnostic exclusion flags:
- `noFBTwitter`: 1 if participant has neither a Facebook account (`socialmedia_1`) nor a Twitter account (`socialmedia_2`) — both are missing
- `noshare`: 1 if participant did not answer the political-sharing willingness question (`sharingtype_1` is missing)

Cross-tabulates the three exclusion dimensions, then **explicitly drops only participants who did not finish the survey** (`didnt_finish==1`). The `noFBTwitter` and `noshare` flags are created and tabulated but **never used in an explicit `drop` statement**.

**Key finding from Python replication:** Running the data through the pipeline reveals that `didnt_finish==1` encodes **all three exclusion criteria** — not just survey non-completion. After dropping `didnt_finish==1`, the `socialmedia` and `sharingtype_1` filters remove zero additional participants. This means the Qualtrics survey logic marked participants as `didnt_finish` regardless of which exit criterion applied. The `noFBTwitter` and `noshare` flags are therefore diagnostic cross-checks, not additional filters.

Reports descriptive statistics (n, age, sex) after the `didnt_finish` drop.

**Paper reference:** Methods → "Participants" subsection:
> "We retained participants who completed the survey, had a Facebook or Twitter account, and indicated they would be willing to share political content."
> Exclusions: 153 (no FB/Twitter), 651 (no political sharing willingness), 16 (did not finish).

**Deviation resolved:** What appeared to be a code deviation (three exclusions, only one `drop`) is explained by how `didnt_finish` was coded in the survey. The single `drop` captures all 820 excluded participants (16+153+651). See Section 4 for n tracing.

---

### Block 2 — Extended Data Figure 1: Accuracy Importance (Lines 24–30)

**What it does:**

```stata
label define bla1x 0 "Accuracy" 1 "Sharing"
label values condition bla1x
histogram accimp, by(condition)
ttest accimp, by(condition)
```

Labels the `condition` variable (0 = Accuracy, 1 = Sharing), generates a histogram of `accimp` (post-experimental 1–5 Likert scale: "How important is it to you that you only share news articles on social media if they are accurate?") split by condition, and runs an independent-samples t-test comparing conditions.

**Paper reference:** Extended Data Fig. 1 and the in-text sentence:
> "Average responses were not statistically different in the sharing condition (accuracy condition: mean = 3.80, s.d. = 1.25; sharing condition: mean = 3.65, s.d. = 1.25; t(1,003) = 1.83, P = 0.067)."

Note: The t-test is run on the participant-level data, **before** the wide-to-long reshape. The n in Extended Data Fig. 1 caption is 1,002 (not 1,003), suggesting a small additional exclusion of missing `accimp` values.

---

### Block 3 — Wide-to-Long Reshape (Lines 34–88)

This is the most complex block. It transforms the 477-column wide dataset into a long-format dataset with one row per participant × headline × veracity.

**Stage 1: Consolidate headline-rating variants for items 1–9 (Lines 36–46)**

Each headline in Qualtrics had three display variants (counterbalanced). In the CSV, fake item 1's main response is `fake1`, and its variants are `fake10`, `fake11`, `fake12` (i.e., the suffixes 0, 1, 2 — **not** items 10, 11, 12). The loop merges them with priority: variant 0 overrides variant 2, which overrides variant 1, which overrides the base:

```stata
forval j = 1/9 {
  replace fake`j'=fake`j'1 if fake`j'1~=.
  replace fake`j'=fake`j'2 if fake`j'2~=.
  replace fake`j'=fake`j'0 if fake`j'0~=.
  drop fake`j'0 fake`j'1 fake`j'2
  ...same for real`j'...
}
```

After this loop, `fake10`, `fake11`, `fake12` (the item-1 variant columns) are **dropped**, freeing those names.

**Critical naming collision:** In the CSV, `fake10` = variant 0 of item 1. After the loop drops it, `fake10` is reused (below) to mean item 10. This must be handled explicitly in the Python replication.

Also: item 9's reaction-time columns are named `q1473_1`–`q1473_4` (Qualtrics internal naming) rather than `fake9_rt_1`–`fake9_rt_4`. This means the later `drop *_rt_*` command does NOT catch these four columns. They remain in the data but are unused.

**Stage 2: Rename generic columns for items 10–12 (Lines 48–53)**

```stata
rename v129 fake10
rename v138 fake11
rename v147 fake12
rename v291 real10
rename v300 real11
rename v309 real12
```

Items 10, 11, 12 were stored under Qualtrics-generated generic names in the CSV. This step gives them the standard naming pattern.

**Stage 3: Consolidate variants for items 10–18 (Lines 55–65)**

Same loop as Stage 1 but for items 10–18. For item 10, the variants are `fake100`, `fake101`, `fake102` (i.e., `fake10` + suffix 0/1/2).

**Stage 4: Drop reaction time variables (Line 68)**

```stata
drop *_rt_*
```

Drops all columns matching `*_rt_*`. Note: does NOT drop `q1473_1`–`q1473_4` (item 9 RT columns with non-standard naming).

**Stage 5a: First reshape — wide to long on item_num (Lines 70–76)**

```stata
reshape long fake real , i(id) j(item_num)
gen uniqueI = id*1000+item_num
rename fake rating1
rename real rating2
```

Creates one row per participant × item_num (1–18), with columns `rating1` (false headline response) and `rating2` (true headline response). Generates `uniqueI` as a composite key.

**Stage 5b: Second reshape — stack rating1/rating2 into single rating column (Line 76)**

```stata
reshape long rating, i(unique) j(real)
```

Creates one row per participant × item × veracity (real=1 for false ratings, real=2 for true ratings), with a single `rating` column. This yields ~36,000+ rows.

**Stage 6: Generate analysis variables (Lines 78–87)**

```stata
gen politically_concordant = (item_num<=9 & demrep==2) | (item_num>9 & demrep==1)
gen rep_leaning=item_num<=9
replace real=real-1                          /* 0=false, 1=true */
replace item_num=item_num+(1-real)*18        /* false items → 19–36, true items stay 1–18 */
```

- `politically_concordant`: Democrat participants (demrep=2) viewing items 1–9 (Democrat-leaning headlines) are concordant; Republican participants (demrep=1) viewing items 10–18 (Republican-leaning headlines) are concordant.
- `rep_leaning`: 1 for items 1–9. Variable name is potentially confusing — see Section 4.
- `item_num` recoding: creates 36 unique headline IDs for the headline-level clustering (false headlines get IDs 19–36, true headlines keep 1–18).

**Paper reference:** Methods → "Analysis plan" subsection. The reshape produces the item-level dataset described in: "analyses were performed at the level of the individual item (one data point per participant per item)."

---

### Block 4 — Figure 1a and 1b (Lines 92–96)

**What it does:**

```stata
graph bar (mean) rating, over(real) over(politically_concordant) over(condition)
bysort condition real politically_conc: cluster2 rating, tcluster(id) fcluster(item_num)
```

Generates a grouped bar chart of mean `rating` by veracity (false/true) × concordance (discordant/concordant) × condition (accuracy/sharing). The second command uses `cluster2` (Cameron-Gelbach-Miller two-way clustering ado) to compute clustered SEs for confidence interval bars, iterating over condition × veracity × concordance cells.

**Paper reference:** Fig. 1 (p. 590). The figure shows panels for accuracy condition (Fig. 1a) and sharing condition (Fig. 1b), with four bars each (false discordant, false concordant, true discordant, true concordant).

**Note:** No `graph export` command is present. The figure was presumably exported manually.

---

### Block 5 — Main Analysis: Table S1 (Lines 100–144)

**What it does — Part A: Standardization and centering (Lines 102–114)**

```stata
egen mean_rating=mean(rating), by(condition)
egen sd_rating=sd(rating), by(condition)
gen z_rating=(rating-mean_rating)/sd_rating
replace real=real-.5              /* centered: -0.5=false, +0.5=true */
replace politically_conc=politically_conc-.5
replace condition=condition-.5    /* centered: -0.5=accuracy, +0.5=sharing */
gen conditionXreal=condition*real
gen conditionXconc=condition*politically_conc
gen realXconc=real*politically_conc
gen conditionXrealXconc=politically_conc*real*condition
```

Z-scores `rating` within each condition. Centers all three main predictors at zero (subtracting 0.5 from 0/1 variables). Generates four interaction terms (three 2-way + one 3-way).

**Part B: Main OLS model (Line 118)**

```stata
xi: cluster2 rating condition real politically_conc conditionXreal conditionXconc realXconc conditionXrealXconc , tcluster(id) fcluster(item_num)
```

Linear regression of binary `rating` on condition, veracity, concordance, and all interactions. Standard errors clustered two-way on participant (`id`) and headline (`item_num`) using the Cameron-Gelbach-Miller (2011) `cluster2` ado.

**Paper reference:** Methods → "Analysis plan": "linear regression with robust standard errors clustered on both participant and headline."

**Part C: Wald tests for specific contrasts (Lines 120–138)**

```stata
test real+conditionXreal*-.5=0           /* veracity effect in accuracy condition */
test politically_concordant+conditionXconc*-0.5=0  /* concordance effect in acc. cond. */
test real+conditionXreal*-.5=politically_concordant+conditionXconc*-0.5  /* veracity > concordance in acc. */
test real+conditionXreal*.5=0            /* veracity effect in sharing condition */
test politically_concordant+conditionXconc*0.5=0   /* concordance in sharing cond. */
test real+conditionXreal*.5=politically_concordant+conditionXconc*0.5  /* veracity > concordance in sharing */
test conditionXreal                      /* veracity × condition interaction */
test conditionXconc                      /* concordance × condition interaction */
```

Each `test` command performs a Wald F-test of the specified linear restriction. These produce the F(1, 36172) statistics reported in the paper's main results.

**Paper reference:** Results section, p. 590–591. See coverage matrix (Section 3) for the exact statistics.

**Part D: Robustness checks (Lines 142–144)**

```stata
xi: logit2 rating condition real politically_conc conditionXreal conditionXconc realXconc conditionXrealXconc, tcluster(id) fcluster(item_num)
xi: cluster2 z_rating condition real politically_conc conditionXreal conditionXconc realXconc conditionXrealXconc , tcluster(id) fcluster(item_num)
outreg2 using "C:\users\drand\desktop\bla3", append excel alpha(.001, .01, .05) stats(coef se pval)
```

- Logistic regression with the same two-way clustering (pre-registered robustness check)
- OLS with z-scored DV instead of raw binary (second robustness check)
- `outreg2` exports to a hardcoded personal desktop path — non-reproducible

**Paper reference:** Methods → "Analysis plan" robustness checks.

---

### Block 6 — Accuracy Importance Moderation (Lines 151–154)

**What it does:**

```stata
xi: cluster2 rating i.real*accimp if condition==.5, fcluster(id) tcluster(item_num)
test _IreaXaccim_2=0
test accimp+_IreaXaccim_2=0
xi: bysort real: cluster2 rating accimp if condition==.5, fcluster(id) tcluster(item_num)
```

Tests whether `accimp` (importance of accuracy) moderates discernment in the **sharing condition only** (`condition==.5` after centering). Interacts `i.real` (indicator for true headline) with `accimp` as a continuous moderator.

**Note:** The clustering arguments are reversed here — `fcluster(id)` and `tcluster(item_num)` — compared to all other models, which use `tcluster(id)` and `fcluster(item_num)`. This is likely a typo in the .do file (the `cluster2` ado may treat `t` and `f` symmetrically, so results should be identical).

**Paper reference:** Supplementary information (not in main text of Study 1).

---

## 2. Coverage Matrix

All statistics and figures reported for Study 1 in the paper's main text, figure captions, Extended Data, and pre-registered contrasts.

| Statistic / Figure | Location in Paper | Covered in .do? | Notes |
|--------------------|------------------|-----------------|-------|
| n = 1,825 began survey | Main text, p. 590 | Implicit | Row count of raw CSV |
| n = 1,015 analyzed (main text) | Main text, p. 590 | Partial | `drop if didnt_finish==1` explicit; other exclusions implicit |
| n = 1,002 (Fig. 1 caption) | Fig. 1 caption | No | Not explained by any code block; likely post-reshape missing-data dropout |
| n = 1,002 (Ext. Data Fig. 1 caption) | Ext. Data Fig. 1 | No | Same issue |
| Age mean (analyzed sample) | Methods, p. 592 | Y (line 14) | `sum id age` |
| Sex distribution | Methods, p. 592 | Y (line 15) | `table sex` |
| Extended Data Fig. 1 (histogram) | Ext. Data Fig. 1 | Y (line 27) | `histogram accimp, by(condition)` |
| accimp: accuracy cond. mean=3.80, s.d.=1.25 | p. 591 | Y (line 29) | Derived from `ttest accimp` |
| accimp: sharing cond. mean=3.65, s.d.=1.25 | p. 591 | Y (line 29) | Derived from `ttest accimp` |
| t(1,003)=1.83, P=0.067 (accimp t-test) | p. 591 | Y (line 29) | `ttest accimp, by(condition)` |
| Fig. 1a bar chart (accuracy condition) | Fig. 1a | Y (line 93) | `graph bar...` — no `graph export` |
| Fig. 1b bar chart (sharing condition) | Fig. 1b | Y (line 93) | Same command, same graph |
| Accuracy cond.: 55.9 pp veracity effect | p. 590 | Y (line 121) | Wald test `test real+conditionXreal*-.5=0` |
| F(1,36172)=375.05, P<0.0001 (veracity, acc.) | p. 590 | Y (line 121) | Same test |
| Accuracy cond.: 10.1 pp concordance effect | p. 590 | Y (line 124) | Wald test concordance in acc. cond. |
| F(1,36172)=26.45, P<0.0001 (concordance, acc.) | p. 590 | Y (line 124) | Same test |
| Veracity × concordance interaction in acc. cond.: F(1,36172)=137.26 | p. 590 | Y (line 126) | `test real+conditionXreal*-.5=politically_concordant+conditionXconc*-0.5` — confirmed in Stata log |
| Veracity > concordance in accuracy condition | p. 590 | Y (line 126) | `test real+...=politically_concordant+...` |
| Sharing cond.: 5.9 pp veracity effect | p. 590 | Y (line 129) | Wald test `test real+conditionXreal*.5=0` |
| Sharing cond.: 19.3 pp concordance effect | p. 590 | Y (line 132) | Wald test concordance in sharing cond. |
| Concordance > veracity in sharing condition | p. 590 | Y (line 134) | `test real+...=politically_concordant+...` |
| Veracity × condition interaction: F(1,36172)=260.68, P<0.0001 | p. 590–591 | Y (line 136) | `test conditionXreal` |
| Concordance × condition interaction: F(1,36172)=17.24, P<0.0001 | p. 591 | Y (line 138) | `test conditionXconc` |
| False concordant 37.4% sharing rate (sharing condition) | p. 591 | No | Computed from means, not explicit in .do; Stata log confirms 37.4% — exact match |
| False concordant 18.2% accuracy rating (accuracy condition) | p. 591 | No | Paper cites these two values as a cross-condition dissociation; Stata log shows 18.3% — 0.1pp rounding match |
| F(1,36172)=19.73 (false concordant vs. true discordant) | p. 591 | Y (line 134) | Same as "veracity > concordance in sharing" — signs flipped, mathematically identical test |
| "Migrant Caravaners": 15.7% rated accurate (Republicans) | p. 591 | No | Item-level descriptive, not in .do |
| "Migrant Caravaners": 51.1% would share (Republicans) | p. 591 | No | Item-level descriptive, not in .do |
| Logistic regression robustness | Methods, p. 593 | Y (line 142) | `logit2` |
| Z-scored DV robustness | Methods, p. 593 | Y (line 144) | `cluster2 z_rating` |
| accimp × sharing condition moderation | Supp. Info | Y (lines 151–154) | Interaction test present |

---

## 3. Key Discrepancies and Flags

### Discrepancy 1 — RESOLVED: Single `drop` Captures All Three Exclusions

**Paper says:** Three exclusion criteria applied — no FB/Twitter account (n=153), no willingness to share political content (n=651), did not finish (n=16). Total removed: 820. Expected remaining: 1,825 − 820 = 1,005.

**Code does:** Only `drop if didnt_finish==1` is explicit (line 12).

**Resolution (confirmed by Python replication and Stata execution log):** The `didnt_finish` variable in the CSV encodes **all three exclusion criteria** simultaneously. The Stata log confirms `drop if didnt_finish==1` deleted exactly **820 observations** (1,825 → 1,005). After applying `drop if didnt_finish==1`, the additional `socialmedia` and `sharingtype_1` filters remove **zero** additional rows. The Qualtrics survey flow set `didnt_finish=1` for anyone who: (a) declined the screener about FB/Twitter, (b) declined to share political content, or (c) abandoned the survey.

The `noFBTwitter` and `noshare` flags are diagnostic cross-checks created for tabulation purposes — they confirm the composition of the `didnt_finish` group but are not needed as additional filters.

**Remaining discrepancy:** The Python pipeline confirms n=1,005 (not n=1,015 as stated in the paper). The paper's stated count of 1,015 is inconsistent with the actual data and the arithmetic (1,825−820=1,005). See Section 4 for full tracing.

### Discrepancy 2 — n=1,015 (main text) vs. n=1,002 (Fig. 1 caption)

**Paper says:** n=1,015 in the main text narrative; n=1,002 in the Fig. 1 and Extended Data Fig. 1 captions.

**Code:** Neither number is explicitly computed or stored.

**Hypothesis:** n=1,015 is the participant count after explicit `drop if didnt_finish==1` plus passive exclusion of those without social media accounts or sharing willingness. n=1,002 may reflect a further reduction due to participants who passed the screener but did not complete all headline ratings (missing values on the DV), which are dropped row-wise in the regression. The 13-participant difference (1,015 − 1,002 = 13) likely represents these partially-completing participants.

**Math check:** 1,825 − 153 − 651 − 16 = 1,005 (not 1,015). The 10-participant gap between 1,005 and 1,015 suggests the exclusion counts given in the paper may be rounded or approximate.

### Discrepancy 3 — Clustering: Pre-Registration vs. Paper

**Pre-registration specified:** Standard errors clustered on participant only.

**Paper and code do:** Two-way clustering on both participant (`tcluster(id)`) and headline (`fcluster(item_num)`) using the Cameron-Gelbach-Miller (2011) `cluster2` ado.

**Authors acknowledge this:** Methods (p. 593):
> "We subsequently realized that treating each item independently might not be entirely justified, given that multiple ratings of the same headline are non-independent in a similar way to multiple ratings from the same participant, and thus deviated from our preregistered plan."

**Impact on replication:** The Python replication must implement two-way clustering manually (V_twoway = V_cluster_participant + V_cluster_headline − V_HC0). Participant-only clustering should also be reported as a robustness check to show the pre-registered result.

### Discrepancy 4 — `cluster2` and `logit2` Are Non-Standard Commands

`cluster2` and `logit2` are user-written Stata ados implementing the Cameron-Gelbach-Miller (2011) multi-way clustering sandwich estimator. They are not built-in Stata commands. The Python replication must implement this manually using `statsmodels` as described in the replication notebook.

### Discrepancy 5 — Fcluster/Tcluster Reversal in Block 6

In Block 6 (moderation analysis, lines 151–154), the clustering arguments are:
```stata
fcluster(id) tcluster(item_num)
```
All other models use:
```stata
tcluster(id) fcluster(item_num)
```
This is likely a typo. The `cluster2` ado should treat the two cluster dimensions symmetrically, so results are identical regardless of which gets the `t`/`f` label.

### Discrepancy 6 — RETRACTED: No Cell-Mean Gap for Paper-Cited Percentages

**Earlier versions of this audit incorrectly identified a ~6pp gap. That claim was wrong and is retracted.**

The paper cites 37.4% and 18.2% on p. 591 as a **cross-condition dissociation** — not two cells from the same condition:

| Paper quote | Value | Condition | DV | Stata log | Gap |
|---|---|---|---|---|---|
| "...consider sharing false but politically concordant headlines (37.4%)..." | 37.4% | Sharing | Sharing rate | 37.4% (line 434) | 0pp — exact match |
| "...as they were to rate such headlines as accurate (18.2%)" | 18.2% | Accuracy | Accuracy rating | 18.3% (line 366) | 0.1pp — rounding only |

The earlier analysis compared the paper's 18.2% (accuracy rating, accuracy condition) against the Stata raw cell mean for true discordant sharing (24.1%) — two completely different cells. That comparison was incorrect.

**Unverified:** The paper also cites 15.7% and 51.1% for the 'Migrant Caravan' headline among Republicans specifically. These are item-level values filtered to one party and one headline; the Stata `.do` file does not compute them explicitly.

### Discrepancy 7 — Non-Reproducible Output Path

Line 145:
```stata
outreg2 using "C:\users\drand\desktop\bla3", append excel ...
```
Hardcoded to a specific researcher's local path. This will fail on any other machine and is not reproducible.

### Discrepancy 8 — `rep_leaning` Variable Naming

```stata
gen rep_leaning=item_num<=9
```
This generates `rep_leaning = 1` for items 1–9. However, based on the concordance formula, items 1–9 are concordant for Democrats (demrep=2), suggesting they are from **Democratic-leaning** sources. The variable name `rep_leaning` therefore appears to be either inverted or a labeling error. It does not affect any analysis (it is generated but never used in a regression), but should be verified against the survey materials.

---

## 4. Sample Size Tracing

| Stage | n | Source |
|-------|---|--------|
| Started survey | 1,825 | Paper main text / raw CSV row count |
| `drop if didnt_finish==1` (encodes all 3 criteria) | −820 | Code line 12; confirmed by Stata log ("820 observations deleted") and Python replication |
| After drop | **1,005** | Python replication (exact) |
| Additional FB/Twitter filter | 0 | Already captured by `didnt_finish` |
| Additional sharing-intent filter | 0 | Already captured by `didnt_finish` |
| After reshape + drop missing ratings | **1,005** | df_resid+8 = 36,172+8 = 36,180 rows ÷ 36 items |
| Reported in paper main text | **1,015** | Discrepancy: +10 vs. actual 1,005 |
| Reported in Fig. 1 caption | **1,002** | −3 from 1,005; likely missing accimp responses |

**Revised explanation of n=1,015 vs. n=1,005:** The Python replication produces n=1,005, which matches the arithmetic (1,825−820=1,005). The paper's stated n=1,015 is unexplained — the actual filtered dataset has 1,005 participants, not 1,015. The exclusion counts given in the paper (153+651+16=820) are internally consistent with 1,005, not 1,015. This suggests either a reporting error or the exclusion counts in the paper are not individually accurate (though they sum correctly to 820).

**n=1,002 (Fig. 1 caption):** The 3-participant difference (1,005 vs 1,002) likely reflects participants with no valid headline responses even after passing screeners — they contribute to the participant count but produce no rows in the long-format regression dataset.

---

## 5. Variable Dictionary (Stata → Python mapping)

| Stata name | CSV column | Meaning | Python equivalent |
|-----------|------------|---------|------------------|
| `condition` | `condition` (col 477) | 0=Accuracy, 1=Sharing (raw); centered to −0.5/+0.5 | `cond_c = condition − 0.5` |
| `real` | Constructed | 0=False headline, 1=True headline (after reshape+recode) | `real_c = real − 0.5` |
| `politically_concordant` | Constructed | 0=Discordant, 1=Concordant | `conc_c = politically_concordant − 0.5` |
| `rating` | Constructed | Binary response (0=No, 1=Yes) from fake/real item cols | `rating` |
| `z_rating` | Constructed | Z-scored rating within condition | `z_rating` |
| `id` | `id` (col 474) | Participant ID | `id` |
| `item_num` | Constructed | Headline ID: true=1–18, false=19–36 | `item_num` |
| `demrep` | `demrep` (col 476) | 1=Republican, 2=Democrat | `demrep` |
| `accimp` | `accimp` (~col 415) | Accuracy importance (1–5 Likert) | `accimp` |
| `didnt_finish` | `didnt_finish` (col 475) | 1=did not complete | `didnt_finish` |
| `socialmedia_1` | `socialmedia_1` (col 27) | Has Facebook account | `socialmedia_1` |
| `socialmedia_2` | `socialmedia_2` (col 28) | Has Twitter account | `socialmedia_2` |
| `sharingtype_1` | `sharingtype_1` (col 20) | Willing to share political content | `sharingtype_1` |
| `fake1`–`fake18` | See note | False headline ratings (after consolidation) | `fake1`–`fake18` |
| `real1`–`real18` | See note | True headline ratings (after consolidation) | `real1`–`real18` |
| `v129`,`v138`,`v147` | cols 118,127,136 | Raw columns for fake items 10,11,12 → renamed | rename to `fake10`,`fake11`,`fake12` |
| `v291`,`v300`,`v309` | cols ~280,289,298 | Raw columns for real items 10,11,12 → renamed | rename to `real10`,`real11`,`real12` |

**Special case — item 9 RT columns:** In the CSV, item 9's reaction time columns are named `q1473_1`–`q1473_4` (Qualtrics internal ID), not `fake9_rt_1`–`fake9_rt_4`. The Stata `drop *_rt_*` command does **not** remove these; they persist in memory but are never used.

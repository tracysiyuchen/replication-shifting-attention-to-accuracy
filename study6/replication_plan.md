# Study 6 Replication Plan
**Paper:** Pennycook et al. (2021), "Shifting Attention to Accuracy Can Reduce Misinformation Online," *Nature*, 592, 590–595.

---

## 1. Overview

Study 6 is a between-subjects survey experiment (n = 710 after exclusions) that **decomposes** the sharing of false news headlines into three causal accounts:

| Account | Mechanism | Label |
|---|---|---|
| Inattention | Participant shares because they never considered accuracy | f_Inattention |
| Confusion | Participant shares *and* (incorrectly) believes the headline is accurate | f_Confusion |
| Purposeful | Participant shares *and* knows the headline is inaccurate | f_Purposeful |

The key output is **Figure 3d** (and Extended Data Table 2): point estimates and 95% bootstrap CIs for each fraction.

Target values to reproduce:
- **Inattention:** 51.2% [38.4%, 62.0%]
- **Confusion:** 33.1% [25.1%, 42.4%]
- **Purposeful:** 15.8% [11.1%, 21.5%]

Pairwise bootstrap comparisons:
- Inattention vs. Purposeful: b = 0.354 [0.178, 0.502], P = 0.0004
- Confusion vs. Purposeful: b = 0.173 [0.098, 0.256], P < 0.0001
- Inattention vs. Confusion: b = 0.181 [−0.036, 0.365], P = 0.098 (n.s.)

---

## 2. Study Design

### Participants
- Two MTurk batches collected on **11 Aug 2017** (n = 218, Batch 1) and **24 Aug 2017** (n = 542, Batch 2).
- Total starters: 760. Excluded: 14 who had no Facebook account, 33 who did not finish.
- Analytic sample restricted to participants who reported they **would ever consider sharing something political on Facebook** (`socialmedia_chk == 1`), reducing n to 398. Full-sample robustness reported in Extended Data Table 2.
- Final analytic sample: 181 males, 213 females, 4 missing; mean age = 35.2.

### Materials
- 24 news headlines (same set as Study 3): 12 **false** (fake) + 12 **true** (real), balanced on partisan alignment (pro-Democrat / pro-Republican).

### Conditions (between-subjects)
- **Control (`condition == 0`):** Participants see each headline and are asked only: *"If you were to see the above article on Facebook, how likely would you be to share it?"*
  - Response scale: 1 (Extremely unlikely) → 6 (Extremely likely)
- **Full-attention treatment (`condition == 1`):** Before each sharing question, participants are asked: *"To the best of your knowledge, how accurate is the claim in the above headline?"*
  - Accuracy scale: 1 (Not at all accurate), 2 (Not very accurate), 3 (Somewhat accurate), 4 (Very accurate)
  - Then the same sharing question as control.

---

## 3. Data Files

| File | N rows | Description |
|---|---|---|
| `Study_6_b1_data.csv` | 204 | Batch 1 (Aug 11, 2017) |
| `Study_6_b2_data.csv` | 506 | Batch 2 (Aug 24, 2017) |

Key column naming conventions (wide format, one row per participant):

- `FakeN_3` / `RealN_3` — sharing intentions for item N in the **treatment** condition (scale 1–6)
- `FakeN_30` / `RealN_30` — sharing intentions for item N in the **control** condition (scale 1–6; note the `_30` suffix distinguishes from treatment)
- `FakeN_2` / `RealN_2` — accuracy ratings for item N in the **treatment** condition (scale 1–4; missing for control participants)
- `SocialMedia_Chk` — whether participant would ever share political news on Facebook (1 = yes, 2 = no, 3 = don't use social media)
- `Condition` — 1 = control, 2 = treatment (note: Stata code recodes to 0/1)
- `FB` — whether participant has a Facebook profile (1 = yes, 2 = no)

---

## 4. Data Processing Steps

Following the Stata reference code (`Study_6_code.do`):

### 4.1 Load and Combine Batches
```python
import pandas as pd
b1 = pd.read_csv("Study_6_b1_data.csv")
b1["batch"] = 1
b2 = pd.read_csv("Study_6_b2_data.csv")
b2["batch"] = 2
df = pd.concat([b1, b2], ignore_index=True)
```

### 4.2 Exclusions
```python
# Exclude those who did not finish (socialmedia_chk is missing) or have no Facebook
df = df[~(df["SocialMedia_Chk"].isna() | (df["FB"] == 2))]
```

### 4.3 Reshape to Long Format
The data are wide (one row per participant, columns per item). Reshape so each row is one `(participant, item)` observation with columns: `sm` (sharing), `acc` (accuracy), `real` (0=fake, 1=real), `condition`.

Steps:
1. Extract sharing columns: for each item i in 1–12:
   - Treatment sharing: `FakeiN_3`, `RealiN_3`
   - Control sharing: `FakeiN_30`, `RealiN_30`
   - Merge: if treatment sharing is missing, use control sharing.
2. Extract accuracy columns: `FakeiN_2`, `RealiN_2` (only in treatment).
3. Stack into long format with columns `[id, item_num, real, condition, sm_raw, acc_raw]`.

### 4.4 Variable Transformations
```python
# Recode condition to 0/1
df_long["condition"] = df_long["condition"] - 1   # was 1/2, now 0/1

# Normalize sharing to [0, 1]
df_long["sm"] = (df_long["sm_raw"] - 1) / 5

# Binary sharing: > 0.5 (i.e., original response >= 4, "slightly likely" or above)
df_long["smB"] = (df_long["sm"] > 0.5).astype(int)

# Binary accuracy: > 2 (i.e., original response >= 3, "somewhat" or "very" accurate)
df_long["accB"] = (df_long["acc_raw"] > 2).astype(int)
df_long.loc[df_long["acc_raw"].isna(), "accB"] = float("nan")
```

### 4.5 Analytic Subsample
Restrict to `socialmedia_chk == 1` (would share political news on Facebook) for main analysis.

---

## 5. Core Decomposition Analysis (Figure 3d)

### 5.1 Compute Quantities from Cross-tabulation

Using only **false headlines** (`real == 0`) and only `socialmedia_chk == 1`:

```
F_cont  = mean(smB) among [condition==0, real==0]
F_treat = mean(smB) among [condition==1, real==0]
```

In the treatment group, for false headlines that were shared (`smB==1`):
```
N_treat      = count of (shared) observations  [condition==1, real==0, smB==1]
N_acc_treat  = count of (shared AND rated accurate)  [condition==1, real==0, smB==1, accB==1]
N_inacc_treat= count of (shared AND rated inaccurate) [condition==1, real==0, smB==1, accB==0]
```

Note: `N_acc_treat + N_inacc_treat = N_treat` by construction (no missing acc in treatment sharers).

### 5.2 Point Estimates

```
f_Inattention = (F_cont - F_treat) / F_cont
f_Confusion   = (N_acc_treat  / N_treat) * (F_treat / F_cont)
f_Purposeful  = (N_inacc_treat / N_treat) * (F_treat / F_cont)
```

Verify: `f_Inattention + f_Confusion + f_Purposeful ≈ 1.0`

### 5.3 Bootstrap Confidence Intervals (10,000 repetitions)

```python
import numpy as np

rng = np.random.default_rng(seed=42)
n_boot = 10_000

# Group data by participant ID before resampling
subjects = df_long[df_long["socialmedia_chk"] == 1]["id"].unique()

boot_results = []
for _ in range(n_boot):
    sampled_ids = rng.choice(subjects, size=len(subjects), replace=True)
    boot_df = df_long[df_long["id"].isin(sampled_ids)]
    # Recompute f_Inattention, f_Confusion, f_Purposeful on boot_df
    # ... (same formulas as 5.2)
    boot_results.append((f_inn, f_con, f_pur))

boot_arr = np.array(boot_results)

# 95% CIs (2.5th and 97.5th percentiles)
ci_inn = np.percentile(boot_arr[:, 0], [2.5, 97.5])
ci_con = np.percentile(boot_arr[:, 1], [2.5, 97.5])
ci_pur = np.percentile(boot_arr[:, 2], [2.5, 97.5])
```

**Important:** Resample at the **subject level** (not at the observation level), to preserve the within-subject correlation across items. This matches the paper's method.

### 5.4 Pairwise Bootstrap P-values

For each comparison (e.g., Inattention vs. Purposeful), compute the difference `d = f_A - f_B` in each bootstrap sample. The two-tailed P-value is:

```python
# Inattention vs. Purposeful (inattention explains more in actual data)
diffs_inn_pur = boot_arr[:, 0] - boot_arr[:, 2]
# Two-tailed p: double the fraction where the direction is reversed
p_inn_pur = 2 * np.mean(diffs_inn_pur <= 0)
```

Apply same logic for Confusion vs. Purposeful and Inattention vs. Confusion.

---

## 6. Secondary Analysis: Pre-registered Condition × Veracity Effect

The Stata code also runs (but the paper does not report) the pre-registered sharing discernment regression matching Studies 3–5:

```
OLS: smB ~ condition + real + condition × real
```

With standard errors clustered two-way on participant and item. This can be replicated in Python using `linearmodels` with clustered SEs, or by manual two-way clustering. Include both the full sample and the `socialmedia_chk == 1` subsample.

---

## 7. Robustness Check: Full Sample (Extended Data Table 2)

Repeat the entire decomposition analysis (Section 5) on the **full sample** (without restricting to `socialmedia_chk == 1`). The paper reports equivalent results hold; we verify this matches Extended Data Table 2 and also run each batch separately to address the post hoc nature of the analysis.

---

## 8. Expected Outputs

| Output | Target Value |
|---|---|
| F_cont (false sharing rate, control) | ~26–28% (to be confirmed) |
| F_treat (false sharing rate, treatment) | ~13–15% (to be confirmed) |
| f_Inattention | 51.2% [38.4%, 62.0%] |
| f_Confusion | 33.1% [25.1%, 42.4%] |
| f_Purposeful | 15.8% [11.1%, 21.5%] |
| Bootstrap b(Inattention − Purposeful) | 0.354 [0.178, 0.502], P = 0.0004 |
| Bootstrap b(Confusion − Purposeful) | 0.173 [0.098, 0.256], P < 0.0001 |
| Bootstrap b(Inattention − Confusion) | 0.181 [−0.036, 0.365], P = 0.098 |

Produce a **bar chart** replicating Figure 3d with error bars = 95% bootstrap CIs.

---

## 9. Known Challenges

1. **Column name inconsistencies across batches.** Batch 1 and Batch 2 were collected as separate Qualtrics surveys with slightly different variable names (e.g., `Real1_ASM` vs. `Real1_A_SM`). Carefully harmonize before stacking.

2. **`_30` vs. `_3` suffix logic.** The Stata code's renaming pattern (`fake*_30 fakeC_sm*`) is non-obvious; this reflects Qualtrics block ordering. Verify by checking which participants have non-missing values in `_3` vs. `_30` columns.

3. **Bootstrap seed.** The paper does not specify a random seed. Results may vary slightly but CIs should be numerically close given 10,000 iterations.

4. **Stata non-standard commands.** The provided code uses `cluster2` and `logit2` (custom .ado files not included). The pre-registered discernment regression (Section 6) must be re-implemented using standard Python libraries (e.g., `statsmodels` with manual two-way cluster correction, or `linearmodels`).

5. **Post hoc analysis caveat.** The decomposition was not pre-registered; the pre-registration only tested condition × veracity. The paper acknowledges this and reports batch-by-batch robustness. We should do the same.

---

## 10. File Structure

```
study6/
├── replication_plan.md        ← this file
├── analysis.py                ← main Python replication script
├── figures/
│   └── figure_3d_replication.png
└── results_summary.md         ← comparison table: original vs. replicated values
```

---

## 11. References

- Pennycook, G., Epstein, Z., Mosleh, M., Arechar, A. A., Eckles, D., & Rand, D. G. (2021). Shifting attention to accuracy can reduce misinformation online. *Nature*, 592, 590–595. https://doi.org/10.1038/s41586-021-03344-2
- Original Stata code: `Data_and_code/Study_6_code.do`
- Raw data: `Data_and_code/Study_6_b1_data.csv`, `Data_and_code/Study_6_b2_data.csv`

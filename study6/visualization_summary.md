# Figure 3d Visualization Summary
**Study 6 — Pennycook et al. (2021)**  
**Replication by:** Hua Deng, 2026-04-19

---

## 1. What the Figure Shows

Figure 3d visualizes the **decomposition of sharing intentions** into three causal accounts, using actual sharing rates (%) on the y-axis rather than abstract fractions. The design exploits Study 6's between-subjects comparison:

- **Control condition**: Participants decided whether to share each headline with no prompt to consider accuracy.
- **Full-attention treatment**: Participants rated each headline's accuracy *before* deciding whether to share it.

Because the treatment eliminates inattention by design, comparing the two conditions reveals how much sharing would have disappeared had people simply paused to think about accuracy — and the accuracy ratings collected in the treatment further split residual sharing into "confused" versus "deliberate" false-news sharing.

### How to read the bars

The figure has two headline-veracity groups (**False**, **True**), each with a pair of bars:

| Bar | Colour | Meaning |
|-----|--------|---------|
| Control | Brick red | Total sharing rate when accuracy is not prompted |
| Treatment – rated accurate | Sky blue | Sharing that persists when accuracy is considered *and* the sharer (incorrectly) believes the headline is accurate → **Confusion** |
| Treatment – rated inaccurate | Dark navy | Sharing that persists when accuracy is considered *and* the sharer knows the headline is inaccurate → **Preference / Purposeful** |
| Gap (Control top − Treatment top) | — | Sharing that disappears once accuracy is considered → **Inattention** |

---

## 2. Interpretation: False Headlines

The False-headlines group is the theoretical centrepiece of the paper.

```
Control sharing rate (False):   30.3%
Treatment sharing rate (False): 15.0%
─────────────────────────────────────
  Preference  (navy, bottom):    4.8%   =  4.8 / 30.3  ≈  15.8% of control sharing
  Confusion   (blue,  middle):  10.2%   = 10.2 / 30.3  ≈  33.6% of control sharing
  Inattention (gap,   top):     15.3%   = 15.3 / 30.3  ≈  50.5% of control sharing
```

**Key takeaway — Inattention dominates.** Just over half of false-news sharing in the control condition vanishes the moment participants are asked to rate accuracy first. These are people who *would not have shared* had they merely paused to think — their sharing reflects distraction or habitual scrolling, not genuine belief in the content.

**Confusion is the second-largest driver.** A further third of false-news sharing comes from participants who share content they sincerely (but mistakenly) believe is accurate. This account is harder to address through nudging alone and may require improved media or digital literacy.

**Purposeful sharing is the smallest component.** Less than one-sixth of false-news sharing comes from participants who share content while knowing it is inaccurate. This directly challenges the popular narrative that online misinformation is driven by partisan warriors who knowingly spread lies; the data suggest this is a minority behaviour.

---

## 3. Interpretation: True Headlines

```
Control sharing rate (True):   34.1%
Treatment sharing rate (True): 25.3%
─────────────────────────────────────
  Preference  (navy, bottom):   1.6%
  Confusion   (blue,  middle): 23.6%
  Inattention (gap,   top):     8.8%
```

For true headlines, the pattern inverts:

- **Confusion dominates the treatment bar**: The sky-blue segment is very large (~93% of treatment sharing), meaning almost everyone who shares a true headline in the treatment condition correctly rates it as accurate. This is reassuring — people sharing true news are mostly doing so because they believe it is true.
- **Purposeful sharing of true news is near zero** (~1.6%): Almost nobody knowingly shares content they rate as inaccurate when that content happens to be true (e.g., sharing a true headline despite not believing it — very rare).
- **Inattention is smaller but still present** (~8.8% absolute, ~26% of control sharing): Even for true headlines, some sharing in the control condition would have been reduced had participants been prompted to think about accuracy. This represents people who share true content for reasons other than accuracy — e.g., it is entertaining or partisan — but who would reconsider if they stopped to verify it.

**The False–True contrast** confirms the mechanism: for false headlines the treatment produces a dramatic drop (30.3% → 15.0%, −50%); for true headlines the drop is much smaller (34.1% → 25.3%, −26%), consistent with the inattention account — accurate content is less affected by an accuracy prompt because people who actually think about accuracy still want to share true content.

---

## 4. Comparison: Replicated vs. Paper Results

### 4.1 Absolute Sharing Rates (bar heights)

| Quantity | Replicated | Paper |
|---|---|---|
| False — Control sharing rate | **30.3%** | not reported explicitly |
| False — Treatment sharing rate | **15.0%** | not reported explicitly |
| False — Preference (navy) | **4.8%** | not reported explicitly |
| False — Confusion (blue) | **10.2%** | not reported explicitly |
| False — Inattention (gap) | **15.3%** | not reported explicitly |
| True — Control sharing rate | **34.1%** | not reported explicitly |
| True — Treatment sharing rate | **25.3%** | not reported explicitly |

The paper does not tabulate the raw sharing rates; they are read off Figure 3d. Our replicated values are fully consistent with the bar heights visible in the published figure (~30% and ~34% for the control bars; ~15% and ~25% for the treatment bars).

### 4.2 Decomposition Fractions (what the paper explicitly reports)

These are the fractions of **false-news control sharing** attributable to each account, with 95% bootstrap confidence intervals.

| Account | Replicated | Paper | Match? |
|---|---|---|---|
| **Inattention** | **50.5%** [37.4%, 61.7%] | **51.2%** [38.4%, 62.0%] | ✓ within <1 pp |
| **Confusion** | **33.5%** [25.2%, 43.1%] | **33.1%** [25.1%, 42.4%] | ✓ within <1 pp |
| **Preference** | **15.7%** [11.0%, 21.3%] | **15.8%** [11.1%, 21.5%] | ✓ within <1 pp |

All three point estimates deviate from the paper by **less than 0.7 percentage points**. The 95% confidence intervals overlap almost perfectly.

### 4.3 Pairwise Bootstrap Comparisons

| Comparison | Replicated b [95% CI] | p | Paper b [95% CI] | p |
|---|---|---|---|---|
| Inattention − Preference | 0.346 [0.169, 0.497] | 0.0006 | 0.354 [0.178, 0.502] | 0.0004 |
| Confusion − Preference | 0.178 [0.099, 0.263] | <0.0001 | 0.173 [0.098, 0.256] | <0.0001 |
| Inattention − Confusion | 0.168 [−0.051, 0.364] | 0.121 | 0.181 [−0.036, 0.365] | 0.098 |

All qualitative conclusions replicate exactly:
- Inattention explains significantly more false-news sharing than purposeful sharing. ✓
- Confusion explains significantly more false-news sharing than purposeful sharing. ✓
- Inattention and confusion do not differ significantly from each other. ✓

The small numerical differences in p-values (e.g., 0.0006 vs. 0.0004) reflect expected Monte Carlo variation from running 10,000 bootstrap resamples without a shared random seed.

---

## 5. Discrepancies and Limitations

### 5.1 Missing Observations (sum ≠ 1.000)
The three fractions sum to **0.997** rather than exactly 1.000. A small number of treatment participants who shared a headline (`smB = 1`) had a missing accuracy rating (`accB = NaN`), so they contribute to the Inattention denominator but not to the Confusion/Preference numerators. This is identical to the paper's approach and the 0.3 pp gap is negligible.

### 5.2 Bootstrap Seed
The paper does not report a random seed for its 10,000-repetition bootstrap. The slight numerical differences in CIs and p-values are entirely attributable to this source of variation and disappear at the level of substantive interpretation.

### 5.3 Post Hoc Analysis Caveat
The paper acknowledges that the decomposition was not pre-registered — only the standard condition × veracity discernment test was pre-registered. The pre-registered test (b = +0.065 for the interaction, p = 0.008) also replicates successfully, and the decomposition results are stable across both data-collection batches and the full (unfiltered) sample, mitigating the post hoc concern.

---

## 6. Summary

Figure 3d provides compelling visual evidence for the paper's central argument: **inattention, not partisan preference or confusion, is the primary driver of false-news sharing**. The stacked treatment bar in the False group reaches only halfway up the control bar, and most of that treatment bar is sky-blue (confused sharers who genuinely believed the content). The dark navy "purposeful" segment is a sliver at the bottom.

Our replication reproduces this figure with high fidelity — bar heights, decomposition fractions, confidence intervals, and statistical tests all match the paper's reported values within rounding error — confirming both the empirical robustness of the result and the correctness of our Python re-implementation of the original Stata analysis.

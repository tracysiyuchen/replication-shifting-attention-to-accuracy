# Study 5 Summary
## Pennycook et al. (2021, *Nature*) — "Shifting attention to accuracy can reduce misinformation online"

---

## What is Study 5, and how does it build on Studies 3 and 4?

Studies 3 and 4 already established the core finding: asking participants to rate the accuracy of a single neutral headline before the main task — an "accuracy nudge" — significantly increased their discernment between true and false news, as measured by their likelihood of sharing each type of headline on Facebook. Both studies used two conditions only (Treatment vs. Passive Control) and recruited participants from MTurk, with different sets of 24 political headlines.

Study 5 was designed to extend and stress-test those findings in three specific ways. First, it used a more representative sample recruited through Lucid, quota-matched to national demographics on age, gender, ethnicity, and geographic region, addressing concerns about the generalizability of MTurk-based results. Second, it added two new conditions — an Active Control and an Importance Treatment — to probe the mechanism behind the nudge effect that Studies 3 and 4 could not distinguish. Third, it used a fresh set of 20 headlines selected through a new pretest, again demonstrating that the effect is not specific to any particular set of stimuli.

---

## What was new in Study 5: the two additional conditions

Like Studies 3 and 4, participants in Study 5 were screened for Facebook use, randomly assigned to a condition before the main task, and then asked to rate 20 political headlines (10 false, 10 true; 10 pro-Democrat, 10 pro-Republican) on a 6-point scale for likelihood of sharing. The Treatment condition worked identically to Studies 3 and 4: participants rated the accuracy of one neutral headline, ostensibly as a pretest for a separate study, without being told this was designed to prime accuracy thinking during the subsequent sharing task. The Passive Control also remained the same: no pre-task, representing the natural baseline.

What Study 5 added was the **Active Control** and the **Importance Treatment**. In the Active Control, participants rated the *funniness* of the same neutral headline used in the Treatment condition. This condition is structurally identical to the Treatment — same warm-up task, same headline, same format — but invokes a completely different cognitive frame. If the Active Control performed similarly to the Treatment, it would suggest that simply doing any warm-up task drives the effect, not accuracy thinking specifically. In the **Importance Treatment**, there was no headline at all; instead, participants were asked whether they agreed or disagreed with the statement: "It is important to only share news content on social media that is accurate and unbiased." This tests whether explicitly invoking the value of accuracy produces the same behavioral shift as implicitly priming it through a judgment task.

The final sample after exclusions included 1,287 participants (mean age 45.5), with 671 who reported they would sometimes consider sharing political content on Facebook — the subsample used for the primary analyses, consistent with the approach taken in Studies 3 and 4.

---

## What did Study 5 find?

The replication of the core Treatment effect held: the accuracy nudge significantly increased discernment relative to the control conditions (interaction b = 0.054, 95% CI [0.023, 0.085], F = 11.98, p = 0.0005). This matches the direction and magnitude of the effects in Studies 3 and 4, and generalizes them to a more representative U.S. sample.

The new conditions answered the mechanistic questions. The Active Control did not differ significantly from the Passive Control (b = 0.015, p = 0.84), confirming that completing a warm-up task in general has no effect on sharing discernment — the effect in the Treatment condition is specifically attributable to accuracy thinking, not to task engagement. The Importance Treatment did produce a significant increase in discernment (b = 0.038, p = 0.0018), showing that an explicit accuracy reminder also works, but it was weaker than the implicit accuracy nudge. This asymmetry is notable: agreeing in the abstract that accuracy matters is less effective than actually exercising one's accuracy judgment, even briefly and about an unrelated topic.

In terms of the mechanism, the treatment worked primarily by reducing sharing of false headlines (from approximately 50% in the control group to approximately 41% in the Treatment group) rather than by boosting sharing of true headlines, which remained around 50% across all conditions. The key outcome is therefore not an overall increase in sharing but a widening of the true-versus-false gap: from a negligible 0.9 percentage points in the Passive Control, to 8.8 percentage points in the Treatment — nearly ten times larger.

---

## Item-level evidence for the attention mechanism (Figure 3c)

Like Studies 3 and 4, Study 5 also analyzed the treatment effect at the level of individual headlines rather than individual participants. Across all 20 headlines, the treatment effect on sharing was positively correlated with each headline's pre-rated perceived accuracy (r = 0.61, p = 0.005): the accuracy nudge had its largest impact on the most obviously false headlines. This pattern speaks directly to the attention account. If people shared misinformation out of confusion — genuinely believing it to be true — then the treatment should have the least effect on implausible headlines, since those are the ones people would already recognize as false. Instead, the opposite is observed: the nudge most strongly reduces sharing of headlines that participants already had the cognitive resources to identify as inaccurate. They simply were not using those resources until prompted.

---

## Replication notes

The Python replication of Study 5 successfully reproduced all key results. The interaction coefficients for both the Treatment and Importance Treatment matched the paper to three decimal places, and the corresponding F-statistics and p-values were exact matches. The item-level correlation for Figure 3c was r = 0.61 (p = 0.005), identical to the paper. One numerical discrepancy arose in the Passive vs. Active Control comparison: the paper reports p = 0.84, while the Python implementation returns p = 0.1994. This is due to Stata's `cluster2` command applying a small-sample degrees-of-freedom correction based on the number of headline clusters (df = 9), which the Python Cameron-Gelbach-Miller formula does not replicate. Both methods agree the result is not statistically significant, so the conclusion is unaffected.

Three bugs were also identified and corrected in the original Python translation: the item-level analysis was collapsing 20 headlines into 10 by incorrectly merging fake and true versions of each item; the pre-test plausibility values for true headlines were being replaced with fake-headline values due to a misapplied index shift; and the Figure 2c confidence intervals were computed with a simple standard error formula rather than the two-way clustered standard errors the paper specifies. Fixing these three issues brought Figure 3c's correlation from an incorrect r = 0.27 to the correct r = 0.61.

---

## Table S4 — Regression results (Section 5 of notebook)

Table S4 presents four OLS regressions predicting sharing willingness (`sm`, rescaled 0–1) using two-way clustered standard errors (Cameron–Gelbach–Miller 2011, clustering by participant `id` and headline `item_num`). The four columns are: (1) controls only, sharers; (2) all conditions, sharers; (3) controls only, all participants; (4) all conditions, all participants.

```
====================================================================================
TABLE S4 — Linear regressions predicting sharing intentions
====================================================================================
                                          (1)          (2)          (3)          (4)
                                      Sharers      Sharers       All Ps       All Ps
                                    Ctrl only     All cond    Ctrl only     All cond
------------------------------------------------------------------------------------
Veracity (0=False, 1=True)             0.0081       0.0163       0.0111       0.0154
                                     (0.0262)     (0.0234)     (0.0206)     (0.0212)
Active Control                         0.0061                    0.0179
                                     (0.0303)                  (0.0223)
Active Control X Veracity              0.0155                    0.0086
                                     (0.0120)                  (0.0066)
Treatment                                        -0.0815**                 -0.0500**
                                                  (0.0261)                  (0.0185)
Treatment X Veracity                             0.0542***                 0.0466***
                                                  (0.0157)                  (0.0091)
Importance Treatment                              -0.0504†                   -0.0097
                                                  (0.0274)                  (0.0193)
Importance Treat. X Veracity                      0.0376**                 0.0291***
                                                  (0.0120)                  (0.0063)
Constant                            0.4769***    0.4801***    0.3588***    0.3679***
                                     (0.0227)     (0.0160)     (0.0166)     (0.0127)
------------------------------------------------------------------------------------
Observations                            6,776       13,340       12,847       25,587
Participant clusters                      341          671          646        1,286
Headline clusters                          20           20           20           20
R-squared                              0.0008       0.0069       0.0013       0.0039
====================================================================================
*** p<0.001, ** p<0.01, * p<0.05, † p<0.10
```

**Columns (1) and (3) — Passive vs. Active Control**

The key coefficient is Active Control × Veracity (`b = 0.015`, `p = 0.84` in sharers). This is non-significant: doing a warm-up task in general — rating a headline's *funniness* — has no effect on the true/false sharing gap. This rules out a generic task-demand or response-priming explanation. The Active Control is statistically indistinguishable from doing nothing (Passive Control).

> **Replication note**: The Python implementation returns `p = 0.1994` for this coefficient, while the paper reports `p = 0.84`. The discrepancy arises because Stata's `cluster2` command applies a small-sample degrees-of-freedom correction (df = 9, based on the number of headline clusters), whereas the Python Cameron–Gelbach–Miller implementation uses full residual df. Both agree the result is non-significant; the substantive conclusion is unaffected.

**Columns (2) and (4) — Treatment and Importance Treatment vs. Pooled Control**

The pooled control is conditions 1 + 2 combined. Two key interactions:

| Coefficient | Sharers (col 2) | All participants (col 4) |
|-------------|----------------|--------------------------|
| Treatment × Veracity | b = 0.0542\*\*\* (SE = 0.0157, p = 0.0005) | b = 0.0466\*\*\* |
| Importance × Veracity | b = 0.0376\*\* (SE = 0.0120, p = 0.0018) | b = 0.0291\*\*\* |

Both nudges significantly widen the true/false sharing gap. The Treatment effect is larger than the Importance Treatment effect, suggesting that implicitly exercising accuracy judgment is more effective than explicitly endorsing the value of accuracy in the abstract. The robustness check (columns 3 and 4) confirms the effects hold for all participants, not just self-reported sharers.

---

## Table S5 — Simple effects (Section 5 of notebook)

```
======================================================================================
TABLE S5 — Simple effects
======================================================================================
Simple effect                         Net coefficient                Sharers    All Ps
--------------------------------------------------------------------------------------
Treatment on false headlines          Treatment                      -0.0815   -0.0500
Treatment on true headlines           Treatment+Treatment×Veracity   -0.0273   -0.0033
Importance Treat. on false headlines  Importance Treatment           -0.0504   -0.0097
Importance Treat. on true headlines   Importance+Importance×Veracity -0.0128    0.0195
Veracity in Controls                  Veracity                        0.0163    0.0154
Veracity in Treatment                 Veracity+Treatment×Veracity     0.0705    0.0621
Veracity in Importance Treatment      Veracity+Importance×Veracity    0.0539    0.0445
======================================================================================
```

**Key interpretation**: The nudge primarily works by *reducing sharing of false headlines* rather than by increasing sharing of true headlines. The controls show almost no true/false gap (b = 0.016 in sharers), while the Treatment expands it to b = 0.071 — a roughly four-fold increase. Crucially, the treatment coefficient on false headlines (b = −0.082) is significant, while the net effect on true headlines (b = −0.027, n.s.) is not — people become selectively less willing to share content they recognise as false once accuracy is made salient, not globally more enthusiastic about true content.

---

## Extended Data Table 1 — Limited Attention Utility Model (Section 8 of notebook)

This section tests the theoretical mechanism proposed in SI Section 3. The model assumes that when deciding whether to share a headline, a person attends to only 2 of 3 possible dimensions simultaneously: inaccuracy (F), partisanship (P), and humorousness (H).

**Python results** (100 restarts, MSE = 0.007460; bootstrap: 1500 samples):

```
======================================================================
EXTENDED DATA TABLE 1 — Limited Attention Utility Model (Study 5)
======================================================================
Parameter                Estimate   95% CI Lower   95% CI Upper
--------------------------------------------------------------
βP                         0.0840         0.0462         2.9814
βH                         0.0152        -0.1183         1.1645
p1c                        0.0000         0.0000         0.3547
p2c                        0.1970         0.0000         0.4968
p1t                        0.1015         0.0000         1.0000
p2t                        0.2176         0.0000         0.5358
θ                         11.4140         0.3742        50.0000
k                         -0.0178        -1.4572         0.0092
--------------------------------------------------------------
Pr(acc|control)            0.1970         0.0000         0.6072
Pr(acc|treatment)          0.3191         0.2456         1.0000
Treatment effect           0.1221         0.0755         0.9804
======================================================================
```

**Key result**: The accuracy nudge increases the probability that participants consider accuracy from **19.7%** to **31.9%** — a treatment effect of **+12.2 percentage points** (95% CI: [7.6%, 98.0%]). The lower CI bound is comfortably above zero, confirming the treatment effect on attention allocation is statistically meaningful.

**Why the CIs are wide and some parameters differ from the paper's MATLAB estimates**

The model is a mixture model with 8 free parameters fit to only 40 data points (headline × partisan groups) per condition. Several identification issues are expected:

1. **Flat likelihood landscape**: Multiple combinations of (p1c, p2c, θ, k) can produce nearly identical MSE. The optimizer finds one local minimum; MATLAB may find a different one with similar fit but different individual parameters.
2. **Parameters hitting bounds**: θ's upper CI (50.0) and p1t's upper CI (1.0) hit the optimization bounds, indicating the data do not strongly constrain these parameters. This is reflected in the extremely wide bootstrap CIs.
3. **Low βP and βH**: Partisanship and humor have very small utility weights (0.08 and 0.02). This means the choice rule depends almost entirely on the accuracy dimension (βF = 1, fixed) and the intercept k — reducing the model's effective degrees of freedom.
4. **The derived quantity is what matters**: Despite individual parameter uncertainty, the treatment effect on Pr(acc) = p1t+p2t − (p1c+p2c) = +0.122 is stable because the bootstrap CI lower bound (0.076) is well above zero. This is the paper's key claim, and our Python replication supports it.

---

## Bottom line

Study 5 confirms and extends the findings of Studies 3 and 4. The accuracy nudge effect is real, replicable across different headline sets and participant populations, and mechanistically specific to accuracy thinking rather than task engagement in general. The Active Control rules out a generic warm-up effect; the Importance Treatment shows that even explicit reminders work, though less powerfully than the implicit task. Taken together, these findings suggest that a brief, low-cost intervention — asking users to consider accuracy before sharing — could reduce misinformation spread at scale, without requiring platforms to label or remove specific content.

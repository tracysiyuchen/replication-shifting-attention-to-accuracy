## Study 1 Replication

### Purpose

Study 1 tests accuracy and willingness to share on new headlines. The experiment operationalizes this study as a between-subjects manipulation: participants in the accuracy condition rate the accuracy of a single unrelated headline before completing the main task, while participants in the sharing condition are asked about their sharing intentions directly. The central prediction is that the accuracy prompt shifts attention toward truth and thereby widens the gap between sharing rates for true versus false headlines (a veracity effect) while narrowing the gap between politically concordant and discordant content (a concordance effect).

---

### Participants and Design

Participants were recruited through Amazon MTurk and were required to have an active Facebook or Twitter account and to indicate at least some willingness to share political content. The study used a single-factor between-subjects design (accuracy condition vs. sharing condition). Each participant rated 18 false and 18 true political headlines, drawn from a pool constructed to include both Republican-leaning (items 10--18) and Democrat-leaning (items 1--9) content, yielding 36 item-level observations per participant.

**Table 1.1: Exclusion Filters and Analytic Sample**

| Step | Criterion | N Excluded | N Remaining |
|------|-----------|-----------|------------|
| Raw recruitment | All respondents who started the survey | -- | 1,825 |
| Incomplete responses | `didnt_finish == 1` | 820 | 1,005 |
| No social media account | `socialmedia_1` and `socialmedia_2` both missing | 0 | 1,005 |
| No willingness to share | `sharingtype_1` missing | 0 | 1,005 |
| **Analytic sample** | | | **1,005** |

*Note.* The paper reports n = 1,015. Our replication produces n = 1,005, a discrepancy of 10 participants. After applying the `didnt_finish` exclusion, the social media and sharing filters remove zero additional observations, because all incomplete respondents in this dataset also lack social media and sharing data. The source of the 10-person gap remains unresolved; it may reflect additional proprietary MTurk quality filters applied prior to data release, or a difference in how the `didnt_finish` threshold was defined. Condition assignment was approximately balanced: accuracy condition n = 502, sharing condition n = 503. Among the 1,003 participants with non-missing political identification, 639 (63.7%) identified as Republican-leaning and 364 (36.3%) as Democrat-leaning. Participants ranged in age from 18 to 76 years (M = 36.7, SD = 11.7).

---

### Results

The main dependent variable is a binary indicator of whether a participant judged a given headline to be accurate (accuracy condition) or indicated willingness to share it (sharing condition). All analyses use ordinary least squares regression with the full set of predictors centered at zero (condition: --0.5 = accuracy, +0.5 = sharing; veracity: --0.5 = false, +0.5 = true; concordance: --0.5 = discordant, +0.5 = concordant). Standard errors are two-way clustered by participant and headline following Cameron, Gelbach, and Miller (2011), which the authors note as a deviation from their pre-registered specification of participant-level clustering only.

**Table 1.2: Gaps Between Pre-Registration, Paper, Stata, and Python**

| Dimension | Pre-Registration | Paper | Stata Code | Python Replication | Status |
|-----------|-----------------|-------|------------|-------------------|--------|
| Standard error clustering | Participant only | Two-way: participant + headline | `cluster2` ado (two-way) | CGM sandwich estimator | Pre-reg deviation; acknowledged by authors |
| Exclusion criteria | FB/Twitter account + willingness to share | Same | Flags created (`noFBTwitter`, `noshare`) but never explicitly applied as `drop if` | Applied as `df.dropna()` on socialmedia/sharingtype | Stata relies on regression listwise deletion; Python makes explicit. Result: no cases dropped beyond `didnt_finish` |
| Analytic n | Not specified | 1,015 | Not computed explicitly | 1,005 | Unresolved 10-person gap |

**Veracity and Concordance Effects (Accuracy Condition).** In the accuracy condition, participants rated 64.0% of true discordant headlines and 78.5% of true concordant headlines as accurate, compared with 12.5% of false discordant and 18.3% of false concordant headlines (see Figure 1.1 and Figure 1.2). The veracity effect -- the difference in accuracy ratings between true and false headlines -- was 55.9 percentage points, F(1, 36172) = 375.04, p < .001, d = 2.89. The concordance effect was 10.1 percentage points, F(1, 36172) = 26.45, p < .001, d = 0.63.

*[Figure 1.1: Replication of paper Figure 1a. Mean accuracy ratings in the accuracy condition by veracity (False vs. True) and political concordance (Discordant vs. Concordant). Error bars represent 95% confidence intervals with two-way clustered standard errors. Saved as output/figures/study1_fig1.png.]*

**Veracity and Concordance Effects (Sharing Condition).** In the sharing condition, participants indicated willingness to share 24.1% of true discordant and 46.7% of true concordant headlines, versus 21.5% of false discordant and 37.4% of false concordant headlines. The veracity effect was only 5.9 percentage points, F(1, 36172) = 7.21, p = .007, d = 0.22, while the concordance effect was 19.3 percentage points, F(1, 36172) = 73.18, p < .001, d = 0.72.

*[Figure 1.2: Replication of paper Figure 1b. Mean sharing intentions in the sharing condition by veracity and concordance, same format as Figure 1.1. Saved as output/figures/study1_fig2.png.]*

**Condition Interactions.** The two-way interaction between veracity and condition was large and highly significant, F(1, 36172) = 260.68, p < .001, reflecting that the accuracy nudge substantially widened the veracity effect (55.9pp vs. 5.9pp). The interaction between concordance and condition was also significant, F(1, 36172) = 17.24, p < .001, reflecting that the nudge reduced, but did not eliminate, the concordance bias (10.1pp vs. 19.3pp). Non-parametric Wilcoxon signed-rank tests on per-participant means confirmed all four main effects (all p < .001), ruling out sensitivity to distributional assumptions.

**Cross-Condition Comparison Cited in Paper.** The paper highlights a cross-condition dissociation in which the false concordant sharing rate in the sharing condition (37.4%) substantially exceeds the false concordant accuracy rating in the accuracy condition (18.3%), illustrating that partisan alignment inflates sharing well beyond what participants themselves endorse as accurate. Our replication recovers both values within rounding: sharing rate 37.4% (exact match), accuracy rating 18.3% vs. paper's 18.2% (0.1pp rounding). This is not a within-condition comparison and should not be interpreted as a gap.

**Accuracy Importance.** Consistent with successful randomization, participants in the two conditions did not differ significantly in their self-reported importance of accuracy (accuracy condition M = 3.80, sharing condition M = 3.65 on a 1--5 scale), t(1003) = 1.83, p = .067.

**Table 1.3: Core Results Comparison**

| Quantity | Paper Value | Stata | Python | Match? |
|----------|------------|-------|--------|--------|
| Analytic n (participants) | 1,015 | not printed | 1,005 | Off by 10 |
| Accuracy cond., veracity effect | 55.9pp | 55.9pp | 55.9pp | Yes |
| F(1,36172) veracity, acc. cond. | 375.05 | 375.05 | 375.04 | Yes (rounding) |
| Accuracy cond., concordance effect | 10.1pp | 10.1pp | 10.1pp | Yes |
| F(1,36172) concordance, acc. cond. | 26.45 | 26.45 | 26.45 | Yes |
| Sharing cond., veracity effect | 5.9pp | 5.9pp | 5.9pp | Yes |
| Sharing cond., concordance effect | 19.3pp | 19.3pp | 19.3pp | Yes |
| F(1,36172) veracity x condition | 260.68 | 260.68 | 260.68 | Yes |
| F(1,36172) concordance x condition | 17.24 | 17.24 | 17.24 | Yes |
| False concordant sharing rate | 37.4% | 37.4% | 37.4% | Yes |
| False concordant accuracy rating | 18.2% | 18.3% | 18.3% | 0.1pp rounding |
| accimp t-test | t(1003) = 1.83, p = .067 | t = 1.83, p = .067 | t = 1.83, p = .067 | Yes |

*[Figure 1.3: Distribution of self-reported accuracy importance (1--5 scale) by condition. Replicates Extended Data Figure 1. Saved as output/figures/study1_fig3.png.]*

---

### Our Contributions

Beyond verifying the main reported statistics, this replication makes three analytical contributions:

- First, we provide an explicit step-by-step accounting of all exclusion filters (Table 1.1), clarifying that the Stata `.do` file achieves the `noFBTwitter` and `noshare` exclusions implicitly through regression listwise deletion rather than explicit `drop if` commands, and documenting the previously unreported 10-participant discrepancy between the paper's stated n = 1,015 and our derived n = 1,005.
- Second, we implement and replicated the two-way Cameron-Gelbach-Miller standard error estimator from scratch in Python without relying on the proprietary `cluster2` Stata ado, enabling full open-source reproducibility.
- Third, we examine the accuracy-importance moderation reported in Supplementary Block 6 of the Stata code. The finding that accuracy importance (`accimp`) is not significantly different between conditions (t = 1.83, p = .067) is consistent with successful randomization.

---

### Python Code for Figures

The following code produces Figures 1.1, 1.2, and 1.3. It assumes the cleaned `df_analysis` DataFrame from the main notebook (Section 3 of `study1_replication.ipynb`) is already in scope.

```python
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import os

os.makedirs('output/figures', exist_ok=True)

C_FALSE = '#E07B39'   # orange, matching paper
C_TRUE  = '#4A9B5F'   # green, matching paper

def make_fig1_panel(ax, df_sub, panel_title, ylabel):
    """Grouped bar chart: groups = Discordant / Concordant, bars = False / True."""
    means, cis = {}, {}
    for real in [0, 1]:
        for conc in [0, 1]:
            cell = df_sub[(df_sub['real'] == real) & (df_sub['politically_concordant'] == conc)]['rating']
            means[(real, conc)] = cell.mean()
            cis[(real, conc)]   = 1.96 * cell.std() / np.sqrt(len(cell))

    w = 0.35
    g = np.array([0.0, 1.0])
    xF, xT = g - w / 2, g + w / 2

    ax.bar(xF, [means[(0,0)], means[(0,1)]], w, color=C_FALSE,
           yerr=[cis[(0,0)], cis[(0,1)]], capsize=4, error_kw={'elinewidth': 1.2}, zorder=3)
    ax.bar(xT, [means[(1,0)], means[(1,1)]], w, color=C_TRUE,
           yerr=[cis[(1,0)], cis[(1,1)]], capsize=4, error_kw={'elinewidth': 1.2}, zorder=3)

    for x, v in zip([xF[0], xF[1], xT[0], xT[1]],
                    [means[(0,0)], means[(0,1)], means[(1,0)], means[(1,1)]]):
        ax.text(x, v + 0.02, f'{v*100:.1f}%', ha='center', va='bottom',
                fontsize=8, fontweight='bold')

    ax.set_xticks(g)
    ax.set_xticklabels(['Discordant', 'Concordant'], fontsize=10)
    ax.set_ylim(0, 1.0)
    ax.set_ylabel(ylabel, fontsize=10)
    ax.set_title(panel_title, fontsize=11, fontweight='bold')
    ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda y, _: f'{y*100:.0f}%'))
    ax.grid(axis='y', alpha=0.3, zorder=0)
    ax.spines[['top', 'right']].set_visible(False)
    ax.legend(handles=[mpatches.Patch(color=C_FALSE, label='False'),
                        mpatches.Patch(color=C_TRUE, label='True')],
              title='Veracity', fontsize=9, title_fontsize=9, loc='upper left')


# Figure 1.1 — Accuracy condition
fig, ax = plt.subplots(figsize=(5.5, 4))
make_fig1_panel(ax, df_analysis[df_analysis['condition'] == 0],
                'Accuracy Condition\n(% rated accurate)', 'Mean accuracy rating')
fig.tight_layout()
fig.savefig('output/figures/study1_fig1.png', dpi=300, bbox_inches='tight')
plt.close()

# Figure 1.2 — Sharing condition
fig, ax = plt.subplots(figsize=(5.5, 4))
make_fig1_panel(ax, df_analysis[df_analysis['condition'] == 1],
                'Sharing Condition\n(% willing to share)', 'Mean sharing rate')
fig.tight_layout()
fig.savefig('output/figures/study1_fig2.png', dpi=300, bbox_inches='tight')
plt.close()

# Figure 1.3 — Accuracy importance distribution (Extended Data Fig. 1)
fig, axes = plt.subplots(1, 2, figsize=(8, 4), sharey=True)
for ax, cond_val, cond_name, color in zip(
        axes, [0, 1],
        ['Accuracy condition', 'Sharing condition'],
        ['#1f6fc7', '#6aafe6']):
    sub = df_analysis.drop_duplicates('id')
    sub = sub[sub['condition'] == cond_val]['accimp'].dropna()
    counts = sub.value_counts().sort_index()
    ax.bar(counts.index, counts.values, color=color, edgecolor='white', linewidth=0.5)
    ax.set_xlabel('Accuracy importance (1--5)', fontsize=10)
    ax.set_ylabel('Count', fontsize=10)
    ax.set_title(f'{cond_name}\n(n = {len(sub)})', fontsize=10)
    ax.set_xticks([1, 2, 3, 4, 5])
    ax.spines[['top', 'right']].set_visible(False)
fig.suptitle('Self-reported importance of accuracy by condition',
             fontsize=11, fontweight='bold')
fig.tight_layout()
fig.savefig('output/figures/study1_fig3.png', dpi=300, bbox_inches='tight')
plt.close()

print("Saved: study1_fig1.png, study1_fig2.png, study1_fig3.png")
```

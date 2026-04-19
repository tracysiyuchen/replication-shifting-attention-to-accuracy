"""
Study 6 Replication: Shifting Attention to Accuracy Can Reduce Misinformation Online
Pennycook et al. (2021), Nature 592, 590-595.

Replicates the decomposition of false-news sharing into Inattention, Confusion,
and Purposeful sharing (Figure 3d and Extended Data Table 2).
"""

import os
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from scipy import stats
import warnings
warnings.filterwarnings("ignore")

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "Data_and_code")
FIG_DIR  = os.path.join(os.path.dirname(__file__), "figures")
os.makedirs(FIG_DIR, exist_ok=True)

N_BOOT   = 10_000
RNG_SEED = 42

# ---------------------------------------------------------------------------
# 1. LOAD AND COMBINE BATCHES
# ---------------------------------------------------------------------------
b1 = pd.read_csv(os.path.join(DATA_DIR, "Study_6_b1_data.csv"), sep="\t", encoding="latin1")
b2 = pd.read_csv(os.path.join(DATA_DIR, "Study_6_b2_data.csv"), encoding="latin1")
b1["batch"] = 1
b2["batch"] = 2

for df in (b1, b2):
    for col in df.select_dtypes("object").columns:
        df[col] = df[col].replace(r"^\s*$", np.nan, regex=True)

df = pd.concat([b1, b2], ignore_index=True)
df["id"] = np.arange(len(df))

# ---------------------------------------------------------------------------
# 2. EXCLUSIONS
# ---------------------------------------------------------------------------
df["Condition"]       = pd.to_numeric(df["Condition"],       errors="coerce")
df["FB"]              = pd.to_numeric(df["FB"],              errors="coerce")
df["SocialMedia_Chk"] = pd.to_numeric(df["SocialMedia_Chk"], errors="coerce")

df["didnt_finish"] = df["SocialMedia_Chk"].isna()
df_excl = df[~df["didnt_finish"] & (df["FB"] != 2)].copy()

print("=" * 60)
print("SAMPLE SIZES")
print("=" * 60)
print(f"  Total starters:           {len(df)}")
print(f"  Excluded (no finish):     {df['didnt_finish'].sum()}")
print(f"  Excluded (no Facebook):   {(df['FB'] == 2).sum()}")
print(f"  After exclusions:         {len(df_excl)}")
print(f"  socialmedia_chk==1:       {(df_excl['SocialMedia_Chk']==1).sum()}")

df_excl["Age"] = pd.to_numeric(df_excl["Age"], errors="coerce")
df_excl["Sex"] = pd.to_numeric(df_excl["Sex"], errors="coerce")
ana = df_excl[df_excl["SocialMedia_Chk"] == 1].copy()

print(f"\n  Full-sample mean age:     {df_excl['Age'].mean():.1f}  (paper: 34.0)")
print(f"  Analytic-sample mean age: {ana['Age'].mean():.1f}  (paper: 35.2)")
print(f"  Analytic-sample males:    {(ana['Sex']==1).sum()}  (paper: 181)")
print(f"  Analytic-sample females:  {(ana['Sex']==2).sum()}  (paper: 213)")
print(f"  Condition 1 (Control):    {(ana['Condition']==1).sum()}")
print(f"  Condition 2 (Treatment):  {(ana['Condition']==2).sum()}")

# ---------------------------------------------------------------------------
# 3. RESHAPE TO LONG FORMAT
# ---------------------------------------------------------------------------
# Column mapping (confirmed empirically):
#   FakeN_3    → control sharing  (filled for Condition==1)
#   FakeN_3.0  → treatment sharing (filled for Condition==2; duplicate col renamed by pandas)
#   FakeN_2    → treatment accuracy rating (filled for Condition==2 only)
#   Same pattern for RealN_*

ITEMS = range(1, 13)

def to_num(val):
    try:
        return float(val)
    except (TypeError, ValueError):
        return np.nan

rows = []
for _, row in df_excl.iterrows():
    pid   = row["id"]
    cond  = row["Condition"]
    smchk = row["SocialMedia_Chk"]
    batch = row["batch"]

    for item in ITEMS:
        for is_real, prefix in [(0, "Fake"), (1, "Real")]:
            sm_ctrl  = to_num(row.get(f"{prefix}{item}_3"))
            sm_treat = to_num(row.get(f"{prefix}{item}_3.0"))
            sm_raw   = sm_ctrl if not np.isnan(sm_ctrl) else sm_treat

            acc_raw  = to_num(row.get(f"{prefix}{item}_2"))

            if np.isnan(sm_raw):
                continue

            rows.append({
                "id":              pid,
                "condition":       int(cond) - 1,   # 0=control, 1=treatment
                "real":            is_real,
                "item_num":        item,
                "batch":           batch,
                "socialmedia_chk": smchk,
                "sm_raw":          sm_raw,
                "acc_raw":         acc_raw,
            })

long = pd.DataFrame(rows)
long["sm"]  = (long["sm_raw"] - 1) / 5
long["smB"] = (long["sm"] > 0.5).astype(float)
long["accB"] = np.where(long["acc_raw"].notna(),
                         (long["acc_raw"] > 2).astype(float), np.nan)

print(f"\n  Long rows (all):          {len(long)}")
print(f"  Long rows (smchk==1):     {(long['socialmedia_chk']==1).sum()}")

# ---------------------------------------------------------------------------
# 4. BALANCE CHECK
# ---------------------------------------------------------------------------
print("\n" + "=" * 60)
print("BALANCE CHECK: socialmedia_chk by condition")
print("=" * 60)
ct = pd.crosstab(df_excl["Condition"], df_excl["SocialMedia_Chk"].fillna(0).astype(int))
chi2_val, chi2_p, *_ = stats.chi2_contingency(ct)
print(f"  chi2={chi2_val:.3f}, p={chi2_p:.3f}  (paper: chi2(2)=1.07, p=0.585)")

# ---------------------------------------------------------------------------
# 5. DECOMPOSITION FUNCTION
# ---------------------------------------------------------------------------

def decompose(df_in):
    fake  = df_in[df_in["real"] == 0]
    ctrl  = fake[fake["condition"] == 0]
    treat = fake[fake["condition"] == 1]

    F_cont  = ctrl["smB"].mean()
    F_treat = treat["smB"].mean()

    shared_treat = treat[treat["smB"] == 1]
    N_treat = len(shared_treat)
    N_acc   = (shared_treat["accB"] == 1).sum()
    N_inacc = (shared_treat["accB"] == 0).sum()

    if F_cont == 0 or N_treat == 0:
        return dict(f_inn=np.nan, f_con=np.nan, f_pur=np.nan,
                    F_cont=F_cont, F_treat=F_treat)

    f_inn = (F_cont - F_treat) / F_cont
    f_con = (N_acc   / N_treat) * (F_treat / F_cont)
    f_pur = (N_inacc / N_treat) * (F_treat / F_cont)

    return dict(f_inn=f_inn, f_con=f_con, f_pur=f_pur,
                F_cont=F_cont, F_treat=F_treat,
                N_treat=int(N_treat), N_acc=int(N_acc), N_inacc=int(N_inacc))


# ---------------------------------------------------------------------------
# 6. POINT ESTIMATES
# ---------------------------------------------------------------------------
main_long = long[long["socialmedia_chk"] == 1].copy()
main_est  = decompose(main_long)

print("\n" + "=" * 60)
print("POINT ESTIMATES — main analytic sample (socialmedia_chk==1)")
print("=" * 60)
print(f"  F_cont  (false share rate, control):   {main_est['F_cont']:.3f}  ({main_est['F_cont']*100:.1f}%)")
print(f"  F_treat (false share rate, treatment): {main_est['F_treat']:.3f}  ({main_est['F_treat']*100:.1f}%)")
print(f"  N shared in treatment:                 {main_est['N_treat']}")
print(f"  N shared & rated accurate:             {main_est['N_acc']}")
print(f"  N shared & rated inaccurate:           {main_est['N_inacc']}")
print(f"\n  f_Inattention: {main_est['f_inn']:.4f}  ({main_est['f_inn']*100:.1f}%)  [paper: 51.2%]")
print(f"  f_Confusion:   {main_est['f_con']:.4f}  ({main_est['f_con']*100:.1f}%)  [paper: 33.1%]")
print(f"  f_Purposeful:  {main_est['f_pur']:.4f}  ({main_est['f_pur']*100:.1f}%)  [paper: 15.8%]")
print(f"  Sum (check≈1): {main_est['f_inn']+main_est['f_con']+main_est['f_pur']:.4f}")

# ---------------------------------------------------------------------------
# 7. VECTORIZED BOOTSTRAP
# ---------------------------------------------------------------------------
# Pre-build per-subject arrays for speed: for each subject store arrays of
# (condition, smB, accB, real) so resampling is pure numpy.

print("\nRunning bootstrap (10,000 reps)...", flush=True)

# Restrict to fake headlines in analytic sample
fake_main = main_long[main_long["real"] == 0].copy().reset_index(drop=True)
subjects  = fake_main["id"].unique()

# Build subject-level summary arrays (one entry per subject-item observation)
# We need: for each bootstrap draw (resample subjects), recompute F_cont, F_treat, N/acc/inacc
# Strategy: store per-subject aggregates to make bootstrap fast.

# For control subjects: total items, items shared
# For treatment subjects: total items, items shared, shared+acc, shared+inacc

ctrl_subj  = fake_main[fake_main["condition"] == 0].groupby("id")
treat_subj = fake_main[fake_main["condition"] == 1].groupby("id")

# Control subjects: [n_items, n_shared]
ctrl_ids   = ctrl_subj["smB"].count().index.values
ctrl_n     = ctrl_subj["smB"].count().values
ctrl_sh    = ctrl_subj["smB"].sum().values

# Treatment subjects: [n_items, n_shared, n_shared_acc, n_shared_inacc]
treat_ids     = treat_subj["smB"].count().index.values
treat_n       = treat_subj["smB"].count().values
treat_sh      = treat_subj["smB"].sum().values
treat_sh_acc  = treat_subj.apply(lambda g: ((g["smB"] == 1) & (g["accB"] == 1)).sum()).values
treat_sh_ina  = treat_subj.apply(lambda g: ((g["smB"] == 1) & (g["accB"] == 0)).sum()).values

rng = np.random.default_rng(RNG_SEED)

boot_inn = np.empty(N_BOOT)
boot_con = np.empty(N_BOOT)
boot_pur = np.empty(N_BOOT)

n_ctrl  = len(ctrl_ids)
n_treat = len(treat_ids)

for b in range(N_BOOT):
    # Resample control subjects
    ci = rng.integers(0, n_ctrl,  size=n_ctrl)
    # Resample treatment subjects
    ti = rng.integers(0, n_treat, size=n_treat)

    total_ctrl  = ctrl_n[ci].sum()
    shared_ctrl = ctrl_sh[ci].sum()
    F_c = shared_ctrl / total_ctrl if total_ctrl > 0 else np.nan

    total_treat  = treat_n[ti].sum()
    shared_treat = treat_sh[ti].sum()
    F_t = shared_treat / total_treat if total_treat > 0 else np.nan

    N_t   = treat_sh[ti].sum()
    N_acc = treat_sh_acc[ti].sum()
    N_ina = treat_sh_ina[ti].sum()

    if F_c == 0 or N_t == 0 or np.isnan(F_c) or np.isnan(F_t):
        boot_inn[b] = np.nan
        boot_con[b] = np.nan
        boot_pur[b] = np.nan
        continue

    boot_inn[b] = (F_c - F_t) / F_c
    boot_con[b] = (N_acc / N_t) * (F_t / F_c)
    boot_pur[b] = (N_ina / N_t) * (F_t / F_c)

valid = ~(np.isnan(boot_inn) | np.isnan(boot_con) | np.isnan(boot_pur))
boot_inn, boot_con, boot_pur = boot_inn[valid], boot_con[valid], boot_pur[valid]
print(f"  Valid bootstrap samples: {valid.sum()} / {N_BOOT}")

ci_inn = np.percentile(boot_inn, [2.5, 97.5])
ci_con = np.percentile(boot_con, [2.5, 97.5])
ci_pur = np.percentile(boot_pur, [2.5, 97.5])

# Pairwise comparisons
d_inn_pur = boot_inn - boot_pur
d_con_pur = boot_con - boot_pur
d_inn_con = boot_inn - boot_con

p_inn_pur = 2 * np.mean(d_inn_pur <= 0)
p_con_pur = 2 * np.mean(d_con_pur <= 0)
p_inn_con = 2 * np.mean(d_inn_con <= 0)

b_inn_pur, ci_ip = np.mean(d_inn_pur), np.percentile(d_inn_pur, [2.5, 97.5])
b_con_pur, ci_cp = np.mean(d_con_pur), np.percentile(d_con_pur, [2.5, 97.5])
b_inn_con, ci_ic = np.mean(d_inn_con), np.percentile(d_inn_con, [2.5, 97.5])

p_label = lambda p: f"{p:.4f}" if p >= 0.0001 else "<0.0001"

print("\n" + "=" * 60)
print("BOOTSTRAP CONFIDENCE INTERVALS (10,000 reps, subject-level)")
print("=" * 60)
print(f"  f_Inattention: {main_est['f_inn']*100:.1f}%  95% CI [{ci_inn[0]*100:.1f}%, {ci_inn[1]*100:.1f}%]")
print(f"    paper:        51.2%  [38.4%, 62.0%]")
print(f"  f_Confusion:   {main_est['f_con']*100:.1f}%  95% CI [{ci_con[0]*100:.1f}%, {ci_con[1]*100:.1f}%]")
print(f"    paper:        33.1%  [25.1%, 42.4%]")
print(f"  f_Purposeful:  {main_est['f_pur']*100:.1f}%  95% CI [{ci_pur[0]*100:.1f}%, {ci_pur[1]*100:.1f}%]")
print(f"    paper:        15.8%  [11.1%, 21.5%]")

print("\n" + "=" * 60)
print("PAIRWISE BOOTSTRAP COMPARISONS")
print("=" * 60)
print(f"  Inattention − Purposeful:  b={b_inn_pur:.3f}  [{ci_ip[0]:.3f}, {ci_ip[1]:.3f}]  p={p_label(p_inn_pur)}")
print(f"    paper:                    b=0.354  [0.178, 0.502]  p=0.0004")
print(f"  Confusion − Purposeful:    b={b_con_pur:.3f}  [{ci_cp[0]:.3f}, {ci_cp[1]:.3f}]  p={p_label(p_con_pur)}")
print(f"    paper:                    b=0.173  [0.098, 0.256]  p<0.0001")
print(f"  Inattention − Confusion:   b={b_inn_con:.3f}  [{ci_ic[0]:.3f}, {ci_ic[1]:.3f}]  p={p_label(p_inn_con)}")
print(f"    paper:                    b=0.181  [-0.036, 0.365]  p=0.098")

# ---------------------------------------------------------------------------
# 8. ROBUSTNESS — Extended Data Table 2
# ---------------------------------------------------------------------------
print("\n" + "=" * 60)
print("ROBUSTNESS — Extended Data Table 2")
print("=" * 60)

full_est = decompose(long)
b1_est   = decompose(long[(long["batch"]==1) & (long["socialmedia_chk"]==1)])
b2_est   = decompose(long[(long["batch"]==2) & (long["socialmedia_chk"]==1)])

# Bootstrap CIs for full sample (vectorized)
fake_full = long[long["real"] == 0].copy()

def boot_cis(fake_df, seed_offset=0):
    rng2 = np.random.default_rng(RNG_SEED + seed_offset)
    cg = fake_df[fake_df["condition"]==0].groupby("id")
    tg = fake_df[fake_df["condition"]==1].groupby("id")
    c_n  = cg["smB"].count().values;  c_sh = cg["smB"].sum().values
    t_n  = tg["smB"].count().values;  t_sh = tg["smB"].sum().values
    t_ac = tg.apply(lambda g: ((g["smB"]==1)&(g["accB"]==1)).sum()).values
    t_ia = tg.apply(lambda g: ((g["smB"]==1)&(g["accB"]==0)).sum()).values
    nc, nt = len(c_n), len(t_n)
    bi, bc, bp = np.empty(N_BOOT), np.empty(N_BOOT), np.empty(N_BOOT)
    for b in range(N_BOOT):
        ci2 = rng2.integers(0, nc, size=nc); ti2 = rng2.integers(0, nt, size=nt)
        Fc = c_sh[ci2].sum() / c_n[ci2].sum() if c_n[ci2].sum()>0 else np.nan
        Ft = t_sh[ti2].sum() / t_n[ti2].sum() if t_n[ti2].sum()>0 else np.nan
        Nt = t_sh[ti2].sum(); Na = t_ac[ti2].sum(); Ni2 = t_ia[ti2].sum()
        if not (Fc and Nt): bi[b]=bc[b]=bp[b]=np.nan; continue
        bi[b]=(Fc-Ft)/Fc; bc[b]=(Na/Nt)*(Ft/Fc); bp[b]=(Ni2/Nt)*(Ft/Fc)
    v = ~(np.isnan(bi)|np.isnan(bc)|np.isnan(bp))
    return (np.percentile(bi[v],[2.5,97.5]), np.percentile(bc[v],[2.5,97.5]),
            np.percentile(bp[v],[2.5,97.5]))

print("\n  Full sample (no smchk filter):")
ci_f_inn, ci_f_con, ci_f_pur = boot_cis(fake_full, seed_offset=1)
print(f"    f_Inn={full_est['f_inn']*100:.1f}% [{ci_f_inn[0]*100:.1f},{ci_f_inn[1]*100:.1f}]  "
      f"f_Con={full_est['f_con']*100:.1f}% [{ci_f_con[0]*100:.1f},{ci_f_con[1]*100:.1f}]  "
      f"f_Pur={full_est['f_pur']*100:.1f}% [{ci_f_pur[0]*100:.1f},{ci_f_pur[1]*100:.1f}]")

print(f"\n  Batch 1 only (smchk==1):")
fake_b1 = long[(long["batch"]==1)&(long["socialmedia_chk"]==1)&(long["real"]==0)]
ci_b1 = boot_cis(long[(long["batch"]==1)&(long["socialmedia_chk"]==1)&(long["real"]==0)], 2) \
        if len(fake_b1[fake_b1["condition"]==0])>0 else ((np.nan,np.nan),(np.nan,np.nan),(np.nan,np.nan))
print(f"    f_Inn={b1_est['f_inn']*100:.1f}%  f_Con={b1_est['f_con']*100:.1f}%  f_Pur={b1_est['f_pur']*100:.1f}%")

print(f"\n  Batch 2 only (smchk==1):")
print(f"    f_Inn={b2_est['f_inn']*100:.1f}%  f_Con={b2_est['f_con']*100:.1f}%  f_Pur={b2_est['f_pur']*100:.1f}%")

# ---------------------------------------------------------------------------
# 9. PRE-REGISTERED ANALYSIS: condition × veracity OLS
# ---------------------------------------------------------------------------

def twoway_cluster_se(X, y, cl1, cl2):
    XtXinv = np.linalg.inv(X.T @ X)
    betas  = XtXinv @ X.T @ y
    e      = y - X @ betas
    k      = X.shape[1]
    n      = len(y)

    def bread(clust):
        meat = np.zeros((k, k))
        for c in np.unique(clust):
            idx = clust == c
            Xc  = X[idx]; ec = e[idx]
            meat += Xc.T @ np.outer(ec, ec) @ Xc
        return XtXinv @ meat @ XtXinv

    V = bread(cl1) + bread(cl2) - bread(cl1 * 100_000 + cl2)
    se = np.sqrt(np.diag(V))
    t  = betas / se
    p  = 2 * (1 - stats.t.cdf(np.abs(t), df=n - k))
    return betas, se, p

print("\n" + "=" * 60)
print("PRE-REGISTERED ANALYSIS: OLS smB ~ condition + real + condition×real")
print("(Two-way clustered SEs on participant and item)")
print("=" * 60)

for label, subset in [("smchk==1", main_long), ("Full sample", long)]:
    sub = subset.dropna(subset=["smB"]).copy()
    sub["cond_x_real"] = sub["condition"] * sub["real"]
    X  = np.column_stack([np.ones(len(sub)), sub["condition"], sub["real"], sub["cond_x_real"]])
    y  = sub["smB"].values
    item_id = sub["item_num"].values + sub["real"].values * 12
    betas, se, p = twoway_cluster_se(X, y, sub["id"].values, item_id)
    print(f"\n  Subset: {label}")
    for nm, b, s, pv in zip(["Intercept","Condition","Real","Cond×Real"], betas, se, p):
        sig = "***" if pv<.001 else "**" if pv<.01 else "*" if pv<.05 else ""
        print(f"    {nm:<15} b={b:+.4f}  SE={s:.4f}  p={pv:.4f} {sig}")

# ---------------------------------------------------------------------------
# 10. FIGURE 3d REPLICATION
# ---------------------------------------------------------------------------
labels = ["Inattention\n(attention-based)", "Confusion\n(confusion-based)", "Purposeful\n(preference-based)"]
vals   = [main_est["f_inn"], main_est["f_con"], main_est["f_pur"]]
lo     = [v - ci[0] for v, ci in zip(vals, [ci_inn, ci_con, ci_pur])]
hi     = [ci[1] - v  for v, ci in zip(vals, [ci_inn, ci_con, ci_pur])]
colors = ["#4878CF", "#6ACC65", "#D65F5F"]

fig, ax = plt.subplots(figsize=(7.5, 5.5))
x    = np.arange(len(labels))
bars = ax.bar(x, [v * 100 for v in vals], color=colors, width=0.5,
              yerr=[[l * 100 for l in lo], [h * 100 for h in hi]],
              capsize=6, error_kw=dict(elinewidth=1.8, ecolor="black"))

ax.set_xticks(x)
ax.set_xticklabels(labels, fontsize=11)
ax.set_ylabel("% of false-news sharing explained", fontsize=12)
ax.set_title("Decomposition of False-News Sharing (Study 6)\n"
             "Replication of Pennycook et al. (2021) Figure 3d", fontsize=11)
ax.set_ylim(0, 78)
ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda v, _: f"{v:.0f}%"))

for bar, v, ci_lo, ci_hi in zip(bars, vals,
                                 [ci_inn[0], ci_con[0], ci_pur[0]],
                                 [ci_inn[1], ci_con[1], ci_pur[1]]):
    ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 1.8,
            f"{v*100:.1f}%\n[{ci_lo*100:.1f}%, {ci_hi*100:.1f}%]",
            ha="center", va="bottom", fontsize=9)

ax.annotate("Paper targets: 51.2% | 33.1% | 15.8%",
            xy=(0.98, 0.97), xycoords="axes fraction",
            ha="right", va="top", fontsize=8.5,
            bbox=dict(boxstyle="round,pad=0.3", fc="lightyellow", ec="gray", alpha=0.85))

plt.tight_layout()
fig_path = os.path.join(FIG_DIR, "figure_3d_replication.png")
fig.savefig(fig_path, dpi=150)
print(f"\nFigure saved: {fig_path}")

# ---------------------------------------------------------------------------
# 11. RESULTS SUMMARY
# ---------------------------------------------------------------------------
print("\n" + "=" * 60)
print("RESULTS SUMMARY — Replicated vs. Paper")
print("=" * 60)
rows_summary = [
    ("F_cont (false share, control)",      f"{main_est['F_cont']*100:.1f}%",                           "~26–28%"),
    ("F_treat (false share, treatment)",   f"{main_est['F_treat']*100:.1f}%",                          "~13–15%"),
    ("f_Inattention",                      f"{main_est['f_inn']*100:.1f}% [{ci_inn[0]*100:.1f},{ci_inn[1]*100:.1f}]",  "51.2% [38.4, 62.0]"),
    ("f_Confusion",                        f"{main_est['f_con']*100:.1f}% [{ci_con[0]*100:.1f},{ci_con[1]*100:.1f}]",  "33.1% [25.1, 42.4]"),
    ("f_Purposeful",                       f"{main_est['f_pur']*100:.1f}% [{ci_pur[0]*100:.1f},{ci_pur[1]*100:.1f}]",  "15.8% [11.1, 21.5]"),
    ("b(Inn−Pur)", f"{b_inn_pur:.3f} [{ci_ip[0]:.3f},{ci_ip[1]:.3f}] p={p_label(p_inn_pur)}",  "0.354 [0.178,0.502] p=0.0004"),
    ("b(Con−Pur)", f"{b_con_pur:.3f} [{ci_cp[0]:.3f},{ci_cp[1]:.3f}] p={p_label(p_con_pur)}",  "0.173 [0.098,0.256] p<0.0001"),
    ("b(Inn−Con)", f"{b_inn_con:.3f} [{ci_ic[0]:.3f},{ci_ic[1]:.3f}] p={p_label(p_inn_con)}",  "0.181 [-0.036,0.365] p=0.098"),
]
print(f"\n  {'Metric':<30} {'Replicated':<38} {'Paper'}")
print("  " + "-" * 95)
for metric, rep, paper in rows_summary:
    print(f"  {metric:<30} {rep:<38} {paper}")

print("\nDone.")

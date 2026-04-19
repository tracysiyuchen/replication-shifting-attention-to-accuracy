"""
Replication of Figure 3d from Pennycook et al. (2021), Nature 592, 590-595.

Layout (matching the paper):
  Two headline groups: False | True
  Within each group, two side-by-side bars:
    • Control bar  (solid red)
    • Treatment bar (stacked: navy bottom = rated inaccurate / Preference;
                               sky-blue top  = rated accurate  / Confusion)
  The vertical gap between the Treatment bar top and the Control bar top
  represents "Inattention".
  Annotations bracket the three components on the False group.
"""

import os
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
HERE     = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(HERE, "..", "Data_and_code")
FIG_DIR  = os.path.join(HERE, "figures")
os.makedirs(FIG_DIR, exist_ok=True)

# ---------------------------------------------------------------------------
# Load and reshape  (identical pre-processing to analysis.py)
# ---------------------------------------------------------------------------
b1 = pd.read_csv(os.path.join(DATA_DIR, "Study_6_b1_data.csv"),
                 sep="\t", encoding="latin1")
b2 = pd.read_csv(os.path.join(DATA_DIR, "Study_6_b2_data.csv"),
                 encoding="latin1")
b1["batch"] = 1
b2["batch"] = 2

for df in (b1, b2):
    str_cols = df.select_dtypes(include="object").columns
    df[str_cols] = df[str_cols].replace(r"^\s*$", np.nan, regex=True)

df = pd.concat([b1, b2], ignore_index=True)
df["id"] = np.arange(len(df))
for col in ("Condition", "FB", "SocialMedia_Chk"):
    df[col] = pd.to_numeric(df[col], errors="coerce")

df_excl = df[df["SocialMedia_Chk"].notna() & (df["FB"] != 2)].copy()

def to_float(val):
    try:   return float(val)
    except: return np.nan

rows = []
for _, row in df_excl.iterrows():
    for item in range(1, 13):
        for is_real, prefix in [(0, "Fake"), (1, "Real")]:
            sm_ctrl = to_float(row.get(f"{prefix}{item}_3"))
            sm_trt  = to_float(row.get(f"{prefix}{item}_3.0"))
            sm_raw  = sm_ctrl if not np.isnan(sm_ctrl) else sm_trt
            acc_raw = to_float(row.get(f"{prefix}{item}_2"))
            if np.isnan(sm_raw):
                continue
            rows.append({
                "id":              row["id"],
                "condition":       int(row["Condition"]) - 1,  # 0=control,1=treatment
                "real":            is_real,
                "socialmedia_chk": row["SocialMedia_Chk"],
                "sm_raw":          sm_raw,
                "acc_raw":         acc_raw,
            })

long = pd.DataFrame(rows)
long["sm"]  = (long["sm_raw"] - 1) / 5
long["smB"] = (long["sm"] > 0.5).astype(float)
long["accB"] = np.where(long["acc_raw"].notna(),
                        (long["acc_raw"] > 2).astype(float), np.nan)

main = long[long["socialmedia_chk"] == 1].copy()

# ---------------------------------------------------------------------------
# Compute bar heights
# ---------------------------------------------------------------------------
def bar_heights(df_in, real_val):
    """
    Returns a dict with:
      ctrl_rate   : Control sharing rate  (= height of red bar)
      pref_rate   : Treatment & rated inaccurate  (bottom of stacked treatment bar)
      conf_rate   : Treatment & rated accurate    (top of stacked treatment bar)
      treat_total : pref_rate + conf_rate  (= height of treatment bar)
      inatt_rate  : ctrl_rate - treat_total
    """
    sub   = df_in[df_in["real"] == real_val]
    ctrl  = sub[sub["condition"] == 0]
    treat = sub[sub["condition"] == 1]

    ctrl_rate  = ctrl["smB"].mean()
    treat_rate = treat["smB"].mean()

    shared  = treat[treat["smB"] == 1]
    N       = len(shared)
    N_acc   = int((shared["accB"] == 1).sum())
    N_inacc = int((shared["accB"] == 0).sum())

    conf_rate = (N_acc   / N) * treat_rate if N > 0 else 0.0
    pref_rate = (N_inacc / N) * treat_rate if N > 0 else 0.0

    return dict(
        ctrl_rate   = ctrl_rate,
        conf_rate   = conf_rate,
        pref_rate   = pref_rate,
        treat_total = treat_rate,
        inatt_rate  = ctrl_rate - treat_rate,
    )

false_h = bar_heights(main, 0)
true_h  = bar_heights(main, 1)

print("False → ctrl={ctrl_rate:.1%}  treat={treat_total:.1%}"
      "  (conf={conf_rate:.1%}  pref={pref_rate:.1%}  inatt={inatt_rate:.1%})"
      .format(**false_h))
print("True  → ctrl={ctrl_rate:.1%}  treat={treat_total:.1%}"
      "  (conf={conf_rate:.1%}  pref={pref_rate:.1%}  inatt={inatt_rate:.1%})"
      .format(**true_h))

# ---------------------------------------------------------------------------
# Colours  (close to paper)
# ---------------------------------------------------------------------------
COL_CTRL = "#C03B26"   # brick-red       → Control bar
COL_CONF = "#7FB2D5"   # sky-blue        → Treatment, rated accurate  (Confusion)
COL_PREF = "#2B2D7E"   # dark navy       → Treatment, rated inaccurate (Preference)

# ---------------------------------------------------------------------------
# Figure geometry
# ---------------------------------------------------------------------------
# Groups at x = 0 (False) and x = 1 (True)
# Within each group:  Control bar left, Treatment bar right
GROUP_GAP  = 1.0    # distance between group centres
BAR_W      = 0.30   # bar width
PAIR_SEP   = 0.05   # gap between Control and Treatment bars within a group

x_false_ctrl  = 0.0 - PAIR_SEP/2 - BAR_W/2    # -0.175
x_false_treat = 0.0 + PAIR_SEP/2 + BAR_W/2    # +0.175
x_true_ctrl   = GROUP_GAP - PAIR_SEP/2 - BAR_W/2
x_true_treat  = GROUP_GAP + PAIR_SEP/2 + BAR_W/2

fig, ax = plt.subplots(figsize=(5.6, 4.6))
fig.patch.set_facecolor("white")
fig.subplots_adjust(left=0.14, right=0.97, top=0.90, bottom=0.11)

# ---------------------------------------------------------------------------
# Draw bars
# ---------------------------------------------------------------------------
for x_ctrl, x_treat, h in [
        (x_false_ctrl, x_false_treat, false_h),
        (x_true_ctrl,  x_true_treat,  true_h)]:

    # Control: solid red bar
    ax.bar(x_ctrl, h["ctrl_rate"] * 100,
           width=BAR_W, color=COL_CTRL,
           linewidth=0.4, edgecolor="white", zorder=3)

    # Treatment: stacked  (pref at bottom, conf on top)
    ax.bar(x_treat, h["pref_rate"] * 100,
           width=BAR_W, color=COL_PREF,
           linewidth=0.4, edgecolor="white", zorder=3)
    ax.bar(x_treat, h["conf_rate"] * 100,
           width=BAR_W, color=COL_CONF,
           bottom=h["pref_rate"] * 100,
           linewidth=0.4, edgecolor="white", zorder=3)

# ---------------------------------------------------------------------------
# Axis formatting
# ---------------------------------------------------------------------------
group_centres = [0.0, GROUP_GAP]
ax.set_xticks(group_centres)
ax.set_xticklabels(["False", "True"], fontsize=12)
ax.set_xlim(x_false_ctrl - BAR_W*1.8, x_true_treat + BAR_W*1.4)
ax.set_ylim(0, 45)
ax.set_yticks(range(0, 46, 5))
ax.set_yticklabels([str(v) for v in range(0, 46, 5)], fontsize=9)
ax.set_ylabel("Likely to share (%)", fontsize=11)
ax.tick_params(axis="x", bottom=False, length=0)
ax.tick_params(axis="y", length=3)

ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.spines["bottom"].set_visible(False)
ax.spines["left"].set_linewidth(0.8)
ax.yaxis.grid(True, linestyle="-", linewidth=0.4, color="#dddddd", zorder=0)

# Panel label
ax.set_title("d", fontsize=14, fontweight="bold", loc="left", pad=6)
ax.text(0.065, 1.01, "Study 6", transform=ax.transAxes,
        fontsize=11, verticalalignment="bottom")

# ---------------------------------------------------------------------------
# Annotations: bracket the three components on the False bars
#
#   "Preference"  → bracket alongside the pref (navy) segment of treatment bar
#   "Confusion"   → bracket alongside the conf (blue) segment of treatment bar
#   "Inattention" → bracket spanning the gap between treat top and ctrl top
#
# The bracket sits between the two bars (between x_false_treat right edge
# and x_false_ctrl left edge), then label to the left.
# ---------------------------------------------------------------------------
pref_lo  = 0.0
pref_hi  = false_h["pref_rate"]  * 100
conf_hi  = false_h["treat_total"] * 100
ctrl_hi  = false_h["ctrl_rate"]   * 100

# x-coordinates for the bracket
x_brk_r  = x_false_ctrl - 0.01   # right tip (just left of Control bar)
x_brk_v  = x_brk_r - 0.14        # vertical line of bracket
x_lbl    = x_brk_v - 0.05        # text anchor

def draw_bracket(ax, xv, xr, y_lo, y_hi, label, fontsize=8):
    """Square bracket ]  pointing right, with label to its left."""
    mid = (y_lo + y_hi) / 2
    lw  = 0.9
    # vertical bar
    ax.plot([xv, xv], [y_lo, y_hi],
            color="black", lw=lw, clip_on=False)
    # caps
    ax.plot([xv, xr], [y_lo, y_lo],
            color="black", lw=lw, clip_on=False)
    ax.plot([xv, xr], [y_hi, y_hi],
            color="black", lw=lw, clip_on=False)
    ax.text(xv - 0.04, mid, label,
            fontsize=fontsize, ha="right", va="center",
            color="black", style="italic", clip_on=False)

GAP = 0.18   # small inset from segment edges
draw_bracket(ax, x_brk_v, x_brk_r,
             pref_lo + GAP * 0.1,
             pref_hi - GAP * 0.1,
             "Preference")
draw_bracket(ax, x_brk_v, x_brk_r,
             pref_hi + GAP * 0.1,
             conf_hi  - GAP * 0.1,
             "Confusion")
draw_bracket(ax, x_brk_v, x_brk_r,
             conf_hi  + GAP * 0.1,
             ctrl_hi  - GAP * 0.1,
             "Inattention")

# ---------------------------------------------------------------------------
# Legend
# ---------------------------------------------------------------------------
legend_handles = [
    mpatches.Patch(facecolor=COL_CTRL, label="Control",
                   linewidth=0.4, edgecolor="white"),
    mpatches.Patch(facecolor=COL_CONF, label="Treatment – rated accurate",
                   linewidth=0.4, edgecolor="white"),
    mpatches.Patch(facecolor=COL_PREF, label="Treatment – rated inaccurate",
                   linewidth=0.4, edgecolor="white"),
]
leg = ax.legend(handles=legend_handles, fontsize=7.5,
                loc="upper right", frameon=True,
                framealpha=0.9, edgecolor="#cccccc",
                handlelength=1.2, handleheight=1.0,
                borderpad=0.5, labelspacing=0.35)
leg.get_frame().set_linewidth(0.5)

# ---------------------------------------------------------------------------
# Save
# ---------------------------------------------------------------------------
out_path = os.path.join(FIG_DIR, "figure_3d_paper_style.png")
fig.savefig(out_path, dpi=200, bbox_inches="tight", facecolor="white")
print(f"\nSaved: {out_path}")

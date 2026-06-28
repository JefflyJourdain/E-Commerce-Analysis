This is rich data. A lot of insights here — let me break it down:

---

**Insight 1 — Office has a margin problem hiding inside its revenue lead**

Office Accessories has the worst margin in the entire dataset at 47%, dragging the category average down. Office Desks at 55% and Chairs at 58% are healthy, but Accessories is quietly eating profit. Office leads revenue by a wide margin yet sits at 53% category margin precisely because of this subcategory. That's a concrete, actionable finding.

---

**Insight 2 — Kitchen is the most consistent category**

Cookware (60%), Cutlery (54%), Utensils (55%) — the tightest margin band of any category. No subcategory is underperforming. This is why Kitchen is the real star despite not leading revenue.

---

**Insight 3 — Bedroom Lighting is a drag on an otherwise solid category**

Bedding sits at 57%, Decor at 57%, but Lighting drops to 48%. Nearly 10 percentage points below its siblings. That's not a small gap — something structural is going on there, either pricing, COGS, or heavy discounting.

---

**Insight 4 — Storage concentration risk**

Boxes (51%) vs Shelves (54%) vs Baskets (54%) — margins are fine, but Baskets only generates $2.9M vs Boxes at $7.2M. Storage is heavily concentrated in Boxes. If that subcategory has a supply or demand issue, the whole category feels it.

---

**Insight 5 — Outdoor Gardening is an outlier by volume**

Same margin as Patio (58-59%) but only $3.1M revenue vs $6.5M for Patio and $6M for Lighting. Less than half the orders of the other subcategories. Either it's a niche product line or it's underexposed in the catalog.

---

Before you write these up formally, one quick thing — your results show `office` and `bedroom` in lowercase for some rows. That's a data cleaning artifact still in the data. Worth fixing in SQL with a `UPPER()` or `INITCAP()` equivalent before the dashboard goes final.



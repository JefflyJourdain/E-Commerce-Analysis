
Before you write these up formally, one quick thing — your results show `office` and `bedroom` in lowercase for some rows. That's a data cleaning artifact still in the data. Worth fixing in SQL with a `UPPER()` or `INITCAP()` equivalent before the dashboard goes final.

Office leads revenue and profit, but kitchen and outdoor leads margin by 56% & 58% 

Office Accessories has the worst margin in the entire dataset at 47%, dragging the category average down. Office Desks at 55% and Chairs at 58% are healthy, but Accessories is quietly eating profit. Office leads revenue by a wide margin yet sits at 53% category margin precisely because of this subcategory. That's a concrete, actionable finding.

Cookware (60%), Cutlery (54%), Utensils (55%) the tightest margin band of any category. No subcategory is underperforming. This is why Kitchen is the real star despite not leading revenue.

Bedding sits at 57%, Decor at 57%, but Lighting drops to 48%. Nearly 10 percentage points below its siblings. That's not a small gap something structural is going on there, either pricing, COGS, or heavy discounting.

Boxes (51%) vs Shelves (54%) vs Baskets (54%) margins are fine, but Baskets only generates $2.9M vs Boxes at $7.2M. Storage is heavily concentrated in Boxes. If that subcategory has a supply or demand issue, the whole category feels it.

Same margin as Patio (58-59%) but only $3.1M revenue vs $6.5M for Patio and $6M for Lighting. Less than half the orders of the other subcategories. Either it's a niche product line or it's underexposed in the catalog.



discounting is consistent across categories, so margin variation is not driven by promotional pricing
* Storage Boxes at 33% return rate but everything else is clustering between 26–28% return rate

b2b  has 1 percent higher aov than wholesale, and 76 percent higher than b2c

wholesale has an 83 percent higher than amazon, and 86 percent higher than shopify in the sales channels



Does discounting actually pay for itself? (their Q2) — Pricing strategy, untouched by your other projects. Plot discount_pct against volume and gross_margin_pct: does extra quantity offset the margin hit, or are you just giving money away?

Which products are heroes vs. dead weight? (their Q9) — Volume/margin quadrant classification. The most "hire this person" question on the list — it's the kind of output a merchandising team actually acts on, and neither existing project does a quadrant-style product classification.


What's your repeat purchase rate? (their Q5) — Retention over acquisition, classic exec question. It's a lightweight version of what you're planning for Project 4 (RFM/cohort in Python), so it sets up a nice arc: quick SQL repeat-rate check now, full cohort analysis later.

Where's fulfillment breaking down? (merge their Q6 + Q7) — Combine order-to-ship-to-delivery time with the product/region breakdown into one question instead of two. Genuinely new territory — neither existing project touches operations. Fix the ship_date duplication above before building this one.

What does order completion/failure actually cost? (their Q8) — but check the distribution first. Run a GROUP BY on order_status, payment_status, fulfillment_status before committing — if it's 95%+ "Completed/Paid/Fulfilled" like your sample suggests, there's no real variance to analyze and it falls flat. If it's genuinely mixed, keep it. If not, swap in seasonality (their Q10) instead — safer since order_date always varies.


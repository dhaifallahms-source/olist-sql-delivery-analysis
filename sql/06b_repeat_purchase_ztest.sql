/* ============================================================
   Query:     06b - Two-proportion z-test for Query 06
   Question:  Is the lower repeat-purchase rate after a late first
              order a real difference or just chance?
   Tables:    none (inputs are the counts from Query 06)
   Logic:     Compares repeat rates of the two groups with a pooled
              two-proportion z-test:
              z = (p1 - p2) / sqrt(p * (1 - p) * (1/n1 + 1/n2))
              where p is the pooled rate of both groups.
   Input:     Late first order:    191 repeat of 7,588
              On-time first order: 2,686 repeat of 85,660
   Finding:   z = -2.99. Since |z| > 1.96, the difference is
              significant at the 5% level (p ~ 0.003).
   Notes:     Counts are typed in by hand from Query 06; rerun this
              file if those numbers change. Significance does not
              mean the gap is large: it is ~0.6 points. It shows an
              association, not that lateness causes lower repurchase.
   ============================================================ */

DECLARE @n1 FLOAT = 7588,  @x1 FLOAT = 191;    -- late first order
DECLARE @n2 FLOAT = 85660, @x2 FLOAT = 2686;   -- on-time first order
DECLARE @p1 FLOAT = @x1 / @n1,  @p2 FLOAT = @x2 / @n2;
DECLARE @p  FLOAT = (@x1 + @x2) / (@n1 + @n2); -- pooled rate

SELECT
    @p1 AS p_late,
    @p2 AS p_on_time,
    (@p1 - @p2) / SQRT(@p * (1 - @p) * (1 / @n1 + 1 / @n2)) AS z_score;
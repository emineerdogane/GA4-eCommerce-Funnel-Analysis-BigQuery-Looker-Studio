SELECT
  funnel_step,
  sessions_count,
  CASE funnel_step
    WHEN 'total_sessions' THEN 1
    WHEN 'sessions_with_view_item' THEN 2
    WHEN 'sessions_with_add_to_cart' THEN 3
    WHEN 'sessions_with_purchase' THEN 4
    ELSE 99
  END AS step_order
FROM
  `project-a713ea7b-7d25-4d24-8e6.ecommerce_analytics.funnel_summary`
UNPIVOT(sessions_count FOR funnel_step IN (total_sessions, sessions_with_view_item, sessions_with_add_to_cart, sessions_with_purchase))
ORDER BY
  step_order ASC
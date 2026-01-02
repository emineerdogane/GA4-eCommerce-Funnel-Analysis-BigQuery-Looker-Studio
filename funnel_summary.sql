-- Project: GA4 eCommerce Funnel Analysis
-- Purpose: Reconstruct session-level user journeys and compute funnel conversion metrics
-- Dataset: bigquery-public-data.ga4_obfuscated_sample_ecommerce
-- Output: funnel_summary (VIEW)
-- Key Techniques:
--   - Session reconstruction using cumulative SUM window function
--   - First-occurrence timestamps per funnel step
--   - Conversion and drop-off rate calculations
-- Business Question:
--   Where do users drop off between session start and purchase?

WITH raw_events AS (
  SELECT
    user_pseudo_id,
    event_name,
    TIMESTAMP_MICROS(event_timestamp) AS event_ts,
    event_date,
    device.operating_system AS device_os,
    platform
  FROM
    `bigquery-public-data`.ga4_obfuscated_sample_ecommerce.`events_*`
  WHERE
    event_name IN ('session_start', 'view_item', 'add_to_cart', 'purchase')
),

events_with_session AS (
  SELECT
    *,
    SUM(
      CASE
        WHEN event_name = 'session_start' THEN 1
        ELSE 0
      END
    ) OVER (
      PARTITION BY user_pseudo_id
      ORDER BY event_ts
      ROWS UNBOUNDED PRECEDING
    ) AS session_num
  FROM raw_events
),

per_session_first AS (
  SELECT
    user_pseudo_id,
    session_num,
    MIN(IF(event_name = 'session_start', event_ts, NULL)) AS ts_session_start,
    MIN(IF(event_name = 'view_item', event_ts, NULL)) AS ts_view_item,
    MIN(IF(event_name = 'add_to_cart', event_ts, NULL)) AS ts_add_to_cart,
    MIN(IF(event_name = 'purchase', event_ts, NULL)) AS ts_purchase,
    ANY_VALUE(device_os) AS device_os,
    ANY_VALUE(platform) AS platform
  FROM events_with_session
  GROUP BY user_pseudo_id, session_num
)

SELECT
  COUNT(1) AS total_sessions,
  COUNTIF(ts_view_item IS NOT NULL) AS sessions_with_view_item,
  COUNTIF(ts_add_to_cart IS NOT NULL) AS sessions_with_add_to_cart,
  COUNTIF(ts_purchase IS NOT NULL) AS sessions_with_purchase,
  ROUND(100 * SAFE_DIVIDE(COUNTIF(ts_view_item IS NOT NULL), COUNT(1)), 2)
    AS pct_view_item_of_sessions,
  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(ts_add_to_cart IS NOT NULL),
      COUNTIF(ts_view_item IS NOT NULL)
    ),
    2
  ) AS pct_add_to_cart_of_viewers,
  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(ts_purchase IS NOT NULL),
      COUNTIF(ts_add_to_cart IS NOT NULL)
    ),
    2
  ) AS pct_purchase_of_adders,
  ROUND(100 * SAFE_DIVIDE(COUNTIF(ts_purchase IS NOT NULL), COUNT(1)), 2)
    AS pct_purchase_of_sessions
FROM per_session_first
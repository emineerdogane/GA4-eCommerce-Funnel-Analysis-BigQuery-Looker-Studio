-- Purpose: Calculate time-to-purchase metrics segmented by device type
-- Output: device_time_to_purchase (VIEW)
-- Business Question:
--   Do users on different devices convert at different speeds?
-- Median used to reduce skew from long-tail sessions

WITH raw_events AS (
  SELECT
    user_pseudo_id,
    event_name,
    TIMESTAMP_MICROS(event_timestamp) AS event_ts,
    device.operating_system AS device_os
  FROM
    `bigquery-public-data`.ga4_obfuscated_sample_ecommerce.`events_*`
  WHERE
    event_name IN ('session_start', 'add_to_cart', 'purchase')
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
    MIN(IF(event_name = 'add_to_cart', event_ts, NULL)) AS ts_add_to_cart,
    MIN(IF(event_name = 'purchase', event_ts, NULL)) AS ts_purchase,
    ANY_VALUE(device_os) AS device_os
  FROM events_with_session
  GROUP BY user_pseudo_id, session_num
)

SELECT
  CASE
    WHEN LOWER(device_os) LIKE '%android%' THEN 'Mobile'
    WHEN LOWER(device_os) LIKE '%ios%' THEN 'Mobile'
    ELSE 'Desktop'
  END AS device_segment,
  COUNT(1) AS sessions_count,
  COUNTIF(ts_purchase IS NOT NULL) AS sessions_with_purchase,
  AVG(TIMESTAMP_DIFF(ts_purchase, ts_session_start, SECOND))
    AS avg_secs_session_start_to_purchase,
  AVG(TIMESTAMP_DIFF(ts_purchase, ts_add_to_cart, SECOND))
    AS avg_secs_addcart_to_purchase,
  APPROX_QUANTILES(
    TIMESTAMP_DIFF(ts_purchase, ts_session_start, SECOND),
    100
  )[OFFSET(50)] AS median_secs_session_start_to_purchase
FROM per_session_first
GROUP BY device_segment
ORDER BY device_segment
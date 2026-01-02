WITH
  raw_events AS (
    SELECT
      user_pseudo_id,
      event_name,
      TIMESTAMP_MICROS(event_timestamp) AS event_ts,
      event_date,
      device.operating_system AS device_os,
      platform,
      event_params,
      _TABLE_SUFFIX AS table_suffix
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
        END) OVER (PARTITION BY user_pseudo_id
        ORDER BY event_ts ROWS UNBOUNDED PRECEDING) AS session_num
    FROM
      raw_events
  ),
  per_session_first AS (
    SELECT
      user_pseudo_id,
      session_num,
      MIN(
        CASE
          WHEN event_name = 'session_start' THEN event_ts
        END) AS ts_session_start,
      MIN(
        CASE
          WHEN event_name = 'view_item' THEN event_ts
        END) AS ts_view_item,
      MIN(
        CASE
          WHEN event_name = 'add_to_cart' THEN event_ts
        END) AS ts_add_to_cart,
      MIN(
        CASE
          WHEN event_name = 'purchase' THEN event_ts
        END) AS ts_purchase,
      ANY_VALUE(device_os) AS device_os,
      ANY_VALUE(platform) AS platform
    FROM
      events_with_session
    GROUP BY user_pseudo_id, session_num
  )
SELECT
  COUNT(1) AS total_sessions,
  COUNTIF(ts_view_item IS NOT NULL) AS sessions_with_view_item,
  COUNTIF(ts_add_to_cart IS NOT NULL) AS sessions_with_add_to_cart,
  COUNTIF(ts_purchase IS NOT NULL) AS sessions_with_purchase,
  ROUND(100 * SAFE_DIVIDE(COUNTIF(ts_view_item IS NOT NULL), COUNT(1)), 2) AS pct_view_item_of_sessions,
  ROUND(100 * SAFE_DIVIDE(COUNTIF(ts_add_to_cart IS NOT NULL), COUNTIF(ts_view_item IS NOT NULL)), 2) AS pct_add_to_cart_of_viewers,
  ROUND(100 * SAFE_DIVIDE(COUNTIF(ts_purchase IS NOT NULL), COUNTIF(ts_add_to_cart IS NOT NULL)), 2) AS pct_purchase_of_adders,
  ROUND(100 * SAFE_DIVIDE(COUNTIF(ts_purchase IS NOT NULL), COUNT(1)), 2) AS pct_purchase_of_sessions
FROM
  per_session_first;
WITH
  raw_events AS (
    SELECT
      user_pseudo_id,
      event_name,
      TIMESTAMP_MICROS(event_timestamp) AS event_ts,
      event_date,
      device.operating_system AS device_os,
      platform,
      event_params,
      _TABLE_SUFFIX AS table_suffix
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
        END) OVER (PARTITION BY user_pseudo_id
        ORDER BY event_ts ROWS UNBOUNDED PRECEDING) AS session_num
    FROM
      raw_events
  ),
  per_session_first AS (
    SELECT
      user_pseudo_id,
      session_num,
      MIN(
        CASE
          WHEN event_name = 'session_start' THEN event_ts
        END) AS ts_session_start,
      MIN(
        CASE
          WHEN event_name = 'view_item' THEN event_ts
        END) AS ts_view_item,
      MIN(
        CASE
          WHEN event_name = 'add_to_cart' THEN event_ts
        END) AS ts_add_to_cart,
      MIN(
        CASE
          WHEN event_name = 'purchase' THEN event_ts
        END) AS ts_purchase,
      ANY_VALUE(device_os) AS device_os,
      ANY_VALUE(platform) AS platform
    FROM
      events_with_session
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
  AVG(TIMESTAMP_DIFF(ts_purchase, ts_session_start, SECOND)) AS avg_secs_session_start_to_purchase,
  AVG(TIMESTAMP_DIFF(ts_purchase, ts_add_to_cart, SECOND)) AS avg_secs_addcart_to_purchase,
  APPROX_QUANTILES(TIMESTAMP_DIFF(ts_purchase, ts_session_start, SECOND), 100)[OFFSET(50)] AS median_secs_session_start_to_purchase
FROM
  per_session_first
GROUP BY device_segment
ORDER BY device_segment;
WITH
  funnel_events AS (
    SELECT
      user_pseudo_id,
      TIMESTAMP_MICROS(event_timestamp) AS ts,
      event_name,
      device.operating_system AS device_os,
      platform
    FROM
      `bigquery-public-data`.ga4_obfuscated_sample_ecommerce.`events_*`
    WHERE
      event_name IN ('session_start', 'view_item', 'add_to_cart', 'purchase')
  ),
  ordered AS (
    SELECT
      *,
      ROW_NUMBER() OVER (PARTITION BY user_pseudo_id
        ORDER BY ts) AS rn,
      LEAD(event_name) OVER (PARTITION BY user_pseudo_id
        ORDER BY ts) AS next_event,
      LEAD(ts) OVER (PARTITION BY user_pseudo_id
        ORDER BY ts) AS next_ts
    FROM
      funnel_events
  )
SELECT
  event_name,
  next_event,
  COUNT(1) AS occurrences,
  ROUND(AVG(TIMESTAMP_DIFF(next_ts, ts, SECOND)), 2) AS avg_seconds_between
FROM
  ordered
WHERE
  next_event IS NOT NULL
GROUP BY event_name, next_event
ORDER BY occurrences DESC;

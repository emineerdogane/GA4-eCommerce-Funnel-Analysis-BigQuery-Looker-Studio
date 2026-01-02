WITH
  funnel_events AS (
    SELECT
      user_pseudo_id,
      TIMESTAMP_MICROS(event_timestamp) AS ts,
      event_name,
      device.operating_system AS device_os,
      platform
    FROM `bigquery-public-data`.`ga4_obfuscated_sample_ecommerce`.`events_*`
    WHERE
      event_name IN ('session_start', 'view_item', 'add_to_cart', 'purchase')
  ),
  ordered AS (
    SELECT
      *,
      ROW_NUMBER() OVER (PARTITION BY user_pseudo_id ORDER BY ts) AS rn,
      LEAD(event_name)
        OVER (PARTITION BY user_pseudo_id ORDER BY ts) AS next_event,
      LEAD(ts) OVER (PARTITION BY user_pseudo_id ORDER BY ts) AS next_ts
    FROM `funnel_events`
  )
SELECT
  event_name,
  next_event,
  COUNT(1) AS occurrences,
  ROUND(AVG(TIMESTAMP_DIFF(next_ts, ts, SECOND)), 2) AS avg_seconds_between,
  -- Add new ordering columns for event_name
  CASE event_name
    WHEN 'session_start' THEN 1
    WHEN 'first_visit'
      THEN 1  -- If 'first_visit' is ever included, give it a similar order
    WHEN 'view_item' THEN 2
    WHEN 'add_to_cart' THEN 3
    WHEN 'purchase' THEN 4
    ELSE 99  -- Assign a high number for any other event_name to appear last
    END
    AS event_name_order,
  -- Add new ordering columns for next_event
  CASE next_event
    WHEN 'session_start' THEN 1
    WHEN 'first_visit' THEN 1
    WHEN 'view_item' THEN 2
    WHEN 'add_to_cart' THEN 3
    WHEN 'purchase' THEN 4
    ELSE 99  -- Assign a high number for any other next_event to appear last
    END
    AS next_event_order
FROM `ordered`
WHERE next_event IS NOT NULL
GROUP BY
  event_name,
  next_event,
  event_name_order,  -- Include new ordering columns in GROUP BY
  next_event_order  -- Include new ordering columns in GROUP BY
ORDER BY
  event_name_order,  -- Order by the new ordering columns for logical sequence
  next_event_order
# GA4 eCommerce Funnel Analysis (BigQuery & Looker Studio)

## 📊 Dashboard Preview

<p align="center">
  <img src="Animation.gif" alt="Dashboard Demo" width="100%">
</p>

> 🎬 **Live Dashboard Demo**: Interactive visualization showing GA4 eCommerce funnel analysis with real-time metrics and insights.

## 📈 Overview

This project analyzes an end-to-end eCommerce user funnel using Google Analytics 4 (GA4) data in BigQuery.

- **Session-level user journeys** are reconstructed using SQL window functions to identify funnel drop-offs, conversion friction, and time-to-purchase behavior
- **Insights are visualized** in Looker Studio dashboards designed for product and business decision-making

## 🎯 Problem Statement

Understanding where and why users drop off in the conversion funnel is critical for improving eCommerce performance.

This project focuses on:
- Identifying the largest drop-off points between key funnel steps
- Measuring time to purchase across device segments (Mobile vs. Desktop)
- Translating event-level data into actionable product insights

## 📊 Dataset

- **Google Analytics 4 Obfuscated Sample Dataset**
- **Source**: BigQuery Public Datasets
- **Schema**: Event-based schema (`events_*` tables)

## 🔬 Methodology

- Reconstructed session-level user journeys from GA4 events
- Applied SQL window functions (`LEAD`, `LAG`) to analyze event transitions
- Built funnel conversion metrics and drop-off rates
- Calculated time-to-purchase by device segment
- Modeled all outputs as BigQuery views for reproducibility

## � Repository Structure

```
GA4-eCommerce-Funnel-Analysis-BigQuery-Looker-Studio/
│
├── funnel_summary.sql              # Session-level funnel metrics and conversion rates
├── funnel_data_for_viz.sql         # UNPIVOT-ed funnel data optimized for Looker Studio
├── device_time_to_purchase.sql     # Time-to-purchase metrics by device type
├── event_transitions.sql           # Event-to-event transitions and latency analysis
├── Animation.gif                   # Dashboard demo animation
├── Dashboard_Funnel_Overview.png   # Funnel visualization screenshot
├── Dashboard_Event_Transitions.png # Event flow visualization screenshot
└── README.md                       # Project documentation
```

## 💡 Key Insights

- **~30% of users drop off between View Item → Add to Cart**, indicating early funnel friction
- **Desktop users take longer to convert than mobile users**, suggesting higher decision complexity
- **Conversion challenges occur before checkout, not during payment**
- Critical drop-off points identified for targeted UX improvements

## 🔧 SQL Queries & Technical Details

### BigQuery Data Modeling

#### 1. `funnel_summary.sql`
Computes session counts and conversion percentages for each funnel step.
- Calculates conversion rates at each stage
- Identifies drop-off rates between steps
- Provides session-level funnel metrics

#### 2. `funnel_data_for_viz.sql`
To support funnel charts in Looker Studio, the `funnel_summary` view is transformed into a long format using `UNPIVOT`.
- Converts funnel step columns into rows
- Enables proper funnel chart rendering
- Provides flexible step ordering
- Cleaner visualization logic in Looker Studio

#### 3. `event_transitions.sql`
Uses `LEAD()` window function to calculate average time between sequential GA4 events.
- Analyzes user flow between different events
- Identifies common conversion paths
- Measures latency between user actions

#### 4. `device_time_to_purchase.sql`
Calculates average and median time-to-purchase segmented by device type.
- Compares conversion times across mobile, desktop, and tablet
- Identifies device-specific behavior patterns
- Supports device optimization strategies

All tables are implemented as **BigQuery views** to ensure reproducibility using the public dataset.

## 🚀 Getting Started

### Prerequisites
- Google Cloud Platform account
- GA4 property with eCommerce tracking enabled (or use public dataset)
- BigQuery access
- Looker Studio access

### How to Reproduce

1. **Open BigQuery**
2. **Access the GA4 public dataset**
   ```
   bigquery-public-data.ga4_obfuscated_sample_ecommerce
   ```
3. **Run SQL scripts** in the following order:
   - `funnel_summary.sql`
   - `device_time_to_purchase.sql`
   - `event_transitions.sql`
   - `funnel_data_for_viz.sql`
4. **Connect the resulting views to Looker Studio**
5. **Build dashboards** using the views created

## 📊 Visualization (Looker Studio)

Dashboard components include:
- **Funnel chart** showing user progression and drop-offs
- **Scorecards** for conversion rates at each stage
- **Bar charts** comparing time-to-purchase by device
- **Event transition table** highlighting latency between user actions

Screenshots of the dashboards are included in this repository.

## 📝 Usage

1. **Run SQL Queries**: Execute the queries in BigQuery to generate analysis views
2. **Create Visualizations**: Use Looker Studio to build interactive dashboards
3. **Monitor Performance**: Track KPIs and identify optimization opportunities
4. **Iterate**: Refine analysis based on business needs

## �️ Technologies Used

- **Google BigQuery**: SQL-based data warehousing and analysis
- **GA4 Event Schema**: Event-based analytics data structure
- **Looker Studio**: Interactive data visualization and dashboards
- **SQL Window Functions**: Advanced analytics (`LEAD`, `LAG`, `UNPIVOT`)

## 🔮 What I Would Do Next

- **Analyze funnel drop-offs by product category** to identify category-specific friction points
- **Add cohort analysis for returning vs. new users** to understand behavior differences
- **Implement attribution modeling** to understand multi-touch conversion paths
- **Validate UX hypotheses through A/B testing** based on identified drop-off points
- **Build predictive models** for purchase propensity
- **Expand device analysis** to include browser and OS segmentation

## 📈 Insights & Findings

This analysis provides actionable insights for eCommerce optimization:

### Conversion Funnel Performance
- **Overall Conversion Rate**: Track end-to-end conversion from product view to purchase
- **Stage-by-Stage Analysis**: Identify which funnel stages have the highest drop-off rates
- **Bottleneck Identification**: Pinpoint specific steps where users abandon their journey
- **~30% drop-off between View Item → Add to Cart** indicates early funnel friction requiring immediate attention

### Device-Specific Patterns
- **Mobile vs Desktop Performance**: Compare conversion rates across device categories
- **Time-to-Purchase Variations**: Desktop users demonstrate higher decision complexity with longer purchase times
- **Device Optimization Opportunities**: Identify which devices need UX improvements

### User Behavior Insights
- **Common Conversion Paths**: Discover the most successful event sequences leading to purchase
- **Drop-off Points**: Conversion challenges occur before checkout, not during payment
- **Engagement Patterns**: Analyze user interaction patterns before conversion

### Business Impact
- **Revenue Optimization**: Identify high-impact areas for improving conversion rates
- **Marketing ROI**: Understand which channels and campaigns drive better funnel performance
- **User Experience Improvements**: Data-driven recommendations for UX enhancements

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Contact

**Emine Erdoğan**

- � GitHub: [@emineerdogane](https://github.com/emineerdogane)
- 💼 LinkedIn: [linkedin.com/in/emine-erdogan](https://www.linkedin.com/in/emine-erdogan/)

*Feel free to reach out for questions, collaboration opportunities, or feedback!*

## 📄 License

This project is licensed under the MIT License - available for educational and commercial use.

---

**Note**: This project uses the publicly available GA4 sample dataset from BigQuery. All queries are designed to work with this dataset out of the box.

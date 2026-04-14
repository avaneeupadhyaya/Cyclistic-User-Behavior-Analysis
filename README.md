# Cyclistic-User-Behavior-Analysis
A data-driven deep dive into bike-share user behavior in Chicago using SQL and Tableau to drive marketing conversion strategies.

## Project Overview
This project analyzes 12 months of historical trip data from Cyclistic, a bike-share company in Chicago. The goal is to identify how annual members and casual riders use the service differently to inform a data-driven marketing strategy for increasing memberships.

**Data Preparation**
Data Source: 12 months of Cyclistic trip data (2025-2026).

Data Gap Resolution: At the time of this analysis, the full datasets for February and March 2026 were not yet released.To maintain a complete 12-month trend analysis, I utilized proxy data from the corresponding months in 2025.This ensures the seasonal trends (Spring surge) are accurately represented while maintaining the integrity of the yearly volume.

**Data Processing**
Tool: Google BigQuery (SQL)

Workflow: * Merged 12 monthly tables into a unified master dataset.

Created a BigQuery VIEW to handle cleaning without altering raw data.

Filtered out trips < 1 minute (false starts) and > 24 hours (stolen/lost).

Engineered ride_length_m, day_of_week, and ride_hour for deep analysis.

**Key Insights**
The Commuter Signature: Annual members peak at 8 AM and 5 PM on weekdays.

The Weekend Surge: Casual ridership increases significantly on Saturdays and Sundays.

The Value Gap: Casual riders average 19.5 minutes per trip, while members average 11.8 minutes. Casual riders take significantly longer trips on average, suggesting more leisure-oriented usage and stronger perceived value potential for membership-based pricing.

Top Hubs: Casual usage is heavily concentrated at recreational stations like Navy Pier and Lake Shore Drive.

**Final Dashboard**
[View the Interactive Tableau Dashboard](https://public.tableau.com/views/Cyclistic_Final_Dashboard_twbx/Dashboard1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link) 

**Strategic Recommendations**
Launch a "Weekend Warrior" Pass: Create a seasonal membership targeting the Saturday/Sunday ridership surge. This offers a low-barrier entry point for leisure-focused casual users.

Hyper-Local Marketing at "Hot Spots": Deploy physical signage and QR-code discounts at the Top 10 Stations (e.g., Navy Pier, Millennium Park). Focus budget where casual density is highest.

"Long-Ride" Value Messaging: Market memberships as a "Scenic Route Pass." Show casual riders how a subscription lowers the cost of their typical 20-minute leisure trips.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/ai_demo_scenario_model.dart';

final aiDemoScenarios = <AiDemoScenarioModel>[
  const AiDemoScenarioModel(
    id: 'exec_summary',
    title: 'Executive Summary',
    description: 'Generate a high-level summary of business performance over the last quarter.',
    prompt: 'Analyze the Q3 financial data and generate an executive summary highlighting key revenue drivers and areas of concern.',
    mockResponse: '''# Q3 Executive Summary

## Key Highlights
* **Revenue Growth:** Overall revenue increased by **14%** compared to Q2, driven primarily by strong performance in the Enterprise sector.
* **Cost Reduction:** Operational costs decreased by 3% due to the new automated logistics routing.
* **Customer Acquisition:** Added 45 new enterprise clients, a record high for the fiscal year.

## Areas of Concern
* **Supply Chain Delays:** We are seeing a 12% increase in lead times for raw materials in the APAC region.
* **Retention:** Churn in the small business tier increased slightly from 2.1% to 2.4%.

## Recommendations
1. Expedite vendor negotiations in APAC to secure priority shipping lines.
2. Launch targeted retention campaigns for small businesses entering their renewal month.
''',
    icon: LucideIcons.fileText,
  ),
  const AiDemoScenarioModel(
    id: 'workflow_opt',
    title: 'Workflow Optimization',
    description: 'Analyze process bottlenecks and suggest routing improvements.',
    prompt: 'Review the current order fulfillment workflow and suggest optimizations to reduce processing time.',
    mockResponse: '''# Workflow Optimization Analysis

## Current Bottlenecks
Based on the event logs from the past 30 days:
1. **Manual Approval Step:** The "Manager QA" step takes an average of **14 hours**, representing 40% of total fulfillment time.
2. **Inventory Sync:** The batch sync with the 3PL provider runs every 6 hours, causing delay in dispatch for ready orders.

## Proposed Optimizations
* **Automated QA for Low-Risk Orders:** Implement a rule to bypass manual "Manager QA" for orders under \$500 with returning customers. *Estimated time savings: 10 hours per order.*
* **Real-time API Webhooks:** Switch the 3PL integration from 6-hour batching to real-time webhooks. *Estimated time savings: 3-5 hours per order.*

### Projected Impact
Implementing these changes could reduce average fulfillment time from **35 hours** to **18 hours**.
''',
    icon: LucideIcons.gitMerge,
  ),
  const AiDemoScenarioModel(
    id: 'prod_prediction',
    title: 'Production Prediction',
    description: 'Predict manufacturing capacity constraints based on upcoming orders.',
    prompt: 'Predict factory load for the next 2 weeks and identify any capacity risks.',
    mockResponse: '''# Production Capacity Prediction (Next 14 Days)

## Load Forecast
* **Factory A (Primary):** Projected to operate at **98% capacity** next week, dropping to 85% the following week.
* **Factory B (Secondary):** Projected to operate at 60% capacity.

## Identified Risks
⚠️ **High Risk:** The upcoming "Holiday Promo" order batch requires 5,000 units of Component X. Factory A only has capacity to produce 4,200 units by the deadline.

## AI Recommendations
1. **Shift Production:** Reallocate the production of 1,000 units of Component X to Factory B immediately. 
2. **Maintenance Scheduling:** Delay the scheduled maintenance on Line 3 in Factory A until the 15th to ensure uninterrupted production.
''',
    icon: LucideIcons.factory,
  ),
  const AiDemoScenarioModel(
    id: 'sales_forecast',
    title: 'Sales Forecast',
    description: 'Project future sales revenue based on historical trends and pipeline.',
    prompt: 'Generate a sales forecast for Q4 based on the current CRM pipeline and historical Q4 seasonality.',
    mockResponse: '''# Q4 Sales Forecast

## Projection
Based on a pipeline of \$12M and a historical Q4 close rate of 35%, the projected Q4 new revenue is **\$4.2M**.
Factoring in expected renewals and seasonal upsells, total Q4 revenue is forecasted at **\$18.5M** (± 5%).

## Pipeline Analysis
* **Strongest Vertical:** Manufacturing (Expected to close \$1.8M)
* **At-Risk Deals:** 3 enterprise deals (totaling \$800k) have been stuck in the "Legal Review" stage for over 14 days.

## Suggested Actions
* Engage Executive Sponsors on the 3 at-risk enterprise deals.
* Allocate additional marketing budget to the Manufacturing vertical to capitalize on current momentum.
''',
    icon: LucideIcons.trendingUp,
  ),
  const AiDemoScenarioModel(
    id: 'inventory_analysis',
    title: 'Inventory Analysis',
    description: 'Identify slow-moving stock and recommend reorder points.',
    prompt: 'Analyze current warehouse stock levels, identify slow-moving items, and suggest optimal reorder points for fast movers.',
    mockResponse: '''# Inventory Health Analysis

## Slow-Moving Stock
* **SKU-992 (Legacy Widget):** 400 units in stock. 0 sales in the last 90 days. *Recommendation: Apply a 30% discount to clear space.*
* **SKU-441 (Blue Casing):** 1,200 units in stock. Selling at 10 units/month. *Recommendation: Stop auto-reordering.*

## Stockout Risks (Fast Movers)
* **SKU-101 (Pro Sensor):** Currently at 150 units. Daily run rate is 25 units. **Stockout in 6 days!**
  * *Action:* Automatically generate a Purchase Order for 1,000 units from Supplier A (Lead time: 4 days).
* **SKU-205 (Copper Wire):** Reorder point is currently set to 500. Suggest adjusting to **800** due to increased production demand.
''',
    icon: LucideIcons.packageSearch,
  ),
  const AiDemoScenarioModel(
    id: 'risk_detect',
    title: 'Risk Detection',
    description: 'Scan financial transactions and flag anomalies.',
    prompt: 'Scan the accounts payable ledger for the last 30 days and highlight any anomalous transactions or compliance risks.',
    mockResponse: '''# Financial Risk & Anomaly Detection

## Anomalies Detected
🚨 **Duplicate Payment Risk:**
* **Invoice #8892** (Vendor: Acme Corp) for \$14,500 was paid on Oct 12.
* A nearly identical invoice **#8892-A** for \$14,500 was submitted on Oct 14 and is pending approval.
* *Action:* Flagged for manual review. Pending payment frozen.

⚠️ **Unusual Vendor Activity:**
* **Vendor: Globex Tech:** Average monthly billing is \$2,000. Current month billing is **\$18,500** across 5 separate invoices just under the \$4,000 auto-approval threshold.
* *Action:* Escalated to VP of Finance for approval.

## Compliance Status
All other transactions match POs and delivery receipts within the 2% variance threshold.
''',
    icon: LucideIcons.shieldAlert,
  ),
  const AiDemoScenarioModel(
    id: 'approval_sugg',
    title: 'Approval Suggestions',
    description: 'Auto-evaluate pending approvals based on policy rules.',
    prompt: 'Evaluate the 15 pending expense reports against the corporate travel policy and suggest approvals or rejections.',
    mockResponse: '''# Expense Approval Evaluation

I have reviewed **15 pending expense reports**. 

## Ready for Auto-Approval (12)
12 reports perfectly match the corporate travel policy (per diems, flight classes, and hotel limits are within bounds). 
*Suggesting batch approval.*

## Flagged for Review (3)
1. **Report EXP-1092 (J. Doe):** 
   * *Flag:* Hotel cost in NYC was \$450/night (Policy limit: \$350/night). No exemption note provided.
   * *Suggestion:* **Reject** and request justification.
2. **Report EXP-1095 (A. Smith):**
   * *Flag:* "Client Dinner" expense of \$800 missing attendee list.
   * *Suggestion:* **Return to Employee** to add attendees.
3. **Report EXP-1102 (M. Johnson):**
   * *Flag:* Flight booked in Business Class on a domestic route (Policy: Economy only for flights < 4 hours).
   * *Suggestion:* **Reject**.
''',
    icon: LucideIcons.checkCircle,
  ),
];

class AiDemoState {
  final String? runningScenarioId;
  final Set<String> completedScenarios;
  final String? previewScenarioId;

  const AiDemoState({
    this.runningScenarioId,
    this.completedScenarios = const {},
    this.previewScenarioId,
  });

  AiDemoState copyWith({
    String? runningScenarioId,
    Set<String>? completedScenarios,
    String? previewScenarioId,
  }) {
    return AiDemoState(
      runningScenarioId: runningScenarioId,
      completedScenarios: completedScenarios ?? this.completedScenarios,
      previewScenarioId: previewScenarioId,
    );
  }
}

class AiDemoNotifier extends Notifier<AiDemoState> {
  @override
  AiDemoState build() {
    return const AiDemoState();
  }

  Future<void> runDemo(String scenarioId) async {
    if (state.runningScenarioId != null) return;

    state = state.copyWith(runningScenarioId: scenarioId);

    // Simulate AI thinking time
    await Future.delayed(const Duration(seconds: 3));

    final newCompleted = Set<String>.from(state.completedScenarios)..add(scenarioId);
    state = state.copyWith(
      runningScenarioId: null, // clear running state
      completedScenarios: newCompleted,
      previewScenarioId: scenarioId, // immediately preview the result
    );
  }

  void previewScenario(String scenarioId) {
    if (state.runningScenarioId != null) return;
    
    // Add to completed if they just want to preview it instantly
    final newCompleted = Set<String>.from(state.completedScenarios)..add(scenarioId);
    state = state.copyWith(
      previewScenarioId: scenarioId,
      completedScenarios: newCompleted,
    );
  }

  void closePreview() {
    state = state.copyWith(previewScenarioId: null);
  }
}

final aiDemoProvider = NotifierProvider<AiDemoNotifier, AiDemoState>(
  AiDemoNotifier.new,
);

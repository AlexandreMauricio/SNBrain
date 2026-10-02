---
type: how-to
tags: [how-to, cmdb, reporting, sla, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Digital Portfolio Management" > "Configure KPIs in Digital Portfolio Management with service availability example" (pp. 2200-2203), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Configure a Service Availability KPI in Digital Portfolio Management

**Goal:** make the **Availability** card on the Run tab of a service offering in [[Digital Portfolio Management]] show a real percentage.

**Needs:** role `sn_dpm.dpm_admin`; Service Portfolio Management (`com.snc.service_portfolio`, premium, installed with DPM) and the Team Performance KPI group plugin. Not tested on an instance.

## Steps

1. **Map the KPI group.** **Digital Portfolio Management > KPI Group Mappings > New**: **KPI Group** = *Outage and Availability*, mapping = the **Offering**. The base system may already have this mapping.
2. **Create the commitment.** **Service Portfolio Management > Commitments > New**: **Name**, **Type** = Availability, **Percentage available**, **Schedule** (for example 24 x 7), **Time zone**, **Description**.
3. **Attach it to the offering.** **Service Portfolio Management > Service commitment** (or `service_offering_commitment.list`) > **New**: **Service offering**, **Service commitment**.
4. **Record an outage** (to have data): **Service Portfolio Management > Outages > New**: **Configuration Item** = the offering, **Begin**, **End**, within the last seven days. The outage also generates a service availability record for the offering.
5. **Collect.** **System Definition > Scheduled Jobs** > *SPM Data Collection job for PA* > check **Relative start** (days to collect, default 1) > **Execute now**. On the **Job Logs** tab the newest log should have **State** = Collected.
6. **Verify the indicator.** On the job's **Indicators** tab open *SPM Availability* > related link **Show Analytics Hub**: the score for the offering should be there.
7. **Verify in the workspace.** Open the offering (from a personal portfolio card or through the enterprise portfolio tree) > **Run** tab > *Performance snapshot* > **Availability**.

## Example

Offering *Example Email Standard* with commitment *Example 99 percent 24x7* (Availability, 99%, schedule 24 x 7). An outage of 2 hours recorded yesterday; after the collection job runs with **Relative start** 1, the Availability card shows a value just under 100%.

## Related

- [[DPM Administration, KPI Groups and Reference]] · [[Service Offerings, Commitments and Availability]] · [[Service Portfolio Management]]

# EvoCompute: Problem Definition, Literature Review and Strategic Business Case

*Working draft, 5 Oct 2026. Every number is tagged to a numbered source (Section 11) or labelled as an assumption. Evidence grades: **E1** = measured or published by a third party; **E2** = our model from stated assumptions; **E3** = hypothesis still to be tested.*

---

## 0. Executive summary

**The idea in one line.** EvoCompute is a RISC-V-class platform that senses its own health, workload and mission context, and switches between pre-certified hardware configurations under a hardware-enforced rule set, so that one piece of silicon serves several products and stays useful for longer.

**What the evidence says (five findings):**

1. **The problem is real and growing.** Design cost rises steeply with node \[2\]\[3\]\[4\]. Only 14% of ASIC projects reach first-silicon success and 75% run late \[7\]. Silent data corruption from individual cores now shows up in hyperscale fleets \[18\]\[19\]. Unplanned downtime costs the world's 500 largest firms about $1.4T a year \[10\].
2. **The idea is not new at the "self-aware chip" level.** Self-aware cyber-physical SoCs, hierarchical goal management and RL-supervised MPSoC control exist \[21\]\[22\]\[23\], as do self-healing RISC-V soft cores \[25\]\[26\]\[27\]. A claim of "first" will not survive review. The defensible novelty is the **unification** (workload + health + mission + security in one loop), a **hardware-enforced admissible-configuration set**, a **switching-cost model**, and **measured evidence across heterogeneous missions**. We add one new axis, **lifetime-carbon as an optimisation objective** (Section 8).
3. **The strongest business argument is not energy.** At 15% energy saving, a 20 W node saves about $2.6 a year (E2). Avoided stoppages are worth 1–3 orders of magnitude more per node, and the break-even rate of compute-attributable stoppages is tiny (Section 3.4). The catch is attribution: you must show the platform, not the plant, caused the avoided minutes.
4. **The platform economics are conditional, not automatic.** Net NRE saving is positive only if EvoCompute avoids enough derivative designs relative to its own extra NRE (break-even rule in 3.3). As a standalone licensing business, the base case is **NPV-negative (about –$6.8M at 15%)**; only the optimistic case clears a venture hurdle (IRR about 32%). Position it as a platform/research programme backed by public design incentives (India's Semicon 2.0 \[38\]), not as a stand-alone IP startup.
5. **Verification is the existential risk.** Adaptivity multiplies the state space, and verification already takes 60–70% of chip-project effort \[8\]. The "certified configuration set" (the controller can only choose pre-verified states) is therefore the central design principle, not a feature.

### Audit of numbers from the earlier thread

| Claim in earlier thread | Status after checking | Use in deck? |
| --- | --- | --- |
| Design cost $298M at 7nm, $540M at 5nm | These are IBS 2018 figures \[3\]. Critics put IBS 50–66% above real-world \[4\]; SemiEngineering suggested about $160M / $280M \[3\]; a real-world AI-chip estimate is $62M at 7nm \[4\]. The IBS 2022 model reproduced in Arm's filing gives $48M at 28nm, $449M at 5nm \[2\] | **Re-base to $48M (28nm)** and show a low-case |
| Learning-based DVFS saves 33% energy "(2024 IEEE)" | Verified, but the source is DVFO: arXiv 2023 / IPSN 2023 poster, tested on NVIDIA Jetson edge devices against other schemes, not custom silicon \[24\] | Cite as **precedent**, not as our target |
| "2026 IEEE TNS self-healing RISC-V: 95.34% / 99.94% recovery" | **Could not locate.** Related papers found: 45.09% effective software recovery under neutron irradiation \[25\]; hypervisor + partial reconfiguration for MPSoCs, 2025 \[26\] | **Do not cite** until the paper is found |
| Siemens: $1.4T/yr, 11% of revenue, auto $2.3M/h, 27 h/month | Verified \[10\]\[11\] | Yes |
| IEA: data-centre demand to about 950 TWh by 2030 | IEA says about 945 TWh, up from 415 TWh in 2024 \[12\]\[13\] | Yes (945) |
| McKinsey: zonal E/E cuts material cost 10–20% | McKinsey states wiring harness is about 20% of E/E budgets and projects 18% zonal share by 2030 \[32\]; the 10%/20% cost figures appear on Bosch's page \[33\] | Attribute to **Bosch**, not McKinsey |
| Arm: up to 12 months faster, "millions" NRE | Arm now says "tens of millions" NRE saved and up to 12 months \[5\] (vendor claim) | Yes, as a **competitor benchmark** |
| ABB 2025 survey, IBM 18–31% predictive-maintenance saving, 2026 approximate-computing and 2025 timing-prediction papers | **Not re-verified** this session | Verify before use |

---

## 1. Problem definition

### 1.1 Problem statement (SCQA)

**Situation.** Silicon is a bet placed 2–5 years before deployment, on a fixed architecture, with fixed safety margins, for an assumed workload and environment. The bet is getting more expensive: design cost at 28nm is about $48M and at 5nm about $449M on IBS's model \[2\].

**Complication.** Reality diverges from the bet in eight measurable ways:

| # | Sub-problem | What goes wrong | Evidence |
| --- | --- | --- | --- |
| P1 | **Workload–silicon mismatch** | Hardware is sized for peak or an assumed mix; resources idle or throttle | Dark/dim silicon, power-limited scaling \[20\]; energy-proportionality gap \[42\] |
| P2 | **Static margins** | Worst-case voltage/timing guard-bands waste energy in typical conditions | Razor-style margin removal precedent \[43\]; learning-based DVFS shows double-digit savings \[24\] |
| P3 | **Silent and latent faults** | Aging, marginal cores and radiation cause wrong answers without crashing | "A few mercurial cores per several thousand machines" at Google \[18\]; Meta fleet findings \[19\] |
| P4 | **Product fragmentation** | Each market variant needs another design, verification and tape-out | Design cost \[2\]\[3\]\[4\]; Arm CSS exists precisely to cut this \[5\] |
| P5 | **Short effective life, high embodied carbon** | Chips are retired for workload obsolescence or partial failure while their manufacturing carbon is sunk | Manufacturing dominates mobile and data-centre footprints \[16\]; 62 Mt e-waste in 2022, 22.3% formally recycled \[17\] |
| P6 | **Unverifiable adaptivity** | A chip that changes behaviour multiplies the verification state space | 14% first-silicon success; verification is 60–70% of effort \[7\]\[8\] |
| P7 | **Adaptivity as an attack surface** | Power/frequency control interfaces have been exploited | CLKSCREW fault attacks via DVFS \[28\]; Hertzbleed frequency side channel \[29\] |
| P8 | **Economic and regulatory friction** | Buyers pay for certainty; sector regulation lags | Safety standards, CRA timelines \[39\]; limited DLI uptake in India \[38\] |

**Question.** Can a single platform adapt to workload, health and mission **safely, provably and economically** enough to beat both static designs and point-solutions (DVFS-only, ECC/TMR-only, chiplets, FPGAs), and does that reduce lifecycle carbon?

### 1.2 Scope and definitions

- **In scope:** coarse-grained, pre-certified adaptation (frequency/voltage, cache ways, accelerator on/off, precision modes, redundancy level, fault isolation, task migration); an on-chip policy engine; a hardware constitution; a fault, thermal and workload evaluation on FPGA, then a test chip.
- **Out of scope for generation 1:** fine-grained runtime fabric reconfiguration, free-form online learning of safety-critical behaviour, certification in automotive/medical, multi-chip "EvoMesh" (kept as vision).
- **Definitions:**
  - *Mission profile*: a weighted objective vector (performance, energy, reliability, safety, security, latency, thermal, lifetime).
  - *Certified configuration set (CCS)*: the finite set of hardware states verified offline; the policy engine may select only from it.
  - *Constitution*: immutable hardware invariants (for example T \< Tmax, safety core never disabled, memory isolation intact) that no policy can override.
  - *Switching economics*: reconfigure only if predicted benefit over the dwell time exceeds switching cost, with hysteresis and minimum residency.

### 1.3 Hypotheses and how each could be proved wrong

| ID | Hypothesis | Metric | Target (design target, not claim) | Falsified if |
| --- | --- | --- | --- | --- |
| H1 | Unified control beats best single-axis control (DVFS-only, fault-only) | Energy, performance/W, recovery rate vs baselines B0–B3 | ≥15% energy saving and ≥25% perf/W on dynamic workloads | Gain over B1 (DVFS-only) is \<5% |
| H2 | Adaptation overhead can stay small | Area overhead of sensing + policy + constitution | ≤10% | >15% after synthesis |
| H3 | Faults are survivable with graceful degradation | Recovered fraction, critical-function survival, silent-corruption rate | ≥95% recovery within a stated fault model; zero silent corruption in critical tasks | Silent corruption observed in critical path |
| H4 | One silicon can serve ≥4 mission profiles | Same RTL, different policies, each hitting its own objective | 4 profiles each within 10% of a per-mission static optimum | Any profile >25% worse than its static optimum |
| H5 | The CCS keeps verification tractable | Number of certified states, formal-property coverage, verification effort | ≤ a stated cap on states; all invariants proven | Proof of constitution fails or effort exceeds the cap |
| H6 | Adaptation is not exploitable to force unsafe states | Attack campaign on sensor, telemetry and policy inputs | Zero constitution violations; bounded availability loss | Any violation under attack |
| H7 | Lifetime-aware policies extend useful service life | Years to a defined capability floor under injected aging | ≥30% longer than static (assumption) | \<10% extension |

**Non-negotiable honesty rule for any presentation:** report these as targets until measured, and report the failures too.

---

## 2. Literature review

### 2.1 Thematic map

| Theme | Key sources | What they establish | Gap for EvoCompute |
| --- | --- | --- | --- |
| **A. Why static silicon is straining** | Esmaeilzadeh et al., ISCA 2011 \[20\]; Hennessy & Patterson 2019 \[41\]; Barroso & Hölzle 2007 \[42\] | Power-limited scaling, dark/dim silicon, need for specialisation; machines are inefficient at low utilisation | Specialisation fixes efficiency but freezes the bet; adaptation is the complement |
| **B. Autonomic and self-aware computing** | Kephart & Chess 2003 \[40\]; Dutt, Jantsch, Sarma 2016 \[44\]; Gonzalez-Martinez et al., 2024 survey \[21\]; CPSoC goal-management project \[22\] | Observe-decide-act loops; self-aware cyber-physical SoCs; two decades of MPSoC management over power, thermal, faults and security | **Closest prior art.** Mission/goal management is already studied. Our edge must be hardware-enforced safety, certified states, switching economics and measured multi-mission evidence |
| **C. Learning-based power management** | Zhang et al. (DVFO) \[24\]; Maurer et al., DATE 2020 \[23\] | RL/learned DVFS reports 33% average energy saving in an edge-cloud setting \[24\]; hierarchical supervisor + RL on an FPGA prototype obeys power limits \[23\] | Single-axis, or no formal guarantee on safety invariants |
| **D. Fault tolerance and self-healing RISC-V** | Bolchini & Miele 2014 \[27\]; Santos et al., TNS 2024 \[25\]; Cano-Páez et al., TNS 2025 \[26\] | Replication + partial reconfiguration + checkpoint/rollback can detect and repair upsets; 45.09% effective software recovery in neutron tests \[25\] | Reliability-only; no joint trade-off with energy and mission |
| **E. Silent data corruption at scale** | Hochschild et al. (Google) \[18\]; Meta fleet work \[19\] | Marginal cores produce wrong results silently; a few per several thousand machines; detection and isolation needed | Strong motivation for on-chip health sensing and core isolation |
| **F. Commercial adaptive platforms** | Microchip RT PolarFire SoC \[30\]; AMD Versal adaptive SoC \[31\]; Arm CSS \[5\] | RISC-V + FPGA fabric with radiation-tolerant variant; functional-safety-certified toolchain (ISO 26262 ASIL-D / IEC 61508 SIL-3) \[30\]; adaptive SoCs for space \[31\]; pre-integrated subsystems cut time and NRE \[5\] | They adapt *function* (fabric) or *integration*; none exposes a mission-level, closed-loop, constitution-bounded policy |
| **G. Security of adaptive control** | Tang et al., CLKSCREW \[28\]; Wang et al., Hertzbleed \[29\] | DVFS interfaces enabled fault injection into TrustZone and a remote frequency side channel | The policy engine itself must be hardened; telemetry must be authenticated |
| **H. Verification and safety economics** | Wilson Research / Siemens 2024 \[7\]\[8\]\[9\] | 14% first-silicon success; 75% projects behind schedule; verification 60–70% of effort | Defines the cost of adaptivity; justifies the certified-state approach |
| **I. Sustainability and LCA** | BCG/SEMI \[14\]; imec.netzero \[15\]; Gupta et al. \[16\]; UN E-waste Monitor \[17\]; IEA \[12\] | Lifecycle split of device emissions; fab electricity dominates fab footprint; manufacturing dominates many compute footprints; e-waste growing faster than recycling | No hardware-architecture work that optimises **lifetime-carbon at runtime** (to our knowledge; to be confirmed by a systematic search) |
| **J. Design economics and reuse** | IBS via Arm filing \[2\]; SemiEngineering \[3\]; Silicon Analysts \[4\]; Arm CSS \[5\]\[6\] | Cost by node; headline numbers likely inflated; reuse via compute subsystems claims up to 12 months and tens of millions saved | Reuse via **runtime adaptation** is untested against reuse via **pre-integration** |

### 2.2 Source-by-source notes (for the related-work section)

- **Esmaeilzadeh et al. 2011 \[20\].** Shows multicore scaling is power-limited "to a degree not widely appreciated" and introduces the dark-silicon framing. Their retrospective says real chips show "dim" silicon with aggressive voltage/frequency scaling, which is exactly the regime where intelligent management pays. *Use:* motivation, not a number.
- **Gonzalez-Martinez et al. 2024 \[21\].** Surveys two decades of MPSoC management and describes autonomous management that integrates self-awareness of environment, behaviour and objectives. *Use:* the anchor survey; our related-work section must position against it.
- **CPSoC / hierarchical goal management \[22\].** Publications on goal-driven autonomy, hierarchical dynamic goal management and self-optimising learning with self-adaptive control. *Implication:* "Mission → architecture" in the earlier thread is **not new as a concept**. Credit it, then differentiate.
- **Maurer et al. DATE 2020 \[23\].** Supervisor + RL identifies optimised MPSoC operating parameters at runtime while strictly obeying power constraints, on an FPGA prototype. *Implication:* a constraint-respecting learned controller already exists for power; ours extends the constraint set to safety/security invariants with a certified-state design.
- **DVFO \[24\].** 33% average energy reduction and 28.6–59.1% latency reduction on edge devices, within about 1% accuracy loss. *Caveat:* different platform and baselines than ours; treat as an upper-plausibility marker.
- **Santos et al. 2024 \[25\].** Hybrid hardening of a RISC-V SoC with checkpoint/rollback; 45.09% effective software recovery in neutron irradiation with low overhead. *Use:* a measured, modest baseline that shows fault recovery is not trivially near-100%.
- **Hochschild et al. 2021 \[18\] and Meta \[19\].** Mercurial cores are rare but visible at fleet scale and corrupt even encryption. *Use:* the best argument that health awareness must be in the core, not only in fleet software.
- **CLKSCREW \[28\] and Hertzbleed \[29\].** Prove that energy-management interfaces are an attack surface. *Use:* the justification for authenticated policy updates, rate-limited actuation, and a constitution.
- **Wilson Research 2024 \[7\]\[8\]\[9\].** Verification effort grows faster than design complexity; first-silicon success was about 30% in 2012 and 14% in 2024. *Use:* the number a sceptical reviewer will cite against us; our answer is H5.
- **Gupta et al. \[16\] vs BCG/SEMI \[14\].** They disagree on where the footprint sits. SEMI/BCG attribute 63% of 2021 device lifetime emissions to **use**, 21% to manufacturing, 16% to supply chain \[14\]; Gupta et al. find most emissions from mobile and data-centre equipment come from **manufacturing and infrastructure** \[16\]. The difference is scope and boundary. *Implication:* our sustainability claim must hold under **both** views: energy saving covers the use-dominated view, lifetime extension covers the manufacturing-dominated view.

### 2.3 Novelty position (what we can and cannot claim)

| Claim | Defensible? | Why |
| --- | --- | --- |
| "First self-aware or self-healing RISC-V" | **No** | Prior art in B and D |
| "Mission-driven management of an SoC" | **Partly** | Goal management exists \[22\]\[23\]; differentiate on hardware enforcement and certified states |
| "Unified workload + health + security + mission loop with hardware constitution, measured across ≥4 missions" | **Yes, if measured** | No single published system found doing all of it (to be confirmed by a systematic search before submission) |
| "Switching-economics-aware policy (benefit over dwell time > switching cost)" | **Likely** | Treat as a core contribution; test against hysteresis-only baselines |
| "Lifetime-carbon-aware runtime policy" | **Likely novel** | No direct precedent found; needs a proper search |

**Search protocol to close the gap (do before any novelty claim):** IEEE Xplore, ACM DL and arXiv with strings combining {self-aware | autonomic | adaptive} × {SoC | RISC-V | MPSoC} × {fault | thermal | mission | goal | carbon}; backward and forward citation chaining from \[21\], \[22\], \[23\], \[25\]; record hits and exclusions in a PRISMA-style table.

---

## 3. Market and financial analysis

### 3.1 Market sizing (E1 inputs, E2 derivation)

| Layer | Size | Source and note |
| --- | --- | --- |
| Global semiconductor market | H1 2026 $702B (+102% YoY); 2026 ≈ $1.66T; 2027 ≈ $2.1T \[34\] | Memory-driven surge (memory +305% in H1); **not** a relevant TAM for this idea |
| **TAM: industrial ICs** | $65.5B in 2026 → $89.8B in 2031 (6.5% CAGR) \[35\]; another estimate $63.5B in 2026 \[36\] | Includes analog, power, sensors |
| Microcontrollers within industrial ICs | 22.95% of the market by 2031, ≈ $20.6B \[35\] | Programmable compute subset |
| Edge-AI chips | $20.6B (2026) \[37a\] vs $29.9B (2026) \[37b\] | Vendor definitions differ widely; overlaps with industrial |
| **SAM (our estimate)** | **≈ $13–25B in 2026** | Industrial programmable compute (MCU/MPU/edge processors for robots, drones, industrial edge) at a similar share of today's industrial ICs, plus the industrial edge-AI portion; overlap not fully removed |
| **SOM** | 0.1–0.5% of SAM by year 8–10 ≈ $15–125M/yr of silicon value influenced (E2, assumption) | Only meaningful as value-influenced revenue; vendor-side revenue is smaller (3.3) |

**Reading:** the opportunity is a niche inside a large market. That is fine for a research-grade UDT story but means the pitch should not lean on "trillion-dollar market" framing.

### 3.2 Three lenses on economics

| Lens | Who | Question |
| --- | --- | --- |
| **A. Platform vendor** | Company building and licensing EvoCompute | Does the business earn more than its cost of capital? |
| **B. Product developer** | Fabless firm or OEM needing several variants | Does one adaptive platform cost less than several fixed derivatives? |
| **C. Customer (end-user TCO)** | Plant or fleet operator | Does the value per node exceed the extra cost per node? |

### 3.3 Lens B: net NRE saving (28nm, E2)

**Assumptions:** a three-product portfolio. Conventional route: one full design *F* plus two derivatives at *d × F* each. EvoCompute route: one platform at *F(1 + e)* plus *m × F* per added mission profile. Full design cost *F* = $48M (IBS via Arm filing \[2\]) and a lower realistic case $25M (our adjustment in light of \[3\]\[4\]). Per-profile policy and evidence cost *m* = 4% of *F*.

**Net NRE saving = (2d − e − 2m) × F.** Break-even extra-NRE share: **e\* = 2d − 2m**.

| Net saving ($M), *m* = 4% | e = 15% | e = 30% | e = 50% |
| --- | --- | --- | --- |
| *F* = $48M, d = 25% | 13.0 | 5.8 | **–3.8** |
| *F* = $48M, d = 35% | 22.6 | 15.4 | 5.8 |
| *F* = $48M, d = 50% | 37.0 | 29.8 | 20.2 |
| *F* = $25M, d = 25% | 6.7 | 3.0 | **–2.0** |
| *F* = $25M, d = 35% | 11.7 | 8.0 | 3.0 |
| *F* = $25M, d = 50% | 19.2 | 15.5 | 10.5 |

**Reading:** with d = 35% and m = 4%, break-even e\* ≈ 62%, so there is headroom, but the saving turns negative when derivatives are cheap (d = 25%) and EvoCompute's extra NRE is high (e = 50%). **Given the verification evidence \[7\]\[8\], a realistic e is 30–50%, not 15%.** The earlier thread's "$253M saved" case (one fully avoided $298M design) should not be used.

**Unit economics (E2):** extra unit cost = area overhead × die cost + extra test. With a $9 die: 5% area and $0.10 test = $0.55; 10% and $0.20 = **$1.10**; 15% on a $12 die and $0.30 test = $2.10.

### 3.4 Lens C: customer value per node (E2)

Annual value per node = λ × μ × T × C, where λ = compute-attributable stoppage events per node-year, μ = fraction mitigated by graceful degradation or recovery (assume 0.5), T = hours per event (assume 0.5), C = cost per hour.

| C (source) | λ = 0.005 (1 per 200 nodes) | λ = 0.02 (1 per 50 nodes) |
| --- | --- | --- |
| $36k/h, FMCG low end \[11\] | $45 | $180 |
| $260k/h, cross-sector average cited secondhand (Aberdeen) | $325 | $1,300 |
| $2.3M/h, automotive \[10\] | $2,875 | $11,500 |

**Energy comparison:** 15% off a 20 W node = 3 W = 26.3 kWh/yr = **$2.63/yr at $0.10/kWh** (131 kWh over 5 years). Energy is an order of magnitude smaller than avoided downtime unless λ is extremely small.

**Break-even stoppage rate.** If the extra cost per node (silicon $1.10 plus about $5 adoption cost, our assumption) is amortised over 5 years (about $1.22/yr), EvoCompute pays back when λ × μ × T × C ≥ $1.22, i.e. **λ ≈ 1.4 × 10⁻⁴ events/node-year at C = $36k/h, 1.9 × 10⁻⁵ at $260k/h, and 2.1 × 10⁻⁶ at $2.3M/h.** In words: the platform needs to prevent a plant-stopping compute fault roughly once per 7,000 node-years at the lowest cost level.

**Critical caveat (attribution).** The plant stops only if the compute fault was the cause and the stoppage would otherwise have happened. Siemens' figures are for all unplanned downtime \[10\]; the share caused by compute-node faults is unknown and must be measured with a design partner. Do not claim the Siemens totals as EvoCompute savings.

### 3.5 Lens A: vendor model (10-year, 15% discount rate, E2)

**Assumptions:** 3 years of development ($4–5M/yr), then $3M/yr operating cost; licence fee per licensee; licensees ship units from year 2 after signing (50% in the first year); royalty per unit. All figures are assumptions to be replaced with partner quotes.

| Scenario | Dev $M/yr | New licensees (yrs 3–7) | Fee $M | Royalty $/unit | Units/licensee/yr (M) | NPV @15% | IRR | Payback |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Pessimistic | 5.0 | 1,1,2,2,2 | 1.0 | 0.10 | 0.2 | **–$18.6M** | n/a | none |
| **Base** | 4.0 | 2,3,4,4,4 | 1.5 | 0.20 | 0.3 | **–$6.8M** | n/a | none in 10 yrs |
| Optimistic | 4.0 | 3,5,6,7,7 | 2.0 | 0.30 | 0.5 | **+$8.4M** | **31.6%** | 4.3 yrs |

**Sweep on the base case:** raising royalty alone to $1.00/unit still gives NPV –$3.8M (IRR 5.3%); raising volume alone to 1.5M units per licensee gives the same. A combination of fee $2.0M, royalty $0.50 and 0.6M units per licensee gives NPV +$0.3M (IRR 15.7%, payback 5.4 years).

**Reading:** a stand-alone licensing business does **not** clear a 15% hurdle without optimistic volume and pricing. The honest framing is a **platform and research programme** funded by grants and design-linked incentives, with services (policy tuning, evidence packs) and later IP licensing. This is the finding most likely to surprise a reviewer, and it makes the paper more credible.

### 3.6 Energy-at-scale envelope (not a claim)

If adaptive hardware influenced 5% of data-centre electricity and cut it 10%, using IEA's 945 TWh for 2030 \[12\]: 945 × 5% × 10% = **4.7 TWh/yr**, about $470M at $0.10/kWh, or roughly 1.9–3.3 Mt CO₂ at an assumed 0.4–0.7 kg/kWh grid factor. Present only as an *opportunity envelope*. Data centres already run mature schedulers and DVFS, so the real bar is high.

---

## 4. Industry impact

### 4.1 Value chain: where EvoCompute touches

| Stage | Today | Effect of EvoCompute | Who gains / loses |
| --- | --- | --- | --- |
| EDA and IP | Tools verify fixed designs | Needs mode-aware verification, formal proof of invariants | EDA vendors gain a new verification market; IP vendors must expose health/telemetry hooks |
| Design house | One design per market variant | Fewer variants, more policy/software work | Gains if H4 holds; loses derivative-design revenue |
| Foundry / OSAT | Wafer and package volume per SKU | Possibly larger die (area overhead), fewer SKUs | Slightly more silicon per unit; less SKU fragmentation |
| OEM / integrator | Qualifies hardware per product | Qualifies a platform plus mission profiles | Lower BOM variety; higher qualification burden for the first profile |
| Operator | Replaces parts on failure or obsolescence | Graceful degradation, health telemetry, longer service | Fewer unplanned stops; needs trust in autonomous adaptation |
| Recycler / policy | Receives retired hardware | Fewer, later retirements | Lower e-waste per service-year \[17\] |

### 4.2 Competitive landscape

| Alternative | Strength | Weakness vs EvoCompute's pitch | Evidence |
| --- | --- | --- | --- |
| Fixed ASIC | Best efficiency for a known workload | Frozen; high NRE \[2\] | E1 |
| **Arm Compute Subsystems / chiplets** | Pre-integrated, verified; up to 12 months faster, tens of millions NRE saved \[5\] | Statically composed; **directly competes for the "avoid redesign" argument** | E1 (vendor claim) |
| **FPGA / SoC FPGA** (Microchip PolarFire SoC, AMD Versal) | Reconfigurable; RISC-V + fabric; radiation-tolerant variant; certified toolchain \[30\]\[31\] | Higher power/cost for fixed functions; adaptation of *function*, not a closed-loop mission policy | E1 |
| Classic DVFS / power management | Mature, cheap | Single-axis; also an attack surface \[28\]\[29\] | E1 |
| Fault-tolerant cores (TMR/ECC/DPR) | Proven for space and safety \[25\]\[26\]\[27\] | Always-on overhead (replicated logic under TMR typically costs about 3× area); reliability-only | E1 / E2 |
| Self-aware MPSoC research | Strong theory \[21\]\[22\]\[23\] | Mostly simulation or FPGA, no hardware-enforced certified states, limited multi-mission evidence | E1 |

**Porter's Five Forces (summary):**

| Force | Intensity | Reasoning |
| --- | --- | --- |
| Rivalry | High | Arm, Microchip, AMD, Intel/Altera, RISC-V IP houses, plus open-source cores |
| Threat of substitutes | High | CSS/chiplets, FPGAs and software-defined orchestration solve overlapping problems |
| Buyer power | High | OEMs buy on qualified, certified, second-sourced parts |
| Supplier power | Medium | Foundry and EDA concentrated; open-source flows (OpenROAD/OpenLane) reduce dependence for prototypes |
| Threat of entry | Medium | Open RISC-V lowers core barriers; verification, safety evidence and trust are the real barriers |

**Likely incumbent response (hypothesis):** add health telemetry and DVFS policy engines to existing SoCs, and market "predictive reliability" features. Our durable differentiators are therefore the **open, auditable, constitution-bounded policy** and the **evidence base**, not the existence of an adaptive loop.

---

## 5. Friction and feasibility

### 5.1 Barriers

| Type | Barrier | Severity | Mitigation |
| --- | --- | --- | --- |
| **Technical** | State-space explosion: 4 modes × 3 voltages × 3 frequencies × 3 cache modes × 2 accelerator states = 216 configurations before corners and fault states (earlier thread) | High | Certified configuration set; formal proof of invariants; test only reachable-state transitions |
| Technical | Adaptation overhead can erase gains on short workloads | Medium | Switching-economics model; hysteresis; minimum residency; benchmark against static |
| Technical | Control oscillation | Medium | Dwell-time and confidence thresholds; stability analysis |
| Technical | Area overhead | Medium | Coarse-grained morphing only; hard cap at ≤10%, kill at >15% |
| **Verification** | 14% first-silicon success; 75% projects behind schedule \[7\] | High | Reuse proven RISC-V cores; formal-first; FPGA before silicon |
| **Security** | DVFS-style interfaces exploited before \[28\]\[29\] | High | Authenticated policy updates, rate-limited actuation, redundant sensors, immutable safe-state controller |
| **Regulatory** | Safety standards (IEC 61508, ISO 26262) demand predictable behaviour; vendor toolchains already carry ASIL-D/SIL-3 certificates \[30\] | High for safety-critical, low for non-safety supervisory nodes | Start in non-safety-critical industrial vision/supervision; design evidence for a later safety case |
| Regulatory | EU CRA: reporting of actively exploited vulnerabilities applies since 11 Sep 2026, full requirements from 11 Dec 2027; sector-regulated areas (for example automotive, medical) are exempt \[39\] | Medium | Build vulnerability handling and secure update into the design; treat CRA as a market-access requirement for connected industrial products |
| **Cultural** | Engineers distrust "AI in the chip"; operators prefer determinism | High | "AI proposes, constitution decides"; expose logs and replay; publish negative results |
| **Economic** | Incumbent reuse offerings already promise NRE savings \[5\] | High | Compete on lifetime, resilience and mission flexibility, not only NRE |
| **Ecosystem (India)** | DLI uptake has been limited and fund utilisation slow \[38\]; Semicon 2.0 (approved 15 Jul 2026) adds deployment-linked incentives to offset tape-out cost \[38\] | Medium | Align the programme with Semicon 2.0 design, IP and productisation priorities |

### 5.2 Roadmap with stage gates

| Phase | Months | Deliverable | Gate (continue only if) |
| --- | --- | --- | --- |
| **0. Golden model + FPGA prototype** | 0–3 | RISC-V core + sensors, 4 modes, fault injector, baselines B0 (static), B1 (DVFS-only), B2 (workload-aware), B3 (fault-tolerant-only) on an FPGA board | Beats B1 on at least one workload mix by >5% *or* shows a recovery benefit |
| **1. Policy + constitution** | 3–9 | Table/bandit policy, then tiny MLP; constitution as hardware checks; CCS defined; formal proofs of invariants | All invariants proven; area overhead ≤15% post-synthesis |
| **2. Attack and fault campaigns** | 6–12 | Thermal, timing, SEU, memory corruption and telemetry-spoofing campaigns | Zero constitution violations under attack |
| **3. Test chip** | 9–18 | MPW tape-out on an open or institutional node; silicon characterisation | Measured overhead and energy within 20% of FPGA/synthesis projections |
| **4. Pilot** | 18–36 | Industrial vision or UAV pilot with a design partner; measure λ (compute-attributable stoppage rate) | Partner data support λ above break-even (3.4) |
| **5. Productisation** | 36+ | 28nm design, safety-case preparation, licensing/services | Business case clears hurdle (3.5) with partner-validated inputs |

*Reuse note:* an existing RV32 core flow and an FPGA board with a working Quartus/OpenLane toolchain can compress Phase 0 substantially.

**Critical success factors:** (1) a reproducible, open evaluation harness with baselines; (2) formal proofs of the constitution; (3) one credible design partner for λ data; (4) honest reporting of overhead and failures; (5) a clear first market (non-safety-critical industrial edge).

**Kill criteria:** area overhead >15% after synthesis; gain over DVFS-only \<5% on realistic workloads; any constitution violation under attack; verification effort for the CCS beyond the stated cap.

---

## 6. Value proposition and selling points

**Unique selling proposition:** *"One silicon, many optimal machines, safe by construction."*

| Stakeholder | Benefit | Evidence now | Evidence needed |
| --- | --- | --- | --- |
| Plant / fleet operator | Fewer plant-stopping compute faults, health telemetry, longer service life | E1 context \[10\]\[11\], E2 break-even (3.4) | Measured λ and μ |
| OEM / product developer | Fewer variants, one qualification base | E2 (3.3) | Partner NRE data |
| Chip designer / EDA | Reusable verified platform, open policy interface | E3 | Prototype |
| Policy maker | Design-led, indigenous, sustainable computing story aligned with Semicon 2.0 \[38\] | E1 policy context | Pilot outcomes |
| Sustainability officer | Lower use-phase energy and lower carbon per service-year | E2 envelopes (Section 8) | LCA with manufacturer data |
| Security officer | Bounded, auditable adaptation | E3 | Attack campaign |

**ESG alignment:** use-phase energy (63% of 2021 device lifetime emissions in SEMI/BCG's accounting \[14\]), embodied carbon amortisation (manufacturing-dominant view \[16\]), e-waste reduction \[17\], and resilience. Frame all of these as **potential**, with measured values to follow.

---

## 7. Pros, cons, SWOT

### 7.1 Pros and cons with quantification

| Pros | Size (grade) | Cons | Size (grade) |
| --- | --- | --- | --- |
| Avoided derivative NRE | $3–37M per three-product portfolio at 28nm (E2, table 3.3) | Extra platform NRE, verification, policy evidence | e = 15–50% of *F*; plausible 30–50% (E2/E3) |
| Avoided stoppage value | $45–$11,500 per node-year depending on inputs (E2) | Extra unit cost | $0.55–$2.10 per unit (E2) |
| Energy saving | $2.6/yr per 20 W node at 15% (E2); 33% precedent in a different setting \[24\] | Adaptation overhead, oscillation risk | Workload-dependent (E3) |
| Longer useful life | 30% longer life cuts amortised embodied carbon about 23% (E2 arithmetic) | Adoption: buyers prefer certified, deterministic parts | Qualitative (E1 context \[7\]) |
| Fault resilience | Recovery benefit vs static (to be measured) | Security exposure of adaptive interfaces | Real precedents \[28\]\[29\] |
| Strong fit with VLSID theme and Semicon 2.0 | Qualitative | Crowded prior art | See 2.3 |

**Do the pros outweigh the cons?** At *research* level, yes: the downside is bounded (a prototype) and the upside includes publishable negative or positive results. At *commercial* level, **not yet proven**: the base-case vendor NPV is negative (3.5) and incumbents offer overlapping savings (4.2). The decision therefore rests on three numbers we do not have: λ, e, and measured energy gain. The roadmap is built to get them cheaply.

### 7.2 SWOT

| Strengths | Weaknesses |
| --- | --- |
| Unified loop plus constitution; open, auditable design; buildable on FPGA | Small team and limited silicon access; no field data yet |
| Clear sustainability angle (lifetime-carbon objective) | Added NRE and verification burden |
| **Opportunities** | **Threats** |
| Semicon 2.0 design incentives \[38\]; CRA pushes secure, updateable hardware \[39\]; rising fleet-scale SDC awareness \[18\]\[19\] | Arm CSS and FPGA vendors already address reuse and reliability \[5\]\[30\]\[31\]; novelty challenges from self-aware SoC literature \[21\]\[22\]\[23\] |

### 7.3 Risk register (top items)

| Risk | Likelihood | Impact | Mitigation | Owner/Gate |
| --- | --- | --- | --- | --- |
| Gain over DVFS-only is small | Medium | High | Early baseline comparison; pivot to reliability + lifetime story | Gate 0 |
| Verification cost exceeds budget | High | High | CCS cap; formal-first | Gate 1 |
| Policy exploited by attacker | Medium | High | Authenticated updates, safe-state controller | Gate 2 |
| Reviewer rejects novelty | Medium | High | Systematic search; explicit differentiation (2.3) | Before submission |
| No partner data for λ | Medium | Medium | Public failure datasets; synthetic fault models stated clearly | Gate 4 |

---

## 8. Sustainability and vision

### 8.1 What the sustainability case rests on

1. **Use-phase energy.** In SEMI/BCG's accounting, 63% of lifetime emissions from 2021-produced devices (500 Mt CO₂e) come from device use, 21% from manufacturing, 16% from the supply chain \[14\]. EvoCompute lowers use-phase energy where workloads vary.
2. **Embodied carbon.** Manufacturing and infrastructure dominate many compute footprints \[16\]; fab electricity can reach 60% of a fab's footprint, and chips contribute about 30% of AI data-centre carbon in imec's framing \[15\]. A chip that stays useful longer amortises sunk carbon over more service-years.
3. **Circularity.** E-waste reached 62 Mt in 2022 with 22.3% formally recycled and is on course for 82 Mt by 2030 \[17\]. Longer service life and graceful degradation reduce retirements.

### 8.2 Envelope calculations (E2, assumptions explicit)

Using SEMI/BCG's 500 Mt baseline: embodied (supply chain + manufacturing) = 37% = **185 Mt**; use = 63% = **315 Mt** \[14\]. If EvoCompute-class platforms influenced a share *s* of devices:

| Share *s* | Lifetime +30% → embodied amortisation falls 23.1% | Energy –15% on use phase | Combined (Mt CO₂e per year-equivalent) |
| --- | --- | --- | --- |
| 0.5% | 0.21 | 0.24 | 0.45 |
| 1% | 0.43 | 0.47 | 0.90 |
| 2% | 0.85 | 0.94 | 1.79 |

These are *illustrative upper-bound arithmetic*, assuming the lifetime and energy effects materialise and are not double-counted. Their purpose is to show order of magnitude (sub-Mt to low Mt per year at 0.5–2% influence), not to forecast.

### 8.3 The new sustainability contribution: carbon-aware lifetime policy

Extend the earlier utility function with a lifetime-carbon term:

**U = wp·P + we·E + wr·R + ws·S − wt·T − wc·(embodied carbon ÷ expected remaining service-years)**

The policy engine then prefers configurations that slow wear (lower voltage, lower temperature, spare-unit rotation) when mission slack allows, extending the capability floor. **Test (H7):** under injected aging, compare years to a capability floor vs static. This turns the sustainability story from a slogan into a measurable result.

### 8.4 Vision: a better silicon future

- **Today:** design a fixed chip for a guessed future, retire it when the guess fails or one block ages out.
- **With EvoCompute-class platforms:** a verified family of states, chosen at run time by a bounded policy, with health that is observable and reportable, and with service life managed as a resource.
- **For policy makers:** programmes such as Semicon 2.0 can fund *evidence* (open benchmarks, shared fault datasets, safety-case templates), not only fabs and tape-outs; and procurement can reward lifetime-carbon reporting for connected industrial equipment.

---

## 9. Solution map: every defined problem to a mechanism and a test

| Problem | Mechanism in EvoCompute | Metric | Experiment | Residual risk |
| --- | --- | --- | --- | --- |
| P1 Workload mismatch | Resource trading across CPU/accelerator/DSP modes; predictive workload horizon | Perf/W, utilisation | Mixed workload traces vs B0–B3 | Gain may be small vs DVFS-only |
| P2 Static margins | Health-aware DVFS within constitution; timing-margin sensing | Energy at iso-performance | Sweep V/F under thermal stress | Margin recovery limited by sensor accuracy |
| P3 Silent/latent faults | Parity/ECC/lockstep sampling, anomaly detection, core isolation, rollback | Recovery %, silent corruption rate | SEU, memory, timing-violation injection | Fault model coverage |
| P4 Fragmentation | Mission profiles as policy + CCS subset | Profiles served within 10% of static optimum | ≥4 profiles on the same RTL | NRE e may exceed break-even (3.3) |
| P5 Short life / embodied carbon | Lifetime-carbon utility term; wear-levelling across spare units | Years to capability floor; carbon per service-year | Aging injection, LCA arithmetic | Life extension unproven until measured |
| P6 Unverifiable adaptivity | CCS + formal invariants + constitution + replayable logs | States certified, properties proven, effort | SymbiYosys/formal on invariants; coverage report | Verification cost (60–70% norm \[8\]) |
| P7 Attack surface | Authenticated policy updates, rate limiting, redundant sensors, safe-state | Violations under attack | Telemetry-spoofing and fault-attack campaigns \[28\]\[29\] | Novel attacks |
| P8 Economic/regulatory friction | First market non-safety-critical; evidence pack; open policy interface; align with incentives \[38\]\[39\] | λ vs break-even; partner LOI | Pilot | Incumbent response \[5\]\[30\] |

---

## 10. What to validate next (in priority order)

1. **Systematic novelty search** (protocol in 2.3) before any claim of newness.
2. **Phase 0 baseline experiment:** does unified control beat DVFS-only by >5%? This one result decides whether the energy story survives.
3. **Measure λ** with a partner or from public failure datasets; if λ is far below the break-even in 3.4, drop the reliability-ROI pitch.
4. **Replace e** (extra NRE share) with a bottom-up estimate from the Phase 1 area and verification numbers.
5. **Locate or discard** the unverified claims in the audit table (self-healing TNS 2026 paper, IBM 18–31%, ABB survey, 2025–26 IEEE efficiency papers).
6. **Get an LCA figure** for the target node (imec.netzero \[15\] or manufacturer data) to replace the SEMI/BCG split in 8.2.

---

## 11. References

*Retrieved 5 Oct 2026 unless marked "from memory". Vendor and market-research figures are secondary and should be re-checked against the primary document before they go on a slide.*

### Conference and policy

\[1\] VLSID 2027, *Call for User Design Track (UDT)*. [https://vlsid.org/call-for-udt/](https://vlsid.org/call-for-udt/) \[38\] India: Semicon India Programme page (Semicon 2.0 approved 15 Jul 2026, ₹1,27,500 crore): [https://en.vikaspedia.in/viewcontent/e-governance/digital-india/semicon-india-program?lgn=en](https://en.vikaspedia.in/viewcontent/e-governance/digital-india/semicon-india-program?lgn=en) ; YourStory, "Finance Ministry panel clears Rs 1.25 lakh crore outlay for ISM 2.0" (24 DLI projects, 105 firms with EDA access, 23 tapeouts): [https://yourstory.com/2026/06/finance-ministry-panel-1-25-lakh-crore-india-semiconductor-mission](https://yourstory.com/2026/06/finance-ministry-panel-1-25-lakh-crore-india-semiconductor-mission) ; IMPRI critique on DLI uptake: [https://www.impriindia.com/?p=74034](https://www.impriindia.com/?p=74034) \[39\] EU Cyber Resilience Act timeline: [https://www.itemis.com/en/glossary/cyber-resilience-act/](https://www.itemis.com/en/glossary/cyber-resilience-act/) ; [https://www.cyberresilienceact.eu/explained.html](https://www.cyberresilienceact.eu/explained.html)

### Design economics, verification, competitors

\[2\] AnySilicon, "How Much Does ASIC Design Cost in 2026?" (IBS model reproduced in Arm's 2023 filing: ≈$48M at 28nm, $449M at 5nm, $725M at 2nm). [https://anysilicon.com/news/how-much-does-asic-design-cost-in-2026-real-price-ranges-by-process-node/](https://anysilicon.com/news/how-much-does-asic-design-cost-in-2026-real-price-ranges-by-process-node/) \[3\] Semiconductor Engineering, "What Will That Chip Cost?" [https://www.semiengineering.com/what-will-that-chip-cost/](https://www.semiengineering.com/what-will-that-chip-cost/) \[4\] Silicon Analysts, Chip Design & NRE Cost by Node (IBS vs SemiAnalysis-adjusted). [https://siliconanalysts.com/market-data/nre-design-cost](https://siliconanalysts.com/market-data/nre-design-cost) \[5\] Arm Newsroom, "How Arm Compute Subsystems Accelerate the Future of Chip Design". [https://newsroom.arm.com/blog/arm-compute-subsystems-css-explainer](https://newsroom.arm.com/blog/arm-compute-subsystems-css-explainer) \[6\] Arm Newsroom, custom-silicon partnership post (2nm cost $500–700M claim). [https://newsroom.arm.com/blog/ai-chip-design-partnership](https://newsroom.arm.com/blog/ai-chip-design-partnership) \[7\] Siemens EDA / Wilson Research Group, *2024 IC/ASIC Functional Verification Trend Report*. [https://verificationacademy.com/topics/planning-measurement-and-analysis/wrg-industry-data-and-trends/2024-siemens-eda-and-wilson-research-group-ic-asic-functional-verification-trend-report/](https://verificationacademy.com/topics/planning-measurement-and-analysis/wrg-industry-data-and-trends/2024-siemens-eda-and-wilson-research-group-ic-asic-functional-verification-trend-report/) \[8\] H. Foster, "Why First-Silicon Success Is Getting Harder for System Companies" (Siemens, 3 Sep 2025). [https://blogs.sw.siemens.com/verificationhorizons/2025/09/03/why-first-silicon-success-is-getting-harder-for-system-companies](https://blogs.sw.siemens.com/verificationhorizons/2025/09/03/why-first-silicon-success-is-getting-harder-for-system-companies) \[9\] Embedded.com, interview on chip-verification challenges (first-silicon about 30% in 2012). [https://www.embedded.com/?p=4497797](https://www.embedded.com/?p=4497797) \[30\] Microchip, RT PolarFire SoC FPGA: [https://microchip.com/en-us/products/fpgas-and-plds/radiation-tolerant-fpgas/rt-polarfire-soc](https://microchip.com/en-us/products/fpgas-and-plds/radiation-tolerant-fpgas/rt-polarfire-soc) ; PolarFire family page (Libero certified ISO 26262 ASIL-D / IEC 61508 SIL-3): [https://microchip.com/en-us/products/fpgas-and-plds/fpgas/polarfire-fpgas](https://microchip.com/en-us/products/fpgas-and-plds/fpgas/polarfire-fpgas) \[31\] ESA workshop session listing (AMD Versal adaptive SoC for space). [https://indico.esa.int/event/531/sessions/2097](https://indico.esa.int/event/531/sessions/2097) \[32\] McKinsey, "Getting ready for next-generation E/E architecture with zonal compute". [https://mckinsey.com/industries/semiconductors/our-insights/getting-ready-for-next-generation-ee-architecture-with-zonal-compute](https://mckinsey.com/industries/semiconductors/our-insights/getting-ready-for-next-generation-ee-architecture-with-zonal-compute) \[33\] Bosch Mobility, E/E architecture. [https://bosch-mobility.com/en/mobility-topics/ee-architecture/](https://bosch-mobility.com/en/mobility-topics/ee-architecture/)

### Markets

\[34\] WSTS Q2 2026 release: [https://www.wsts.org/esraCMS/extension/media/f/WST/7745/WSTS-Q2-Release-2026-08-06.pdf](https://www.wsts.org/esraCMS/extension/media/f/WST/7745/WSTS-Q2-Release-2026-08-06.pdf) ; Bits&Chips, 11 Aug 2026: [https://bits-chips.com/article/global-semiconductor-market-doubles-in-h1-2026/](https://bits-chips.com/article/global-semiconductor-market-doubles-in-h1-2026/) \[35\] Mordor Intelligence, Industrial Integrated Circuits Market. [https://www.mordorintelligence.com/industry-reports/industrial-integrated-circuits-market](https://www.mordorintelligence.com/industry-reports/industrial-integrated-circuits-market) \[36\] Coherent Market Insights, Industrial Chips Market (via GII). [https://www.gii.tw/report/coh2058284-industrial-chips-market-by-product-type-by.html](https://www.gii.tw/report/coh2058284-industrial-chips-market-by-product-type-by.html) \[37a\] Meticulous Research, Edge AI Chips Market. [https://www.meticulousresearch.com/product/edge-ai-chips-market-6869](https://www.meticulousresearch.com/product/edge-ai-chips-market-6869) \[37b\] Fortune Business Insights, Edge AI Semiconductor Market. [https://www.fortunebusinessinsights.com/edge-ai-semiconductor-market-117383](https://www.fortunebusinessinsights.com/edge-ai-semiconductor-market-117383)

### Industrial cost of downtime, energy, sustainability

\[10\] Siemens, *The True Cost of Downtime 2024*. [https://assets.new.siemens.com/siemens/assets/api/uuid:1b43afb5-2d07-47f7-9eb7-893fe7d0bc59/TCOD-2024_original.pdf](https://assets.new.siemens.com/siemens/assets/api/uuid:1b43afb5-2d07-47f7-9eb7-893fe7d0bc59/TCOD-2024_original.pdf) \[11\] vsight.io summary of Siemens/Senseye (FMCG $36k/h, 27 h/month, 25 incidents/month). [https://vsight.io/blog/cost-of-unplanned-downtime-manufacturing/](https://vsight.io/blog/cost-of-unplanned-downtime-manufacturing/) \[12\] IEA, *Energy and AI* (Apr 2025). [https://www.iea.org/news/ai-is-set-to-drive-surging-electricity-demand-from-data-centres-while-offering-the-potential-to-transform-how-the-energy-sector-works](https://www.iea.org/news/ai-is-set-to-drive-surging-electricity-demand-from-data-centres-while-offering-the-potential-to-transform-how-the-energy-sector-works) \[13\] Scientific American on the IEA report (415 TWh in 2024; 945 TWh in 2030). [https://scientificamerican.com/article/ai-will-drive-doubling-of-data-center-energy-demand-by-2030](https://scientificamerican.com/article/ai-will-drive-doubling-of-data-center-energy-demand-by-2030) \[14\] BCG / SEMI Semiconductor Climate Consortium, *Transparency, Ambition and Collaboration* (2023): [https://discover.semi.org/rs/320-QBB-055/images/Transparency-Ambition-and-Collaboration-BCG-SEMI-SCC-20230919.pdf](https://discover.semi.org/rs/320-QBB-055/images/Transparency-Ambition-and-Collaboration-BCG-SEMI-SCC-20230919.pdf) ; summary (500 Mt; 16/21/63%): [https://www.3dincites.com/2023/10/tracking-and-reporting-sustainability-a-stake-in-the-sand/](https://www.3dincites.com/2023/10/tracking-and-reporting-sustainability-a-stake-in-the-sand/) \[15\] imec, "How can we reduce the environmental impact of chip manufacturing?" (imec.netzero). [https://www.imec-int.com/en/articles/how-can-we-reduce-environmental-impact-chip-manufacturing](https://www.imec-int.com/en/articles/how-can-we-reduce-environmental-impact-chip-manufacturing) \[16\] U. Gupta et al., "Chasing Carbon: The Elusive Environmental Footprint of Computing," HPCA 2021 / IEEE Micro 42(4), 2022. [https://arxiv.org/abs/2011.02839](https://arxiv.org/abs/2011.02839) \[17\] UNITAR/ITU, *Global E-waste Monitor 2024*. [https://www.unitar.org/about/news-stories/press/global-e-waste-monitor-2024-electronic-waste-rising-five-times-faster-documented-e-waste-recycling](https://www.unitar.org/about/news-stories/press/global-e-waste-monitor-2024-electronic-waste-rising-five-times-faster-documented-e-waste-recycling)

### Architecture, self-awareness, reliability, security

\[18\] P. Hochschild et al., "Cores that don't count," HotOS 2021. [https://research.google/pubs/cores-that-dont-count/](https://research.google/pubs/cores-that-dont-count/) \[19\] Meta Engineering, silent errors / silent data corruption at scale (H. Dixit et al., 2021). [https://engineering.fb.com/2022/03/17/production-engineering/silent-errors/](https://engineering.fb.com/2022/03/17/production-engineering/silent-errors/) \[20\] H. Esmaeilzadeh et al., "Dark Silicon and the End of Multicore Scaling," ISCA 2011. [https://doi.org/10.1145/2000064.2000108](https://doi.org/10.1145/2000064.2000108) \[21\] G. Gonzalez-Martinez et al., "A Survey of MPSoC Management toward Self-Awareness," *Micromachines* 15(5):577, 2024. [https://doi.org/10.3390/mi15050577](https://doi.org/10.3390/mi15050577) \[22\] CORDIS project 705617, "Self-Aware CPSoCs with Hierarchical Goal Management" (publication list). [https://cordis.europa.eu/project/id/705617](https://cordis.europa.eu/project/id/705617) \[23\] F. Maurer et al., hierarchical supervisor / reinforcement-learning MPSoC control, DATE 2020 special session. [https://date20.date-conference.com/node/627](https://date20.date-conference.com/node/627) \[24\] Z. Zhang et al., "DVFO: Learning-Based DVFS for Energy-Efficient Edge-Cloud Collaborative Inference," arXiv:2306.01811. [https://arxiv.org/abs/2306.01811](https://arxiv.org/abs/2306.01811) \[25\] D. A. Santos et al., "Hybrid Hardening Approach for a Fault-Tolerant RISC-V System-on-Chip," IEEE TNS 71(8), 2024. [https://doi.org/10.1109/TNS.2024.3406021](https://doi.org/10.1109/TNS.2024.3406021) \[26\] J. Cano-Páez et al., "Architecture for error detection and recovery in MPSoCs: A hypervisor approach using Dynamic Partial Reconfiguration," IEEE TNS 2025. [https://doi.org/10.1109/TNS.2025.3534431](https://doi.org/10.1109/TNS.2025.3534431) \[27\] C. Bolchini, A. Miele, "Design and implementation of a self-healing processor on SRAM-based FPGAs," 2014. [https://re.public.polimi.it/handle/11311/869755](https://re.public.polimi.it/handle/11311/869755) \[28\] A. Tang, S. Sethumadhavan, S. Stolfo, "CLKSCREW," USENIX Security 2017. [https://www.usenix.org/conference/usenixsecurity17/technical-sessions/presentation/tang](https://www.usenix.org/conference/usenixsecurity17/technical-sessions/presentation/tang) \[29\] Y. Wang et al., "Hertzbleed," USENIX Security 2022. [https://www.usenix.org/conference/usenixsecurity22/presentation/wang-yingchen](https://www.usenix.org/conference/usenixsecurity22/presentation/wang-yingchen)

### Background works cited from memory (verify before publishing)

\[40\] J. O. Kephart, D. M. Chess, "The Vision of Autonomic Computing," *IEEE Computer* 36(1), 2003. \[41\] J. L. Hennessy, D. A. Patterson, "A New Golden Age for Computer Architecture," *CACM* 62(2), 2019. \[42\] L. A. Barroso, U. Hölzle, "The Case for Energy-Proportional Computing," *IEEE Computer* 40(12), 2007. \[43\] D. Ernst et al., "Razor: A Low-Power Pipeline Based on Circuit-Level Timing Speculation," MICRO 2003. \[44\] N. Dutt, A. Jantsch, S. Sarma, "Toward Smart Embedded Systems: A Self-aware System-on-Chip (SoC) Perspective," *ACM TECS* 15(2), 2016.

### Model files

The financial, TCO and sustainability arithmetic in Sections 3 and 8 was run in a short Python script (NPV, IRR, payback, sweeps). Inputs are labelled as assumptions; change them before any external use.
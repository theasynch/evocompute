# EvoCompute: One Silicon. Many Optimal Machines.

**EvoCompute** is a mission-driven, predictive architecture that dynamically selects from a hardware-certified configuration space to jointly optimize workload performance, energy, reliability, and system health.

By turning the architecture itself into a runtime variable, EvoCompute effectively allows a single piece of silicon to serve as multiple optimal machines depending on its environment and mission requirements—all while remaining safely bounded by immutable hardware invariants.

## The Core Concept

Modern chips are designed years before deployment based on a fixed set of assumptions. But in reality:
- Workloads spike and stall.
- Thermal boundaries shift.
- Silicon wears and degrades.

EvoCompute addresses this by closing the loop directly in hardware:
1. **Sense:** Monitors physical health (temperature) and workload intensity.
2. **Predict & Policy:** A Policy Engine decides the optimal *Certified Configuration* (e.g., Low Power, Balanced, High Performance).
3. **Constitution (Safety):** A strict *Hardware Constitution* intercepts the policy decision and overrides it if physical limits (e.g., thermal thresholds) are violated.
4. **Morph:** The underlying compute fabric adapts its clock, cache, and redundancy state to match the approved configuration.

## RTL Implementation Overview

This repository contains the initial proof-of-concept RTL implementation of the EvoCompute wrapper, integrated with the [PicoRV32](https://github.com/YosysHQ/picorv32) open-source RISC-V core.

### Directory Structure
```
evocompute/
├── docs/                      # Documentation and images
│   └── img/waveform.png       # Simulation waveform plot
├── rtl/                       # Verilog / SystemVerilog Sources
│   ├── evocompute_top.sv      # Top-level integration wrapping the CPU and Evo logic
│   ├── hardware_constitution.sv # Enforces physical thermal limits
│   ├── picorv32.v             # The underlying RISC-V core
│   ├── policy_engine.sv       # Maps workload to desired configuration state
│   └── sensor_mock.sv         # Mocks environmental telemetry (temp/workload)
├── tb/                        # Testbenches
│   └── evocompute_tb.sv       # Main testbench injecting dynamic workloads/thermal events
└── README.md                  # This file
```

### Module Descriptions

- **Sensor Mock (`sensor_mock.sv`):** Provides environmental data simulating thermal sensors and workload monitors.
- **Policy Engine (`policy_engine.sv`):** Interprets the workload data and requests one of three states:
  - `0`: Low Power
  - `1`: Balanced
  - `2`: High Performance
- **Hardware Constitution (`hardware_constitution.sv`):** An independent safety block. It reviews the requested state against current thermal limits. If the requested state would push the chip past safe thermal limits (e.g. 85°C warning limit, 100°C critical limit), it overrides the state to protect the hardware and flags a violation.
- **EvoCompute Top (`evocompute_top.sv`):** Connects the sensors, policy engine, and constitution, then gates the clock for the `picorv32` core dynamically based on the finalized state.

## Quantitative Impact & Economic Viability

The real strength of EvoCompute goes beyond adaptive switching—it creates **mathematical and economic viability** across three critical layers: Operational Utility, NRE Savings, and Fleet Resilience.

### 1. The Mission Utility Function
EvoCompute continuously solves for the maximum **Mission Utility ($U$)**:
$$ U = w_pP + w_eE + w_rR + w_sS - w_tT - w_cC $$
Where:
- $P$ = Performance | $E$ = Energy Efficiency | $R$ = Reliability 
- $S$ = Security/Safety | $T$ = Thermal/Latency Penalty | $C$ = Lifecycle-carbon cost
*(Weights $w$ vary per mission profile. The hardware constitution restricts the solution space to guarantee survival, allowing the Policy Engine to freely maximize $U$.)*

### 2. Platform Economics (Net NRE Savings)
By deploying *one adaptive platform* serving multiple mission profiles instead of spinning multiple fixed variants, the Non-Recurring Engineering (NRE) savings scale directly. 

For a baseline three-product portfolio (one base chip + two variants), the net saving can be modeled as:
**`Net NRE saving = (2d − e − 2m) × F`**
- **$F$**: Base ASIC design cost (e.g., ~$48M at 28nm)
- **$d$**: Cost of a derivative design (e.g., 35% of $F$)
- **$e$**: EvoCompute logic overhead (e.g., 15-30% of $F$)
- **$m$**: Cost to certify a new mission profile (e.g., 4% of $F$)

Even at a conservative 30% overhead ($e=0.3$) and 35% derivative cost ($d=0.35$), **a single three-product portfolio avoids ~$15.4M in redesign costs**.

### 3. Customer ROI (Resilience vs. Energy)
While dynamic energy saving is useful (e.g., 15% off a 20W node yields ~$2.60/year), the true ROI of EvoCompute stems from **avoided stoppages** due to hardware fatigue or thermal throttling.

**`Annual Resilience Value = λ × μ × T × C`**
- **$λ$**: Compute-attributable stoppages per year
- **$μ$**: Fraction mitigated by EvoCompute's graceful degradation
- **$T$**: Hours per stoppage | **$C$**: Cost per hour of downtime

At a baseline industrial downtime cost of $36,000/hour, preventing just *one compute-induced plant stoppage per 7,000 node-years* completely pays for the EvoCompute silicon overhead. In high-stakes automotive or FMCG sectors, this payback scales exponentially.

## Simulation and Results

The testbench (`evocompute_tb.sv`) stresses the logic across five distinct stages to prove the adaptive behavior.

### Running the Simulation
To run the simulation locally, you will need [Icarus Verilog](https://steveicarus.github.io/iverilog/) installed.
```bash
iverilog -g2012 -o evocompute.vvp rtl/sensor_mock.sv rtl/policy_engine.sv rtl/hardware_constitution.sv rtl/picorv32.v rtl/evocompute_top.sv tb/evocompute_tb.sv
vvp evocompute.vvp
```

### Waveform Analysis

![Simulation Waveform](docs/img/waveform.png)

As demonstrated in the waveform above:
1. **Stage 1 (Low Workload):** The policy engine safely runs the chip in Low Power mode (Config 0).
2. **Stage 2 (High Workload Spike):** The policy engine jumps to High Performance mode (Config 2).
3. **Stage 3 (Thermal Warning):** The temperature crosses the 85°C warning threshold. The Hardware Constitution intercepts the Policy Engine and downgrades the chip to Balanced mode (Config 1) to stem thermal runaway.
4. **Stage 4 (Critical Thermal Limit):** The temperature crosses the 100°C critical threshold. The Constitution completely forces the chip into Low Power mode (Config 0) regardless of the workload demand, ensuring survival.
5. **Stage 5 (Recovery):** Temperatures normalize, and the chip is allowed to resume its workload-directed state (Balanced, Config 1).

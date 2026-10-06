`default_nettype none

module evocompute_top (
    input  wire clk,
    input  wire resetn,
    
    // Testbench interfaces for mocking environment
    input  wire [7:0] tb_temp,
    input  wire [7:0] tb_workload,
    input  wire       tb_fault,
    input  wire       tb_security_threat,
    input  wire [1:0] tb_mission_profile,
    
    // Simple memory interface from picorv32 (brought to top for TB)
    output wire mem_valid,
    output wire mem_instr,
    input  wire mem_ready,
    output wire [31:0] mem_addr,
    output wire [31:0] mem_wdata,
    output wire [3:0]  mem_wstrb,
    input  wire [31:0] mem_rdata,
    
    // Status outputs
    output wire [1:0] current_config,
    output wire constitution_flag
);

    // Internal wires
    wire [7:0] temp_val;
    wire [7:0] workload_val;
    wire       fault_val;
    wire       security_val;
    wire [1:0] mission_val;
    
    wire [1:0] desired_cfg;
    
    wire fault_recovery_active;
    wire [1:0] recovery_cfg;
    wire lockdown_active;

    // ----------------------------------------------------
    // Sensors (Mock)
    // ----------------------------------------------------
    sensor_mock sensors_inst (
        .clk                   (clk),
        .rst_n                 (resetn),
        .tb_temp               (tb_temp),
        .tb_workload           (tb_workload),
        .tb_fault              (tb_fault),
        .tb_security_threat    (tb_security_threat),
        .tb_mission_profile    (tb_mission_profile),
        
        .temp_sensor           (temp_val),
        .workload_sensor       (workload_val),
        .fault_sensor          (fault_val),
        .security_threat_sensor(security_val),
        .mission_profile_sensor(mission_val)
    );
    
    // ----------------------------------------------------
    // Threat & Fault Monitors
    // ----------------------------------------------------
    fault_recovery_engine fault_inst (
        .clk(clk),
        .rst_n(resetn),
        .fault_sensor(fault_val),
        .fault_recovery_active(fault_recovery_active),
        .recovery_cfg(recovery_cfg)
    );

    security_monitor sec_inst (
        .clk(clk),
        .rst_n(resetn),
        .security_threat(security_val),
        .lockdown_active(lockdown_active)
    );

    // ----------------------------------------------------
    // Policy Engine
    // ----------------------------------------------------
    policy_engine policy_inst (
        .clk            (clk),
        .rst_n          (resetn),
        .temp_sensor    (temp_val),
        .workload_sensor(workload_val),
        .mission_profile(mission_val),
        .actual_cfg     (current_config),
        .desired_cfg    (desired_cfg)
    );
    
    // ----------------------------------------------------
    // Hardware Constitution
    // ----------------------------------------------------
    hardware_constitution const_inst (
        .clk                        (clk),
        .rst_n                      (resetn),
        .temp_sensor                (temp_val),
        .desired_cfg                (desired_cfg),
        .fault_recovery_active      (fault_recovery_active),
        .recovery_cfg               (recovery_cfg),
        .lockdown_active            (lockdown_active),
        .actual_cfg                 (current_config),
        .constitution_violation_flag(constitution_flag)
    );
    
    // ----------------------------------------------------
    // Adaptive Core Wrapper (Clock Gating Simulation)
    // ----------------------------------------------------
    reg [1:0] clk_div_counter;
    reg core_clk_en;
    reg acc_en;
    reg dsp_en;
    reg redund_en;
    
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            clk_div_counter <= 2'd0;
        end else begin
            clk_div_counter <= clk_div_counter + 2'd1;
        end
    end
    
    always_comb begin
        case (current_config)
            2'd0: begin // Low Power
                core_clk_en = (clk_div_counter == 2'd3); 
                acc_en = 1'b0;
                dsp_en = 1'b0;
                redund_en = 1'b0;
            end
            2'd1: begin // Balanced / Reliable
                core_clk_en = (clk_div_counter[0] == 1'b1);
                acc_en = 1'b0;
                dsp_en = 1'b1; // Enable DSP
                redund_en = 1'b1; // Enable redundancy in balanced/reliable mode
            end
            2'd2: begin // High Perf
                core_clk_en = 1'b1;                      
                acc_en = 1'b1; // Accelerators on!
                dsp_en = 1'b1;
                redund_en = 1'b0; // Sacrifice redundancy for raw speed
            end
            default: begin
                core_clk_en = (clk_div_counter == 2'd3); 
                acc_en = 1'b0;
                dsp_en = 1'b0;
                redund_en = 1'b0;
            end
        endcase
    end
    
    // Generate gated clock for the core
    wire core_clk = clk & core_clk_en;
    wire acc_clk  = clk & acc_en;
    wire dsp_clk  = clk & dsp_en;
    
    // ----------------------------------------------------
    // PicoRV32 Core
    // ----------------------------------------------------
    wire [31:0] core0_rdata = mem_rdata;
    
    picorv32 core (
        .clk         (core_clk),
        .resetn      (resetn),
        .mem_valid   (mem_valid),
        .mem_instr   (mem_instr),
        .mem_ready   (mem_ready),
        .mem_addr    (mem_addr),
        .mem_wdata   (mem_wdata),
        .mem_wstrb   (mem_wstrb),
        .mem_rdata   (core0_rdata)
    );

    // ----------------------------------------------------
    // Accelerators and DSP
    // ----------------------------------------------------
    wire [31:0] acc_out;
    accelerator acc_inst (
        .clk(acc_clk),
        .rst_n(resetn),
        .enable(acc_en),
        .data_in(32'hDEADBEEF),
        .data_out(acc_out)
    );

    wire [31:0] dsp_out;
    dsp dsp_inst (
        .clk(dsp_clk),
        .rst_n(resetn),
        .enable(dsp_en),
        .signal_in(32'hCAFEBABE),
        .signal_out(dsp_out)
    );

    // ----------------------------------------------------
    // Redundancy Manager
    // ----------------------------------------------------
    wire vote_fault;
    wire [31:0] reliable_data;
    redundancy_manager red_inst (
        .clk(core_clk),
        .rst_n(resetn),
        .redundancy_enable(redund_en),
        .core0_data(mem_addr),
        .core1_data(mem_addr),
        .reliable_data(reliable_data),
        .vote_fault(vote_fault)
    );

endmodule

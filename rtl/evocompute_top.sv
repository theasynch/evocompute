`default_nettype none

module evocompute_top (
    input  wire clk,
    input  wire resetn,
    
    // Testbench interfaces for mocking environment
    input  wire [7:0] tb_temp,
    input  wire [7:0] tb_workload,
    
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
    wire [1:0] desired_cfg;
    
    // ----------------------------------------------------
    // Sensors (Mock)
    // ----------------------------------------------------
    sensor_mock sensors_inst (
        .clk            (clk),
        .rst_n          (resetn),
        .tb_temp        (tb_temp),
        .tb_workload    (tb_workload),
        .temp_sensor    (temp_val),
        .workload_sensor(workload_val)
    );
    
    // ----------------------------------------------------
    // Policy Engine
    // ----------------------------------------------------
    policy_engine policy_inst (
        .clk            (clk),
        .rst_n          (resetn),
        .temp_sensor    (temp_val),
        .workload_sensor(workload_val),
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
        .actual_cfg                 (current_config),
        .constitution_violation_flag(constitution_flag)
    );
    
    // ----------------------------------------------------
    // Adaptive Core Wrapper (Clock Gating Simulation)
    // ----------------------------------------------------
    reg [1:0] clk_div_counter;
    reg core_clk_en;
    
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            clk_div_counter <= 2'd0;
        end else begin
            clk_div_counter <= clk_div_counter + 2'd1;
        end
    end
    
    always_comb begin
        case (current_config)
            2'd0: core_clk_en = (clk_div_counter == 2'd3); // Low Power: 1/4 rate
            2'd1: core_clk_en = (clk_div_counter[0] == 1'b1); // Balanced: 1/2 rate
            2'd2: core_clk_en = 1'b1;                      // High Perf: Full rate
            default: core_clk_en = (clk_div_counter == 2'd3); // Failsafe
        endcase
    end
    
    // Generate gated clock for the core
    wire core_clk = clk & core_clk_en;
    
    // ----------------------------------------------------
    // PicoRV32 Core
    // ----------------------------------------------------
    picorv32 core (
        .clk         (core_clk),
        .resetn      (resetn),
        .mem_valid   (mem_valid),
        .mem_instr   (mem_instr),
        .mem_ready   (mem_ready),
        .mem_addr    (mem_addr),
        .mem_wdata   (mem_wdata),
        .mem_wstrb   (mem_wstrb),
        .mem_rdata   (mem_rdata)
    );

endmodule

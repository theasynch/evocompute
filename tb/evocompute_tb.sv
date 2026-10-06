`default_nettype none
`timescale 1ns/1ps

module evocompute_tb;

    reg clk;
    reg resetn;
    reg [7:0] tb_temp;
    reg [7:0] tb_workload;
    reg       tb_fault;
    reg       tb_security_threat;
    reg [1:0] tb_mission_profile;
    
    wire mem_valid;
    wire mem_instr;
    reg  mem_ready;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    reg  [31:0] mem_rdata;
    
    wire [1:0] current_config;
    wire constitution_flag;

    // Instantiate Top
    evocompute_top uut (
        .clk              (clk),
        .resetn           (resetn),
        .tb_temp          (tb_temp),
        .tb_workload      (tb_workload),
        .tb_fault         (tb_fault),
        .tb_security_threat(tb_security_threat),
        .tb_mission_profile(tb_mission_profile),
        .mem_valid        (mem_valid),
        .mem_instr        (mem_instr),
        .mem_ready        (mem_ready),
        .mem_addr         (mem_addr),
        .mem_wdata        (mem_wdata),
        .mem_wstrb        (mem_wstrb),
        .mem_rdata        (mem_rdata),
        .current_config   (current_config),
        .constitution_flag(constitution_flag)
    );

    // Clock gen
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Dummy memory response
    always @(posedge clk) begin
        if (mem_valid && !mem_ready) begin
            mem_ready <= 1'b1;
            mem_rdata <= 32'h00000013; // NOP instruction (addi x0, x0, 0)
        end else begin
            mem_ready <= 1'b0;
        end
    end

    // Test sequence
    initial begin
        $dumpfile("evocompute.vcd");
        $dumpvars(0, evocompute_tb);

        // Init
        resetn = 0;
        tb_temp = 8'd25;
        tb_workload = 8'd0;
        tb_fault = 1'b0;
        tb_security_threat = 1'b0;
        tb_mission_profile = 2'd0;
        #20 resetn = 1;

        $display("Time | Temp | Workload | Config | Violation");
        $monitor("%4t |  %3d |      %3d |      %1d |         %1d", $time, tb_temp, tb_workload, current_config, constitution_flag);

        // Stage 1: Low Workload, Normal Temp
        #100;
        $display("--- STAGE 1: Low Workload -> Expect Config 0 (Low Power) ---");
        
        // Stage 2: High Workload, Normal Temp
        #100;
        tb_workload = 8'd90;
        $display("--- STAGE 2: High Workload -> Expect Config 2 (High Perf) ---");

        // Stage 3: High Workload, High Temp (Constitution limits to Balanced)
        #100;
        tb_temp = 8'd90;
        $display("--- STAGE 3: High Temp (90C) -> Constitution limits to Config 1 ---");

        // Stage 4: High Workload, Critical Temp (Constitution forces Low Power)
        #100;
        tb_temp = 8'd105;
        $display("--- STAGE 4: Critical Temp (105C) -> Constitution limits to Config 0 ---");

        // Stage 5: Recovery
        #100;
        tb_temp = 8'd60;
        tb_workload = 8'd50;
        $display("--- STAGE 5: Normal Conditions -> Expect Config 1 (Balanced) ---");

        #100;
        $display("--- SIMULATION COMPLETE ---");
        $finish;
    end

endmodule

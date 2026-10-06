`default_nettype none

module policy_engine (
    input  wire clk,
    input  wire rst_n,
    
    input  wire [7:0] temp_sensor,
    input  wire [7:0] workload_sensor,
    
    // Desired configuration from policy
    // 0: Low Power, 1: Balanced, 2: High Performance
    output reg [1:0] desired_cfg
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            desired_cfg <= 2'd1; // Default to balanced
        end else begin
            // Simple mapping: workload -> performance tier
            if (workload_sensor > 8'd80)
                desired_cfg <= 2'd2; // High perf
            else if (workload_sensor < 8'd30)
                desired_cfg <= 2'd0; // Low power
            else
                desired_cfg <= 2'd1; // Balanced
        end
    end

endmodule

`default_nettype none

module hardware_constitution (
    input  wire clk,
    input  wire rst_n,
    
    input  wire [7:0] temp_sensor,
    input  wire [1:0] desired_cfg,
    
    // Certified Configuration Set Outputs
    output reg [1:0] actual_cfg,
    output reg constitution_violation_flag
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            actual_cfg <= 2'd1;
            constitution_violation_flag <= 1'b0;
        end else begin
            // Constitution Rule 1: Critical Thermal Limit
            // If temperature > 100C, force Low Power (0)
            if (temp_sensor > 8'd100) begin
                actual_cfg <= 2'd0; // Force Low Power
                constitution_violation_flag <= 1'b1;
            end
            // Constitution Rule 2: Thermal Limit
            // If temperature > 85C, forbid High Performance (2)
            else if (temp_sensor > 8'd85 && desired_cfg == 2'd2) begin
                actual_cfg <= 2'd1; // Downgrade to Balanced safely
                constitution_violation_flag <= 1'b1;
            end else begin
                actual_cfg <= desired_cfg;
                constitution_violation_flag <= 1'b0;
            end
        end
    end

endmodule

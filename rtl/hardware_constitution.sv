`default_nettype none

module hardware_constitution (
    input  wire clk,
    input  wire rst_n,
    
    input  wire [7:0] temp_sensor,
    input  wire [1:0] desired_cfg,
    input  wire fault_recovery_active,
    input  wire [1:0] recovery_cfg,
    input  wire lockdown_active,
    
    // Certified Configuration Set Outputs
    output reg [1:0] actual_cfg,
    output reg constitution_violation_flag
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            actual_cfg <= 2'd1;
            constitution_violation_flag <= 1'b0;
        end else begin
            // Constitution rules are hierarchical and absolute

            // Rule 0: Security Lockdown
            if (lockdown_active) begin
                actual_cfg <= 2'd0; // Lowest power, restricted
                constitution_violation_flag <= 1'b1;
            end
            // Rule 1: Fault Recovery
            else if (fault_recovery_active) begin
                actual_cfg <= recovery_cfg;
                constitution_violation_flag <= 1'b1;
            end
            // Rule 2: Critical Thermal Limit
            else if (temp_sensor > 8'd100) begin
                actual_cfg <= 2'd0; // Force Low Power
                constitution_violation_flag <= 1'b1;
            end
            // Rule 3: Thermal Warning
            else if (temp_sensor > 8'd85 && desired_cfg == 2'd2) begin
                actual_cfg <= 2'd1; // Downgrade to Balanced safely
                constitution_violation_flag <= 1'b1;
            end 
            // Default: Approve desired config
            else begin
                actual_cfg <= desired_cfg;
                constitution_violation_flag <= 1'b0;
            end
        end
    end

endmodule

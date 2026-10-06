`default_nettype none

module fault_recovery_engine (
    input  wire clk,
    input  wire rst_n,
    input  wire fault_sensor,
    
    output reg fault_recovery_active,
    output reg [1:0] recovery_cfg
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fault_recovery_active <= 1'b0;
            recovery_cfg <= 2'd1;
        end else begin
            if (fault_sensor) begin
                fault_recovery_active <= 1'b1;
                recovery_cfg <= 2'd0; // Failsafe mode
            end else begin
                fault_recovery_active <= 1'b0;
            end
        end
    end
endmodule

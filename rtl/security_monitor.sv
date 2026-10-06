`default_nettype none

module security_monitor (
    input  wire clk,
    input  wire rst_n,
    input  wire security_threat,
    
    output reg lockdown_active
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lockdown_active <= 1'b0;
        end else begin
            if (security_threat) begin
                lockdown_active <= 1'b1;
            end else begin
                lockdown_active <= 1'b0;
            end
        end
    end
endmodule

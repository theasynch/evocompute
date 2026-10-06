`default_nettype none

module dsp (
    input wire clk,
    input wire rst_n,
    input wire enable,
    
    input  wire [31:0] signal_in,
    output reg  [31:0] signal_out
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            signal_out <= 32'd0;
        end else if (enable) begin
            signal_out <= signal_in + 32'd42;
        end
    end
endmodule

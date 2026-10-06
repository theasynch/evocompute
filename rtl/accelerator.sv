`default_nettype none

module accelerator (
    input wire clk,
    input wire rst_n,
    input wire enable,
    
    input  wire [31:0] data_in,
    output reg  [31:0] data_out
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= 32'd0;
        end else if (enable) begin
            data_out <= data_in * 32'd5;
        end
    end
endmodule

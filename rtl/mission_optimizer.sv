`default_nettype none

module mission_optimizer (
    input  wire clk,
    input  wire rst_n,
    input  wire [1:0] mission_profile, 
    
    output reg [3:0] w_p, // performance weight
    output reg [3:0] w_e, // energy weight
    output reg [3:0] w_r, // reliability weight
    output reg [3:0] w_s  // security weight
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            w_p <= 4'd5; w_e <= 4'd5; w_r <= 4'd5; w_s <= 4'd5;
        end else begin
            case (mission_profile)
                2'd0: begin w_p <= 4'd5; w_e <= 4'd5; w_r <= 4'd5; w_s <= 4'd5; end // Balanced
                2'd1: begin w_p <= 4'd9; w_e <= 4'd2; w_r <= 4'd5; w_s <= 4'd5; end // Perf focus
                2'd2: begin w_p <= 4'd2; w_e <= 4'd9; w_r <= 4'd5; w_s <= 4'd5; end // Energy focus
                2'd3: begin w_p <= 4'd3; w_e <= 4'd3; w_r <= 4'd9; w_s <= 4'd9; end // Secure/Reliable
            endcase
        end
    end
endmodule

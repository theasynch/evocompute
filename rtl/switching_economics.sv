`default_nettype none

module switching_economics (
    input  wire clk,
    input  wire rst_n,
    input  wire [1:0] proposed_cfg,
    input  wire [1:0] actual_cfg,
    
    output reg [1:0] econ_approved_cfg
);
    reg [3:0] stable_counter;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            econ_approved_cfg <= 2'd1;
            stable_counter <= 4'd0;
        end else begin
            if (proposed_cfg != econ_approved_cfg) begin
                if (stable_counter >= 4'd3) begin
                    econ_approved_cfg <= proposed_cfg;
                    stable_counter <= 4'd0;
                end else begin
                    stable_counter <= stable_counter + 1;
                end
            end else begin
                stable_counter <= 4'd0;
            end
        end
    end
endmodule

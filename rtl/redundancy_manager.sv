`default_nettype none

module redundancy_manager (
    input wire clk,
    input wire rst_n,
    input wire redundancy_enable,
    
    input  wire [31:0] core0_data,
    input  wire [31:0] core1_data,
    output reg  [31:0] reliable_data,
    output reg         vote_fault
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reliable_data <= 32'd0;
            vote_fault <= 1'b0;
        end else begin
            if (redundancy_enable) begin
                if (core0_data == core1_data) begin
                    reliable_data <= core0_data;
                    vote_fault <= 1'b0;
                end else begin
                    reliable_data <= core0_data;
                    vote_fault <= 1'b1;
                end
            end else begin
                reliable_data <= core0_data;
                vote_fault <= 1'b0;
            end
        end
    end
endmodule

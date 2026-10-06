`default_nettype none

module learning_engine (
    input  wire clk,
    input  wire rst_n,
    input  wire [7:0] predicted_workload,
    input  wire [3:0] w_p,
    input  wire [3:0] w_e,
    
    output reg [1:0] learned_cfg
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            learned_cfg <= 2'd1;
        end else begin
            integer high_thresh, low_thresh;
            high_thresh = 80 - (w_p * 2) + (w_e * 2); 
            low_thresh = 30 + (w_e * 2) - (w_p * 2);
            
            if (predicted_workload > high_thresh)
                learned_cfg <= 2'd2; // High perf
            else if (predicted_workload < low_thresh)
                learned_cfg <= 2'd0; // Low power
            else
                learned_cfg <= 2'd1; // Balanced
        end
    end
endmodule

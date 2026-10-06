`default_nettype none

module predictor (
    input  wire clk,
    input  wire rst_n,
    input  wire [7:0] workload_sensor,
    input  wire [7:0] temp_sensor,
    
    output reg [7:0] predicted_workload,
    output reg [7:0] predicted_temp
);
    reg [7:0] last_workload;
    reg [7:0] last_temp;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            predicted_workload <= 8'd0;
            predicted_temp <= 8'd25;
            last_workload <= 8'd0;
            last_temp <= 8'd25;
        end else begin
            integer pw, pt;
            pw = workload_sensor + (workload_sensor - last_workload);
            pt = temp_sensor + (temp_sensor - last_temp);
            
            if (pw < 0) pw = 0;
            if (pw > 255) pw = 255;
            if (pt < 0) pt = 0;
            if (pt > 255) pt = 255;
            
            predicted_workload <= pw[7:0];
            predicted_temp <= pt[7:0];
            
            last_workload <= workload_sensor;
            last_temp <= temp_sensor;
        end
    end
endmodule

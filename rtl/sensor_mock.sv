`default_nettype none

module sensor_mock (
    input  wire clk,
    input  wire rst_n,
    
    // Testbench control to mock environment
    input  wire [7:0] tb_temp,
    input  wire [7:0] tb_workload,
    
    // Outputs to Policy Engine
    output reg [7:0] temp_sensor,
    output reg [7:0] workload_sensor
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            temp_sensor <= 8'd25; // 25C baseline
            workload_sensor <= 8'd0;
        end else begin
            // Simple pass-through for mock
            temp_sensor <= tb_temp;
            workload_sensor <= tb_workload;
        end
    end

endmodule

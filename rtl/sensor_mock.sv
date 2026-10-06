`default_nettype none

module sensor_mock (
    input  wire clk,
    input  wire rst_n,
    
    // Testbench control to mock environment
    input  wire [7:0] tb_temp,
    input  wire [7:0] tb_workload,
    input  wire       tb_fault,
    input  wire       tb_security_threat,
    input  wire [1:0] tb_mission_profile,
    
    // Outputs to internal system
    output reg [7:0] temp_sensor,
    output reg [7:0] workload_sensor,
    output reg       fault_sensor,
    output reg       security_threat_sensor,
    output reg [1:0] mission_profile_sensor
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            temp_sensor <= 8'd25;
            workload_sensor <= 8'd0;
            fault_sensor <= 1'b0;
            security_threat_sensor <= 1'b0;
            mission_profile_sensor <= 2'd0;
        end else begin
            temp_sensor <= tb_temp;
            workload_sensor <= tb_workload;
            fault_sensor <= tb_fault;
            security_threat_sensor <= tb_security_threat;
            mission_profile_sensor <= tb_mission_profile;
        end
    end

endmodule

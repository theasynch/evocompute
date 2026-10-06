`default_nettype none

module policy_engine (
    input  wire clk,
    input  wire rst_n,
    
    input  wire [7:0] temp_sensor,
    input  wire [7:0] workload_sensor,
    input  wire [1:0] mission_profile,
    input  wire [1:0] actual_cfg, // Feedback from constitution
    
    // Desired configuration from policy
    output wire [1:0] desired_cfg
);

    wire [3:0] w_p, w_e, w_r, w_s;
    wire [7:0] predicted_workload, predicted_temp;
    wire [1:0] learned_cfg;

    mission_optimizer m_opt (
        .clk(clk),
        .rst_n(rst_n),
        .mission_profile(mission_profile),
        .w_p(w_p), .w_e(w_e), .w_r(w_r), .w_s(w_s)
    );

    predictor pred (
        .clk(clk),
        .rst_n(rst_n),
        .workload_sensor(workload_sensor),
        .temp_sensor(temp_sensor),
        .predicted_workload(predicted_workload),
        .predicted_temp(predicted_temp)
    );

    learning_engine learn (
        .clk(clk),
        .rst_n(rst_n),
        .predicted_workload(predicted_workload),
        .w_p(w_p),
        .w_e(w_e),
        .learned_cfg(learned_cfg)
    );

    switching_economics econ (
        .clk(clk),
        .rst_n(rst_n),
        .proposed_cfg(learned_cfg),
        .actual_cfg(actual_cfg),
        .econ_approved_cfg(desired_cfg)
    );

endmodule

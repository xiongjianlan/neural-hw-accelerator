// ======================================================
// Convolution + ReLU Chain Module
// 将卷积层与ReLU激活层连接
// ======================================================

module conv_relu_chain #(
    parameter DATA_WIDTH = 16,
    parameter WEIGHT_WIDTH = 16,
    parameter ACC_WIDTH = 32
)(
    input wire clk,
    input wire rst_n,
    
    // 卷积层输入 (3x3窗口)
    input wire signed [DATA_WIDTH-1:0] conv_window_00,
    input wire signed [DATA_WIDTH-1:0] conv_window_01,
    input wire signed [DATA_WIDTH-1:0] conv_window_02,
    input wire signed [DATA_WIDTH-1:0] conv_window_10,
    input wire signed [DATA_WIDTH-1:0] conv_window_11,
    input wire signed [DATA_WIDTH-1:0] conv_window_12,
    input wire signed [DATA_WIDTH-1:0] conv_window_20,
    input wire signed [DATA_WIDTH-1:0] conv_window_21,
    input wire signed [DATA_WIDTH-1:0] conv_window_22,
    
    // 卷积核权重 (3x3)
    input wire signed [WEIGHT_WIDTH-1:0] conv_weight_00,
    input wire signed [WEIGHT_WIDTH-1:0] conv_weight_01,
    input wire signed [WEIGHT_WIDTH-1:0] conv_weight_02,
    input wire signed [WEIGHT_WIDTH-1:0] conv_weight_10,
    input wire signed [WEIGHT_WIDTH-1:0] conv_weight_11,
    input wire signed [WEIGHT_WIDTH-1:0] conv_weight_12,
    input wire signed [WEIGHT_WIDTH-1:0] conv_weight_20,
    input wire signed [WEIGHT_WIDTH-1:0] conv_weight_21,
    input wire signed [WEIGHT_WIDTH-1:0] conv_weight_22,
    
    // 偏置项
    input wire signed [DATA_WIDTH-1:0] conv_bias,
    
    // 控制信号
    input wire valid_in,
    output wire valid_out,
    
    // 最终输出 (经过卷积和ReLU)
    output wire signed [DATA_WIDTH-1:0] final_out
);

    // ======================================================
    // 内部信号
    // ======================================================
    
    // 卷积层输出
    wire signed [DATA_WIDTH-1:0] conv_output;
    wire conv_valid_out;
    
    // ReLU层输出
    wire signed [DATA_WIDTH-1:0] relu_output;
    wire relu_valid_out;
    
    // ======================================================
    // 卷积层实例
    // ======================================================
    
    convolution_3x3 #(
        .DATA_WIDTH(DATA_WIDTH),
        .WEIGHT_WIDTH(WEIGHT_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) conv_layer (
        .clk(clk),
        .rst_n(rst_n),
        
        // 输入窗口
        .window_00(conv_window_00),
        .window_01(conv_window_01),
        .window_02(conv_window_02),
        .window_10(conv_window_10),
        .window_11(conv_window_11),
        .window_12(conv_window_12),
        .window_20(conv_window_20),
        .window_21(conv_window_21),
        .window_22(conv_window_22),
        
        // 权重
        .weight_00(conv_weight_00),
        .weight_01(conv_weight_01),
        .weight_02(conv_weight_02),
        .weight_10(conv_weight_10),
        .weight_11(conv_weight_11),
        .weight_12(conv_weight_12),
        .weight_20(conv_weight_20),
        .weight_21(conv_weight_21),
        .weight_22(conv_weight_22),
        
        // 偏置
        .bias(conv_bias),
        
        // 控制信号
        .valid_in(valid_in),
        .valid_out(conv_valid_out),
        
        // 输出
        .conv_out(conv_output)
    );
    
    // ======================================================
    // ReLU层实例
    // ======================================================
    
    simple_relu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) relu_layer (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(conv_output),
        .valid_in(conv_valid_out),
        .data_out(relu_output),
        .valid_out(relu_valid_out)
    );
    
    // ======================================================
    // 输出连接
    // ======================================================
    
    assign final_out = relu_output;
    assign valid_out = relu_valid_out;
    
    // ======================================================
    // 调试信息（可选）
    // ======================================================
    
    // always @(posedge clk) begin
    //     if (relu_valid_out) begin
    //         $display("[CONV+ReLU] Conv output: %0d, ReLU output: %0d", 
    //                  conv_output, relu_output);
    //     end
    // end

endmodule
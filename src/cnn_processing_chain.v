// ======================================================
// CNN Processing Chain
// 完整的卷积→ReLU→池化处理链
// ======================================================

module cnn_processing_chain #(
    parameter DATA_WIDTH = 16,
    parameter WEIGHT_WIDTH = 16,
    parameter ACC_WIDTH = 32
)(
    input wire clk,
    input wire rst_n,
    
    // ========== 卷积层输入 ==========
    // 输入特征图窗口 (3x3)
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
    
    // ========== 池化层输入 ==========
    // 池化需要4个输入，但这里我们假设卷积输出后
    // 需要缓冲和重新组织数据，简化处理
    
    // ========== 控制信号 ==========
    input wire valid_in,
    output wire valid_out,
    
    // ========== 最终输出 ==========
    output wire signed [DATA_WIDTH-1:0] final_out
);

    // ======================================================
    // 内部信号定义
    // ======================================================
    
    // 卷积层输出
    wire signed [DATA_WIDTH-1:0] conv_output;
    wire conv_valid_out;
    
    // ReLU层输出
    wire signed [DATA_WIDTH-1:0] relu_output;
    wire relu_valid_out;
    
    // 池化层输入缓冲（需要4个值）
    reg signed [DATA_WIDTH-1:0] pool_buffer [0:3];
    reg [1:0] buffer_index;
    wire pool_buffer_ready;
    
    // 池化层输出
    wire signed [DATA_WIDTH-1:0] pool_output;
    wire pool_valid_out;
    
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
    // 池化输入缓冲逻辑
    // 收集4个ReLU输出形成2x2池化窗口
    // ======================================================
    
    assign pool_buffer_ready = (buffer_index == 2'd3);
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            buffer_index <= 2'd0;
            pool_buffer[0] <= 0;
            pool_buffer[1] <= 0;
            pool_buffer[2] <= 0;
            pool_buffer[3] <= 0;
        end else if (relu_valid_out) begin
            // 收集ReLU输出到缓冲
            pool_buffer[buffer_index] <= relu_output;
            
            if (buffer_index == 2'd3) begin
                buffer_index <= 2'd0;  // 缓冲满，重置
            end else begin
                buffer_index <= buffer_index + 1;
            end
        end
    end
    
    // ======================================================
    // 池化层实例（当缓冲满时触发）
    // ======================================================
    
    max_pooling_2x2 #(
        .DATA_WIDTH(DATA_WIDTH)
    ) pool_layer (
        .clk(clk),
        .rst_n(rst_n),
        .in_00(pool_buffer[0]),
        .in_01(pool_buffer[1]),
        .in_10(pool_buffer[2]),
        .in_11(pool_buffer[3]),
        .valid_in(pool_buffer_ready),
        .valid_out(pool_valid_out),
        .pool_out(pool_output)
    );
    
    // ======================================================
    // 输出连接
    // ======================================================
    
    assign final_out = pool_output;
    assign valid_out = pool_valid_out;
    
    // ======================================================
    // 调试信息
    // ======================================================
    
    // always @(posedge clk) begin
    //     if (relu_valid_out) begin
    //         $display("[CNN Chain] Conv->ReLU: %0d -> %0d", conv_output, relu_output);
    //     end
    //     if (pool_valid_out) begin
    //         $display("[CNN Chain] Pool input: %0d %0d %0d %0d -> Max: %0d",
    //                  pool_buffer[0], pool_buffer[1], pool_buffer[2], pool_buffer[3],
    //                  pool_output);
    //     end
    // end

endmodule
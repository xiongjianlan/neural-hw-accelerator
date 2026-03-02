// ======================================================
// 3x3 Convolution Module
// 支持3x3卷积核的卷积层实现
// ======================================================

module convolution_3x3 #(
    parameter DATA_WIDTH = 16,          // 数据位宽
    parameter WEIGHT_WIDTH = 16,        // 权重位宽
    parameter ACC_WIDTH = 32            // 累加器位宽，防止溢出
)(
    input wire clk,                     // 时钟
    input wire rst_n,                   // 异步复位，低有效
    
    // 输入特征图窗口 (3x3)
    input wire signed [DATA_WIDTH-1:0] window_00,
    input wire signed [DATA_WIDTH-1:0] window_01,
    input wire signed [DATA_WIDTH-1:0] window_02,
    input wire signed [DATA_WIDTH-1:0] window_10,
    input wire signed [DATA_WIDTH-1:0] window_11,
    input wire signed [DATA_WIDTH-1:0] window_12,
    input wire signed [DATA_WIDTH-1:0] window_20,
    input wire signed [DATA_WIDTH-1:0] window_21,
    input wire signed [DATA_WIDTH-1:0] window_22,
    
    // 卷积核权重 (3x3)
    input wire signed [WEIGHT_WIDTH-1:0] weight_00,
    input wire signed [WEIGHT_WIDTH-1:0] weight_01,
    input wire signed [WEIGHT_WIDTH-1:0] weight_02,
    input wire signed [WEIGHT_WIDTH-1:0] weight_10,
    input wire signed [WEIGHT_WIDTH-1:0] weight_11,
    input wire signed [WEIGHT_WIDTH-1:0] weight_12,
    input wire signed [WEIGHT_WIDTH-1:0] weight_20,
    input wire signed [WEIGHT_WIDTH-1:0] weight_21,
    input wire signed [WEIGHT_WIDTH-1:0] weight_22,
    
    // 偏置项
    input wire signed [DATA_WIDTH-1:0] bias,
    
    // 控制信号
    input wire valid_in,               // 输入有效
    output reg valid_out,              // 输出有效
    
    // 卷积结果输出
    output reg signed [DATA_WIDTH-1:0] conv_out
);

    // ======================================================
    // 内部信号定义
    // ======================================================
    
    // 中间乘法结果 (18个并行乘法器)
    wire signed [ACC_WIDTH-1:0] mul_00, mul_01, mul_02;
    wire signed [ACC_WIDTH-1:0] mul_10, mul_11, mul_12;
    wire signed [ACC_WIDTH-1:0] mul_20, mul_21, mul_22;
    
    // 累加结果
    reg signed [ACC_WIDTH-1:0] sum_1;
    reg signed [ACC_WIDTH-1:0] sum_2;
    reg signed [ACC_WIDTH-1:0] sum_3;
    reg signed [ACC_WIDTH-1:0] sum_total;
    
    // ======================================================
    // 并行乘法器 (9个乘法同时进行)
    // ======================================================
    
    assign mul_00 = window_00 * weight_00;
    assign mul_01 = window_01 * weight_01;
    assign mul_02 = window_02 * weight_02;
    
    assign mul_10 = window_10 * weight_10;
    assign mul_11 = window_11 * weight_11;
    assign mul_12 = window_12 * weight_12;
    
    assign mul_20 = window_20 * weight_20;
    assign mul_21 = window_21 * weight_21;
    assign mul_22 = window_22 * weight_22;
    
    // ======================================================
    // 累加逻辑 (流水线设计)
    // ======================================================
    
    // 流水线寄存器
    reg valid_stage1, valid_stage2, valid_stage3;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 复位所有寄存器
            sum_1 <= 0;
            sum_2 <= 0;
            sum_3 <= 0;
            sum_total <= 0;
            conv_out <= 0;
            
            // 复位有效信号流水线
            valid_stage1 <= 1'b0;
            valid_stage2 <= 1'b0;
            valid_stage3 <= 1'b0;
            valid_out <= 1'b0;
            
        end else begin
            // ===== 第1级流水线：行累加 =====
            if (valid_in) begin
                sum_1 <= mul_00 + mul_01 + mul_02;
                sum_2 <= mul_10 + mul_11 + mul_12;
                sum_3 <= mul_20 + mul_21 + mul_22;
                valid_stage1 <= 1'b1;  // 标记第1级有效
            end else begin
                valid_stage1 <= 1'b0;  // 第1级无效
            end
            
            // ===== 第2级流水线：列累加 =====
            if (valid_stage1) begin
                sum_total <= sum_1 + sum_2 + sum_3;
                valid_stage2 <= 1'b1;  // 标记第2级有效
            end else begin
                valid_stage2 <= 1'b0;  // 第2级无效
            end
            
            // ===== 第3级流水线：加偏置并截断 =====
            if (valid_stage2) begin
                // 将32位结果截断回16位，加偏置
                // 取中间16位（防止溢出）
                conv_out <= sum_total[DATA_WIDTH-1:0] + bias;
                valid_stage3 <= 1'b1;  // 标记第3级有效
            end else begin
                valid_stage3 <= 1'b0;  // 第3级无效
            end
            
            // ===== 最终输出有效信号 =====
            valid_out <= valid_stage3;  // 第3级完成后输出有效
        end
    end
    
    // ======================================================
    // 调试输出（可选）
    // ======================================================
    
    // always @(posedge clk) begin
    //     if (valid_in) begin
    //         $display("[CONV] Window: %d %d %d | %d %d %d | %d %d %d", 
    //                  window_00, window_01, window_02,
    //                  window_10, window_11, window_12,
    //                  window_20, window_21, window_22);
    //         $display("[CONV] Weight: %d %d %d | %d %d %d | %d %d %d", 
    //                  weight_00, weight_01, weight_02,
    //                  weight_10, weight_11, weight_12,
    //                  weight_20, weight_21, weight_22);
    //         $display("[CONV] Bias: %d, Output: %d", bias, conv_out);
    //     end
    // end

endmodule
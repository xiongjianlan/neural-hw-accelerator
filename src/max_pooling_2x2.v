// ======================================================
// Max Pooling 2x2 Module
// 2x2最大池化层实现
// ======================================================

module max_pooling_2x2 #(
    parameter DATA_WIDTH = 16,          // 数据位宽
    parameter STRIDE = 2                // 步长（固定为2）
)(
    input wire clk,
    input wire rst_n,
    
    // 输入特征图窗口 (2x2区域)
    input wire signed [DATA_WIDTH-1:0] in_00,
    input wire signed [DATA_WIDTH-1:0] in_01,
    input wire signed [DATA_WIDTH-1:0] in_10,
    input wire signed [DATA_WIDTH-1:0] in_11,
    
    // 控制信号
    input wire valid_in,
    output reg valid_out,
    
    // 池化输出（2x2窗口的最大值）
    output reg signed [DATA_WIDTH-1:0] pool_out
);

    // ======================================================
    // 内部比较信号
    // ======================================================
    
    wire signed [DATA_WIDTH-1:0] row_0_max;
    wire signed [DATA_WIDTH-1:0] row_1_max;
    wire signed [DATA_WIDTH-1:0] final_max;
    
    // ======================================================
    // 组合逻辑：最大值比较
    // ======================================================
    
    // 第一行最大值
    assign row_0_max = (in_00 > in_01) ? in_00 : in_01;
    
    // 第二行最大值
    assign row_1_max = (in_10 > in_11) ? in_10 : in_11;
    
    // 两行间的最大值
    assign final_max = (row_0_max > row_1_max) ? row_0_max : row_1_max;
    
    // ======================================================
    // 时序逻辑：输出和有效信号
    // ======================================================
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pool_out <= 0;
            valid_out <= 1'b0;
        end else if (valid_in) begin
            pool_out <= final_max;
            valid_out <= 1'b1;
        end else begin
            valid_out <= 1'b0;
        end
    end
    
    // ======================================================
    // 调试输出（可选）
    // ======================================================
    
    // always @(posedge clk) begin
    //     if (valid_in) begin
    //         $display("[MaxPool] Input: %0d %0d | %0d %0d -> Max: %0d",
    //                  in_00, in_01, in_10, in_11, final_max);
    //     end
    // end

endmodule
// ======================================================
// ReLU (Rectified Linear Unit) Activation Module
// 最简单的神经网络激活函数硬件实现
// ======================================================

module relu_activation #(
    parameter DATA_WIDTH = 16,          // 数据位宽
    parameter VECTOR_SIZE = 8          // 向量大小
)(
    input wire clk,                     // 时钟信号
    input wire rst_n,                   // 异步复位，低有效
    
    // 输入向量 - 使用展开的数组
    input wire signed [DATA_WIDTH-1:0] data_in_0,
    input wire signed [DATA_WIDTH-1:0] data_in_1,
    input wire signed [DATA_WIDTH-1:0] data_in_2,
    input wire signed [DATA_WIDTH-1:0] data_in_3,
    input wire signed [DATA_WIDTH-1:0] data_in_4,
    input wire signed [DATA_WIDTH-1:0] data_in_5,
    input wire signed [DATA_WIDTH-1:0] data_in_6,
    input wire signed [DATA_WIDTH-1:0] data_in_7,
    
    // 输出向量 - 使用展开的数组
    output reg signed [DATA_WIDTH-1:0] data_out_0,
    output reg signed [DATA_WIDTH-1:0] data_out_1,
    output reg signed [DATA_WIDTH-1:0] data_out_2,
    output reg signed [DATA_WIDTH-1:0] data_out_3,
    output reg signed [DATA_WIDTH-1:0] data_out_4,
    output reg signed [DATA_WIDTH-1:0] data_out_5,
    output reg signed [DATA_WIDTH-1:0] data_out_6,
    output reg signed [DATA_WIDTH-1:0] data_out_7,
    
    // 控制信号
    input wire valid_in,               // 输入有效信号
    output reg valid_out               // 输出有效信号
);

    integer i;  // 循环变量
    
    // 组合逻辑：ReLU计算
    always @(*) begin
        if (!rst_n) begin
            for (i = 0; i < VECTOR_SIZE; i = i + 1) begin
                data_out[i] <= {DATA_WIDTH{1'b0}};  // 复位时输出0
            end
        end else if (valid_in) begin
            for (i = 0; i < VECTOR_SIZE; i = i + 1) begin
                // ReLU: f(x) = max(0, x)
                if (data_in[i] > 0) begin
                    data_out[i] <= data_in[i];      // x > 0: 输出x
                end else begin
                    data_out[i] <= 0;               // x <= 0: 输出0
                end
            end
        end
    end
    
    // 时序逻辑：有效信号延迟一拍
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_out <= 1'b0;
        end else begin
            valid_out <= valid_in;
        end
    end

endmodule
// ======================================================
// Simple ReLU Module
// 单数据路径的ReLU激活函数
// ======================================================

module simple_relu #(
    parameter DATA_WIDTH = 16
)(
    input wire clk,
    input wire rst_n,
    input wire signed [DATA_WIDTH-1:0] data_in,
    input wire valid_in,
    output reg signed [DATA_WIDTH-1:0] data_out,
    output reg valid_out
);

    // 组合逻辑部分：ReLU计算
    always @(*) begin
        if (!rst_n) begin
            data_out = 0;
        end else if (valid_in) begin
            // ReLU: f(x) = max(0, x)
            if (data_in > 0) begin
                data_out = data_in;
            end else begin
                data_out = 0;
            end
        end else begin
            data_out = data_out;  // 保持当前值
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
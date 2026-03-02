// ======================================================
// Simple Weight Memory Module
// 简化的权重存储和加载机制
// ======================================================

module simple_weight_mem #(
    parameter DATA_WIDTH = 16,
    parameter NUM_WEIGHTS = 9
)(
    input wire clk,
    input wire rst_n,
    
    // 控制接口
    input wire load_en,
    output reg ready,
    
    // 权重输出（展开为9个独立信号）
    output reg signed [DATA_WIDTH-1:0] weight_00,
    output reg signed [DATA_WIDTH-1:0] weight_01,
    output reg signed [DATA_WIDTH-1:0] weight_02,
    output reg signed [DATA_WIDTH-1:0] weight_10,
    output reg signed [DATA_WIDTH-1:0] weight_11,
    output reg signed [DATA_WIDTH-1:0] weight_12,
    output reg signed [DATA_WIDTH-1:0] weight_20,
    output reg signed [DATA_WIDTH-1:0] weight_21,
    output reg signed [DATA_WIDTH-1:0] weight_22
);

    // ======================================================
    // 内部寄存器
    // ======================================================
    
    reg signed [DATA_WIDTH-1:0] weight_reg [0:8];
    reg [3:0] load_state;
    
    // ======================================================
    // 初始权重（示例：边缘检测核）
    // ======================================================
    
    localparam signed [DATA_WIDTH-1:0] DEFAULT_WEIGHTS [0:8] = '{
        16'sd1, 16'sd0, 16'sd-1,
        16'sd2, 16'sd0, 16'sd-2,
        16'sd1, 16'sd0, 16'sd-1
    };
    
    // ======================================================
    // 主逻辑
    // ======================================================
    
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 复位：加载默认权重
            for (i = 0; i < NUM_WEIGHTS; i = i + 1) begin
                weight_reg[i] <= DEFAULT_WEIGHTS[i];
            end
            
            // 更新输出
            weight_00 <= DEFAULT_WEIGHTS[0];
            weight_01 <= DEFAULT_WEIGHTS[1];
            weight_02 <= DEFAULT_WEIGHTS[2];
            weight_10 <= DEFAULT_WEIGHTS[3];
            weight_11 <= DEFAULT_WEIGHTS[4];
            weight_12 <= DEFAULT_WEIGHTS[5];
            weight_20 <= DEFAULT_WEIGHTS[6];
            weight_21 <= DEFAULT_WEIGHTS[7];
            weight_22 <= DEFAULT_WEIGHTS[8];
            
            ready <= 1'b1;
            load_state <= 0;
            
            $display("[Weight Mem] Reset: loaded default Sobel kernel");
            
        end else begin
            // 正常操作：更新输出（组合逻辑部分）
            weight_00 <= weight_reg[0];
            weight_01 <= weight_reg[1];
            weight_02 <= weight_reg[2];
            weight_10 <= weight_reg[3];
            weight_11 <= weight_reg[4];
            weight_12 <= weight_reg[5];
            weight_20 <= weight_reg[6];
            weight_21 <= weight_reg[7];
            weight_22 <= weight_reg[8];
            
            // 加载状态机
            if (load_en && ready) begin
                case (load_state)
                    0: begin
                        // 可以在这里添加外部加载逻辑
                        // 当前使用固定权重
                        $display("[Weight Mem] Load triggered");
                        load_state <= 1;
                        ready <= 1'b0;
                    end
                    
                    1: begin
                        // 模拟加载延迟
                        load_state <= 2;
                    end
                    
                    2: begin
                        // 加载完成
                        ready <= 1'b1;
                        load_state <= 0;
                        $display("[Weight Mem] Load completed");
                    end
                    
                    default: load_state <= 0;
                endcase
            end
        end
    end
    
    // ======================================================
    // 调试功能
    // ======================================================
    
    // always @(posedge clk) begin
    //     if (ready) begin
    //         $display("[Weight Mem] Current weights:");
    //         $display("  %0d %0d %0d", weight_00, weight_01, weight_02);
    //         $display("  %0d %0d %0d", weight_10, weight_11, weight_12);
    //         $display("  %0d %0d %0d", weight_20, weight_21, weight_22);
    //     end
    // end

endmodule
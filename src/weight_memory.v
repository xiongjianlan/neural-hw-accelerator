// ======================================================
// Weight Memory Module
// 卷积核权重存储和加载机制
// ======================================================

module weight_memory #(
    parameter DATA_WIDTH = 16,          // 数据位宽
    parameter NUM_WEIGHTS = 9,          // 权重数量 (3x3卷积核)
    parameter ADDR_WIDTH = 4            // 地址位宽 (可寻址16个权重)
)(
    input wire clk,
    input wire rst_n,
    
    // ========== 写入接口 ==========
    input wire wr_en,                   // 写使能
    input wire [ADDR_WIDTH-1:0] wr_addr, // 写地址
    input wire signed [DATA_WIDTH-1:0] wr_data, // 写数据
    
    // ========== 读取接口 ==========
    input wire rd_en,                   // 读使能
    input wire [ADDR_WIDTH-1:0] rd_addr, // 读地址
    output reg signed [DATA_WIDTH-1:0] rd_data, // 读数据
    
    // ========== 并行加载接口 ==========
    input wire load_en,                 // 并行加载使能
    input wire signed [DATA_WIDTH-1:0] weights_in [0:NUM_WEIGHTS-1], // 并行输入
    output reg signed [DATA_WIDTH-1:0] weights_out [0:NUM_WEIGHTS-1], // 并行输出
    
    // ========== 状态输出 ==========
    output reg ready,                   // 存储器就绪
    output reg [ADDR_WIDTH-1:0] weight_count // 当前存储的权重数
);

    // ======================================================
    // 内部存储器
    // ======================================================
    
    reg signed [DATA_WIDTH-1:0] memory [0:(1<<ADDR_WIDTH)-1];
    
    // ======================================================
    // 初始化
    // ======================================================
    
    integer i;
    initial begin
        for (i = 0; i < (1<<ADDR_WIDTH); i = i + 1) begin
            memory[i] = 0;
        end
        weight_count = 0;
        ready = 1'b1;
    end
    
    // ======================================================
    // 写入逻辑
    // ======================================================
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 复位：清空存储器
            for (i = 0; i < (1<<ADDR_WIDTH); i = i + 1) begin
                memory[i] <= 0;
            end
            weight_count <= 0;
            ready <= 1'b1;
        end else begin
            // 写入操作
            if (wr_en && ready) begin
                if (wr_addr < NUM_WEIGHTS) begin
                    memory[wr_addr] <= wr_data;
                    
                    // 更新权重计数
                    if (wr_addr >= weight_count) begin
                        weight_count <= wr_addr + 1;
                    end
                    
                    $display("[Weight Mem] Write: addr=%0d, data=%0d", 
                            wr_addr, wr_data);
                end
            end
            
            // 并行加载操作
            if (load_en && ready) begin
                for (i = 0; i < NUM_WEIGHTS; i = i + 1) begin
                    memory[i] <= weights_in[i];
                    weights_out[i] <= weights_in[i];
                end
                weight_count <= NUM_WEIGHTS;
                ready <= 1'b0;  // 加载期间忙
                
                $display("[Weight Mem] Parallel load completed");
                
                // 一个周期后恢复就绪
                ready <= #1 1'b1;
            end
        end
    end
    
    // ======================================================
    // 读取逻辑
    // ======================================================
    
    always @(posedge clk) begin
        if (rd_en && ready) begin
            if (rd_addr < NUM_WEIGHTS) begin
                rd_data <= memory[rd_addr];
            end else begin
                rd_data <= 0;  // 地址越界返回0
            end
        end
    end
    
    // ======================================================
    // 并行输出更新
    // ======================================================
    
    always @(posedge clk) begin
        if (ready) begin
            for (i = 0; i < NUM_WEIGHTS; i = i + 1) begin
                weights_out[i] <= memory[i];
            end
        end
    end
    
    // ======================================================
    // 辅助功能
    // ======================================================
    
    // 检查权重是否已完全加载
    function is_fully_loaded;
        input [ADDR_WIDTH-1:0] count;
    begin
        is_fully_loaded = (count >= NUM_WEIGHTS);
    end
    endfunction
    
    // 获取指定位置的权重
    function signed [DATA_WIDTH-1:0] get_weight;
        input [ADDR_WIDTH-1:0] index;
    begin
        if (index < NUM_WEIGHTS) begin
            get_weight = memory[index];
        end else begin
            get_weight = 0;
        end
    end
    endfunction

endmodule
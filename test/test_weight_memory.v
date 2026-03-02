// ======================================================
// Weight Memory Testbench
// ======================================================

`timescale 1ns/1ps

module test_weight_memory();

    parameter DATA_WIDTH = 16;
    parameter NUM_WEIGHTS = 9;
    parameter ADDR_WIDTH = 4;
    
    // 时钟和复位
    reg clk;
    reg rst_n;
    
    // 写入接口
    reg wr_en;
    reg [ADDR_WIDTH-1:0] wr_addr;
    reg signed [DATA_WIDTH-1:0] wr_data;
    
    // 读取接口
    reg rd_en;
    reg [ADDR_WIDTH-1:0] rd_addr;
    wire signed [DATA_WIDTH-1:0] rd_data;
    
    // 并行接口
    reg load_en;
    reg signed [DATA_WIDTH-1:0] weights_in [0:NUM_WEIGHTS-1];
    wire signed [DATA_WIDTH-1:0] weights_out [0:NUM_WEIGHTS-1];
    
    // 状态
    wire ready;
    wire [ADDR_WIDTH-1:0] weight_count;
    
    // 待测模块
    weight_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_WEIGHTS(NUM_WEIGHTS),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .rd_en(rd_en),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .load_en(load_en),
        .weights_in(weights_in),
        .weights_out(weights_out),
        .ready(ready),
        .weight_count(weight_count)
    );
    
    // 时钟
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end
    
    // 复位
    initial begin
        rst_n = 1'b0;
        #20 rst_n = 1'b1;
    end
    
    // 主测试程序
    integer i;
    integer test_weights [0:8];
    initial begin
        // 初始化
        wr_en = 1'b0;
        wr_addr = 0;
        wr_data = 0;
        rd_en = 1'b0;
        rd_addr = 0;
        load_en = 1'b0;
        
        for (i = 0; i < NUM_WEIGHTS; i = i + 1) begin
            weights_in[i] = 0;
            test_weights[i] = (i + 1) * 10;  // 10,20,...,90
        end
        
        // 等待复位
        #30;
        
        $display("\n=== Weight Memory Test ===");
        
        // ===== 测试1: 顺序写入和读取 =====
        $display("\n[Test 1] Sequential write/read");
        
        // 顺序写入9个权重
        for (i = 0; i < NUM_WEIGHTS; i = i + 1) begin
            wr_en = 1'b1;
            wr_addr = i;
            wr_data = test_weights[i];
            #10;
            wr_en = 1'b0;
            #10;
        end
        
        // 顺序读取验证
        for (i = 0; i < NUM_WEIGHTS; i = i + 1) begin
            rd_en = 1'b1;
            rd_addr = i;
            #10;
            
            if (rd_data == test_weights[i]) begin
                $display("  PASS: addr=%0d, expected=%0d, got=%0d", 
                        i, test_weights[i], rd_data);
            end else begin
                $display("  FAIL: addr=%0d, expected=%0d, got=%0d", 
                        i, test_weights[i], rd_data);
            end
            
            rd_en = 1'b0;
            #10;
        end
        
        // ===== 测试2: 并行加载 =====
        $display("\n[Test 2] Parallel load");
        
        // 准备新的权重数据
        for (i = 0; i < NUM_WEIGHTS; i = i + 1) begin
            weights_in[i] = test_weights[i] + 100;  // 110,120,...,190
        end
        
        // 执行并行加载
        load_en = 1'b1;
        #10;
        load_en = 1'b0;
        
        // 等待加载完成
        #20;
        
        // 验证并行输出
        $display("  Parallel outputs:");
        for (i = 0; i < NUM_WEIGHTS; i = i + 1) begin
            if (weights_out[i] == test_weights[i] + 100) begin
                $display("    [%0d] %0d ✓", i, weights_out[i]);
            end else begin
                $display("    [%0d] %0d ✗ (expected %0d)", 
                        i, weights_out[i], test_weights[i] + 100);
            end
        end
        
        // ===== 测试3: 混合操作 =====
        $display("\n[Test 3] Mixed operations");
        
        // 在执行并行输出的同时进行读取
        rd_en = 1'b1;
        rd_addr = 3;  // 读取地址3
        #10;
        
        if (rd_data == 130) begin  // 应该是120+100=130
            $display("  PASS: Mixed read during parallel output = %0d", rd_data);
        end else begin
            $display("  FAIL: Expected 130, got %0d", rd_data);
        end
        
        rd_en = 1'b0;
        
        // ===== 测试4: 状态信号检查 =====
        $display("\n[Test 4] Status signals");
        
        $display("  Ready signal: %0d", ready);
        $display("  Weight count: %0d", weight_count);
        
        if (ready && (weight_count == NUM_WEIGHTS)) begin
            $display("  PASS: Memory ready and fully loaded");
        end else begin
            $display("  FAIL: Memory not ready or not fully loaded");
        end
        
        // ===== 测试5: 边界测试 =====
        $display("\n[Test 5] Boundary test");
        
        // 测试越界写入
        wr_en = 1'b1;
        wr_addr = 15;  // 超过NUM_WEIGHTS
        wr_data = 999;
        #10;
        wr_en = 1'b0;
        
        // 测试越界读取
        rd_en = 1'b1;
        rd_addr = 15;
        #10;
        
        $display("  Out-of-bound read: %0d (should be 0 or undefined)", rd_data);
        
        rd_en = 1'b0;
        
        // 完成
        #10;
        $display("\n[INFO] Weight memory test completed!");
        $finish;
    end
    
    // 波形记录
    initial begin
        $dumpfile("test_weight_memory.vcd");
        $dumpvars(0, test_weight_memory);
    end

endmodule
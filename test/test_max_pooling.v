// ======================================================
// Max Pooling 2x2 Testbench
// ======================================================

`timescale 1ns/1ps

module test_max_pooling();

    parameter DATA_WIDTH = 16;
    
    // 时钟和复位
    reg clk;
    reg rst_n;
    
    // 输入
    reg signed [DATA_WIDTH-1:0] in_00, in_01, in_10, in_11;
    reg valid_in;
    
    // 输出
    wire valid_out;
    wire signed [DATA_WIDTH-1:0] pool_out;
    
    // 待测模块
    max_pooling_2x2 #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .in_00(in_00),
        .in_01(in_01),
        .in_10(in_10),
        .in_11(in_11),
        .valid_in(valid_in),
        .valid_out(valid_out),
        .pool_out(pool_out)
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
    integer expected;
    initial begin
        // 初始化
        valid_in = 1'b0;
        in_00 = 0; in_01 = 0; in_10 = 0; in_11 = 0;
        
        // 等待复位
        #30;
        
        // ===== 测试1: 简单最大值 =====
        $display("\n[Test 1] Simple max pool");
        in_00 = 10; in_01 = 20; in_10 = 30; in_11 = 40;
        expected = 40;  // 最大值
        
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        #20;
        
        if (pool_out == expected) begin
            $display("  PASS: Max of [10,20,30,40] = %0d", pool_out);
        end else begin
            $display("  FAIL: Expected %0d, got %0d", expected, pool_out);
        end
        
        // ===== 测试2: 负数和正数混合 =====
        $display("\n[Test 2] Mixed positive/negative");
        in_00 = -10; in_01 = 5; in_10 = -20; in_11 = 15;
        expected = 15;  // 最大值
        
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        #20;
        
        if (pool_out == expected) begin
            $display("  PASS: Max of [-10,5,-20,15] = %0d", pool_out);
        end else begin
            $display("  FAIL: Expected %0d, got %0d", expected, pool_out);
        end
        
        // ===== 测试3: 全负数 =====
        $display("\n[Test 3] All negative");
        in_00 = -50; in_01 = -30; in_10 = -10; in_11 = -5;
        expected = -5;  // 最大值（最接近0的负数）
        
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        #20;
        
        if (pool_out == expected) begin
            $display("  PASS: Max of [-50,-30,-10,-5] = %0d", pool_out);
        end else begin
            $display("  FAIL: Expected %0d, got %0d", expected, pool_out);
        end
        
        // ===== 测试4: 相等值 =====
        $display("\n[Test 4] Equal values");
        in_00 = 25; in_01 = 25; in_10 = 25; in_11 = 25;
        expected = 25;  // 所有值相等
        
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        #20;
        
        if (pool_out == expected) begin
            $display("  PASS: Max of [25,25,25,25] = %0d", pool_out);
        end else begin
            $display("  FAIL: Expected %0d, got %0d", expected, pool_out);
        end
        
        // ===== 测试5: 连续输入 =====
        $display("\n[Test 5] Continuous inputs (pipeline test)");
        
        // 第一组
        in_00 = 1; in_01 = 2; in_10 = 3; in_11 = 4;
        valid_in = 1'b1;
        #10;
        
        // 第二组
        in_00 = 10; in_01 = 9; in_10 = 8; in_11 = 7;
        #10;
        
        // 第三组
        in_00 = -1; in_01 = -2; in_10 = -3; in_11 = -4;
        #10;
        
        valid_in = 1'b0;
        #30;
        
        $display("  Note: Check waveform for pipeline behavior");
        
        // 完成
        #10;
        $display("\n[INFO] Max pooling tests completed!");
        $display("       Latency: 1 clock cycle");
        $finish;
    end
    
    // 波形记录
    initial begin
        $dumpfile("test_max_pooling.vcd");
        $dumpvars(0, test_max_pooling);
    end

endmodule
// ======================================================
// Simple ReLU Testbench
// ======================================================

`timescale 1ns/1ps

module test_simple_relu();

    parameter DATA_WIDTH = 16;
    
    // 时钟和复位
    reg clk;
    reg rst_n;
    
    // 输入输出
    reg signed [DATA_WIDTH-1:0] data_in;
    reg valid_in;
    wire signed [DATA_WIDTH-1:0] data_out;
    wire valid_out;
    
    // 实例化待测模块
    simple_relu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .valid_in(valid_in),
        .data_out(data_out),
        .valid_out(valid_out)
    );
    
    // 时钟生成
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;  // 100MHz
    end
    
    // 复位信号
    initial begin
        rst_n = 1'b0;
        #20 rst_n = 1'b1;
    end
    
    // 测试主程序
    initial begin
        // 初始化
        data_in = 0;
        valid_in = 1'b0;
        
        // 等待复位结束
        #30;
        
        // 测试1: 正数输入
        $display("[Test 1] Positive input: 100");
        data_in = 100;
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        #10;
        
        if (data_out === 100) begin
            $display("  PASS: 100 -> 100");
        end else begin
            $display("  FAIL: Expected 100, got %0d", data_out);
        end
        
        // 测试2: 负数输入
        $display("\n[Test 2] Negative input: -50");
        data_in = -50;
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        #10;
        
        if (data_out === 0) begin
            $display("  PASS: -50 -> 0");
        end else begin
            $display("  FAIL: Expected 0, got %0d", data_out);
        end
        
        // 测试3: 0输入
        $display("\n[Test 3] Zero input: 0");
        data_in = 0;
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        #10;
        
        if (data_out === 0) begin
            $display("  PASS: 0 -> 0");
        end else begin
            $display("  FAIL: Expected 0, got %0d", data_out);
        end
        
        // 测试4: 大正数
        $display("\n[Test 4] Large positive: 32767");
        data_in = 32767;
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        #10;
        
        if (data_out === 32767) begin
            $display("  PASS: 32767 -> 32767");
        end else begin
            $display("  FAIL: Expected 32767, got %0d", data_out);
        end
        
        // 测试5: 无效输入
        $display("\n[Test 5] Invalid input (valid_in=0)");
        data_in = 200;
        valid_in = 1'b0;
        #10;
        
        // 输出应保持不变（或实现定义）
        $display("  Output during invalid: %0d", data_out);
        
        // 完成
        #10;
        $display("\n[INFO] All tests completed!");
        $finish;
    end
    
    // 波形记录
    initial begin
        $dumpfile("test_simple_relu.vcd");
        $dumpvars(0, test_simple_relu);
    end
    
endmodule
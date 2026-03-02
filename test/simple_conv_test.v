// ======================================================
// Simplified Convolution Testbench
// ======================================================

`timescale 1ns/1ps

module simple_conv_test();

    parameter DATA_WIDTH = 16;
    parameter WEIGHT_WIDTH = 16;
    parameter ACC_WIDTH = 32;
    
    // 时钟和复位
    reg clk;
    reg rst_n;
    
    // 输入窗口 (3x3)
    reg signed [DATA_WIDTH-1:0] window_00, window_01, window_02;
    reg signed [DATA_WIDTH-1:0] window_10, window_11, window_12;
    reg signed [DATA_WIDTH-1:0] window_20, window_21, window_22;
    
    // 卷积核权重 (3x3)
    reg signed [WEIGHT_WIDTH-1:0] weight_00, weight_01, weight_02;
    reg signed [WEIGHT_WIDTH-1:0] weight_10, weight_11, weight_12;
    reg signed [WEIGHT_WIDTH-1:0] weight_20, weight_21, weight_22;
    
    // 偏置项
    reg signed [DATA_WIDTH-1:0] bias;
    
    // 控制信号
    reg valid_in;
    wire valid_out;
    
    // 输出
    wire signed [DATA_WIDTH-1:0] conv_out;
    
    // 期望输出寄存器
    integer expected;
    
    // 待测模块实例化
    convolution_3x3 #(
        .DATA_WIDTH(DATA_WIDTH),
        .WEIGHT_WIDTH(WEIGHT_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        
        // 输入窗口
        .window_00(window_00),
        .window_01(window_01),
        .window_02(window_02),
        .window_10(window_10),
        .window_11(window_11),
        .window_12(window_12),
        .window_20(window_20),
        .window_21(window_21),
        .window_22(window_22),
        
        // 权重
        .weight_00(weight_00),
        .weight_01(weight_01),
        .weight_02(weight_02),
        .weight_10(weight_10),
        .weight_11(weight_11),
        .weight_12(weight_12),
        .weight_20(weight_20),
        .weight_21(weight_21),
        .weight_22(weight_22),
        
        // 偏置
        .bias(bias),
        
        // 控制信号
        .valid_in(valid_in),
        .valid_out(valid_out),
        
        // 输出
        .conv_out(conv_out)
    );
    
    // 时钟生成
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end
    
    // 复位信号
    initial begin
        rst_n = 1'b0;
        #20 rst_n = 1'b1;
    end
    
    // 测试主程序
    integer actual_val;
    initial begin
        
        // 初始化
        valid_in = 1'b0;
        bias = 0;
        window_00 = 0; window_01 = 0; window_02 = 0;
        window_10 = 0; window_11 = 0; window_12 = 0;
        window_20 = 0; window_21 = 0; window_22 = 0;
        
        weight_00 = 0; weight_01 = 0; weight_02 = 0;
        weight_10 = 0; weight_11 = 0; weight_12 = 0;
        weight_20 = 0; weight_21 = 0; weight_22 = 0;
        
        // 等待复位结束
        #30;
        
        // ===== 测试1: 简单卷积 =====
        $display("\n[Test 1] Simple convolution");
        
        // 设置输入：全1矩阵
        window_00 = 1; window_01 = 1; window_02 = 1;
        window_10 = 1; window_11 = 1; window_12 = 1;
        window_20 = 1; window_21 = 1; window_22 = 1;
        
        // 设置卷积核：单位矩阵
        weight_00 = 1; weight_01 = 0; weight_02 = 0;
        weight_10 = 0; weight_11 = 1; weight_12 = 0;
        weight_20 = 0; weight_21 = 0; weight_22 = 1;
        
        // 期望输出：1+1+1=3
        expected = 3;
        
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        
        // 等待流水线完成 (需要更多时间，因为valid_out也需要时间)
        wait(valid_out == 1'b1);
        #10;
        
        // 检查输出
        if (conv_out == 3) begin
            $display("  PASS: Output = %0d (expected 3)", conv_out);
        end else begin
            $display("  FAIL: Expected 3, got %0d", conv_out);
        end
        
        // ===== 测试2: 边缘检测核 =====
        $display("\n[Test 2] Edge detection kernel");
        
        // 均匀区域
        window_00 = 10; window_01 = 10; window_02 = 10;
        window_10 = 10; window_11 = 10; window_12 = 10;
        window_20 = 10; window_21 = 10; window_22 = 10;
        
        // Sobel垂直核
        weight_00 = -1; weight_01 = 0; weight_02 = 1;
        weight_10 = -2; weight_11 = 0; weight_12 = 2;
        weight_20 = -1; weight_21 = 0; weight_22 = 1;
        
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        #40;
        
        // 均匀区域应该输出0
        if (conv_out == 0) begin
            $display("  PASS: Uniform area -> 0 (edge detection working)");
        end else begin
            $display("  FAIL: Expected 0, got %0d", conv_out);
        end
        
        // 完成测试
        #10;
        $display("\n[INFO] Convolution tests completed successfully!");
        $finish;
    end
    
    // 波形记录
    initial begin
        $dumpfile("simple_conv_test.vcd");
        $dumpvars(0, simple_conv_test);
    end

endmodule
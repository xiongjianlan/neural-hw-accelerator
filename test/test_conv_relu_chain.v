// ======================================================
// Convolution + ReLU Chain Testbench
// ======================================================

`timescale 1ns/1ps

module test_conv_relu_chain();

    parameter DATA_WIDTH = 16;
    parameter WEIGHT_WIDTH = 16;
    parameter ACC_WIDTH = 32;
    
    // 时钟和复位
    reg clk;
    reg rst_n;
    
    // 输入
    reg signed [DATA_WIDTH-1:0] conv_window_00, conv_window_01, conv_window_02;
    reg signed [DATA_WIDTH-1:0] conv_window_10, conv_window_11, conv_window_12;
    reg signed [DATA_WIDTH-1:0] conv_window_20, conv_window_21, conv_window_22;
    
    reg signed [WEIGHT_WIDTH-1:0] conv_weight_00, conv_weight_01, conv_weight_02;
    reg signed [WEIGHT_WIDTH-1:0] conv_weight_10, conv_weight_11, conv_weight_12;
    reg signed [WEIGHT_WIDTH-1:0] conv_weight_20, conv_weight_21, conv_weight_22;
    
    reg signed [DATA_WIDTH-1:0] conv_bias;
    reg valid_in;
    
    // 输出
    wire valid_out;
    wire signed [DATA_WIDTH-1:0] final_out;
    
    // 待测模块
    conv_relu_chain #(
        .DATA_WIDTH(DATA_WIDTH),
        .WEIGHT_WIDTH(WEIGHT_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        
        // 卷积输入
        .conv_window_00(conv_window_00),
        .conv_window_01(conv_window_01),
        .conv_window_02(conv_window_02),
        .conv_window_10(conv_window_10),
        .conv_window_11(conv_window_11),
        .conv_window_12(conv_window_12),
        .conv_window_20(conv_window_20),
        .conv_window_21(conv_window_21),
        .conv_window_22(conv_window_22),
        
        // 权重
        .conv_weight_00(conv_weight_00),
        .conv_weight_01(conv_weight_01),
        .conv_weight_02(conv_weight_02),
        .conv_weight_10(conv_weight_10),
        .conv_weight_11(conv_weight_11),
        .conv_weight_12(conv_weight_12),
        .conv_weight_20(conv_weight_20),
        .conv_weight_21(conv_weight_21),
        .conv_weight_22(conv_weight_22),
        
        // 偏置
        .conv_bias(conv_bias),
        
        // 控制
        .valid_in(valid_in),
        .valid_out(valid_out),
        
        // 输出
        .final_out(final_out)
    );
    
    // 时钟生成
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
    integer expected_conv;
    integer expected_relu;
    initial begin
        
        // 初始化
        valid_in = 1'b0;
        conv_bias = 0;
        
        // 等待复位
        #30;
        
        // ===== 测试1: 正数输出（ReLU应保持不变）=====
        $display("\n[Test 1] Positive convolution output");
        
        // 设置输入：全1矩阵
        conv_window_00 = 1; conv_window_01 = 1; conv_window_02 = 1;
        conv_window_10 = 1; conv_window_11 = 1; conv_window_12 = 1;
        conv_window_20 = 1; conv_window_21 = 1; conv_window_22 = 1;
        
        // 设置卷积核：单位矩阵
        conv_weight_00 = 1; conv_weight_01 = 0; conv_weight_02 = 0;
        conv_weight_10 = 0; conv_weight_11 = 1; conv_weight_12 = 0;
        conv_weight_20 = 0; conv_weight_21 = 0; conv_weight_22 = 1;
        
        // 期望：卷积输出 = 3，ReLU输出 = 3
        expected_conv = 3;
        expected_relu = 3;
        
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        
        // 等待整个流水线完成（卷积3级 + ReLU 1级 ≈ 4级）
        #60;
        
        if (final_out == expected_relu) begin
            $display("  PASS: Conv output %0d -> ReLU output %0d", 
                    expected_conv, expected_relu);
        end else begin
            $display("  FAIL: Expected %0d, got %0d", expected_relu, final_out);
        end
        
        // ===== 测试2: 负数输出（ReLU应为0）=====
        $display("\n[Test 2] Negative convolution output (ReLU -> 0)");
        
        // 设置输入：全-1矩阵
        conv_window_00 = -1; conv_window_01 = -1; conv_window_02 = -1;
        conv_window_10 = -1; conv_window_11 = -1; conv_window_12 = -1;
        conv_window_20 = -1; conv_window_21 = -1; conv_window_22 = -1;
        
        // 设置卷积核：单位矩阵
        conv_weight_00 = 1; conv_weight_01 = 0; conv_weight_02 = 0;
        conv_weight_10 = 0; conv_weight_11 = 1; conv_weight_12 = 0;
        conv_weight_20 = 0; conv_weight_21 = 0; conv_weight_22 = 1;
        
        // 期望：卷积输出 = -3，ReLU输出 = 0
        expected_conv = -3;
        expected_relu = 0;
        
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        #60;
        
        if (final_out == expected_relu) begin
            $display("  PASS: Conv output %0d -> ReLU output %0d", 
                    expected_conv, expected_relu);
        end else begin
            $display("  FAIL: Expected %0d, got %0d", expected_relu, final_out);
        end
        
        // ===== 测试3: 带偏置的正数输出 =====
        $display("\n[Test 3] Convolution with bias");
        
        conv_window_00 = 1; conv_window_01 = 1; conv_window_02 = 1;
        conv_window_10 = 1; conv_window_11 = 1; conv_window_12 = 1;
        conv_window_20 = 1; conv_window_21 = 1; conv_window_22 = 1;
        
        // 平均池化核
        conv_weight_00 = 1; conv_weight_01 = 1; conv_weight_02 = 1;
        conv_weight_10 = 1; conv_weight_11 = 1; conv_weight_12 = 1;
        conv_weight_20 = 1; conv_weight_21 = 1; conv_weight_22 = 1;
        
        conv_bias = 5;  // 添加偏置
        
        // 期望：1*9 + 5 = 14，ReLU输出 = 14
        expected_conv = 14;
        expected_relu = 14;
        
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        #60;
        
        if (final_out == expected_relu) begin
            $display("  PASS: (1*9 + 5) = %0d -> ReLU = %0d", 
                    expected_conv, expected_relu);
        end else begin
            $display("  FAIL: Expected %0d, got %0d", expected_relu, final_out);
        end
        
        // 完成
        #10;
        $display("\n[INFO] Conv+ReLU chain test completed!");
        $display("       Total pipeline stages: ~4 cycles");
        $display("       (Conv: 3 stages, ReLU: 1 stage)");
        $finish;
    end
    
    // 波形记录
    initial begin
        $dumpfile("test_conv_relu_chain.vcd");
        $dumpvars(0, test_conv_relu_chain);
    end

endmodule
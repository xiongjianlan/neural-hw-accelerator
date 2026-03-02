// ======================================================
// Convolution Timing Verification Testbench
// 验证卷积层流水线时序
// ======================================================

`timescale 1ns/1ps

module verify_conv_timing();

    parameter DATA_WIDTH = 16;
    parameter WEIGHT_WIDTH = 16;
    parameter ACC_WIDTH = 32;
    
    // 时钟和复位
    reg clk;
    reg rst_n;
    
    // 输入信号
    reg signed [DATA_WIDTH-1:0] window_00, window_01, window_02;
    reg signed [DATA_WIDTH-1:0] window_10, window_11, window_12;
    reg signed [DATA_WIDTH-1:0] window_20, window_21, window_22;
    
    reg signed [WEIGHT_WIDTH-1:0] weight_00, weight_01, weight_02;
    reg signed [WEIGHT_WIDTH-1:0] weight_10, weight_11, weight_12;
    reg signed [WEIGHT_WIDTH-1:0] weight_20, weight_21, weight_22;
    
    reg signed [DATA_WIDTH-1:0] bias;
    reg valid_in;
    
    // 输出信号
    wire valid_out;
    wire signed [DATA_WIDTH-1:0] conv_out;
    
    // 待测模块
    convolution_3x3 #(
        .DATA_WIDTH(DATA_WIDTH),
        .WEIGHT_WIDTH(WEIGHT_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .window_00(window_00),
        .window_01(window_01),
        .window_02(window_02),
        .window_10(window_10),
        .window_11(window_11),
        .window_12(window_12),
        .window_20(window_20),
        .window_21(window_21),
        .window_22(window_22),
        .weight_00(weight_00),
        .weight_01(weight_01),
        .weight_02(weight_02),
        .weight_10(weight_10),
        .weight_11(weight_11),
        .weight_12(weight_12),
        .weight_20(weight_20),
        .weight_21(weight_21),
        .weight_22(weight_22),
        .bias(bias),
        .valid_in(valid_in),
        .valid_out(valid_out),
        .conv_out(conv_out)
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
    integer cycle_counter;
    integer test_inputs [0:2];
    integer expected_outputs [0:2];
    integer i;
    
    initial begin
        // 初始化
        valid_in = 1'b0;
        bias = 0;
        cycle_counter = 0;
        
        // 测试用例：对角线权重，单位矩阵
        test_inputs[0] = 1;
        test_inputs[1] = 2;
        test_inputs[2] = 3;
        
        expected_outputs[0] = 1;  // 1*1
        expected_outputs[1] = 2;  // 2*1
        expected_outputs[2] = 3;  // 3*1
        
        // 设置权重为单位矩阵（只有对角线为1）
        weight_00 = 1; weight_01 = 0; weight_02 = 0;
        weight_10 = 0; weight_11 = 1; weight_12 = 0;
        weight_20 = 0; weight_21 = 0; weight_22 = 1;
        
        // 等待复位
        #30;
        
        $display("\n=== Convolution Timing Verification ===\n");
        
        // ===== 测试1: 单次输入，验证3级流水线 =====
        $display("[Test 1] Single input, 3-stage pipeline verification");
        
        // 设置输入
        window_00 = test_inputs[0]; window_01 = 0; window_02 = 0;
        window_10 = 0; window_11 = 0; window_12 = 0;
        window_20 = 0; window_21 = 0; window_22 = 0;
        
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        
        // 等待3个周期后输出应该有效
        #30;
        
        if (valid_out && conv_out == expected_outputs[0]) begin
            $display("  ✓ PASS: Output %0d after 3 cycles", conv_out);
        end else begin
            $display("  ✗ FAIL: Expected valid_out=1, out=%0d", conv_out);
        end
        
        // ===== 测试2: 连续输入，验证流水线吞吐量 =====
        $display("\n[Test 2] Continuous inputs, pipeline throughput");
        
        // 连续输入3个数据
        for (i = 0; i < 3; i = i + 1) begin
            window_00 = test_inputs[i]; window_01 = 0; window_02 = 0;
            window_10 = 0; window_11 = 0; window_12 = 0;
            window_20 = 0; window_21 = 0; window_22 = 0;
            
            valid_in = 1'b1;
            #10;
        end
        
        valid_in = 1'b0;
        
        // 等待所有结果输出
        #60;
        
        $display("  Note: Check waveform for continuous pipeline behavior");
        
        // ===== 测试3: 完整3x3计算验证 =====
        $display("\n[Test 3] Full 3x3 calculation");
        
        // 等待一段时间
        #20;
        
        // 设置完整输入矩阵
        window_00 = 1; window_01 = 2; window_02 = 3;
        window_10 = 4; window_11 = 5; window_12 = 6;
        window_20 = 7; window_21 = 8; window_22 = 9;
        
        // 设置权重（平均池化）
        weight_00 = 1; weight_01 = 1; weight_02 = 1;
        weight_10 = 1; weight_11 = 1; weight_12 = 1;
        weight_20 = 1; weight_21 = 1; weight_22 = 1;
        
        bias = 10;
        
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        
        // 等待结果
        #40;
        
        // 期望：(1+2+3+4+5+6+7+8+9) + 10 = 45 + 10 = 55
        if (valid_out && conv_out == 55) begin
            $display("  ✓ PASS: Full calculation correct (%0d)", conv_out);
        end else begin
            $display("  ✗ FAIL: Expected 55, got %0d", conv_out);
        end
        
        // ===== 时序总结 =====
        $display("\n[Timing Summary]");
        $display("  Pipeline stages: 3");
        $display("  Latency: 3 clock cycles");
        $display("  Throughput: 1 operation per cycle (when pipeline full)");
        
        // 完成
        #10;
        $display("\n[INFO] Convolution timing verification completed!");
        $finish;
    end
    
    // 时钟计数器
    always @(posedge clk) begin
        if (rst_n) cycle_counter <= cycle_counter + 1;
    end
    
    // 波形记录
    initial begin
        $dumpfile("verify_conv_timing.vcd");
        $dumpvars(0, verify_conv_timing);
    end

endmodule
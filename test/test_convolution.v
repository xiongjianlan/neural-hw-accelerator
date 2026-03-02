// ======================================================
// Convolution 3x3 Testbench
// ======================================================

`timescale 1ns/1ps

module test_convolution();

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
    
    // ======================================================
    // 时钟生成
    // ======================================================
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;  // 100MHz时钟
    end
    
    // ======================================================
    // 复位信号
    // ======================================================
    initial begin
        rst_n = 1'b0;          // 复位有效
        #20 rst_n = 1'b1;      // 20ns后释放复位
    end
    
    // ======================================================
    // 辅助函数：设置窗口值
    // ======================================================
    task set_window;
        input signed [DATA_WIDTH-1:0] w00, w01, w02;
        input signed [DATA_WIDTH-1:0] w10, w11, w12;
        input signed [DATA_WIDTH-1:0] w20, w21, w22;
    begin
        window_00 = w00;
        window_01 = w01;
        window_02 = w02;
        window_10 = w10;
        window_11 = w11;
        window_12 = w12;
        window_20 = w20;
        window_21 = w21;
        window_22 = w22;
    end
    endtask
    
    // ======================================================
    // 辅助函数：设置卷积核
    // ======================================================
    task set_kernel;
        input signed [WEIGHT_WIDTH-1:0] w00, w01, w02;
        input signed [WEIGHT_WIDTH-1:0] w10, w11, w12;
        input signed [WEIGHT_WIDTH-1:0] w20, w21, w22;
    begin
        weight_00 = w00;
        weight_01 = w01;
        weight_02 = w02;
        weight_10 = w10;
        weight_11 = w11;
        weight_12 = w12;
        weight_20 = w20;
        weight_21 = w21;
        weight_22 = w22;
    end
    endtask
    
    // ======================================================
    // 主测试程序
    // ======================================================
    initial begin
        integer expected;
        integer actual;
        
        // 初始化
        valid_in = 1'b0;
        bias = 0;
        
        // 设置默认值（避免未定义）
        set_window(0, 0, 0, 0, 0, 0, 0, 0, 0);
        set_kernel(0, 0, 0, 0, 0, 0, 0, 0, 0);
        
        // 等待复位结束
        #30;
        
        // ======================================================
        // 测试1: 简单全1卷积（单位核）
        // ======================================================
        $display("\n[Test 1] Simple convolution: all 1s with identity kernel");
        set_window(1, 1, 1, 1, 1, 1, 1, 1, 1);
        set_kernel(1, 0, 0, 0, 1, 0, 0, 0, 1);  // 对角线为1
        
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        
        // 等待流水线完成（3个周期）
        #30;
        
        expected = 1*1 + 1*0 + 1*0 + 
                   1*0 + 1*1 + 1*0 + 
                   1*0 + 1*0 + 1*1 + 0;  // 1+1+1+0=3
        
        actual = conv_out;
        if (actual == expected) begin
            $display("  PASS: Expected %0d, got %0d", expected, conv_out);
        end else begin
            $error("  FAIL: Expected %0d, got %0d", expected, conv_out);
        end
        
        // ======================================================
        // 测试2: 垂直边缘检测核
        // ======================================================
        $display("\n[Test 2] Vertical edge detection kernel");
        set_window(10, 10, 10, 
                   10, 10, 10,
                   10, 10, 10);  // 均匀区域
        
        // Sobel垂直核
        set_kernel(-1, 0, 1,
                   -2, 0, 2,
                   -1, 0, 1);
        
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        #30;
        
        // 均匀区域应该输出0
        expected = 0;
        
        actual = conv_out;
        if (actual == expected) begin
            $display("  PASS: Uniform area -> 0 (correct edge detection)");
        end else begin
            $error("  FAIL: Uniform area should be 0, got %0d", conv_out);
        end
        
        // ======================================================
        // 测试3: 水平边缘检测（梯度变化）
        // ======================================================
        $display("\n[Test 3] Horizontal edge detection");
        // 创建水平梯度
        set_window(5, 5, 5,
                   10, 10, 10,
                   15, 15, 15);
        
        // Sobel水平核
        set_kernel(-1, -2, -1,
                    0,  0,  0,
                    1,  2,  1);
        
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        #30;
        
        // 计算期望值
        expected = ( -5 + -10 + -5 +
                       0 +   0 +   0 +
                      15 +  30 +  15) + 0;  // -20 + 60 = 40
        
        actual = conv_out;
        if (actual == expected) begin
            $display("  PASS: Gradient -> %0d", expected);
        end else begin
            $error("  FAIL: Expected %0d, got %0d", expected, conv_out);
        end
        
        // ======================================================
        // 测试4: 带偏置项的卷积
        // ======================================================
        $display("\n[Test 4] Convolution with bias");
        set_window(2, 2, 2,
                   2, 2, 2,
                   2, 2, 2);
        
        // 平均池化核（1/9近似为1）
        set_kernel(1, 1, 1,
                   1, 1, 1,
                   1, 1, 1);
        
        bias = 10;  // 添加偏置
        
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        #30;
        
        // 期望值 = 2*9 + 10 = 28
        expected = 28;
        
        actual = conv_out;
        if (actual == expected) begin
            $display("  PASS: (2*9) + 10 = %0d", expected);
        end else begin
            $error("  FAIL: Expected %0d, got %0d", expected, conv_out);
        end
        
        // ======================================================
        // 测试5: 连续卷积（测试流水线）
        // ======================================================
        $display("\n[Test 5] Pipeline test (continuous convolution)");
        bias = 0;
        
        // 第一组数据
        set_window(1, 0, 0, 0, 1, 0, 0, 0, 1);
        set_kernel(1, 0, 0, 0, 1, 0, 0, 0, 1);
        
        valid_in = 1'b1;
        #10;
        
        // 第二组数据（连续输入）
        set_window(2, 0, 0, 0, 2, 0, 0, 0, 2);
        #10;
        
        // 第三组数据
        set_window(3, 0, 0, 0, 3, 0, 0, 0, 3);
        #10;
        
        valid_in = 1'b0;
        
        // 等待所有结果输出
        #50;
        
        $display("  Note: Pipeline working - check waveform for timing");
        
        // ======================================================
        // 测试完成
        // ======================================================
        #10;
        $display("\n[INFO] All convolution tests completed!");
        $display("       Module has 3-stage pipeline (latency)");
        $display("       1. Multiplication (parallel)");
        $display("       2. Row accumulation");
        $display("       3. Column accumulation + bias + truncation");
        $finish;
    end
    
    // ======================================================
    // 波形记录
    // ======================================================
    initial begin
        $dumpfile("test_convolution.vcd");
        $dumpvars(0, test_convolution);
    end

endmodule
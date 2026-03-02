// ======================================================
// Fixed Convolution Test
// ======================================================

`timescale 1ns/1ps

module test_fixed_conv();

    parameter DATA_WIDTH = 16;
    parameter WEIGHT_WIDTH = 16;
    parameter ACC_WIDTH = 32;
    
    // 时钟和复位
    reg clk;
    reg rst_n;
    
    // 简化输入
    reg signed [DATA_WIDTH-1:0] window_00, window_11, window_22;
    reg signed [WEIGHT_WIDTH-1:0] weight_00, weight_11, weight_22;
    reg signed [DATA_WIDTH-1:0] bias;
    reg valid_in;
    
    // 输出
    wire valid_out;
    wire signed [DATA_WIDTH-1:0] conv_out;
    
    // 实例化（简化版本）
    fixed_conv_simple #(
        .DATA_WIDTH(DATA_WIDTH),
        .WEIGHT_WIDTH(WEIGHT_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .window_00(window_00),
        .window_11(window_11),
        .window_22(window_22),
        .weight_00(weight_00),
        .weight_11(weight_11),
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
    
    // 主测试
    integer cycle_count;
    integer test_result;
    initial begin
        // 初始化
        valid_in = 1'b0;
        window_00 = 0; window_11 = 0; window_22 = 0;
        weight_00 = 0; weight_11 = 0; weight_22 = 0;
        bias = 0;
        cycle_count = 0;
        
        // 等待复位
        #30;
        
        // ===== 测试1: 简单计算，验证流水线 =====
        $display("\n[Test 1] Simple convolution with pipeline");
        
        // 设置输入
        window_00 = 2;
        window_11 = 3;
        window_22 = 4;
        
        weight_00 = 1;
        weight_11 = 2;
        weight_22 = 3;
        
        bias = 0;
        
        // 第1个周期：输入有效
        valid_in = 1'b1;
        #10;
        
        // 第2个周期：继续输入有效，观察流水线
        window_00 = 10;
        window_11 = 20;
        window_22 = 30;
        
        weight_00 = -1;
        weight_11 = 0;
        weight_22 = 1;
        #10;
        
        valid_in = 1'b0;
        
        // 等待流水线完成
        #60;
        
        // 检查结果（应该在第3个周期后输出）
        $display("  Pipeline test completed - check waveform for timing");
        
        // ===== 测试2: 带偏置的计算 =====
        $display("\n[Test 2] Convolution with bias");
        
        // 等待一段时间
        #20;
        
        window_00 = 1;
        window_11 = 1;
        window_22 = 1;
        
        weight_00 = 1;
        weight_11 = 1;
        weight_22 = 1;
        
        bias = 10;
        
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        
        // 等待输出
        #40;
        
        // 期望：1+1+1+10 = 13
        test_result = conv_out;
        $display("  Result: %0d (expected 13)", test_result);
        
        if (test_result == 13) begin
            $display("  PASS: Correct calculation with bias!");
        end else begin
            $display("  FAIL: Expected 13");
        end
        
        // 完成
        #10;
        $display("\n[INFO] Fixed convolution test completed!");
        $finish;
    end
    
    // 波形记录
    initial begin
        $dumpfile("test_fixed_conv.vcd");
        $dumpvars(0, test_fixed_conv);
    end
    
    // 时钟计数器
    always @(posedge clk) begin
        if (rst_n) cycle_count <= cycle_count + 1;
    end

endmodule

// 简化的卷积模块（只测试3个对角线元素，修复了时序）
module fixed_conv_simple #(
    parameter DATA_WIDTH = 16,
    parameter WEIGHT_WIDTH = 16,
    parameter ACC_WIDTH = 32
)(
    input wire clk,
    input wire rst_n,
    input wire signed [DATA_WIDTH-1:0] window_00,
    input wire signed [DATA_WIDTH-1:0] window_11,
    input wire signed [DATA_WIDTH-1:0] window_22,
    input wire signed [WEIGHT_WIDTH-1:0] weight_00,
    input wire signed [WEIGHT_WIDTH-1:0] weight_11,
    input wire signed [WEIGHT_WIDTH-1:0] weight_22,
    input wire signed [DATA_WIDTH-1:0] bias,
    input wire valid_in,
    output reg valid_out,
    output reg signed [DATA_WIDTH-1:0] conv_out
);
    
    // 中间信号
    wire signed [ACC_WIDTH-1:0] mul_00, mul_11, mul_22;
    reg signed [ACC_WIDTH-1:0] sum_stage1;
    reg signed [ACC_WIDTH-1:0] sum_stage2;
    reg valid_stage1, valid_stage2, valid_stage3;
    
    // 乘法
    assign mul_00 = window_00 * weight_00;
    assign mul_11 = window_11 * weight_11;
    assign mul_22 = window_22 * weight_22;
    
    // 3级流水线
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 复位
            sum_stage1 <= 0;
            sum_stage2 <= 0;
            conv_out <= 0;
            valid_stage1 <= 1'b0;
            valid_stage2 <= 1'b0;
            valid_stage3 <= 1'b0;
            valid_out <= 1'b0;
        end else begin
            // 第1级：部分和
            if (valid_in) begin
                sum_stage1 <= mul_00 + mul_11;
                valid_stage1 <= 1'b1;
            end else begin
                valid_stage1 <= 1'b0;
            end
            
            // 第2级：完整和
            if (valid_stage1) begin
                sum_stage2 <= sum_stage1 + mul_22;
                valid_stage2 <= 1'b1;
            end else begin
                valid_stage2 <= 1'b0;
            end
            
            // 第3级：加偏置并截断
            if (valid_stage2) begin
                conv_out <= sum_stage2[ACC_WIDTH-1:ACC_WIDTH-DATA_WIDTH] + bias;
                valid_stage3 <= 1'b1;
            end else begin
                valid_stage3 <= 1'b0;
            end
            
            // 输出有效信号
            valid_out <= valid_stage3;
        end
    end

endmodule
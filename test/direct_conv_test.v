// ======================================================
// Direct Convolution Test (Simplified)
// 直接测试卷积计算，不使用复杂控制信号
// ======================================================

`timescale 1ns/1ps

module direct_conv_test();

    parameter DATA_WIDTH = 16;
    parameter WEIGHT_WIDTH = 16;
    parameter ACC_WIDTH = 32;
    
    // 时钟和复位
    reg clk;
    reg rst_n;
    
    // 简化接口 - 只测试计算
    reg signed [DATA_WIDTH-1:0] window_00, window_11, window_22;
    reg signed [WEIGHT_WIDTH-1:0] weight_00, weight_11, weight_22;
    wire signed [DATA_WIDTH-1:0] conv_out;
    
    // 创建简单的模块
    simple_conv uut (
        .clk(clk),
        .rst_n(rst_n),
        .window_00(window_00),
        .window_11(window_11),
        .window_22(window_22),
        .weight_00(weight_00),
        .weight_11(weight_11),
        .weight_22(weight_22),
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
    initial begin
        // 等待复位
        #30;
        
        // 测试简单点积
        $display("\n[Test] Simple dot product");
        window_00 = 2;
        window_11 = 3;
        window_22 = 4;
        
        weight_00 = 1;
        weight_11 = 2;
        weight_22 = 3;
        
        #20;
        
        // 期望: 2*1 + 3*2 + 4*3 = 2 + 6 + 12 = 20
        $display("  Inputs: 2,3,4 * 1,2,3");
        $display("  Output: %0d", conv_out);
        
        if (conv_out == 20) begin
            $display("  PASS: Correct dot product!");
        end else begin
            $display("  FAIL: Expected 20, got %0d", conv_out);
        end
        
        // 另一个测试
        #10;
        window_00 = 10;
        window_11 = 20;
        window_22 = 30;
        
        weight_00 = -1;
        weight_11 = 0;
        weight_22 = 1;
        
        #20;
        
        // 期望: 10*(-1) + 20*0 + 30*1 = -10 + 0 + 30 = 20
        $display("\n[Test] Mixed signs");
        $display("  Inputs: 10,20,30 * -1,0,1");
        $display("  Output: %0d", conv_out);
        
        if (conv_out == 20) begin
            $display("  PASS: Mixed signs correct!");
        end else begin
            $display("  FAIL: Expected 20, got %0d", conv_out);
        end
        
        // 完成
        #10;
        $display("\n[INFO] Direct convolution test completed!");
        $finish;
    end
    
    // 波形记录
    initial begin
        $dumpfile("direct_conv_test.vcd");
        $dumpvars(0, direct_conv_test);
    end

endmodule

// 简化卷积模块（只测试3个对角线元素）
module simple_conv #(
    parameter DATA_WIDTH = 16,
    parameter WEIGHT_WIDTH = 16
)(
    input wire clk,
    input wire rst_n,
    input wire signed [DATA_WIDTH-1:0] window_00,
    input wire signed [DATA_WIDTH-1:0] window_11,
    input wire signed [DATA_WIDTH-1:0] window_22,
    input wire signed [WEIGHT_WIDTH-1:0] weight_00,
    input wire signed [WEIGHT_WIDTH-1:0] weight_11,
    input wire signed [WEIGHT_WIDTH-1:0] weight_22,
    output reg signed [DATA_WIDTH-1:0] conv_out
);
    
    // 直接组合逻辑计算
    always @(*) begin
        if (!rst_n) begin
            conv_out = 0;
        end else begin
            // 简单点积
            conv_out = window_00 * weight_00 + 
                      window_11 * weight_11 + 
                      window_22 * weight_22;
        end
    end
    
endmodule
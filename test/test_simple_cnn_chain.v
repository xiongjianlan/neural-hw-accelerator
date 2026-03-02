// ======================================================
// Simplified CNN Chain Test
// 测试卷积→ReLU→池化的基本流程
// ======================================================

`timescale 1ns/1ps

module test_simple_cnn_chain();

    parameter DATA_WIDTH = 16;
    
    // 时钟和复位
    reg clk;
    reg rst_n;
    
    // 简化CNN模块
    simple_cnn_chain uut (
        .clk(clk),
        .rst_n(rst_n),
        .conv_in(conv_in),
        .weight(weight),
        .bias(bias),
        .valid_in(valid_in),
        .valid_out(valid_out),
        .cnn_out(cnn_out)
    );
    
    // 输入
    reg signed [DATA_WIDTH-1:0] conv_in;
    reg signed [DATA_WIDTH-1:0] weight;
    reg signed [DATA_WIDTH-1:0] bias;
    reg valid_in;
    
    // 输出
    wire valid_out;
    wire signed [DATA_WIDTH-1:0] cnn_out;
    
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
    integer test_count;
    integer expected_result;
    initial begin
        // 初始化
        conv_in = 0;
        weight = 0;
        bias = 0;
        valid_in = 1'b0;
        test_count = 0;
        
        // 等待复位
        #30;
        
        $display("\n=== CNN Processing Chain Test ===");
        
        // ===== 测试1: 简单正数 =====
        $display("\n[Test 1] Positive values only");
        
        // 模拟4个连续的卷积输出
        for (test_count = 0; test_count < 4; test_count = test_count + 1) begin
            conv_in = test_count + 1;  // 1,2,3,4
            weight = 1;
            bias = 0;
            valid_in = 1'b1;
            #10;
        end
        
        valid_in = 1'b0;
        
        // 等待处理完成（卷积3周期 + ReLU 1周期 + 缓冲4周期 + 池化1周期 ≈ 9周期）
        #100;
        
        // 期望：max(1,2,3,4) = 4
        expected_result = 4;
        if (cnn_out == expected_result) begin
            $display("  PASS: Max of [1,2,3,4] = %0d", cnn_out);
        end else begin
            $display("  FAIL: Expected %0d, got %0d", expected_result, cnn_out);
        end
        
        // ===== 测试2: 混合正负数 =====
        $display("\n[Test 2] Mixed positive/negative values");
        
        // 等待一段时间
        #20;
        
        // 模拟4个连续的卷积输出（有负数）
        conv_in = 10; valid_in = 1'b1; #10;
        conv_in = -5; valid_in = 1'b1; #10;
        conv_in = 20; valid_in = 1'b1; #10;
        conv_in = -10; valid_in = 1'b1; #10;
        
        valid_in = 1'b0;
        
        // 等待处理
        #100;
        
        // 期望：经过ReLU后变成[10,0,20,0]，max=20
        expected_result = 20;
        if (cnn_out == expected_result) begin
            $display("  PASS: Max of [10,0,20,0] = %0d", cnn_out);
        end else begin
            $display("  FAIL: Expected %0d, got %0d", expected_result, cnn_out);
        end
        
        // ===== 测试3: 带偏置的计算 =====
        $display("\n[Test 3] With bias");
        
        // 等待
        #20;
        
        bias = 5;  // 设置偏置
        
        // 模拟4个输入
        conv_in = 1; valid_in = 1'b1; #10;
        conv_in = 2; valid_in = 1'b1; #10;
        conv_in = 3; valid_in = 1'b1; #10;
        conv_in = 4; valid_in = 1'b1; #10;
        
        valid_in = 1'b0;
        
        // 等待处理
        #100;
        
        // 期望：输入[1,2,3,4] + 偏置5 = [6,7,8,9]，max=9
        expected_result = 9;
        if (cnn_out == expected_result) begin
            $display("  PASS: Max of [6,7,8,9] = %0d", cnn_out);
        end else begin
            $display("  FAIL: Expected %0d, got %0d", expected_result, cnn_out);
        end
        
        // 完成
        #10;
        $display("\n[INFO] Simplified CNN chain test completed!");
        $display("       Total pipeline: Conv(3) + ReLU(1) + Buffer(4) + Pool(1) = ~9 cycles");
        $finish;
    end
    
    // 波形记录
    initial begin
        $dumpfile("test_simple_cnn_chain.vcd");
        $dumpvars(0, test_simple_cnn_chain);
    end

endmodule

// 简化的CNN处理链（概念验证）
module simple_cnn_chain #(
    parameter DATA_WIDTH = 16
)(
    input wire clk,
    input wire rst_n,
    input wire signed [DATA_WIDTH-1:0] conv_in,
    input wire signed [DATA_WIDTH-1:0] weight,
    input wire signed [DATA_WIDTH-1:0] bias,
    input wire valid_in,
    output reg valid_out,
    output reg signed [DATA_WIDTH-1:0] cnn_out
);
    
    // 内部状态
    reg signed [DATA_WIDTH-1:0] conv_buffer [0:3];
    reg [1:0] buffer_index;
    reg conv_valid_delayed;
    reg pool_trigger;
    
    // 简化卷积计算（假设已计算好的结果）
    wire signed [DATA_WIDTH-1:0] conv_result;
    assign conv_result = conv_in * weight + bias;
    
    // 简化ReLU
    wire signed [DATA_WIDTH-1:0] relu_result;
    assign relu_result = (conv_result > 0) ? conv_result : 0;
    
    // 缓冲收集逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            buffer_index <= 2'd0;
            conv_buffer[0] <= 0;
            conv_buffer[1] <= 0;
            conv_buffer[2] <= 0;
            conv_buffer[3] <= 0;
            conv_valid_delayed <= 1'b0;
            pool_trigger <= 1'b0;
            valid_out <= 1'b0;
            cnn_out <= 0;
        end else begin
            // 延迟有效信号
            conv_valid_delayed <= valid_in;
            
            // 收集ReLU结果
            if (conv_valid_delayed) begin
                conv_buffer[buffer_index] <= relu_result;
                
                if (buffer_index == 2'd3) begin
                    buffer_index <= 2'd0;
                    pool_trigger <= 1'b1;  // 缓冲满，触发池化
                end else begin
                    buffer_index <= buffer_index + 1;
                    pool_trigger <= 1'b0;
                end
            end else begin
                pool_trigger <= 1'b0;
            end
            
            // 池化计算（下一个周期）
            if (pool_trigger) begin
                // 计算2x2窗口的最大值
                cnn_out <= max4(conv_buffer[0], conv_buffer[1], 
                               conv_buffer[2], conv_buffer[3]);
                valid_out <= 1'b1;
            end else begin
                valid_out <= 1'b0;
            end
        end
    end
    
    // 辅助函数：计算4个数中的最大值
    function signed [DATA_WIDTH-1:0] max4;
        input signed [DATA_WIDTH-1:0] a, b, c, d;
        reg signed [DATA_WIDTH-1:0] max1, max2;
    begin
        max1 = (a > b) ? a : b;
        max2 = (c > d) ? c : d;
        max4 = (max1 > max2) ? max1 : max2;
    end
    endfunction

endmodule
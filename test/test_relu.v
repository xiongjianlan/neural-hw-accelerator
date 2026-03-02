// ======================================================
// ReLU Module Testbench
// 验证ReLU激活函数的正确性
// ======================================================

`timescale 1ns/1ps

module test_relu();

    // 参数定义
    parameter DATA_WIDTH = 16;
    parameter VECTOR_SIZE = 8;
    
    // 时钟和复位信号
    reg clk;
    reg rst_n;
    
    // 待测模块接口
    reg signed [DATA_WIDTH-1:0] data_in [0:VECTOR_SIZE-1];
    wire signed [DATA_WIDTH-1:0] data_out [0:VECTOR_SIZE-1];
    reg valid_in;
    wire valid_out;
    
    // 测试向量定义
    reg signed [DATA_WIDTH-1:0] test_vectors_pos [0:VECTOR_SIZE-1] = {
        16'd10, 16'd25, 16'd100, 16'd50,
        16'd75, 16'd200, 16'd150, 16'd80
    };
    
    reg signed [DATA_WIDTH-1:0] test_vectors_mixed [0:VECTOR_SIZE-1] = {
        16'd10, -16'd5, 16'd100, -16'd20,
        -16'd15, 16'd200, -16'd30, 16'd80
    };
    
    reg signed [DATA_WIDTH-1:0] test_vectors_neg [0:VECTOR_SIZE-1] = {
        -16'd10, -16'd25, -16'd100, -16'd50,
        -16'd75, -16'd200, -16'd150, -16'd80
    };
    
    // 期望输出
    reg signed [DATA_WIDTH-1:0] expected_mixed [0:VECTOR_SIZE-1] = {
        16'd10, 16'd0, 16'd100, 16'd0,
        16'd0, 16'd200, 16'd0, 16'd80
    };
    
    // 实例化待测模块
    relu_activation #(
        .DATA_WIDTH(DATA_WIDTH),
        .VECTOR_SIZE(VECTOR_SIZE)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .data_out(data_out),
        .valid_in(valid_in),
        .valid_out(valid_out)
    );
    
    // 时钟生成
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;  // 100MHz时钟
    end
    
    // 复位信号
    initial begin
        rst_n = 1'b0;           // 开始复位
        #20 rst_n = 1'b1;       // 20ns后释放复位
    end
    
    // 测试序列
    initial begin
        // 初始化
        valid_in = 1'b0;
        for (integer i = 0; i < VECTOR_SIZE; i = i + 1) begin
            data_in[i] = 0;
        end
        
        #30;  // 等待复位结束
        
        // ===== 测试1: 全正数输入 =====
        $display("[Test 1] All positive inputs");
        for (integer i = 0; i < VECTOR_SIZE; i = i + 1) begin
            data_in[i] = test_vectors_pos[i];
        end
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        #20;
        
        // 验证输出
        for (integer i = 0; i < VECTOR_SIZE; i = i + 1) begin
            if (data_out[i] !== test_vectors_pos[i]) begin
                $error("Test 1 failed at index %0d: expected %0d, got %0d", 
                      i, test_vectors_pos[i], data_out[i]);
            end else begin
                $display("  Index %0d: %0d -> %0d (PASS)", 
                        i, test_vectors_pos[i], data_out[i]);
            end
        end
        
        // ===== 测试2: 混合输入 =====
        $display("\n[Test 2] Mixed positive/negative inputs");
        for (integer i = 0; i < VECTOR_SIZE; i = i + 1) begin
            data_in[i] = test_vectors_mixed[i];
        end
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        #20;
        
        // 验证输出
        for (integer i = 0; i < VECTOR_SIZE; i = i + 1) begin
            if (data_out[i] !== expected_mixed[i]) begin
                $error("Test 2 failed at index %0d: expected %0d, got %0d", 
                      i, expected_mixed[i], data_out[i]);
            end else begin
                $display("  Index %0d: %0d -> %0d (PASS)", 
                        i, test_vectors_mixed[i], data_out[i]);
            end
        end
        
        // ===== 测试3: 全负数输入 =====
        $display("\n[Test 3] All negative inputs");
        for (integer i = 0; i < VECTOR_SIZE; i = i + 1) begin
            data_in[i] = test_vectors_neg[i];
        end
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        #20;
        
        // 验证输出应为全0
        for (integer i = 0; i < VECTOR_SIZE; i = i + 1) begin
            if (data_out[i] !== 0) begin
                $error("Test 3 failed at index %0d: expected 0, got %0d", 
                      i, data_out[i]);
            end else begin
                $display("  Index %0d: %0d -> %0d (PASS)", 
                        i, test_vectors_neg[i], data_out[i]);
            end
        end
        
        // ===== 测试4: 无效输入 =====
        $display("\n[Test 4] Invalid input (valid_in=0)");
        for (integer i = 0; i < VECTOR_SIZE; i = i + 1) begin
            data_in[i] = test_vectors_pos[i];
        end
        valid_in = 1'b0;
        #10;
        
        // 输出应保持为0（或上一值）
        // 这取决于设计，这里只打印观察
        
        // 完成测试
        #10;
        $display("\n[INFO] All tests completed!");
        $finish;
    end
    
    // 波形记录
    initial begin
        $dumpfile("test_relu.vcd");
        $dumpvars(0, test_relu);
    end
    
endmodule
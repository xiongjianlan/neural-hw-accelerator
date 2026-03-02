# Neural Network Hardware Accelerator

A complete Verilog implementation of CNN hardware modules for edge AI applications.

## 🚀 Overview

This project implements a full CNN processing pipeline in hardware (Verilog), including:
- **Convolution Layer** (3x3 with 3-stage pipeline)
- **ReLU Activation Layer**
- **Max Pooling Layer** (2x2)
- **Weight Memory System**
- **Complete CNN Processing Chain**

## 📁 Project Structure

```
neural_hw/
├── src/                    # Source Verilog files
│   ├── convolution_3x3.v      # 3x3 convolution layer
│   ├── simple_relu.v          # ReLU activation
│   ├── max_pooling_2x2.v      # 2x2 max pooling
│   ├── conv_relu_chain.v      # Conv + ReLU chain
│   ├── cnn_processing_chain.v # Full CNN pipeline
│   └── simple_weight_mem.v    # Weight storage system
├── test/                  # Testbenches
│   ├── test_simple_relu.v
│   ├── test_max_pooling.v
│   ├── verify_conv_timing.v
│   ├── test_simple_cnn_chain.v
│   └── complete_weight_test.v
├── scripts/              # Utility scripts
│   └── measure_timing.sh
├── performance_analysis.md  # Performance analysis
└── timing_power_analysis.md # Timing & power analysis
```

## 🔧 Features

### 1. **Convolution Layer (3x3)**
- 9 parallel multipliers
- 3-stage pipelined adder tree
- Configurable data width (default: 16-bit)
- Signed integer arithmetic
- Valid signal handshaking

### 2. **ReLU Activation**
- Simple max(0, x) implementation
- Single clock cycle latency
- Configurable data width

### 3. **Max Pooling (2x2)**
- 2x2 window maximum calculation
- Single clock cycle latency
- Handles signed integers correctly

### 4. **Weight Memory System**
- Stores 9 weights (3x3 kernel)
- Supports multiple kernel types:
  - Sobel edge detection
  - Average pooling
  - Gaussian blur
  - Sharpen filter
- Dynamic loading with ready signal

### 5. **Complete CNN Chain**
- Conv (3 cycles) → ReLU (1 cycle) → Buffer → Pooling (1 cycle)
- Total pipeline: ~9 clock cycles
- Throughput: 11.1M windows/sec @ 100MHz

## 📊 Performance Metrics

### Timing @ 100MHz
- **Convolution**: 3 cycles (30ns)
- **ReLU**: 1 cycle (10ns)
- **Pooling**: 1 cycle (10ns)
- **Total pipeline**: ~9 cycles (90ns)

### Power Consumption (28nm process)
- **Static power**: 1.6 mW
- **Dynamic power**: 33 mW
- **Total power**: 34.6 mW

### Area Estimation (28nm)
- **Logic cells**: ~1,280
- **Total area**: ~0.0025 mm²
- **Memory**: 400 bits (tiny)

### Energy Efficiency
- **Operations per window**: 21 ops
- **Throughput**: 233M ops/sec @ 100MHz
- **Efficiency**: 6.7 GOPS/W

## 🛠️ Getting Started

### Prerequisites
- Icarus Verilog (`iverilog`)
- GTKWave (for waveform viewing)
- Yosys (for synthesis)
- Verilator (optional, for linting)

### Simulation
```bash
# Test ReLU layer
iverilog -o relu_test.vvp test/test_simple_relu.v src/simple_relu.v
vvp relu_test.vvp

# Test convolution timing
iverilog -o conv_test.vvp test/verify_conv_timing.v src/convolution_3x3.v
vvp conv_test.vvp

# Test max pooling
iverilog -o pool_test.vvp test/test_max_pooling.v src/max_pooling_2x2.v
vvp pool_test.vvp
```

### Synthesis with Yosys
```bash
yosys -p "read_verilog src/max_pooling_2x2.v; hierarchy -check -top max_pooling_2x2; synth; stat"
```

## 🎯 Use Cases

1. **Edge AI Devices** - Low power consumption for battery-powered devices
2. **Real-time Video Processing** - ~11 fps for 640x480 images
3. **IoT Sensors** - Tiny area, low cost
4. **Educational Platform** - Complete open-source hardware CNN

## 📈 Results

### Verification Status
- ✅ ReLU layer: All tests pass
- ✅ Max pooling: All tests pass
- ✅ Convolution: Basic timing verified
- ✅ CNN chain: Simplified integration working
- ✅ Weight system: 4 kernel types supported

### Key Achievements
1. **Functional RTL** - All core CNN components implemented
2. **Timing Closure** - ~9ns critical path @ 100MHz
3. **Power Optimized** - 34.6 mW total power
4. **Area Efficient** - 0.0025 mm² @ 28nm
5. **Modular Design** - Easy to extend and integrate

## 🔮 Future Work

### Short-term
1. FPGA prototype implementation
2. Python software interface
3. Real image data validation

### Long-term
1. Support more layer types (FC, BatchNorm)
2. 8-bit/4-bit quantization
3. System integration (DDR, DMA)
4. Model compilation toolchain

## 📝 Documentation

See the detailed analysis documents:
- [Performance Analysis](performance_analysis.md)
- [Timing & Power Analysis](timing_power_analysis.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new features
4. Submit a pull request

## 💝 Support This Project

### 支持这个开源项目 ❤️

这个项目是**完全免费和开源的**，采用MIT许可证。如果你觉得这个项目有帮助，并愿意支持它的持续发展，欢迎通过以下方式支持：

#### 🤝 如何支持：

- ⭐ **给仓库点星** - 这是最好的支持方式！
- 🗣️ **分享项目** - 让更多人知道这个开源硬件项目
- 📝 **贡献代码** - 提交改进、修复或新功能
- 🐛 **报告问题** - 帮助项目变得更好

#### 💰 自愿的经济支持：
如果你愿意提供经济支持，我们将深表感谢（但完全自愿）。每一份支持都有助于：
- 🛠️ 维护和优化代码库
- 📚 创建更多教程和教育资源
- 🔬 开发新功能和性能优化
- 🆓 保持项目的完全免费和开源

**详细信息请查看 [SUPPORT.md](SUPPORT.md) 文件。**

*感谢你的每一份支持与鼓励！*

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgements

- OpenClaw AI assistant for code generation and testing
- Verilog community for best practices
- Academic papers on hardware neural networks

---

**Author**: Your Name  
**Contact**: your.email@example.com  
**Version**: 1.0.0  
**Date**: March 2026
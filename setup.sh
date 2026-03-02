#!/bin/bash
# Setup script for Neural Network Hardware Accelerator

echo "========================================="
echo "Neural Network Hardware Accelerator Setup"
echo "========================================="
echo ""

# Check for required tools
echo "Checking required tools..."
echo ""

REQUIRED_TOOLS=("iverilog" "yosys" "gtkwave")
MISSING_TOOLS=()

for tool in "${REQUIRED_TOOLS[@]}"; do
    if command -v $tool &> /dev/null; then
        echo "✓ $tool installed"
    else
        echo "✗ $tool not found"
        MISSING_TOOLS+=($tool)
    fi
done

echo ""

if [ ${#MISSING_TOOLS[@]} -ne 0 ]; then
    echo "The following tools are missing:"
    for tool in "${MISSING_TOOLS[@]}"; do
        echo "  - $tool"
    done
    echo ""
    echo "Installation commands:"
    echo "  Ubuntu/Debian: sudo apt-get install iverilog gtkwave yosys"
    echo "  macOS: brew install icarus-verilog gtkwave yosys"
    echo "  CentOS/RHEL: sudo yum install iverilog gtkwave yosys"
    echo ""
    exit 1
fi

# Create directory structure
echo "Creating directory structure..."
mkdir -p build
mkdir -p sim/waveforms
echo "✓ Directories created"
echo ""

# Test compilation
echo "Testing compilation..."
echo ""

echo "1. Testing ReLU module..."
iverilog -o build/relu_test.vvp test/test_simple_relu.v src/simple_relu.v 2>&1
if [ $? -eq 0 ]; then
    echo "  ✓ ReLU compiles successfully"
else
    echo "  ✗ ReLU compilation failed"
    exit 1
fi

echo ""
echo "2. Testing convolution module..."
iverilog -o build/conv_test.vvp test/verify_conv_timing.v src/convolution_3x3.v 2>&1
if [ $? -eq 0 ]; then
    echo "  ✓ Convolution compiles successfully"
else
    echo "  ✗ Convolution compilation failed"
    exit 1
fi

echo ""
echo "3. Testing pooling module..."
iverilog -o build/pool_test.vvp test/test_max_pooling.v src/max_pooling_2x2.v 2>&1
if [ $? -eq 0 ]; then
    echo "  ✓ Pooling compiles successfully"
else
    echo "  ✗ Pooling compilation failed"
    exit 1
fi

echo ""
echo "4. Testing synthesis with Yosys..."
yosys -Q -T -p "read_verilog src/max_pooling_2x2.v; hierarchy -check -top max_pooling_2x2; synth; stat" 2>&1 | tail -5 > /dev/null
if [ $? -eq 0 ]; then
    echo "  ✓ Synthesis works"
else
    echo "  ✗ Synthesis failed"
    exit 1
fi

echo ""
echo "========================================="
echo "Setup completed successfully! 🎉"
echo ""
echo "Next steps:"
echo "1. Run tests:"
echo "   ./scripts/run_tests.sh"
echo ""
echo "2. View performance analysis:"
echo "   cat performance_analysis.md"
echo ""
echo "3. Run timing measurements:"
echo "   ./scripts/measure_timing.sh"
echo ""
echo "4. Explore the source code in src/"
echo "========================================="
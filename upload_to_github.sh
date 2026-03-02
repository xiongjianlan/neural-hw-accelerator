#!/bin/bash
# Script to upload Neural Network Hardware Accelerator to GitHub

echo "================================================"
echo "Neural Network Hardware Accelerator - GitHub Upload"
echo "================================================"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install git first."
    echo "   Ubuntu/Debian: sudo apt-get install git"
    echo "   macOS: brew install git"
    echo "   CentOS/RHEL: sudo yum install git"
    exit 1
fi

# Display current status
echo "📁 Project directory: $(pwd)"
echo "📊 Files ready for upload:"
echo ""

# Show file summary
echo "Source files (src/):"
ls -la src/*.v | wc -l | xargs echo "  Verilog modules:"
echo ""

echo "Test files (test/):"
ls -la test/*.v | wc -l | xargs echo "  Testbenches:"
echo ""

echo "Documentation:"
ls -la *.md | wc -l | xargs echo "  Markdown files:"
echo ""

echo "Scripts:"
ls -la scripts/*.sh setup.sh | wc -l | xargs echo "  Shell scripts:"
echo ""

# Check if already a git repository
if [ -d ".git" ]; then
    echo "✅ Git repository already initialized"
    echo "📝 Current commit:"
    git log --oneline -1
    echo ""
else
    echo "❓ Not a git repository. Initializing..."
    git init
    git add .
    git commit -m "Initial commit: Complete CNN hardware accelerator"
    echo "✅ Git repository initialized"
fi

echo "================================================"
echo "📋 GitHub Upload Instructions"
echo "================================================"
echo ""
echo "Follow these steps to upload to GitHub:"
echo ""
echo "1. Create a new repository on GitHub:"
echo "   👉 https://github.com/new"
echo ""
echo "2. Repository details:"
echo "   - Name: neural-hw-accelerator"
echo "   - Description: Complete CNN hardware accelerator in Verilog"
echo "   - Visibility: Public (recommended)"
echo "   - DO NOT initialize with README, .gitignore, or license"
echo ""
echo "3. After creating repository, run these commands:"
echo "-----------------------------------------------"
echo "git remote add origin https://github.com/YOUR_USERNAME/neural-hw-accelerator.git"
echo "git branch -M main"
echo "git push -u origin main"
echo "-----------------------------------------------"
echo ""
echo "Alternative (if GitHub CLI is installed):"
echo "-----------------------------------------"
echo "gh repo create neural-hw-accelerator \\"
echo "  --public \\"
echo "  --description=\"Complete CNN hardware accelerator in Verilog\" \\"
echo "  --source=. \\"
echo "  --remote=origin \\"
echo "  --push"
echo "-----------------------------------------"
echo ""
echo "================================================"
echo "🔗 Quick Links After Upload"
echo "================================================"
echo ""
echo "After uploading, your repository will be available at:"
echo "👉 https://github.com/YOUR_USERNAME/neural-hw-accelerator"
echo ""
echo "Visitors can:"
echo "1. Clone: git clone https://github.com/YOUR_USERNAME/neural-hw-accelerator"
echo "2. Setup: cd neural-hw-accelerator && ./setup.sh"
echo "3. Test: ./scripts/run_tests.sh"
echo ""
echo "================================================"
echo "📊 Project Statistics"
echo "================================================"
echo ""
echo "Total files: $(find . -type f -name "*.v" -o -name "*.md" -o -name "*.sh" | wc -l)"
echo "Verilog source: $(find src -name "*.v" | wc -l) files"
echo "Testbenches: $(find test -name "*.v" | wc -l) files"
echo "Documentation: $(find . -name "*.md" | wc -l) files"
echo ""
echo "Performance highlights:"
echo "- Power: 34.6 mW @ 28nm"
echo "- Area: 0.0025 mm² @ 28nm"
echo "- Efficiency: 6.7 GOPS/W"
echo "- Throughput: 11.1M windows/sec @ 100MHz"
echo ""
echo "================================================"
echo "🚀 Ready for GitHub Upload!"
echo "================================================"
echo ""
echo "Next steps:"
echo "1. Create GitHub repository (web interface)"
echo "2. Run the push commands above"
echo "3. Share your hardware AI accelerator with the world!"
echo ""
echo "Need help? Check DEPLOYMENT.md for detailed instructions."
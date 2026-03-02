#!/bin/bash
# Auto Upload Script for Neural Network Hardware Accelerator

echo "================================================"
echo "🤖 Auto GitHub Upload Assistant"
echo "================================================"
echo ""

# Configuration
REPO_NAME="neural-hw-accelerator"
REPO_DESC="Complete CNN hardware accelerator in Verilog"

# Check if in project directory
if [ ! -f "README.md" ] || [ ! -d "src" ]; then
    echo "❌ Error: Not in the neural-hw-accelerator project directory"
    echo "Please run: cd /root/.openclaw/workspace/neural_hw"
    exit 1
fi

echo "📋 Project detected:"
echo "  Directory: $(pwd)"
echo "  Files ready: $(find . -type f -name "*.v" -o -name "*.md" -o -name "*.sh" | wc -l)"
echo ""

# Method selection
echo "🔐 Select upload method:"
echo "  1) GitHub CLI (gh) - Recommended"
echo "  2) Personal Access Token"
echo "  3) SSH Key"
echo "  4) Manual upload instructions"
echo ""
read -p "Enter choice (1-4): " method

case $method in
    1)
        echo ""
        echo "🔧 Method 1: GitHub CLI"
        echo "-----------------------"
        
        # Check if gh is installed
        if ! command -v gh &> /dev/null; then
            echo "GitHub CLI not found. Installing..."
            
            # Detect OS and install
            if [ -f /etc/debian_version ]; then
                # Debian/Ubuntu
                sudo apt-get update
                sudo apt-get install gh -y
            elif [ -f /etc/redhat-release ]; then
                # RHEL/CentOS
                sudo yum install gh -y
            elif [ "$(uname)" == "Darwin" ]; then
                # macOS
                brew install gh
            else
                echo "Please install GitHub CLI manually:"
                echo "  https://github.com/cli/cli#installation"
                exit 1
            fi
        fi
        
        echo "✅ GitHub CLI installed"
        echo ""
        echo "📝 Login to GitHub (will open browser):"
        gh auth login
        
        echo ""
        echo "🚀 Creating repository..."
        gh repo create $REPO_NAME \
            --public \
            --description="$REPO_DESC" \
            --source=. \
            --remote=origin \
            --push
        
        echo ""
        echo "✅ Repository created and pushed!"
        ;;
    
    2)
        echo ""
        echo "🔑 Method 2: Personal Access Token"
        echo "---------------------------------"
        
        read -p "Enter your GitHub username: " username
        read -sp "Enter your GitHub Personal Access Token: " token
        echo ""
        
        # Create remote URL with token
        remote_url="https://${username}:${token}@github.com/${username}/${REPO_NAME}.git"
        
        echo ""
        echo "🔄 Setting up remote..."
        git remote add origin $remote_url
        
        echo "🚀 Pushing to GitHub..."
        git push -u origin main
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "✅ Success! Repository uploaded to:"
            echo "   https://github.com/${username}/${REPO_NAME}"
        else
            echo ""
            echo "❌ Push failed. Please check your token and try again."
        fi
        ;;
    
    3)
        echo ""
        echo "🔐 Method 3: SSH Key"
        echo "-------------------"
        
        # Check for SSH key
        if [ ! -f ~/.ssh/id_ed25519.pub ] && [ ! -f ~/.ssh/id_rsa.pub ]; then
            echo "No SSH key found. Generating new key..."
            read -p "Enter your email for SSH key: " ssh_email
            ssh-keygen -t ed25519 -C "$ssh_email" -f ~/.ssh/id_ed25519 -N ""
            
            echo ""
            echo "🔑 Your new SSH public key:"
            echo "----------------------------------------"
            cat ~/.ssh/id_ed25519.pub
            echo "----------------------------------------"
            echo ""
            echo "📋 Please add this key to GitHub:"
            echo "1. Go to https://github.com/settings/keys"
            echo "2. Click 'New SSH key'"
            echo "3. Paste the key above"
            echo "4. Click 'Add SSH key'"
            echo ""
            read -p "Press Enter after adding the key to GitHub..."
        fi
        
        read -p "Enter your GitHub username: " username
        
        echo ""
        echo "🔄 Setting up SSH remote..."
        git remote add origin git@github.com:${username}/${REPO_NAME}.git
        
        echo "🚀 Pushing to GitHub..."
        git push -u origin main
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "✅ Success! Repository uploaded to:"
            echo "   https://github.com/${username}/${REPO_NAME}"
        else
            echo ""
            echo "❌ Push failed. Please check SSH setup and try again."
        fi
        ;;
    
    4)
        echo ""
        echo "📖 Method 4: Manual Instructions"
        echo "------------------------------"
        echo ""
        echo "Follow these steps manually:"
        echo ""
        echo "1. Create repository on GitHub:"
        echo "   👉 https://github.com/new"
        echo ""
        echo "2. Repository details:"
        echo "   - Name: neural-hw-accelerator"
        echo "   - Description: Complete CNN hardware accelerator in Verilog"
        echo "   - Public repository"
        echo "   - DO NOT initialize with README"
        echo ""
        echo "3. After creation, run these commands:"
        echo "--------------------------------------"
        echo "cd $(pwd)"
        echo "git remote add origin https://github.com/YOUR_USERNAME/neural-hw-accelerator.git"
        echo "git branch -M main"
        echo "git push -u origin main"
        echo "--------------------------------------"
        echo ""
        echo "4. If asked for credentials:"
        echo "   - Username: your GitHub username"
        echo "   - Password: your GitHub Personal Access Token"
        echo ""
        echo "5. Access your repository at:"
        echo "   https://github.com/YOUR_USERNAME/neural-hw-accelerator"
        ;;
    
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "================================================"
echo "🎉 Upload Complete!"
echo "================================================"
echo ""
echo "Your neural network hardware accelerator is now on GitHub!"
echo ""
echo "Next steps:"
echo "1. Share the repository link"
echo "2. Run tests: ./scripts/run_tests.sh"
echo "3. Check performance: ./scripts/measure_timing.sh"
echo "4. Star the repository to show support!"
echo ""
echo "Need help? Check README.md for project details."
echo "================================================"
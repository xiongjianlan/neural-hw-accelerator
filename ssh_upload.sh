#!/bin/bash
# SSH方式上传到GitHub

echo "🔐 SSH方式上传到GitHub"
echo "====================="

USERNAME="xiongjianlan"
REPO="neural-hw-accelerator"
EMAIL="user@example.com"  # 可以替换为你的邮箱

echo "📋 配置信息:"
echo "  GitHub用户: $USERNAME"
echo "  仓库: $REPO"
echo "  项目目录: $(pwd)"
echo ""

# Step 1: Generate SSH key if not exists
echo "🔑 步骤1: 检查/生成SSH密钥..."
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "  生成新的Ed25519 SSH密钥..."
    ssh-keygen -t ed25519 -C "$EMAIL" -f ~/.ssh/id_ed25519 -N "" -q
    echo "  ✅ SSH密钥生成完成"
else
    echo "  ✅ 已有SSH密钥"
fi

echo ""

# Step 2: Display public key for GitHub
echo "📋 步骤2: 你的SSH公钥 (请添加到GitHub):"
echo "----------------------------------------"
cat ~/.ssh/id_ed25519.pub
echo "----------------------------------------"
echo ""
echo "📝 请按以下步骤操作:"
echo "1. 复制上面的SSH公钥"
echo "2. 访问: https://github.com/settings/keys"
echo "3. 点击 'New SSH key'"
echo "4. 粘贴公钥，标题可填 'Neural-HW-Upload'"
echo "5. 点击 'Add SSH key'"
echo ""
read -p "完成后按Enter继续..." dummy

echo ""

# Step 3: Test SSH connection
echo "🔗 步骤3: 测试SSH连接..."
ssh -T git@github.com 2>&1 | grep -i "successfully authenticated"

if [ $? -eq 0 ]; then
    echo "  ✅ SSH连接成功！"
else
    echo "  ⚠️  SSH连接测试失败，但继续尝试..."
    # Add GitHub to known hosts
    ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null
fi

echo ""

# Step 4: Setup git remote with SSH
echo "🔄 步骤4: 配置Git SSH远程..."
git remote remove origin 2>/dev/null
git remote add origin "git@github.com:${USERNAME}/${REPO}.git"

if [ $? -eq 0 ]; then
    echo "  ✅ SSH远程配置成功"
    echo "  远程地址: git@github.com:${USERNAME}/${REPO}.git"
else
    echo "  ❌ SSH远程配置失败"
    exit 1
fi

echo ""

# Step 5: Push via SSH
echo "🚀 步骤5: 通过SSH推送代码..."
echo "  分支: main"
echo "  提交: $(git log --oneline -1)"
echo ""

echo "正在推送，请稍候..."
echo "----------------------------------------"

# Try push with SSH
timeout 30 git push -u origin main 2>&1 | tee /tmp/push_output.txt

PUSH_STATUS=${PIPESTATUS[0]}

echo "----------------------------------------"
echo ""

if [ $PUSH_STATUS -eq 0 ]; then
    echo "🎉 🎉 🎉 SSH推送成功！ 🎉 🎉 🎉"
    echo ""
    echo "🔗 你的GitHub仓库:"
    echo "   https://github.com/${USERNAME}/${REPO}"
    echo ""
    echo "📁 项目已包含:"
    echo "  ✅ 8个Verilog源文件"
    echo "  ✅ 13个测试文件"
    echo "  ✅ 6个详细文档"
    echo "  ✅ 3个实用脚本"
    echo ""
    echo "🚀 现在可以:"
    echo "   1. 访问 https://github.com/${USERNAME}/${REPO}"
    echo "   2. 克隆: git clone git@github.com:${USERNAME}/${REPO}.git"
    echo "   3. 测试: ./setup.sh && ./scripts/run_tests.sh"
elif [ $PUSH_STATUS -eq 124 ]; then
    echo "⏱️  推送超时，但可能已部分成功"
    echo ""
    echo "📋 请手动检查:"
    echo "   1. 访问 https://github.com/${USERNAME}/${REPO}"
    echo "   2. 如果仓库为空，请手动推送:"
    echo "      git push -u origin main"
    echo ""
    echo "🔑 SSH公钥已添加到你的账户"
else
    echo "❌ SSH推送失败 (状态码: $PUSH_STATUS)"
    echo ""
    echo "📋 错误详情:"
    tail -10 /tmp/push_output.txt 2>/dev/null
    echo ""
    echo "🔧 备选方案:"
    echo "   1. 使用HTTPS方式:"
    echo "      git remote set-url origin https://github.com/${USERNAME}/${REPO}.git"
    echo "      git push -u origin main"
    echo "   2. 或使用GitHub网页界面上传"
fi

# Cleanup
rm -f /tmp/push_output.txt

echo ""
echo "🏁 SSH上传过程完成"
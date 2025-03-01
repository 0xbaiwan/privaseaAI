#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_message() {
    echo -e "${GREEN}$1${NC}"
}

# 检查命令执行状态
check_status() {
    if [ $? -eq 0 ]; then
        print_message "✓ $1 成功"
    else
        echo -e "${RED}✗ $1 失败${NC}"
        exit 1
    fi
}

# 安装依赖项
install_dependencies() {
    print_message "\n正在安装依赖项..."
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt install curl iptables build-essential git wget jq make gcc nano automake autoconf tmux htop pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip -y
    check_status "依赖项安装"
}

# 安装 Docker
install_docker() {
    print_message "\n正在安装 Docker..."
    sudo apt update -y && sudo apt upgrade -y
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update -y && sudo apt upgrade -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    check_status "Docker 安装"
}

# 设置 Privasea 节点
setup_privasea_node() {
    print_message "\n正在设置 Privasea 节点..."
    
    # 拉取 Docker 镜像
    print_message "正在拉取 Docker 镜像..."
    docker pull privasea/acceleration-node-beta
    check_status "Docker 镜像拉取"

    # 创建配置目录
    print_message "正在创建配置目录..."
    mkdir -p $HOME/privasea/config && cd $HOME/privasea
    check_status "配置目录创建"

    # 生成密钥库
    print_message "\n即将生成密钥库，请注意："
    echo -e "${YELLOW}1. 您需要输入并记住密钥库密码"
    echo -e "2. 请保存生成的密钥详细信息"
    echo -e "3. 按回车继续...${NC}"
    read

    docker run -it -v "$HOME/privasea/config:/app/config" privasea/acceleration-node-beta:latest ./node-calc new_keystore
    
    # 重命名密钥库文件
    cd $HOME/privasea/config
    mv UTC--* wallet_keystore
    check_status "密钥库设置"

    print_message "\n请完成以下步骤："
    echo -e "${YELLOW}1. 访问 https://deepsea-beta.privasea.ai/privanetixNode"
    echo -e "2. 连接您的 EVM 奖励钱包"
    echo -e "3. 点击「立即设置」并输入您的节点地址"
    echo -e "4. 完成后按回车继续...${NC}"
    read

    # 启动节点
    print_message "\n请输入您之前设置的密钥库密码："
    read -s password
    
    docker run -d -v "$HOME/privasea/config:/app/config" \
        -e KEYSTORE_PASSWORD=$password \
        privasea/acceleration-node-beta:latest
    check_status "节点启动"

    # 显示容器日志
    container_id=$(docker ps -q --filter ancestor=privasea/acceleration-node-beta:latest)
    print_message "\n节点已启动！容器ID: $container_id"
    print_message "\n查看日志请运行: docker logs -f $container_id"
}

# 主菜单
show_menu() {
    clear
    echo -e "${GREEN}=== Privasea 节点安装程序 ===${NC}"
    echo "1) 安装节点 (完整安装)"
    echo "2) 仅安装依赖项"
    echo "3) 仅安装 Docker"
    echo "4) 仅设置 Privasea 节点"
    echo "5) 查看节点日志"
    echo "0) 退出"
    echo
    echo -n "请选择: "
}

# 主循环
while true; do
    show_menu
    read opt
    case $opt in
        1)
            install_dependencies
            install_docker
            setup_privasea_node
            ;;
        2)
            install_dependencies
            ;;
        3)
            install_docker
            ;;
        4)
            setup_privasea_node
            ;;
        5)
            container_id=$(docker ps -q --filter ancestor=privasea/acceleration-node-beta:latest)
            if [ -n "$container_id" ]; then
                docker logs -f $container_id
            else
                echo -e "${RED}未找到运行中的节点容器${NC}"
            fi
            ;;
        0)
            exit 0
            ;;
        *)
            echo -e "${RED}无效选项${NC}"
            ;;
    esac
    echo
    echo -n "按回车返回主菜单..."
    read
done 
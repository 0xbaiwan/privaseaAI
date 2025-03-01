# 设置并运行 Privanetix 节点
按照此指南设置并运行 Privanetix 节点。
* 总供应量的 1% 分配给 Privasea 节点贡献者。
* 排行榜将在 30 天后结束。
* 节点排行榜仅基于设备性能和节点正常运行时间；质押的代币不会影响排名。
* 确保在运行节点后加入 [ImHuman 应用程序](https://github.com/0xbaiwan/privaseaAI/blob/main/README.md#8-join-imhuman-application-built-by-privasea)。

![image](https://github.com/user-attachments/assets/749bd88b-94bf-4cea-98b8-342a4e2124ab)

## 系统要求
您的节点层级取决于您的硬件规格。您可以在最低配置的系统上运行节点。

![image](https://github.com/user-attachments/assets/5dcf9fc7-bd82-44c5-a3cb-7a3b68cb07dd)

# 安装方式

## 方式一：使用自动安装脚本（推荐）

1. 下载安装脚本：
```bash
wget -O install.sh https://raw.githubusercontent.com/0xbaiwan/privaseaAI/main/install.sh
```

2. 设置脚本权限：
```bash
chmod +x install.sh
```

3. 运行安装脚本：
```bash
./install.sh
```

4. 在菜单中选择选项 "1" 进行完整安装。安装过程将自动执行以下步骤：

   a. 安装所需依赖
   b. 安装并配置 Docker
   c. 设置 Privasea 节点：
      - 拉取 Docker 镜像
      - 创建配置目录
      - 生成密钥库（需要您输入并保存密码）
      - 启动节点

5. 节点设置过程中需要您进行的操作：
   - 输入并记住密钥库密码
   - 保存生成的密钥详细信息
   - 访问 [仪表板](https://deepsea-beta.privasea.ai/privanetixNode) 连接 EVM 钱包
   - 在仪表板中输入节点地址进行绑定

6. 完成节点设置后，您需要：
   - 从 [水龙头](https://deepsea-beta.privasea.ai/deepSeaFaucet) 获取 1 $TPRAI
   - 在节点详情页面质押代币

其他可用的菜单选项：
- 选项 2：仅安装依赖项
- 选项 3：仅安装 Docker
- 选项 4：仅设置 Privasea 节点
- 选项 5：查看节点日志
- 选项 0：退出程序

注意事项：
- 安装过程中需要 root 权限，请确保有 sudo 权限
- 请妥善保管密钥库密码和节点地址
- 建议在安装完成后使用选项 5 查看节点日志，确认节点正常运行

## 方式二：手动安装

### 1. 安装依赖项
```bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev  -y
```

### 2. 安装 Docker
```bash
sudo apt update -y && sudo apt upgrade -y
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y && sudo apt upgrade -y

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 测试 Docker
sudo docker run hello-world
```

### 3. 拉取 Privasea Docker 镜像
```bash
docker pull privasea/acceleration-node-beta
```

### 4. 节点程序配置
**1. 创建目录**
```bash
mkdir -p privasea/config && cd privasea
```

**2. 获取密钥库文件**
```bash
docker run -it -v "$HOME/privasea/config:/app/config"  \
privasea/acceleration-node-beta:latest ./node-calc new_keystore
```
* 为您的密钥库文件输入密码。

![image](https://github.com/user-attachments/assets/417187be-8d51-4cfc-b90f-1e4c1f5225e8)

* 保存密钥详细信息。
* 将生成的 `UTC--2025...` 文件保存到本地电脑的 `/root/privasea/config/` 文件夹中。

**3. 将密钥库文件重命名为 `wallet_keystore`：**
```bash
mv $HOME/privasea/config/UTC--*  ./wallet_keystore 
```

### 5. 将节点地址与奖励地址关联
**1. 将 EVM 奖励钱包连接到 [仪表板](https://deepsea-beta.privasea.ai/privanetixNode) 以将您的节点密钥库与奖励钱包绑定**
* 您可以使用与节点密钥不同的钱包作为奖励钱包。

**2. 点击"立即设置"**

![image](https://github.com/user-attachments/assets/727c834e-bbc4-47fd-acda-35795ce380b6)

**3. 输入您之前保存的节点地址并设置您的节点**

![image](https://github.com/user-attachments/assets/82885607-9e5f-4312-9580-3595d2eced3d)

### 6. 运行节点
**1. 输入以下命令启动您的节点**
* 将 `KEYSTORE_PASSWORD=` 中的 `password` 替换为您的密钥库密码，然后执行该命令。
```bash
docker run  -d   -v "$HOME/privasea/config:/app/config" \
  -e KEYSTORE_PASSWORD=password  \
  privasea/acceleration-node-beta:latest
```

**2. 查看日志**
```bash
docker ps -a
```
* 将 `CONTAINER_ID` 替换为 Privasea Docker 的容器 ID。
```bash
docker logs -f CONTAINER_ID
```

### 7. 为您的节点质押
**1. 在 [水龙头](https://deepsea-beta.privasea.ai/deepSeaFaucet) 处为连接到仪表板的 EVM 钱包获取水龙头**
* 您将在 Arbitrum Sepolia 上收到 1 $TPRAI。
* 不要使用多个钱包领取水龙头，最终奖励基于节点正常运行时间和性能，而不是您质押的代币。

**2. 点击您的节点"详情"，并在其上质押 1 $TPRAI**

![Screenshot_600](https://github.com/user-attachments/assets/8dea9953-99b7-4546-bbd8-1f1dff526215)

**3. 几小时后，预质押将变为质押状态，您将开始获得奖励**

![image](https://github.com/user-attachments/assets/5d73dd2d-3b3a-48fd-b428-5015dbaaaee8)

#

# 8. 加入 Privasea 构建的 ImHuman 应用程序
总供应量的 10% 分配给 ImHuman 应用程序贡献者。
* 您可能需要在 TGE 之前将节点的奖励与 ImHuman 应用程序关联。

1. 下载移动应用：[https://privasea.ai/download-app](https://privasea.ai/download-app)
2. 创建账户。
3. 输入助力码：`TGd56WC`。
4. 将 Arbitrum ETH 发送到您的应用钱包。
5. 通过扫描面部以 0.0016 ETH 的价格铸造您的人性证明 NFT。
6. 在应用中完成其他任务并领取 XP。

![image](https://github.com/user-attachments/assets/8ebe0f30-73e6-4423-ac53-5f47e18fc78c)

---

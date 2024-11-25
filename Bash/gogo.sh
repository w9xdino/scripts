#!/bin/bash

# 初始化计数器
i=1

# 提示用户输入 IP 地址列表
echo "请输入 IP 地址，每行一个，输入完毕后按 Ctrl+D（Linux/macOS）或 Ctrl+Z（Windows）结束："

# 动态读取用户输入的 IP 地址列表
ip_list=()
while IFS= read -r ip; do
    # 跳过空行或注释
    [[ -z "$ip" || "$ip" =~ ^# ]] && continue
    ip_list+=("$ip")
done

# 检查是否有输入 IP
if [[ ${#ip_list[@]} -eq 0 ]]; then
    echo "未输入任何 IP 地址，退出..."
    exit 1
fi

# 获取 IP 总数
j=${#ip_list[@]}

# 计数器函数
counter() {
    echo -e "\033[32mCompleted $i/$j\033[0m"
    let i++
}

# 提示用户选择操作
echo "请选择要执行的操作:"
echo "1) 卸载并重新安装 bnxt-en-dkms，并重启"
echo "2) 设置 PXE 启动并循环电源"
echo "3) 停止 authzd-agent 服务"
echo "4) 执行 ipmitool mc reset cold（需要用户名和密码）"
read -p "输入选项 (1, 2, 3 或 4): " option

# 检查输入是否合法
if [[ "$option" != "1" && "$option" != "2" && "$option" != "3" && "$option" != "4" ]]; then
    echo "无效选项，退出..."
    exit 1
fi

# 遍历 IP 列表并执行相应操作
for ip in "${ip_list[@]}"; do
    echo "Processing $ip..."

    case $option in
        1)
            ssh -o StrictHostKeyChecking=no "$ip" \
            "apt purge -y bnxt-en-dkms; apt-get install -y bnxt-en-dkms; reboot" < /dev/null
            ;;
        2)
            ssh -o StrictHostKeyChecking=no "$ip" \
            "ipmitool chassis bootdev pxe; ipmitool chassis power cycle" < /dev/null
            ;;
        3)
            ssh -o StrictHostKeyChecking=no "$ip" \
            "systemctl stop authzd-agent" < /dev/null
            ;;
        4)
            sshpass -p "minios@123" ssh -o StrictHostKeyChecking=no root@"$ip" \
            "ipmitool mc reset cold" < /dev/null
            ;;
    esac

    counter
done

echo "所有任务完成！"


#!/bin/bash

# 初始化计数器
i=1

# 提示用户输入 IP 地址
echo -e "\033[33m请输入目标 IP 地址（每行一个，输入空行结束）：\033[0m"

# 从用户输入读取多行 IP，保存到数组
ip_list=()
while IFS= read -r ip; do
    [[ -z "$ip" ]] && break  # 遇到空行结束输入
    ip_list+=("$ip")
done

# 检查是否输入了 IP
if [[ ${#ip_list[@]} -eq 0 ]]; then
    echo -e "\033[31m错误: 未输入任何 IP！\033[0m"
    exit 1
fi

# 获取总 IP 数量
j=${#ip_list[@]}

# 计数器函数
counter() {
    echo -e "\033[32m[Completed $i/$j]\033[0m\n"
    let i++
}

# 提示用户选择操作（改为黄色）
echo -e "\033[33m请选择要执行的操作:\033[0m"
echo "1) 卸载并重新安装 bnxt-en-dkms，并重启"
echo "2) 设置 PXE 启动并循环电源"
echo "3) 停止 authzd-agent 服务"
echo "4) minios 操作"
read -p "输入选项 (1, 2, 3 或 4): " option

# 检查输入是否合法
if [[ "$option" != "1" && "$option" != "2" && "$option" != "3" && "$option" != "4" ]]; then
    echo -e "\033[31m无效选项，退出...\033[0m"
    exit 1
fi

# 如果用户选择了选项 4，提示子选项（改为黄色）
if [[ "$option" == "4" ]]; then
    echo -e "\033[33m请选择具体的子操作:\033[0m"
    echo "1) 重置主板管理控制器 (ipmitool mc reset cold)"
    echo "2) 设置 PXE 启动并循环电源 (ipmitool chassis bootdev pxe; ipmitool chassis power cycle)"
    read -p "输入子选项 (1 或 2): " sub_option

    # 检查子选项输入是否合法
    if [[ "$sub_option" != "1" && "$sub_option" != "2" ]]; then
        echo -e "\033[31m无效子选项，退出...\033[0m"
        exit 1
    fi
fi

# 遍历 IP 并执行相应操作
for ip in "${ip_list[@]}"; do
    echo -e "\n\033[36m===============================\033[0m"
    echo -e "\033[33mProcessing $ip...\033[0m"
    echo -e "\033[36m===============================\033[0m\n"

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
            case $sub_option in
                1)
                    echo -e "\033[32m[执行操作: 重置主板管理控制器]\033[0m"
                    sshpass -p "minios@123" ssh -o StrictHostKeyChecking=no root@"$ip" \
                    "ipmitool mc reset cold" < /dev/null
                    ;;
                2)
                    echo -e "\033[32m[执行操作: 设置 PXE 启动并循环电源]\033[0m"
                    sshpass -p "minios@123" ssh -o StrictHostKeyChecking=no root@"$ip" \
                    "ipmitool chassis bootdev pxe; ipmitool chassis power cycle" < /dev/null
                    ;;
            esac
            ;;
    esac

    counter
done

echo -e "\033[32m所有任务完成！\033[0m"


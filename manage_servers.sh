#!/bin/bash

# Initialize the counter
i=1

# Prompt user to input IP addresses
echo -e "\033[33mPlease enter the target IP addresses (one per line, empty line to end):\033[0m"

# Read multiple IP addresses from user input and store them in an array
ip_list=()
while IFS= read -r ip; do
    [[ -z "$ip" ]] && break  # End input when an empty line is entered
    ip_list+=("$ip")
done

# Check if any IP addresses were entered
if [[ ${#ip_list[@]} -eq 0 ]]; then
    echo -e "\033[31mError: No IP addresses entered!\033[0m"
    exit 1
fi

# Get the total number of IP addresses
j=${#ip_list[@]}

# Counter function
counter() {
    echo -e "\033[32m[Completed $i/$j]\033[0m\n"
    let i++
}

# Prompt user to select an operation (changed to yellow)
echo -e "\033[33mPlease select the operation to perform:\033[0m"
echo "1) Uninstall and reinstall bnxt-en-dkms, then reboot"
echo "2) Set PXE boot and cycle power"
echo "3) Stop authzd-agent service"
echo "4) minios operations"
read -p "Enter option (1, 2, 3, or 4): " option

# Check if the input option is valid
if [[ "$option" != "1" && "$option" != "2" && "$option" != "3" && "$option" != "4" ]]; then
    echo -e "\033[31mInvalid option, exiting...\033[0m"
    exit 1
fi

# If the user selects option 4, prompt for a sub-option (changed to yellow)
if [[ "$option" == "4" ]]; then
    echo -e "\033[33mPlease select the sub-operation:\033[0m"
    echo "1) Reset motherboard management controller (ipmitool mc reset cold)"
    echo "2) Set PXE boot and cycle power (ipmitool chassis bootdev pxe; ipmitool chassis power cycle)"
    read -p "Enter sub-option (1 or 2): " sub_option

    # Check if the sub-option input is valid
    if [[ "$sub_option" != "1" && "$sub_option" != "2" ]]; then
        echo -e "\033[31mInvalid sub-option, exiting...\033[0m"
        exit 1
    fi
fi

# Iterate over the IPs and perform the corresponding operation
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
                    echo -e "\033[32m[Executing operation: Reset motherboard management controller]\033[0m"
                    sshpass -p "minios@123" ssh -o StrictHostKeyChecking=no root@"$ip" \
                    "ipmitool mc reset cold" < /dev/null
                    ;;
                2)
                    echo -e "\033[32m[Executing operation: Set PXE boot and cycle power]\033[0m"
                    sshpass -p "minios@123" ssh -o StrictHostKeyChecking=no root@"$ip" \
                    "ipmitool chassis bootdev pxe; ipmitool chassis power cycle" < /dev/null
                    ;;
            esac
            ;;
    esac

    counter
done

echo -e "\033[32mAll tasks completed!\033[0m"


#!/bin/bash

# 定义管道文件用于实时传递数据给 yad
PIPE=$(mktemp -u)
mkfifo "$PIPE"
exec 3<> "$PIPE"

# 后台进程：不断读取风扇转速并传给管道
(
    while true; do
        SPEED=$(grep "speed:" /proc/acpi/ibm/fan | awk '{print $2}')
        LEVEL=$(grep "level:" /proc/acpi/ibm/fan | awk '{print $2}')
        STATUS=$(grep "status:" /proc/acpi/ibm/fan | awk '{print $2}')
        
        # 将数据发送到 yad 列表
        # 格式：第一列图标，第二列属性，第三列数值
        echo "1: 当前转速: $SPEED RPM" >&3
        echo "1:⚙️ 运行模式: $LEVEL" >&3
        echo "1: 运行状态: $STATUS" >&3
        sleep 1
    done
) &
LOOP_PID=$!

# 退出时清理后台进程和管道
trap "kill $LOOP_PID; rm '$PIPE'" EXIT

# 显示界面
yad --title="ThinkPad 散热控制" \
    --window-icon=utilities-system-monitor \
    --width=350 --height=250 --center \
    --text="\n<span size='large'><b>系统状态监控</b></span>\n" \
    --list \
    --column="图标:IMG" --column="状态信息:TEXT" \
    --no-headers \
    --listen <&3 \
    --button="🚀 狂暴起飞!":1 \
    --button="🍃 恢复自动":2 \
    --button="关闭":0

choice=$?

# 执行命令
if [ $choice -eq 1 ]; then
    echo level disengaged | sudo tee /proc/acpi/ibm/fan > /dev/null
elif [ $choice -eq 2 ]; then
    echo level auto | sudo tee /proc/acpi/ibm/fan > /dev/null
fi

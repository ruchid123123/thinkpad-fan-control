#!/bin/bash

# 定义管道文件用于实时传递数据给 yad
PIPE=$(mktemp -u)
mkfifo "$PIPE"
exec 3<> "$PIPE"

# 后台进程：不断读取系统数据并精准更新表单字段
(
    while true; do
        SPEED=$(grep "speed:" /proc/acpi/ibm/fan | awk '{print $2}')
        LEVEL=$(grep "level:" /proc/acpi/ibm/fan | awk '{print $2}')
        STATUS=$(grep "status:" /proc/acpi/ibm/fan | awk '{print $2}')
        
        # 1:VALUE 表示更新表单中的第 1 个字段，以此类推
        echo "1:$SPEED RPM" >&3
        echo "2:$LEVEL" >&3
        echo "3:$STATUS" >&3
        
        sleep 1
    done
) &
LOOP_PID=$!

# 退出时清理
trap "kill $LOOP_PID; rm '$PIPE'" EXIT

# 显示界面：使用表单模式 (--form)
# :RO 表示只读字段 (Read-Only)，用户不能修改数值
yad --title="ThinkPad 散热控制" \
    --window-icon=utilities-system-monitor \
    --width=300 --height=200 --center \
    --text="\n<span size='large'><b>风扇状态实时监控</b></span>\n" \
    --form \
    --field="🌀 当前转速":RO \
    --field="⚙️ 运行模式":RO \
    --field="✅ 运行状态":RO \
    --listen <&3 \
    --button="🚀 狂暴起飞!":1 \
    --button="🍃 恢复自动":2 \
    --button="关闭":0

choice=$?

# 执行控制命令
if [ $choice -eq 1 ]; then
    echo level disengaged | sudo tee /proc/acpi/ibm/fan > /dev/null
elif [ $choice -eq 2 ]; then
    echo level auto | sudo tee /proc/acpi/ibm/fan > /dev/null
fi

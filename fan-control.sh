#!/bin/bash

# 定义管道文件用于实时传递数据给 yad
PIPE=$(mktemp -u)
mkfifo "$PIPE"
exec 3<> "$PIPE"

# 后台进程：不断读取风扇转速并传给管道
(
    while true; do
        # 从系统中抓取数据
        SPEED=$(grep "speed:" /proc/acpi/ibm/fan | awk '{print $2}')
        LEVEL=$(grep "level:" /proc/acpi/ibm/fan | awk '{print $2}')
        STATUS=$(grep "status:" /proc/acpi/ibm/fan | awk '{print $2}')
        
        # 使用 @clear 清空并重新发送数据
        # 使用标准 Emoji 代替特殊字体图标，避免乱码
        printf "@clear\n🚀 项目\n📊 数值\n" >&3
        printf "🌀 当前转速\n%s RPM\n" "$SPEED" >&3
        printf "⚙️ 运行模式\n%s\n" "$LEVEL" >&3
        printf "✅ 运行状态\n%s\n" "$STATUS" >&3
        
        sleep 1
    done
) &
LOOP_PID=$!

# 退出时清理后台进程和管道
trap "kill $LOOP_PID; rm '$PIPE'" EXIT

# 显示界面
# 使用双列显示，左侧是项目，右侧是具体数值
yad --title="ThinkPad 散热控制" \
    --window-icon=utilities-system-monitor \
    --width=350 --height=280 --center \
    --text="\n<span size='large'><b>系统状态实时监控</b></span>\n" \
    --list \
    --column="项目:TEXT" --column="数值:TEXT" \
    --no-headers \
    --listen <&3 \
    --button="🚀 狂暴起飞!":1 \
    --button="🍃 恢复自动":2 \
    --button="关闭":0

choice=$?

# 执行风扇控制命令
if [ $choice -eq 1 ]; then
    echo level disengaged | sudo tee /proc/acpi/ibm/fan > /dev/null
elif [ $choice -eq 2 ]; then
    echo level auto | sudo tee /proc/acpi/ibm/fan > /dev/null
fi

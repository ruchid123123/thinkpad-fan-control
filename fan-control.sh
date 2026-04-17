#!/bin/bash

# 定义管道文件用于实时传递数据给 yad
PIPE=$(mktemp -u)
mkfifo "$PIPE"
exec 3<> "$PIPE"

# 后台进程：实时抓取数据并精准更新表单字段
(
    while true; do
        SPEED=$(grep "speed:" /proc/acpi/ibm/fan | awk '{print $2}')
        LEVEL=$(grep "level:" /proc/acpi/ibm/fan | awk '{print $2}')
        STATUS=$(grep "status:" /proc/acpi/ibm/fan | awk '{print $2}')
        
        # 精准更新表单中的第 1, 2, 3 个字段
        echo "1:$SPEED RPM" >&3
        echo "2:$LEVEL" >&3
        echo "3:$STATUS" >&3
        
        sleep 1
    done
) &
LOOP_PID=$!

# 定义按钮点击时执行的逻辑
# 使用 fbtn 时，它们通过调用 shell 执行命令，不会导致 yad 退出
export -f echo # 导出一些基本命令以防万一
CMD_TURBO="bash -c 'echo level disengaged | sudo tee /proc/acpi/ibm/fan'"
CMD_AUTO="bash -c 'echo level auto | sudo tee /proc/acpi/ibm/fan'"

# 退出时清理
trap "kill $LOOP_PID; rm '$PIPE'" EXIT

# 显示界面
# fbtn 按钮不会关闭窗口
yad --title="ThinkPad 散热控制" \
    --window-icon=utilities-system-monitor \
    --width=300 --height=250 --center \
    --text="\n<span size='large'><b>风扇状态实时监控</b></span>\n" \
    --form \
    --field="🌀 当前转速":RO \
    --field="⚙️ 运行模式":RO \
    --field="✅ 运行状态":RO \
    --field="🚀 狂暴起飞!":fbtn "$CMD_TURBO" \
    --field="🍃 恢复自动":fbtn "$CMD_AUTO" \
    --listen <&3 \
    --button="关闭":0

# 当点击底部的“关闭”按钮或红叉时，脚本结束

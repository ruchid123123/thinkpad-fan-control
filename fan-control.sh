#!/bin/bash

# 显示 yad 界面
yad --title="ThinkPad 散热控制" \
  --text="\n<span size='large'><b>请选择你的散热模式：</b></span>\n\n• <b>狂暴起飞</b>：解除转速限制，适合满载压测\n• <b>恢复自动</b>：交还 BIOS 控温，适合日常静音\n" \
  --image=dialog-information \
  --width=450 --center \
  --window-icon=utilities-system-monitor \
  --button="🚀 狂暴起飞!":1 \
  --button="🍃 恢复自动":2 \
  --button="取消":0

choice=$?

# 根据选择执行免密命令，将输出重定向到 /dev/null 保持后台干净
if [ $choice -eq 1 ]; then
    echo level disengaged | sudo tee /proc/acpi/ibm/fan > /dev/null
elif [ $choice -eq 2 ]; then
    echo level auto | sudo tee /proc/acpi/ibm/fan > /dev/null
fi

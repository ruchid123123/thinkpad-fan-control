# ThinkPad Fan Control 散热控制

这是一个简单的 Linux 脚本，通过图形界面 (yad) 快速切换 ThinkPad 的风扇散热模式。

## 功能介绍
- **🚀 狂暴起飞 (Full Speed)**: 解除风扇转速限制 (disengaged)，适合高负载散热。
- **🍃 恢复自动 (Auto)**: 交由 BIOS 自动控温，适合日常使用，静音节能。

## 安装要求
- 硬件: ThinkPad 系列笔记本
- 软件: `yad`, `bash`, `sudo`
- 内核模块: `thinkpad_acpi` 需要启用 `fan_control=1` 参数

### 启用内核模块参数
编辑 `/etc/modprobe.d/thinkpad_acpi.conf` (若无则创建):
```bash
options thinkpad_acpi fan_control=1
```
然后重新加载模块或重启。

## 安装方法
运行项目中的 `install.sh` 脚本:
```bash
chmod +x install.sh
./install.sh
```

## 使用方法
安装完成后，在应用菜单中搜索 **“散热控制”** 即可启动。

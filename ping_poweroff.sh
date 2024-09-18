#!/bin/bash

# 配置变量
ROUTER_IP=${1:-"192.168.2.97"}  # 使用命令行参数或默认值
PING_COUNT=10
PING_FAIL_FILE="/tmp/pingfail_${ROUTER_IP}"
SCRIPT_DIR=$(dirname "$0")
LOG_FILE="${SCRIPT_DIR}/network_monitor.log"

# 日志函数
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

# 关机函数
shutdown_synology() {
    log_message "执行群晖关机..."
    synopoweroff
}

# 主函数
main() {
    log_message "脚本开始执行"

    if ping -c "$PING_COUNT" "$ROUTER_IP" >/dev/null 2>&1; then
        log_message "Ping $ROUTER_IP 成功"
        rm -f "$PING_FAIL_FILE"
    else
        log_message "Ping $ROUTER_IP 失败"
        if [[ -f "$PING_FAIL_FILE" ]]; then
            log_message "连续两次ping失败，准备关机"
            shutdown_synology
            rm -f "$PING_FAIL_FILE"
        else
            touch "$PING_FAIL_FILE"
            log_message "首次ping失败，创建标记文件"
        fi
    fi

    log_message "脚本执行结束"
}

# 执行主函数
main

exit 0
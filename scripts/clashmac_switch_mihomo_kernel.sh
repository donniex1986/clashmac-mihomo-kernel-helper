#!/bin/sh

# 配置变量
# CLASH_MAC_DIR="/Applications/ClashMac.app/Contents/Resources"
CORE_DIR="$HOME/Library/Application Support/clashmac/core"
ACTIVE="mihomo"

# 终端颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

cd "$CORE_DIR" || { echo -e "${RED}Directory not found: $CORE_DIR${NC}\n"; exit 1; }

# --------------------------
# 工具函数：判断是否 smart 内核
# --------------------------
is_smart() {
    local file="$1"
    [ -f "$file" ] || { echo ""; return; }
    TYPE=$("./$file" -v 2>/dev/null | head -n 1)
    if echo "$TYPE" | grep -iq "smart"; then
        echo "${GREEN}[SMART]${NC}"
    else
        echo ""
    fi
}

# --------------------------
# 列出所有备份
# --------------------------
if [ "$1" = "list" ]; then
    echo
    echo -e "${BLUE}Available backups:${NC}\n"
    ls -1 mihomo.backup.* 2>/dev/null | sort -r | while read -r f; do
        MARK=$(is_smart "$f")
        echo "$f $MARK"
    done
    echo
    exit 0
fi

# --------------------------
# status：显示当前 active + 最新备份 + smart 标记
# --------------------------
if [ "$1" = "status" ]; then
    echo
    MARK_ACTIVE=$(is_smart "$ACTIVE")
    echo -e "${GREEN}Current active:${NC} $ACTIVE $MARK_ACTIVE"
    echo

    LATEST=$(ls -1 mihomo.backup.* 2>/dev/null | sort -r | head -n 1)
    if [ -n "$LATEST" ]; then
        MARK_LATEST=$(is_smart "$LATEST")

        echo -e "${GREEN}Latest backup:${NC} $LATEST $MARK_LATEST\n"
        echo -e "${BLUE}Tip:${NC} To switch to this backup, run: ./clashmac_switch_mihomo_kernel.sh ${LATEST##*.}\n"
    else
        echo -e "${RED}No backups found${NC}\n"
    fi
    exit 0
fi

# --------------------------
# 切换到指定备份或最新备份
# --------------------------
# 选择目标备份
if [ -n "$1" ]; then
    TARGET_BACKUP="mihomo.backup.$1"
else
    TARGET_BACKUP=$(ls -1 mihomo.backup.* 2>/dev/null | sort -r | head -n 1)
fi

[ -f "$ACTIVE_CORE" ] || { echo; echo "未找到当前核心"; echo; exit 1; }
[ -f "$TARGET_BACKUP" ] || { echo; echo "未找到备份: $TARGET_BACKUP"; echo; exit 1; }

# 先备份当前核心为最新时间戳文件
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NEW_BACKUP="mihomo.backup.$TIMESTAMP"
mv "$ACTIVE_CORE" "$NEW_BACKUP"

# 将目标备份复制为当前核心
cp "$TARGET_BACKUP" "$ACTIVE_CORE"
chmod +x "$ACTIVE_CORE"

echo
echo -e "${GREEN}切换成功! 当前核心已更新为最新${NC}"
echo
echo -e "${YELLOW}原核心已备份为:${NC} $NEW_BACKUP"
echo -e "${YELLOW}目标备份保留为:${NC} $TARGET_BACKUP"
echo -e "${YELLOW}当前使用核心:${NC} $ACTIVE_CORE $(is_smart "$ACTIVE_CORE")"
echo

# 提示最新备份和切换命令
LATEST=$(ls -1 mihomo.backup.* 2>/dev/null | sort -r | head -n 1)
[ -n "$LATEST" ] && echo -e "${BLUE}Latest backup:${NC} $LATEST | Switch with: ./switch-mihomo.sh ${LATEST##*.}\n"




# .bashrc

alias yay='x'
alias pacman='x'

x() {
    # Если вызов без аргументов — эмулируем флаг помощи, чтобы попасть в блок *)
    if [ $# -eq 0 ]; then
        set -- "-h"
    fi

    # Проверяем первый аргумент. Если он не начинается с '-', это прямая установка
    local cmd="$1"
    if [[ "$cmd" != -* ]]; then
        cmd="-I" # Внутренний маркер для установки без синхронизации
    fi

    case "$cmd" in
        -S|-I)
            local DO_SYNC=1
            local pkgs=("${@:2}") # Для -S берем пакеты начиная со 2-го аргумента

            if [ "$cmd" = "-I" ]; then
                DO_SYNC=0
                pkgs=("$@")
            fi

            if [ ${#pkgs[@]} -eq 0 ]; then 
                echo "Ошибка: Укажите хотя бы один пакет для установки"
                return 1
            fi
            
            if [ "$DO_SYNC" -eq 1 ]; then
                echo "--- [Установка] xbps-install -S ${pkgs[*]} ---"
                sudo xbps-install -S "${pkgs[@]}"
            else
                echo "--- [Установка] xbps-install ${pkgs[*]} ---"
                sudo xbps-install "${pkgs[@]}"
            fi
            ;;
        
        -Su)
            echo "--- [Обновление] xbps-install -Su ---"
            sudo xbps-install -Su
            
            echo "--- [Очистка] xbps-remove -Ooy ---"
            sudo xbps-remove -Ooy
            ;;

        -R)
            if [ $# -lt 2 ]; then 
                echo "Ошибка: Укажите хотя бы один пакет для удаления."
                return 1
            fi
            echo "--- [Удаление] xbps-remove -RFdf ${@:2} ---"
            sudo xbps-remove -RFdf "${@:2}"
            
            echo "--- [Очистка] xbps-remove -Ooy ---"
            sudo xbps-remove -Ooy
            ;;
            
        -O)
            echo "--- [Очистка] xbps-remove -Ooy ---"
            sudo xbps-remove -Ooy
            ;;
            
        -s)
            echo "--- [Поиск] xbps-query -Rs ${@:2} ---"
            xbps-query -Rs "${@:2}"
            ;;
        
        *)
            echo "========================================================"
            echo "                 x — Обертка для XBPS"
            echo "========================================================"
            echo "Использование:"
            echo "  x     - Установка пакетов (xbps-install)"
            echo "  x -S  - Установка с синхронизацией (xbps-install -S)"
            echo "  x -Su - Полное обновление системы (xbps-install -Su)"
            echo "  x -s  - Поиск пакета в репозиториях (xbps-query -Rs)"
            echo "  x -R  - Принудительное удаление (xbps-remove -RFdf)"
            echo "  x -O  - Чистка кэша и сирот (xbps-remove -Ooy)"
            ;;
    esac
}

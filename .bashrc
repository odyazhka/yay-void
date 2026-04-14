# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

yay() {
    local VOID_PACKAGES_DIR="$HOME/void-packages"

    case "$1" in
        -S)
            # Проверяем, передали ли хотя бы один пакет
            if [ $# -lt 2 ]; then
                echo "Ошибка: Укажите хотя бы один пакет для установки."
                return 1
            fi

            # Массивы для сортировки пакетов
            local bin_pkgs=()
            local src_pkgs=()

            # Перебираем все аргументы, начиная со второго (сами пакеты)
            for pkg in "${@:2}"; do
                if xbps-query -Rs "^${pkg}$" > /dev/null; then
                    bin_pkgs+=("$pkg")
                else
                    src_pkgs+=("$pkg")
                fi
            done

            # 1. Установка бинарных пакетов одной командой
            if [ ${#bin_pkgs[@]} -gt 0 ]; then
                echo "--- [XBPS] Установка бинарников: ${bin_pkgs[*]} ---"
                sudo xbps-install -S "${bin_pkgs[@]}"
            fi

            # 2. Сборка пакетов из исходников по очереди
            if [ ${#src_pkgs[@]} -gt 0 ]; then
                echo "--- [xbps-src] Сборка из исходников: ${src_pkgs[*]} ---"
                if [ ! -d "$VOID_PACKAGES_DIR" ]; then
                    echo "Критическая ошибка: Директория $VOID_PACKAGES_DIR не найдена."
                    return 1
                fi

                cd "$VOID_PACKAGES_DIR" || return 1
                echo "-> Синхронизация шаблонов..."
                git pull

                for pkg in "${src_pkgs[@]}"; do
                    echo "-> Сборка $pkg..."
                    ./xbps-src pkg "$pkg" && xi "$pkg"
                done

                cd - > /dev/null || return 1
            fi
            ;;

        -Su)
            echo "--- [Система] Синхронизация и полное обновление ---"
            sudo xbps-install -Su

            echo "--- [Git] Обновление локальных шаблонов сборки ---"
            if [ -d "$VOID_PACKAGES_DIR" ]; then
                cd "$VOID_PACKAGES_DIR" || return 1
                git pull
                cd - > /dev/null || return 1
            else
                echo "Предупреждение: $VOID_PACKAGES_DIR не найдена, пропускаем git pull."
            fi

            sudo xbps-remove -Oy
            ;;

        -R)
            # Теперь можно удалять сразу несколько пакетов
            if [ $# -lt 2 ]; then
                echo "Ошибка: Укажите хотя бы один пакет для удаления."
                return 1
            fi
            echo "--- [Удаление] Принудительный снос пакетов: ${@:2} ---"
            # Передаем все пакеты разом в xbps-remove
            sudo xbps-remove -Rf "${@:2}"
            sudo xbps-remove -Oy
            ;;

        *)
            echo "======================================================"
            echo "  Void Linux Helper (yay clone) — Обертка для XBPS"
            echo "======================================================"
            echo "Использование:"
            echo "  yay -S <pkg1> <pkg2>  - Установка (бинарники или сборка)"
            echo "  yay -Su               - Полное обновление системы"
            echo "  yay -R <pkg1> <pkg2>  - Принудительное удаление"
            ;;
    esac
}

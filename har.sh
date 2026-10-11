#!/data/data/com.termux/files/usr/bin/bash

# =====================================================================================
#                    HAR EXTRACTOR v8.0 - PROFESSIONAL EDITION
# =====================================================================================
#                    Ultra-Fast HAR Analysis & API Extraction Tool
# =====================================================================================
#
#   Author:      Your Name
#   Repository:  https://github.com/YOUR_USER/har-extractor
#   License:     MIT
#   Version:     8.0.0
#
# =====================================================================================

set -euo pipefail

# =====================================================================================
#                              CONSTANTS
# =====================================================================================
readonly SCRIPT_VERSION="8.0.0"
readonly SCRIPT_NAME="HAR Extractor"
readonly SCRIPT_AUTHOR="Your Name"
readonly SCRIPT_REPO="https://github.com/YOUR_USER/har-extractor"
readonly SCRIPT_LICENSE="MIT"

readonly MAX_RESPONSE_SIZE=10000
readonly CONFIG_FILE="$HOME/.har_extractor.conf"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly MAGENTA='\033[0;35m'
readonly DIM='\033[2m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# =====================================================================================
#                              DEFAULT FILTERS
# =====================================================================================
FILTER_IMAGES="y"
FILTER_CSS="y"
FILTER_JS="y"
FILTER_FONTS="y"
FILTER_MEDIA="y"
FILTER_PATHS="y"

# =====================================================================================
#                              UI FUNCTIONS
# =====================================================================================
print_banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                                  ║"
    echo "║              HAR EXTRACTOR v${SCRIPT_VERSION} - PROFESSIONAL EDITION                    ║"
    echo "║                                                                                  ║"
    echo "║              Extract APIs | Full Request/Response | Smart Filtering               ║"
    echo "║                                                                                  ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error()   { echo -e "${RED}✗${NC} $1"; }
print_info()    { echo -e "${CYAN}⟳${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }

show_help() {
    cat << EOF
${BOLD}HAR Extractor v${SCRIPT_VERSION}${NC}

${BOLD}USAGE:${NC}
    ./har.sh [OPTIONS]

${BOLD}OPTIONS:${NC}
    -h, --help       Show this help
    -v, --version    Show version
    -c, --config     Show config file path
    --reset-config   Reset saved preferences

${BOLD}DESCRIPTION:${NC}
    Interactive HAR file analyzer that:
    • Filters out static assets (images, CSS, JS, fonts, media)
    • Groups requests by domain
    • Exports full request/response data to a clean text file

${BOLD}REQUIREMENTS:${NC}
    • Bash 4.0+
    • jq

${BOLD}EXAMPLES:${NC}
    ./har.sh
    ./har.sh --help
    ./har.sh --reset-config

${BOLD}REPOSITORY:${NC}
    ${SCRIPT_REPO}

${BOLD}LICENSE:${NC}
    ${SCRIPT_LICENSE} © ${SCRIPT_AUTHOR}
EOF
}

show_version() {
    echo "HAR Extractor v${SCRIPT_VERSION}"
    echo "© ${SCRIPT_AUTHOR}"
    echo "${SCRIPT_REPO}"
}

# =====================================================================================
#                              CONFIG MANAGEMENT
# =====================================================================================
load_config() {
    [ -f "$CONFIG_FILE" ] || return 0
    # shellcheck disable=SC1090
    source "$CONFIG_FILE" 2>/dev/null || true
}

save_config() {
    cat > "$CONFIG_FILE" << EOF
# HAR Extractor Preferences
# Generated: $(date)
FILTER_IMAGES=$FILTER_IMAGES
FILTER_CSS=$FILTER_CSS
FILTER_JS=$FILTER_JS
FILTER_FONTS=$FILTER_FONTS
FILTER_MEDIA=$FILTER_MEDIA
FILTER_PATHS=$FILTER_PATHS
MAX_RESPONSE_SIZE=$MAX_RESPONSE_SIZE
EOF
}

reset_config() {
    if [ -f "$CONFIG_FILE" ]; then
        rm -f "$CONFIG_FILE"
        print_success "Config reset: $CONFIG_FILE"
    else
        print_warning "No config file found"
    fi
}

# =====================================================================================
#                              FILTER CONFIGURATION
# =====================================================================================
configure_filters() {
    echo -e "\n${BLUE}${BOLD}═══ FILTER CONFIGURATION ═══${NC}"
    echo -e "${YELLOW}Filter out asset types? (Enter = yes)${NC}\n"

    read -p "  🖼️  Images [y/n]: " FILTER_IMAGES; FILTER_IMAGES=${FILTER_IMAGES:-y}
    read -p "  🎨 Styles [y/n]: " FILTER_CSS; FILTER_CSS=${FILTER_CSS:-y}
    read -p "  📜 Scripts [y/n]: " FILTER_JS; FILTER_JS=${FILTER_JS:-y}
    read -p "  🔤 Fonts [y/n]: " FILTER_FONTS; FILTER_FONTS=${FILTER_FONTS:-y}
    read -p "  🎬 Media [y/n]: " FILTER_MEDIA; FILTER_MEDIA=${FILTER_MEDIA:-y}
    read -p "  📁 Asset paths [y/n]: " FILTER_PATHS; FILTER_PATHS=${FILTER_PATHS:-y}

    echo ""
    print_success "Filter configuration complete"
    save_config
}

# =====================================================================================
#                              ASSET DETECTION
# =====================================================================================
is_asset() {
    local url
    url=$(echo "$1" | tr '[:upper:]' '[:lower:]')

    if [ "$FILTER_IMAGES" = "y" ]; then
        case "$url" in
            *.svg*|*.png*|*.jpg*|*.jpeg*|*.gif*|*.webp*|*.ico*|*.bmp*) return 0 ;;
        esac
    fi
    if [ "$FILTER_CSS" = "y" ]; then
        case "$url" in
            *.css*|*.scss*|*.sass*|*.less*) return 0 ;;
        esac
    fi
    if [ "$FILTER_JS" = "y" ]; then
        case "$url" in
            *.js|*.js\?*|*.mjs*|*.ts|*.ts\?*|*.jsx*|*.tsx*) return 0 ;;
        esac
    fi
    if [ "$FILTER_FONTS" = "y" ]; then
        case "$url" in
            *.woff*|*.ttf*|*.eot*|*.otf*) return 0 ;;
        esac
    fi
    if [ "$FILTER_MEDIA" = "y" ]; then
        case "$url" in
            *.mp4*|*.mp3*|*.webm*|*.ogg*|*.avi*) return 0 ;;
        esac
    fi
    if [ "$FILTER_PATHS" = "y" ]; then
        case "$url" in
            */assets/*|*/static/*|*/images/*|*/img/*|*/fonts/*|*/media/*|*favicon*) return 0 ;;
        esac
    fi
    return 1
}

# =====================================================================================
#                              DEPENDENCY CHECK
# =====================================================================================
check_dependencies() {
    if ! command -v jq &>/dev/null; then
        print_warning "jq not found. Installing..."
        if command -v pkg &>/dev/null; then
            pkg install jq -y 2>/dev/null
        elif command -v apt &>/dev/null; then
            sudo apt install -y jq
        elif command -v brew &>/dev/null; then
            brew install jq
        else
            print_error "Please install jq manually"
            exit 1
        fi
        print_success "jq installed"
    fi
}

# =====================================================================================
#                              MAIN
# =====================================================================================
main() {
    # Parse args
    case "${1:-}" in
        -h|--help)      show_help; exit 0 ;;
        -v|--version)   show_version; exit 0 ;;
        -c|--config)    echo "$CONFIG_FILE"; exit 0 ;;
        --reset-config) reset_config; exit 0 ;;
    esac

    # Load saved config
    load_config

    print_banner
    configure_filters

    echo -e "\n${WHITE}┌────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${WHITE}│${GREEN}  📁 Enter HAR file path: ${NC}                                       ${WHITE}│${NC}"
    echo -e "${WHITE}└────────────────────────────────────────────────────────────────┘${NC}"
    echo -ne "${YELLOW}➜ ${NC}"
    read HAR_FILE

    [ ! -f "$HAR_FILE" ] && print_error "File not found: $HAR_FILE" && exit 1

    check_dependencies

    TOTAL_ENTRIES=$(jq '.log.entries | length' "$HAR_FILE" 2>/dev/null)
    [ -z "$TOTAL_ENTRIES" ] || [ "$TOTAL_ENTRIES" -eq 0 ] && print_error "Invalid HAR file" && exit 1

    local file_size
    file_size=$(stat -c%s "$HAR_FILE" 2>/dev/null || stat -f%z "$HAR_FILE" 2>/dev/null)

    echo ""
    print_success "File: $(basename "$HAR_FILE") | Size: $((file_size/1048576)) MB | Entries: $TOTAL_ENTRIES"

    # Extract URLs
    print_info "Extracting URLs..."
    local start_time
    start_time=$(date +%s)

    local temp_urls=".urls_$$.txt"
    local temp_domains=".domains_$$.txt"

    jq -r '.log.entries[] | "\(.request.url)\t\(.request.url | capture("^(?<d>https?://[^/]+)").d)"' \
        "$HAR_FILE" 2>/dev/null > "$temp_urls"

    > "$temp_domains"
    local API_COUNT=0
    local ASSET_COUNT=0

    while IFS=$'\t' read -r url domain; do
        [ -z "$url" ] && continue
        if is_asset "$url"; then
            ASSET_COUNT=$((ASSET_COUNT + 1))
        else
            echo "$domain" >> "$temp_domains"
            API_COUNT=$((API_COUNT + 1))
        fi
    done < "$temp_urls"

    print_success "API requests: $API_COUNT | Assets: $ASSET_COUNT"

    if [ $API_COUNT -eq 0 ]; then
        print_error "No API requests found"
        rm -f "$temp_urls" "$temp_domains"
        exit 1
    fi

    # Unique domains
    sort "$temp_domains" | uniq -c | sort -rn | awk '{print $2"|"$1}' > "${temp_domains}.counted"

    mapfile -t domain_arr < <(cut -d'|' -f1 "${temp_domains}.counted")
    mapfile -t count_arr  < <(cut -d'|' -f2 "${temp_domains}.counted")
    local total_domains=${#domain_arr[@]}

    # Display
    echo ""
    echo -e "${BLUE}${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}${BOLD}  AVAILABLE DOMAINS${NC}"
    echo -e "${BLUE}${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}\n"

    for i in "${!domain_arr[@]}"; do
        local icon="🌐"
        local color="${WHITE}"
        [[ "${domain_arr[$i]}" == *"api"* ]]    && { icon="📡"; color="${CYAN}"; }
        [[ "${domain_arr[$i]}" == *"auth"* ]]   && { icon="🔐"; color="${YELLOW}"; }
        [[ "${domain_arr[$i]}" == *"cdn"* ]]    && { icon="📦"; color="${MAGENTA}"; }
        [[ "${domain_arr[$i]}" == *"socket"* ]] && { icon="🔌"; color="${GREEN}"; }
        printf "  ${GREEN}[%2d]${NC} ${color}${icon} %-50s${NC} ${CYAN}▶ %4d requests${NC}\n" \
            $((i+1)) "${domain_arr[$i]}" "${count_arr[$i]}"
    done

    echo ""
    echo -e "${BLUE}${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${WHITE}• Single:${NC}     2    ${WHITE}• Multiple:${NC}   1,3,5    ${WHITE}• Range:${NC}   1-3    ${WHITE}• All:${NC}   all"
    echo -e "${BLUE}${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -ne "\n${YELLOW}➜ Enter selection: ${NC}"
    read selection

    # Parse selection
    local selected_indices=()
    if [ "$selection" = "all" ]; then
        for i in "${!domain_arr[@]}"; do selected_indices+=("$i"); done
    elif [[ "$selection" == *"-"* ]]; then
        local s e
        s=$(echo "$selection" | cut -d'-' -f1)
        e=$(echo "$selection" | cut -d'-' -f2)
        for ((i=s-1; i<e && i<total_domains; i++)); do selected_indices+=("$i"); done
    elif [[ "$selection" == *","* ]]; then
        IFS=',' read -ra nums <<< "$selection"
        for n in "${nums[@]}"; do
            n=$(echo "$n" | xargs)
            [ "$n" -ge 1 ] && [ "$n" -le "$total_domains" ] && selected_indices+=("$((n-1))")
        done
    else
        [ "$selection" -ge 1 ] && [ "$selection" -le "$total_domains" ] && selected_indices+=("$((selection-1))")
    fi

    if [ ${#selected_indices[@]} -eq 0 ]; then
        print_error "Invalid selection"
        rm -f "$temp_urls" "$temp_domains" "${temp_domains}.counted"
        exit 1
    fi

    # Export
    local timestamp output_file
    timestamp=$(date +%Y%m%d_%H%M%S)
    output_file="api_export_${timestamp}.txt"

    echo ""
    print_success "Exporting ${#selected_indices[@]} domains to: ${CYAN}$output_file${NC}"
    print_info "Processing..."

    cat > "$output_file" << EOF
╔═══════════════════════════════════════════════════════════════════════════════════════╗
║                         PROFESSIONAL HAR API EXPORT REPORT                            ║
╠═══════════════════════════════════════════════════════════════════════════════════════╣
║  Generated:      $(date '+%Y-%m-%d %H:%M:%S')
║  Tool:           HAR Extractor v${SCRIPT_VERSION}
║  HAR File:       $(basename "$HAR_FILE")
║  Total Entries:  $TOTAL_ENTRIES
║  Domains Exported: ${#selected_indices[@]}
╚═══════════════════════════════════════════════════════════════════════════════════════╝

EOF

    local total_exported=0

    for idx in "${selected_indices[@]}"; do
        local domain="${domain_arr[$idx]}"
        local count="${count_arr[$idx]}"

        echo -ne "${YELLOW}⟳ Processing: ${domain}${NC}"

        cat >> "$output_file" << EOF

╔═══════════════════════════════════════════════════════════════════════════════════════╗
║  🌐 DOMAIN: $domain
║  📊 Total Requests: $count
╚═══════════════════════════════════════════════════════════════════════════════════════╝

EOF

        jq -r --arg domain "$domain" --argjson max_size "$MAX_RESPONSE_SIZE" '
            def fmt_req(num):
                "\n┌────────────────────────────────────────────────────────────────────────────────────┐",
                "│  📤 REQUEST #\(num)",
                "└────────────────────────────────────────────────────────────────────────────────────┘",
                "",
                "URL :- \(.request.url)",
                "",
                "Method :- \(.request.method // "GET")",
                "",
                "Headers :-",
                ((.request.headers // []) | map("  \(.name): \(.value)") | .[]),
                "",
                "Body :-",
                "",
                "RAW :-",
                (.request.postData.text // .request.content.text // "(No request body)");

            def fmt_res(num):
                "\n┌────────────────────────────────────────────────────────────────────────────────────┐",
                "│  📥 RESPONSE #\(num)",
                "└────────────────────────────────────────────────────────────────────────────────────┘",
                "",
                "Status :-",
                "",
                "RAW :-",
                "\(.response.httpVersion // "HTTP/1.1") \(.response.status // "") \(.response.statusText // "")",
                ((.response.headers // []) | map("  \(.name): \(.value)") | .[]),
                "",
                "BODY :-",
                "",
                ((.response.content.text // "(No response body)") | if length > $max_size then .[0:$max_size] + "\n... [TRUNCATED]" else . end),
                "",
                "┌────────────────────────────────────────────────────────────────────────────────────┐",
                "│  ✓ END OF REQUEST/RESPONSE #\(num)",
                "└────────────────────────────────────────────────────────────────────────────────────┘";

            [.log.entries[] | select(.request.url | startswith($domain))]
            | to_entries[]
            | (.key + 1) as $n
            | (.value | fmt_req($n)),
              (.value | fmt_res($n))
        ' "$HAR_FILE" >> "$output_file" 2>&1

        echo -e "\r  ${GREEN}✓ Completed: $count requests${NC}    "
        total_exported=$((total_exported + count))
    done

    cat >> "$output_file" << EOF

╔═══════════════════════════════════════════════════════════════════════════════════════╗
║                              📊 EXPORT SUMMARY                                        ║
╠═══════════════════════════════════════════════════════════════════════════════════════╣
║  • Domains Exported:  ${#selected_indices[@]}
║  • Total Requests:    $total_exported
║  • Assets Skipped:    $ASSET_COUNT
║  • Output File Size:  $(du -h "$output_file" | cut -f1)
║  • Export Date:       $(date '+%Y-%m-%d %H:%M:%S')
╚═══════════════════════════════════════════════════════════════════════════════════════╝

✅ EXPORT COMPLETE
EOF

    rm -f "$temp_urls" "$temp_domains" "${temp_domains}.counted"

    local total_time=$(($(date +%s) - start_time))

    echo ""
    echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║                          ✅ EXPORT COMPLETE!                                      ║${NC}"
    echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${WHITE}📄 Output:${NC}  ${CYAN}$(pwd)/$output_file${NC}"
    echo -e "  ${WHITE}📊 Size:${NC}    ${GREEN}$(du -h "$output_file" | cut -f1)${NC}"
    echo -e "  ${WHITE}🌐 Domains:${NC} ${MAGENTA}${#selected_indices[@]}${NC}"
    echo -e "  ${WHITE}📊 Requests:${NC} ${GREEN}${total_exported}${NC}"
    echo -e "  ${WHITE}⏱️  Time:${NC}   ${YELLOW}${total_time}s${NC}"
    echo ""
    echo -e "  ${BLUE}💡 View:${NC} ${WHITE}cat $output_file | less -R${NC}"
    echo ""
}

trap 'echo -e "\n${YELLOW}⚠ Interrupted${NC}"; rm -f .urls_* .domains_* 2>/dev/null; exit 1' INT
main "$@"
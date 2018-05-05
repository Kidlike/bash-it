. "$BASH_IT/themes/powerline/powerline.base.bash"

function __powerline_left_segment {
  local OLD_IFS="${IFS}"; IFS="|"
  local params=( $1 )
  IFS="${OLD_IFS}"
  local separator_char="${POWERLINE_PROMPT_CHAR}"
  local separator=""

  if [[ "${SEGMENTS_AT_LEFT}" -gt 0 ]]; then
    separator="${separator_char}"
  fi
  LEFT_PROMPT+="${separator}$(set_color ${params[1]} -) ${params[0]} ${normal}"
  (( SEGMENTS_AT_LEFT += 1 ))
}

function __powerline_kube_prompt {
	if [ -n "$KUBE_NS" ]; then
		local icon="⎈"
		echo "${icon} ${KUBE_NS}|-"
	fi
}

function __powerline_battery_prompt {
  local color=""
  local battery_status="$(battery_percentage 2> /dev/null)"

  if [[ -z "${battery_status}" ]] || [[ "${battery_status}" = "-1" ]] || [[ "${battery_status}" = "no" ]]; then
    true
  else
	if [[ $battery_status -gt $BATTERY_STATUS_THEME_PROMPT_DISPLAY_THRESHOLD ]]; then
		true
	else
	    if [[ "$((10#${battery_status}))" -le 10 ]]; then
	      color="${BATTERY_STATUS_THEME_PROMPT_CRITICAL_COLOR}"
	    elif [[ "$((10#${battery_status}))" -le 30 ]]; then
	      color="${BATTERY_STATUS_THEME_PROMPT_LOW_COLOR}"
	    else
	      color="${BATTERY_STATUS_THEME_PROMPT_GOOD_COLOR}"
	    fi
	    ac_adapter_connected && battery_status="${BATTERY_AC_CHAR}${battery_status}"
	    echo "${battery_status}%|${color}"
        fi
  fi
}

function ac_adapter_connected {
	[ "$(upower -i /org/freedesktop/UPower/devices/line_power_AC | grep online | awk '{print $2}')" == "yes" ]
}

function __powerline_prompt_command {
  local last_status="$?" ## always the first
  local separator_char="${POWERLINE_PROMPT_CHAR}"

  LEFT_PROMPT=""
  SEGMENTS_AT_LEFT=0
  LAST_SEGMENT_COLOR=""

  if [[ -n "${POWERLINE_PROMPT_DISTRO_LOGO}" ]]; then
      LEFT_PROMPT+="$(set_color ${PROMPT_DISTRO_LOGO_COLOR} ${PROMPT_DISTRO_LOGO_COLORBG})${PROMPT_DISTRO_LOGO}$(set_color - -)"
  fi

  ## left prompt ##
  for segment in $POWERLINE_PROMPT; do
    local info="$(__powerline_${segment}_prompt)"
    [[ -n "${info}" ]] && __powerline_left_segment "${info}"
  done

  [[ "${last_status}" -ne 0 ]] && __powerline_left_segment $(__powerline_last_status_prompt ${last_status})
  [[ -n "${LEFT_PROMPT}" ]] && LEFT_PROMPT+="$(set_color ${LAST_SEGMENT_COLOR} -)${normal}"

  PS1="${LEFT_PROMPT}\n$(set_color - -)$separator_char "

  ## cleanup ##
  unset LAST_SEGMENT_COLOR \
        LEFT_PROMPT \
        SEGMENTS_AT_LEFT
}


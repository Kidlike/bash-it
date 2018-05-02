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

  BATTERY_SEGMENT=""
  if [[ "${THEME_BATTERY_PERCENTAGE_CHECK}" == true ]]; then
	  battery=$(battery_percentage)
	  if [ $battery -le 75 ]; then
		  BATTERY_SEGMENT="${orange}🗲 ${battery}%$(set_color - -) $separator_char"
	  elif [ $battery -le 25 ]; then
		  BATTERY_SEGMENT="${red}🗲 ${battery}%$(set_color - -) $separator_char"
	  fi
  fi

  PS1="${BATTERY_SEGMENT}${LEFT_PROMPT}\n$(set_color - -)$separator_char "

  ## cleanup ##
  unset LAST_SEGMENT_COLOR \
        LEFT_PROMPT \
        SEGMENTS_AT_LEFT
}


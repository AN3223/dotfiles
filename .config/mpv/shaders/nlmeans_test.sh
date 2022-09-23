#!/bin/sh -e
# $1: input image
# $2: noise level
# $3: output file (default: nlmeans_test.stats)

#
# This script benchmarks nlmeans.glsl by running the shader with a 
# corrupt image as input, and comparing the output to the clean image 
# with SSIM. A multitude of configurations are tested, and for each 
# configuration the SSIM is maximized by adjusting the S value.
#
# The configurations (including S values) and their corresponding SSIM 
# scores are output into a file called nlmeans_test.stats in the 
# script's directory.
# 

# Starting point for S
NLM_START=${NLM_START:-0.25}

# Number multiplied against S each step
NLM_FACTOR=${NLM_FACTOR:-16.0}

# Number multiplied against FACTOR every time SSIM decreases
NLM_FACTOR_DECAY=${NLM_FACTOR_DECAY:-0.73}

renice -n 19 $$; ionice -c 3 -p $$;

shader() {
	sed -i "
		63s|.*|//!HOOK $PLANE|
		${S:+s/^#define S .*/#define S $S/}
		${P:+s/^#define P .*/#define P $P/}
		${R:+s/^#define R .*/#define R $R/}
		${WF:+s/^#define WF .*/#define WF $WF/}
		${SS:+s/^#define SS .*/#define SS $SS/}
		${RF:+s/^#define RF .*/#define RF $RF_BOOL/}
		${RF:+s|//!WIDTH .*|//!WIDTH HOOKED.w $RF_SAFE /|}
		${RF:+s|//!HEIGHT .*|//!HEIGHT HOOKED.w $RF_SAFE /|}
		${WD_BOOL:+s/^#define WDT .*/#define WDT $WDT/}
		${WD_BOOL:+s/^#define WDP .*/#define WDP $WDP/}
		${WD_BOOL:+s/^#define WD .*/#define WD $WD_BOOL/}
		s/^#define EP .*/#define EP 0/
	" "$SHADER"

	ffmpeg -nostdin -i "${1:-$CORRUPT_IMAGE}" -i "$INPUT_IMAGE" -init_hw_device vulkan"$NLM_VK" \
		-lavfi "hwupload,libplacebo=custom_shader_path=$SHADER,hwdownload,format=yuv420p[placebo];
			[placebo]ssim=f=$TMP" \
		-f null -
}

ssim_tsv() {
	cut -d ' ' -f 2-5 "$TMP" | tr ' ' '\t'
}

avg_ssim() {
	[ "$REALIZATIONS" ] || return 0

	SSIM_Y=$(echo "$SSIM" | cut -f 1 | cut -d : -f 2)
	SSIM_U=$(echo "$SSIM" | cut -f 2 | cut -d : -f 2)
	SSIM_V=$(echo "$SSIM" | cut -f 3 | cut -d : -f 2)
	SSIM_ALL=$(echo "$SSIM" | cut -f 4 | cut -d : -f 2)
	SSIM="$SSIM_Y	$SSIM_U	$SSIM_V	$SSIM_ALL"

	i=1
	while [ "$i" -lt "$REALIZATIONS" ]; do
		shader "${CORRUPT_IMAGE%0.mkv}$i.mkv"
		NEW_SSIM=$(ssim_tsv)
		NEW_SSIM_Y=$(echo "$NEW_SSIM" | cut -f 1 | cut -d : -f 2)
		NEW_SSIM_U=$(echo "$NEW_SSIM" | cut -f 2 | cut -d : -f 2)
		NEW_SSIM_V=$(echo "$NEW_SSIM" | cut -f 3 | cut -d : -f 2)
		NEW_SSIM_ALL=$(echo "$NEW_SSIM" | cut -f 4 | cut -d : -f 2)
		SSIM="$SSIM
$NEW_SSIM_Y	$NEW_SSIM_U	$NEW_SSIM_V	$NEW_SSIM_ALL"
		i=$((i+1))
	done

	SSIM=$(printf '%s\n' "$SSIM" | awk '
		{ y+=$1; u+=$2; v+=$3; a+=$4; }
		END { printf("Y:%s\tU:%s\tV:%s\tAll:%s\n", y/NR, u/NR, v/NR, a/NR) }
	')
}

STATS=${3:-nlmeans_test}.stats
TMP=${3:-nlmeans_test}.tmp
SHADER=${3:-nlmeans_test}.shader
INPUT_IMAGE=${1:?}

# make sure old stats aren't appended to
if [ -f "$STATS" ]; then
	echo "remove existing $STATS? y/N" >&2
	read -r input
	case "$input" in 
		y|Y) rm "$STATS" ;;
		*) exit 1 ;;
	esac
fi

# generate corrupted image and get baseline from it
case "${2:?}" in
	JPEG=*)
		CORRUPTION="$2"
		CORRUPT_IMAGE=${3:-nlmeans_test}.jpg
		ffmpeg -y -i "$INPUT_IMAGE" -q:v "${2#JPEG=}" "$CORRUPT_IMAGE"
		ffmpeg -i "$INPUT_IMAGE" -i "$CORRUPT_IMAGE" -lavfi ssim=f="$TMP" -f null -
		BASELINE=$(ssim_tsv)
		;;
	*)
		REALIZATIONS=${NLM_REALIZATIONS:-10}
		CORRUPTION="NOISE=${2#NOISE=}:REALIZATIONS=$REALIZATIONS"

		i=0
		BASELINE=""
		while [ "$i" -lt "$REALIZATIONS" ]; do
			ffmpeg -y -i "$INPUT_IMAGE" -vf noise="alls=${2#NOISE=}:all_seed=$i" \
				-c:v libx265 -x265-params lossless=1 "${3:-nlmeans_test}$i.mkv"
			ffmpeg -i "$INPUT_IMAGE" -i "${3:-nlmeans_test}$i.mkv" -lavfi ssim=f="$TMP" -f null -
			SSIM=$(ssim_tsv)
			SSIM_Y=$(echo "$SSIM" | cut -f 1 | cut -d : -f 2)
			SSIM_U=$(echo "$SSIM" | cut -f 2 | cut -d : -f 2)
			SSIM_V=$(echo "$SSIM" | cut -f 3 | cut -d : -f 2)
			SSIM_ALL=$(echo "$SSIM" | cut -f 4 | cut -d : -f 2)
			BASELINE="$BASELINE
$SSIM_Y $SSIM_U $SSIM_V $SSIM_ALL"
			i=$((i+1))
		done

		BASELINE=$(printf '%s\n' "$BASELINE" | awk '
			{ y+=$1; u+=$2; v+=$3; a+=$4; }
			END { printf("Y:%s\tU:%s\tV:%s\tAll:%s\n", y/NR, u/NR, v/NR, a/NR) }
		')
		CORRUPT_IMAGE=${3:-nlmeans_test}0.mkv
		;;
esac
BASELINE_ALL=$(echo "$BASELINE" | cut -f 4 | cut -d : -f 2)
echo "BASELINE=$CORRUPTION	$BASELINE" >> "$STATS"

cp nlmeans.glsl "$SHADER"
sed -i '64,66d' "$SHADER"

for PLANE in ${NLM_PLANES:-LUMA CHROMA}; do
for WF in ${NLM_WF:-0}; do
for R in ${NLM_R:-15 13 11 9 7 5 3}; do
for P in ${NLM_P:-5 3 1}; do
for SS in ${NLM_SS:-""}; do
for RF in ${NLM_RF:-""}; do
	if [ "$RF" = 0 ] || [ ! "$RF" ]; then
		RF_SAFE=1
		RF_BOOL=0
	else
		RF_SAFE="$RF"
		RF_BOOL=1
	fi
for WDT in ${NLM_WDT:-""}; do
	if [ ! "$WDT" ]; then
		unset -v WD_BOOL
	elif [ "$WDT" = 0 ]; then
		unset -v NLM_WDP_
		WD_BOOL=0
	else
		WD_BOOL=1
		NLM_WDP_="$NLM_WDP"
	fi
for WDP in ${NLM_WDP_:-""}; do
	S="$NLM_START"
	FACTOR="$NLM_FACTOR"
	unset -v SSIM SSIM_ALL OLD_SSIM OLD_SSIM_ALL
	while :; do
		shader
		NEW_SSIM=$(ssim_tsv)
		NEW_SSIM_ALL=$(echo "$NEW_SSIM" | cut -f 4 | cut -d : -f 2)

		if expr "$NEW_SSIM_ALL" '<' "$BASELINE_ALL" >/dev/null; then
			break
		elif [ "$SSIM_ALL" ] && expr "$NEW_SSIM_ALL" '<=' "$SSIM_ALL" >/dev/null; then
			NEW_FACTOR=$(echo "scale=2; $FACTOR * $NLM_FACTOR_DECAY" | bc)
			if expr "$NEW_FACTOR" '<=' 1 >/dev/null; then
				S=$(echo "scale=2; $S / $FACTOR" | bc)
				break
			else
				S=$(echo "scale=2; $S / $FACTOR / $FACTOR * $NEW_FACTOR" | bc)
				FACTOR="$NEW_FACTOR"
				SSIM="$OLD_SSIM"
				SSIM_ALL="$OLD_SSIM_ALL"
			fi
		else
			OLD_SSIM="$SSIM"
			OLD_SSIM_ALL="$SSIM_ALL"
			SSIM="$NEW_SSIM"
			SSIM_ALL="$NEW_SSIM_ALL"
			S=$(echo "scale=2; $S * $FACTOR" | bc)
		fi
	done

	if [ "$SSIM" ]; then
		avg_ssim
		echo "$PLANE=${S:+S=$S}${P:+:P=$P}${R:+:R=$R}${WF:+:WF=$WF}${SS:+:SS=$SS}${RF:+:RF=$RF}${WDT:+:WDT=$WDT}${WDP:+:WDP=$WDP}	$SSIM" >> "$STATS"
	fi
done
done
done
done
done
done
done
done

if [ "$REALIZATIONS" ]; then
	i=0
	while [ "$i" -lt "$REALIZATIONS" ]; do
		rm "${CORRUPT_IMAGE%0.mkv}$i.mkv"
		i=$((i+1))
	done
else
	rm "$CORRUPT_IMAGE"
fi

rm "$SHADER" "$TMP"


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

# XXX refactor to use nlmeans_cfg

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
		${SS:+s/^#define SS .*/#define SS $SS/}
		${RF:+s/^#define RF .*/#define RF $RF_BOOL/}
		${RF:+s|//!WIDTH .*|//!WIDTH HOOKED.w $RF_SAFE /|}
		${RF:+s|//!HEIGHT .*|//!HEIGHT HOOKED.w $RF_SAFE /|}
		${WD_BOOL:+s/^#define WDT .*/#define WDT $WDT/}
		${WD_BOOL:+s/^#define WDP .*/#define WDP $WDP/}
		${WD_BOOL:+s/^#define WD .*/#define WD $WD/}
		${RS:+s/^#define RS .*/#define RS $RS/}
		${PS:+s/^#define PS .*/#define PS $PS/}
		${RI:+s/^#define RI .*/#define RI $RI/}
		s/^#define EP .*/#define EP 0/
	" "$SHADER"

	ffmpeg -nostdin -i "$1" -i "$INPUT_IMAGE" -init_hw_device vulkan"$NLM_VK" \
		-lavfi "hwupload,libplacebo=custom_shader_path=$SHADER,hwdownload,format=yuv420p[placebo];
			[placebo]ssim=f=$TMP" \
		-f null -
}

ssim_tsv() {
	cut -d ' ' -f 2-5 "$TMP" | tr ' ' '\t' | sed 's/[YUV]://g ; s/All://g'
}

avg_ssim() {
	awk '{ s+=$1; y+=$2; u+=$3; v+=$4; a+=$5; }
		END { printf("%s\t%s\t%s\t%s\t%s\n", s/NR, y/NR, u/NR, v/NR, a/NR) }'
}

STATS=${3:-nlmeans_test}.stats
TMP=${3:-nlmeans_test}.tmp
SHADER="$TMP.glsl"
INPUT_IMAGE="$TMP.input.mkv"
CORRUPT_IMAGE="$TMP.corrupt"
REALIZATIONS=${NLM_REALIZATIONS:-10}

# make sure old stats aren't appended to
if [ -f "$STATS" ]; then
	echo "remove existing $STATS? y/N" >&2
	read -r input
	case "$input" in 
		y|Y) rm "$STATS" ;;
		*) exit 1 ;;
	esac
fi

# save a yuv420p version of the input
ffmpeg -y -i "${1:?}" -c:v libx265 -x265-params lossless=1 -pix_fmt yuv420p "$INPUT_IMAGE"

# generate corrupted image and get baseline from it
case "${2:?}" in
	JPEG=*)
		REALIZATIONS=1
		CORRUPTION="$2"
		ffmpeg -y -i "$INPUT_IMAGE" -q:v "${2#JPEG=}" -c:v mjpeg "${CORRUPT_IMAGE}0.mkv"
		ffmpeg -i "$INPUT_IMAGE" -i "${CORRUPT_IMAGE}0.mkv" -lavfi ssim=f="$TMP" -f null -
		BASELINE=$(ssim_tsv)
		;;
	*)
		CORRUPTION="NOISE=${2#NOISE=}:REALIZATIONS=$REALIZATIONS"

		i=0
		BASELINE=""
		while [ "$i" -lt "$REALIZATIONS" ]; do
			ffmpeg -y -i "$INPUT_IMAGE" -vf noise="alls=${2#NOISE=}:all_seed=$i" \
				-c:v libx265 -x265-params lossless=1 "${CORRUPT_IMAGE}$i.mkv"
			ffmpeg -i "$INPUT_IMAGE" -i "${CORRUPT_IMAGE}$i.mkv" -lavfi ssim=f="$TMP" -f null -
			BASELINE="${BASELINE:+$BASELINE
}0	$(ssim_tsv)"
			i=$((i+1))
		done

		BASELINE=$(printf '%s\n' "$BASELINE" | avg_ssim | cut -f 2-5)
		;;
esac
echo "BASELINE=$CORRUPTION	$BASELINE" >> "$STATS"

# XXX add an env var for nlmeans.glsl path
cp nlmeans.glsl "$SHADER"
sed -i '64,66d' "$SHADER"

for PLANE in ${NLM_PLANES:-LUMA CHROMA}; do
for R in ${NLM_R:-9 7 5 3}; do
for P in ${NLM_P:-5 3 1}; do
for SS in ${NLM_SS:-""}; do
for RF in ${NLM_RF:-""}; do
	case "$RF" in
		0|"")
			RF_SAFE=1
			RF_BOOL=0
			;;
		*)
			RF_SAFE="$RF"
			RF_BOOL=1
			;;
	esac
for WD in ${NLM_WD:-""}; do
	case "$WD" in
	0)
		WD_BOOL=1
		unset -v NLM_WDT_ NLM_WDP_
		;;
	1)
		WD_BOOL=1
		NLM_WDT_="$NLM_WDT"
		NLM_WDP_="$NLM_WDP"
		;;
	2)
		WD_BOOL=1
		NLM_WDT_="$NLM_WDT"
		NLM_WDP_=0
		;;
	"")
		unset -v WD_BOOL NLM_WDP_ NLM_WDT_
		;;
	esac
for WDT in ${NLM_WDT_:-""}; do
for WDP in ${NLM_WDP_:-""}; do
for RS in ${NLM_RS:-""}; do
for PS in ${NLM_PS:-""}; do
for RI in ${NLM_RI:-""}; do
	unset -v AVG_SSIM
	i=0
	while [ "$i" -lt "$REALIZATIONS" ]; do
		unset -v SSIM SSIM_ALL OLD_SSIM OLD_SSIM_ALL

		# try starting the last good S value
		if [ "$AVG_SSIM" ]; then
			S=$(printf '%s\n' "$AVG_SSIM" | tail -n 1 | cut -f 1)
		else
			S="$NLM_START"
		fi

		FACTOR="$NLM_FACTOR"
	while :; do
		shader "${CORRUPT_IMAGE}$i.mkv"
		NEW_SSIM=$(ssim_tsv)
		NEW_SSIM_ALL=$(echo "$NEW_SSIM" | cut -f 4)

		if [ "$SSIM_ALL" ] && expr "$NEW_SSIM_ALL" '<=' "$SSIM_ALL" >/dev/null; then
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
		AVG_SSIM="${AVG_SSIM:+$AVG_SSIM
}$S	$SSIM"
		i=$((i+1))
	done

	AVG_SSIM=$(printf '%s\n' "$AVG_SSIM" | avg_ssim)
	S=$(printf '%s\n' "$AVG_SSIM" | cut -f 1)
	YUVA=$(printf '%s\n' "$AVG_SSIM" | cut -f 2-)

	# XXX this would be a lot better as a for loop w/ printf and eval
	echo "$PLANE=S=${S}${P:+:P=$P}${R:+:R=$R}${SS:+:SS=$SS}${RF:+:RF=$RF}${WD:+:WD=$WD}${WDT:+:WDT=$WDT}${WDP:+:WDP=$WDP}${RS:+:RS=$RS}${PS:+:PS=$PS}${RI:+:RI=$RI}	$YUVA" >> "$STATS"
done
done
done
done
done
done
done
done
done
done
done

i=0
while [ "$i" -lt "$REALIZATIONS" ]; do
	rm "${CORRUPT_IMAGE}$i.mkv"
	i=$((i+1))
done

rm "$SHADER" "$TMP" "$INPUT_IMAGE"


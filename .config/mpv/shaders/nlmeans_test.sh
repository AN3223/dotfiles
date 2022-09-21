#!/bin/sh -e
# $1: input image
# $2: noise level
# $3: output file (default: nlmeans_test.stats)

#
# This script approximates the ideal sigma (S) value for a set of 
# nlmeans.glsl configurations by trying multiple S values for each 
# configuration and comparing their SSIM scores.
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
cd "$(dirname "$0")"

shader() {
	sed -i "
		35s|.*|//!HOOK $PLANE|
		${S:+s/^#define S .*/#define S $S/}
		${P:+s/^#define P .*/#define P $P/}
		${R:+s/^#define R .*/#define R $R/}
		${WF:+s/^#define WF .*/#define WF $WF/}
		${SS:+s/^#define SS .*/#define SS $SS/}
		${RF:+s/^#define RF .*/#define RF $RF_BOOL/}
		${RF:+s|//!WIDTH .*|//!WIDTH HOOKED.w $RF_SAFE /|}
		${RF:+s|//!HEIGHT .*|//!HEIGHT HOOKED.w $RF_SAFE /|}
		s/^#define EP .*/#define EP 0/
	" "$3"

	ffmpeg -nostdin -i "$1" -i "$2" -init_hw_device vulkan \
		-lavfi "hwupload,libplacebo=custom_shader_path="$3",hwdownload,format=yuv420p[placebo];
			[placebo]ssim=f=nlmeans_test.stats.tmp" \
		-f null -
}

ssim_tsv() {
	cut -d ' ' -f 2-5 nlmeans_test.stats.tmp | tr ' ' '\t'
}

# make sure old stats aren't appended to
if [ -f nlmeans_test.stats ]; then
	echo 'remove old nlmeans_test.stats file? y/N' >&2
	read -r input
	case "$input" in 
		y|Y) rm nlmeans_test.stats ;;
		*) exit 1 ;;
	esac
fi

# generate corrupted image and get baseline from it
case "${2:?}" in
	JPEG=*)
		CORRUPTION="$2"
		ffmpeg -y -i "${1:?}" -c:v mjpeg -q:v "${2#JPEG=}" nlmeans_test_corrupt.mkv
		;;
	*)
		CORRUPTION="NOISE=${2#NOISE=}"
		ffmpeg -y -i "${1:?}" -vf noise=alls="${2#NOISE=}" -c:v libx265 -x265-params lossless=1 nlmeans_test_corrupt.mkv
		;;
esac
ffmpeg -i "$1" -i nlmeans_test_corrupt.mkv -lavfi ssim=f=nlmeans_test.stats.tmp -f null -
BASELINE=$(ssim_tsv nlmeans_test.stats.tmp)
BASELINE_ALL=$(echo "$BASELINE" | cut -f 4 | cut -d : -f 2)
echo "BASELINE=$CORRUPTION	$BASELINE" >> "${3:-nlmeans_test.stats}"

cp nlmeans.glsl nlmeans_test.glsl
sed -i '36,38d' nlmeans_test.glsl

for PLANE in ${NLM_PLANES:-LUMA CHROMA}; do
for WF in ${NLM_WF:-0}; do
for R in ${NLM_R:-15 13 11 9 7 5 3}; do
for P in ${NLM_P:-5 3 1}; do
for SS in ${NLM_SS:-6 0}; do
for RF in ${NLM_RF:-0}; do
	if [ "$RF" = 0 ]; then
		RF_SAFE=1
		RF_BOOL=0
	else
		RF_SAFE="$RF"
		RF_BOOL=1
	fi

	S="$NLM_START"
	FACTOR="$NLM_FACTOR"
	unset -v SSIM SSIM_ALL OLD_SSIM OLD_SSIM_ALL

	# Depiction of the peak approximation algorithm with FACTOR=4 and 
	# FACTOR_DECAY=0.375
	#
	#             |1 2 3 4 5 6 7 8 9 ...         16
	#  True SSIM: |I I I I I I I I I I I I P D D D D D D D D D D D D 
	# Known SSIM: |I     I                       D
	# Known SSIM: |I I I   I     I     A           D
	#
	# I = Increase; P = Peak; D = Decrease; A = Approximated peak
	#
	while :; do
		shader nlmeans_test_corrupt.mkv "$1" nlmeans_test.glsl
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
		echo "$PLANE=${S:+S=$S}${P:+:P=$P}${R:+:R=$R}${WF:+:WF=$WF}${SS:+:SS=$SS}${RF:+:RF=$RF}	$SSIM" >> nlmeans_test.stats
	fi
done
done
done
done
done
done

rm nlmeans_test.glsl nlmeans_test_corrupt.mkv nlmeans_test.stats.tmp


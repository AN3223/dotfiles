#!/usr/bin/make -f

all: pyramid guided nlmeans hdeband

pyramid: pyramid.glsl

pyramid.glsl: pyramid_template
	./shader_cfg $? > $@

guided: ../guided.glsl ../guided_s.glsl ../guided_s_fast.glsl ../guided_fast.glsl experimental/guided_lgc.glsl 

GUIDED_SELF_DESC=Self-guided.

GUIDED_LGC_DESC=Luma-guided-chroma denoising.
GUIDED_LGC=CFG_HOOKS=CHROMA:I=SHARE_LUMA:MEANI=2.0/:E=100.0

GUIDED_FAST_DESC=Fast.
GUIDED_FAST=I=2/:MEANI=1.5/
GUIDED_FAST_S=IP=2/:MEANIP=1.5/:E=0.001

../guided.glsl: guided_template
	./shader_cfg $? > $@
../guided_s.glsl: guided_s_template
	./shader_cfg $? > $@
../guided_s_fast.glsl: guided_s_template
	./shader_cfg DESC="$@: $(GUIDED_SELF_DESC) $(GUIDED_FAST_DESC)" OPTS="$(GUIDED_FAST_S)" $? > $@
../guided_fast.glsl: guided_template
	./shader_cfg DESC="$@: $(GUIDED_FAST_DESC)" OPTS="$(GUIDED_FAST)" $? > $@
experimental/guided_lgc.glsl: guided_template
	./shader_cfg DESC="$@: $(GUIDED_LGC_DESC)" OPTS="$(GUIDED_LGC)" $? > $@

nlmeans: nlmeans_default nlmeans_lq nlmeans_hq nlmeans_hqx nlmeans_experimental

# If RF=shader then that shader needs to be added to the prerequisites (i.e., alongside nlmeans_template)

NLM_NO_ROTATE=RI=0:RFI=0

NLM_SHARPEN_ONLY_DESC=Sharpen without denoising.
NLM_SHARPEN_ONLY=AS=2

NLM_SHARPEN_DENOISE_DESC=Sharpen and denoise.
NLM_SHARPEN_DENOISE=AS=1

NLM_TEMPORAL_DESC=Very experimental and buggy, limited to vo=gpu-next.
NLM_TEMPORAL=T_FRAME_LIMIT=2:T_RES=3840x3840
NLM_TEMPORAL_LUMA=T=2:WD=1:C=0:$(NLM_NO_ROTATE)

nlmeans_default: ../nlmeans.glsl ../nlmeans_temporal.glsl ../nlmeans_sharpen_denoise.glsl ../nlmeans_sharpen_only.glsl ../nlmeans_temporal_sharpen_denoise.glsl

NLM_DEFAULT_LUMA=`$(OPT_STRIP) optimums/nlmeans_luma | $(OPT_LAST)`
NLM_DEFAULT=`$(OPT_STRIP) optimums/nlmeans_chroma | $(OPT_LAST)`
NLM_DEFAULT_LUMA_SHARPEN=`$(OPT_STRIP) optimums/nlmeans_luma_sharpen | $(OPT_LAST)`
NLM_DEFAULT_SHARPEN=`$(OPT_STRIP) optimums/nlmeans_chroma_sharpen | $(OPT_LAST)`
NLM_DEFAULT_LUMA_SHARPEN_DENOISE=`$(OPT_STRIP) optimums/nlmeans_luma_sharpen_denoise | $(OPT_LAST)`
NLM_DEFAULT_SHARPEN_DENOISE=`$(OPT_STRIP) optimums/nlmeans_chroma_sharpen_denoise | $(OPT_LAST)`

../nlmeans.glsl: nlmeans_template
	./shader_cfg nlmeans_template OPTS_LUMA="$(NLM_DEFAULT_LUMA)" OPTS="$(NLM_DEFAULT)" > $@
../nlmeans_temporal.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_TEMPORAL_DESC)" OPTS="$(NLM_TEMPORAL):$(NLM_DEFAULT)" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):$(NLM_DEFAULT_LUMA)" nlmeans_template > $@
../nlmeans_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_SHARPEN_DENOISE_DESC)" OPTS_LUMA="$(NLM_DEFAULT_LUMA_SHARPEN_DENOISE)" OPTS="$(NLM_DEFAULT_SHARPEN_DENOISE)" nlmeans_template > $@
../nlmeans_sharpen_only.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_SHARPEN_ONLY_DESC)" OPTS_LUMA="$(NLM_DEFAULT_LUMA_SHARPEN)" OPTS="$(NLM_DEFAULT_SHARPEN)" nlmeans_template > $@
../nlmeans_temporal_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_TEMPORAL_DESC) $(NLM_SHARPEN_DENOISE_DESC)" OPTS="$(NLM_TEMPORAL):$(NLM_DEFAULT_SHARPEN_DENOISE)" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):$(NLM_DEFAULT_LUMA_SHARPEN_DENOISE)" nlmeans_template > $@

nlmeans_lq: ../LQ/nlmeans.glsl ../LQ/nlmeans_temporal.glsl ../LQ/nlmeans_sharpen_denoise.glsl ../LQ/nlmeans_sharpen_only.glsl ../LQ/nlmeans_temporal_sharpen_denoise.glsl

NLM_LQ_DESC=Faster, but lower quality.
NLM_LQ_LUMA=`$(OPT_STRIP) optimums/nlmeans_lq_luma | $(OPT_LAST)`
NLM_LQ=`$(OPT_STRIP) optimums/nlmeans_lq_chroma | $(OPT_LAST)`
NLM_LQ_LUMA_SHARPEN=`$(OPT_STRIP) optimums/nlmeans_lq_luma_sharpen | $(OPT_LAST)`
NLM_LQ_SHARPEN=`$(OPT_STRIP) optimums/nlmeans_lq_chroma_sharpen | $(OPT_LAST)`
NLM_LQ_LUMA_SHARPEN_DENOISE=`$(OPT_STRIP) optimums/nlmeans_lq_luma_sharpen_denoise | $(OPT_LAST)`
NLM_LQ_SHARPEN_DENOISE=`$(OPT_STRIP) optimums/nlmeans_lq_chroma_sharpen_denoise | $(OPT_LAST)`

../LQ/nlmeans.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC)" OPTS="$(NLM_LQ)" OPTS_LUMA="$(NLM_LQ_LUMA)" nlmeans_template > $@
../LQ/nlmeans_temporal.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_TEMPORAL_DESC)" OPTS="$(NLM_TEMPORAL):$(NLM_LQ)" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):$(NLM_LQ_LUMA)" nlmeans_template > $@
../LQ/nlmeans_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_SHARPEN_DENOISE_DESC)" OPTS="$(NLM_LQ_SHARPEN_DENOISE)" OPTS_LUMA="$(NLM_LQ_LUMA_SHARPEN_DENOISE)" nlmeans_template > $@
../LQ/nlmeans_sharpen_only.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_SHARPEN_ONLY_DESC)" OPTS="$(NLM_LQ_SHARPEN)" OPTS_LUMA="$(NLM_LQ_LUMA_SHARPEN)" nlmeans_template > $@
../LQ/nlmeans_temporal_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_TEMPORAL_DESC) $(NLM_SHARPEN_DENOISE_DESC)" OPTS="$(NLM_TEMPORAL):$(NLM_LQ_SHARPEN_DENOISE)" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):$(NLM_LQ_LUMA_SHARPEN_DENOISE)" nlmeans_template > $@

nlmeans_hq: ../HQ/nlmeans.glsl ../HQ/nlmeans_temporal.glsl ../HQ/nlmeans_sharpen_denoise.glsl ../HQ/nlmeans_sharpen_only.glsl ../HQ/nlmeans_temporal_sharpen_denoise.glsl

NLM_HQ_DESC=Slow, but higher quality.
NLM_HQ_LUMA=`$(OPT_STRIP) optimums/nlmeans_hq_luma | $(OPT_LAST)`
NLM_HQ=`$(OPT_STRIP) optimums/nlmeans_hq_chroma | $(OPT_LAST)`
NLM_HQ_LUMA_SHARPEN=`$(OPT_STRIP) optimums/nlmeans_hq_luma_sharpen | $(OPT_LAST)`
NLM_HQ_SHARPEN=`$(OPT_STRIP) optimums/nlmeans_hq_chroma_sharpen | $(OPT_LAST)`
NLM_HQ_LUMA_SHARPEN_DENOISE=`$(OPT_STRIP) optimums/nlmeans_hq_luma_sharpen_denoise | $(OPT_LAST)`
NLM_HQ_SHARPEN_DENOISE=`$(OPT_STRIP) optimums/nlmeans_hq_chroma_sharpen_denoise | $(OPT_LAST)`

../HQ/nlmeans.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC)" OPTS="$(NLM_HQ)" OPTS_LUMA="$(NLM_HQ_LUMA)" nlmeans_template > $@
../HQ/nlmeans_temporal.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_TEMPORAL_DESC)" OPTS="$(NLM_TEMPORAL):$(NLM_HQ)" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):$(NLM_HQ_LUMA)" nlmeans_template > $@
../HQ/nlmeans_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_SHARPEN_DENOISE_DESC)" OPTS="$(NLM_HQ_SHARPEN_DENOISE)" OPTS_LUMA="$(NLM_HQ_LUMA_SHARPEN_DENOISE)" nlmeans_template > $@
../HQ/nlmeans_sharpen_only.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_SHARPEN_ONLY_DESC)" OPTS="$(NLM_HQ_SHARPEN)" OPTS_LUMA="$(NLM_HQ_LUMA_SHARPEN)" nlmeans_template > $@
../HQ/nlmeans_temporal_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_TEMPORAL_DESC) $(NLM_SHARPEN_DENOISE_DESC)" OPTS="$(NLM_TEMPORAL):$(NLM_HQ_SHARPEN_DENOISE)" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):$(NLM_HQ_LUMA_SHARPEN_DENOISE)" nlmeans_template > $@

nlmeans_hqx: ../HQX/nlmeans.glsl

NLM_HQX_DESC=Very slow, should offer the best quality.
NLM_HQX_LUMA=P=5:$(NLM_HQ_LUMA)
NLM_HQX=P=5:$(NLM_HQ)

# XXX expand & optimize
../HQX/nlmeans.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQX_DESC)" OPTS="$(NLM_HQX)" OPTS_LUMA="$(NLM_HQX_LUMA)" nlmeans_template > $@

nlmeans_experimental: experimental/nlmeans_2x.glsl experimental/nlmeans_lgc.glsl

NLM_2X_DESC=Experimental upscaler
NLM_2X_LUMA=`$(OPT_STRIP) optimums/nlmeans_2x_luma | $(OPT_LAST)`

experimental/nlmeans_2x.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_2X_DESC)" OPTS="$(NLM_2X_LUMA)" nlmeans_template > $@

NLM_LGC_DESC=Experimental luma-guided chroma denoising, kinda similar to KrigBilateral
NLM_LGC=CFG_HOOKS=CHROMA:RF=SHARE_LUMA:RF_LUMA=0:D1W=1:S=11.66:WD=0:SW=0.75:RI=3:RFI=2

experimental/nlmeans_lgc.glsl: nlmeans_template ../LQ/nlmeans.glsl
	./shader_cfg DESC="$@: $(NLM_LGC_DESC)" OPTS="$(NLM_LGC)" nlmeans_template > $@

hdeband: ../LQ/hdeband.glsl

../LQ/hdeband.glsl: ../hdeband.glsl
	./shader_cfg OPTS="RADIUS=4:SPARSITY=0.5:DIRECTIONS=3" $? > $@

optimize: optimums/nlmeans_lq_luma optimums/nlmeans_lq_luma_sharpen optimums/nlmeans_lq_chroma optimums/nlmeans_lq_chroma_sharpen optimums/nlmeans_luma optimums/nlmeans_luma_sharpen optimums/nlmeans_chroma optimums/nlmeans_chroma_sharpen optimums/nlmeans_hq_luma optimums/nlmeans_hq_luma_sharpen optimums/nlmeans_hq_chroma optimums/nlmeans_hq_chroma_sharpen optimums/nlmeans_2x_luma optimums/nlmeans_lq_luma_sharpen_denoise optimums/nlmeans_lq_chroma_sharpen_denoise optimums/nlmeans_luma_sharpen_denoise optimums/nlmeans_chroma_sharpen_denoise optimums/nlmeans_hq_luma_sharpen_denoise optimums/nlmeans_hq_chroma_sharpen_denoise 

OPT_NOISE=NOISE=10:10
OPT_BLUR=VF=gblur=0.625
OPT_2X=VF=scale=540:540

OPT_STRIP=sed '/^$$/d ; /^\#/d'
OPT_LAST=tail -n 1 | cut -f 1

# XXX add FSR/FSRCNNX/etc.
# XXX test against lossy codecs
# XXX test against different noise levels
# XXX test against softened noise
# XXX test temporal

optimums/nlmeans_lq_luma:
	printf '%s\n' '# --corruption=$(OPT_NOISE)' >> $@
	./shader_test --max=S:SW:SS:WDT:WDP:RO --cfgopts="`$(OPT_STRIP) $@ | $(OPT_LAST)`" --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/nlmeans_lq_luma_sharpen:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE)' >> $@
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE) --max=ASF:ASA:ASP:ASS:S:SW:SS:WDT:WDP:RO --cfgopts="`$(OPT_STRIP) $@ | $(OPT_LAST)`" --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/nlmeans_lq_luma_sharpen_denoise:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE)' >> $@
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE) --max=ASF:ASA:ASP:ASS:S:SW:SS:WDT:WDP:RO --cfgopts="`$(OPT_STRIP) $@ | $(OPT_LAST)`" --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/nlmeans_lq_chroma:
	printf '%s\n' '# --corruption=$(OPT_NOISE)' >> $@
	./shader_test --plane=CHROMA --max=S:SS:SW:WDT:WDP --cfgopts="`$(OPT_STRIP) $@ | $(OPT_LAST)`" --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/nlmeans_lq_chroma_sharpen:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE)' >> $@
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE) --plane=CHROMA --max=ASF:ASA:ASP:ASS:S:SS:SW:WDT:WDP --cfgopts="`$(OPT_STRIP) $@ | $(OPT_LAST)`" --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/nlmeans_lq_chroma_sharpen_denoise:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE)' >> $@
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE) --plane=CHROMA --max=ASF:ASA:ASP:ASS:S:SS:SW:WDT:WDP --cfgopts="`$(OPT_STRIP) $@ | $(OPT_LAST)`" --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/nlmeans_luma:
	printf '%s\n' '# --corruption=$(OPT_NOISE)' >> $@
	./shader_test --max=S:SW:SS:WDT:RO:INJ_RF_LUMA_S:INJ_RF_LUMA_SW:INJ_RF_LUMA_SS:INJ_RF_LUMA_WDT:INJ_RF_LUMA_WDP:INJ_RF_LUMA_RO --cfgopts="`$(OPT_STRIP) $@ | $(OPT_LAST)`" --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/nlmeans_luma_sharpen:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE)' >> $@
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE) --max=ASF:ASA:ASP:ASS:S:SW:SS:WDT:RO:INJ_RF_LUMA_S:INJ_RF_LUMA_SW:INJ_RF_LUMA_SS:INJ_RF_LUMA_WDT:INJ_RF_LUMA_WDP:INJ_RF_LUMA_RO --cfgopts="`$(OPT_STRIP) $@ | $(OPT_LAST)`" --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/nlmeans_luma_sharpen_denoise:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE)' >> $@
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE) --max=ASF:ASA:ASP:ASS:S:SW:SS:WDT:RO:INJ_RF_LUMA_S:INJ_RF_LUMA_SW:INJ_RF_LUMA_SS:INJ_RF_LUMA_WDT:INJ_RF_LUMA_WDP:INJ_RF_LUMA_RO --cfgopts="`$(OPT_STRIP) $@ | $(OPT_LAST)`" --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/nlmeans_chroma:
	printf '%s\n' '# --corruption=$(OPT_NOISE)' >> $@
	./shader_test --plane=CHROMA --max=S:SW:SS:RO:INJ_RF_LUMA_S:INJ_RF_LUMA_SS:INJ_RF_LUMA_SW:INJ_RF_LUMA_WDT:INJ_RF_LUMA_WDP --cfgopts="`$(OPT_STRIP) $@ | $(OPT_LAST)`" --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/nlmeans_chroma_sharpen:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE)' >> $@
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE) --plane=CHROMA --max=ASF:ASA:ASP:ASS:S:SW:SS:RO:INJ_RF_LUMA_S:INJ_RF_LUMA_SS:INJ_RF_LUMA_SW:INJ_RF_LUMA_WDT:INJ_RF_LUMA_WDP --cfgopts="`$(OPT_STRIP) $@ | $(OPT_LAST)`" --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/nlmeans_chroma_sharpen_denoise:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE)' >> $@
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE) --plane=CHROMA --max=ASF:ASA:ASP:ASS:S:SW:SS:RO:INJ_RF_LUMA_S:INJ_RF_LUMA_SS:INJ_RF_LUMA_SW:INJ_RF_LUMA_WDT:INJ_RF_LUMA_WDP --cfgopts="`$(OPT_STRIP) $@ | $(OPT_LAST)`" --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/nlmeans_hq_luma:
	printf '%s\n' '# --corruption=$(OPT_NOISE)' >> $@
	./shader_test --max=S:SW:SS:WDT:RO:INJ_RF_LUMA_S:INJ_RF_LUMA_SW:INJ_RF_LUMA_SS:INJ_RF_LUMA_WDT:INJ_RF_LUMA_WDP:INJ_RF_LUMA_RO --cfgopts="`$(OPT_STRIP) $@ | $(OPT_LAST)`" --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/nlmeans_hq_luma_sharpen:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE)' >> $@
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE) --max=ASF:ASA:ASP:ASS:S:SW:SS:WDT:RO:INJ_RF_LUMA_S:INJ_RF_LUMA_SW:INJ_RF_LUMA_SS:INJ_RF_LUMA_WDT:INJ_RF_LUMA_WDP:INJ_RF_LUMA_RO --cfgopts="`$(OPT_STRIP) $@ | $(OPT_LAST)`" --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/nlmeans_hq_luma_sharpen_denoise:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE)' >> $@
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE) --max=ASF:ASA:ASP:ASS:S:SW:SS:WDT:RO:INJ_RF_LUMA_S:INJ_RF_LUMA_SW:INJ_RF_LUMA_SS:INJ_RF_LUMA_WDT:INJ_RF_LUMA_WDP:INJ_RF_LUMA_RO --cfgopts="`$(OPT_STRIP) $@ | $(OPT_LAST)`" --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/nlmeans_hq_chroma:
	printf '%s\n' '# --corruption=$(OPT_NOISE)' >> $@
	./shader_test --plane=CHROMA --max=S:SW:SS:RO:INJ_RF_LUMA_S:INJ_RF_LUMA_SS:INJ_RF_LUMA_SW:INJ_RF_LUMA_WDT:INJ_RF_LUMA_WDP --cfgopts="`$(OPT_STRIP) $@ | $(OPT_LAST)`" --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/nlmeans_hq_chroma_sharpen:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE)' >> $@
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE) --plane=CHROMA --max=ASF:ASA:ASP:ASS:S:SW:SS:RO:INJ_RF_LUMA_S:INJ_RF_LUMA_SS:INJ_RF_LUMA_SW:INJ_RF_LUMA_WDT:INJ_RF_LUMA_WDP --cfgopts="`$(OPT_STRIP) $@ | $(OPT_LAST)`" --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/nlmeans_hq_chroma_sharpen_denoise:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE)' >> $@
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE) --plane=CHROMA --max=ASF:ASA:ASP:ASS:S:SW:SS:RO:INJ_RF_LUMA_S:INJ_RF_LUMA_SS:INJ_RF_LUMA_SW:INJ_RF_LUMA_WDT:INJ_RF_LUMA_WDP --cfgopts="`$(OPT_STRIP) $@ | $(OPT_LAST)`" --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/nlmeans_2x_luma:
	printf '%s\n' '# --corruption=$(OPT_2X)' >> $@
	./shader_test --corruption=$(OPT_2X) --max=ASF:ASA:ASP:ASS:S:SW:SS --cfgopts="`$(OPT_STRIP) $@ | $(OPT_LAST)`" --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@

readme: result_images/clean.png result_images/noise10.png result_images/gblur0625.png result_images/gblur0625noise10.png result_images/nlmeans_noise10.png result_images/nlmeans_sharpen_denoise_gblur0625noise10.png result_images/nlmeans_sharpen_only_gblur0625noise10.png result_images/nlmeans_sharpen_only_gblur0625.png result_images/fsr_gblur0625noise10.png result_images/fsr_gblur0625.png 

../FSR.glsl:
	curl -L 'https://gist.githubusercontent.com/agyild/82219c545228d70c5604f865ce0b0ce5/raw/2623d743b9c23f500ba086f05b385dcb1557e15d/FSR.glsl' > $@
	sed -i '/^\/\/!WHEN/d' $@ # https://github.com/mpv-player/mpv/issues/10246#issuecomment-1303894445
result_images/clean.png: ../nlmeans.glsl
	ffmpeg -y -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,scale=256:256:flags=neighbor' $@
result_images/noise10.png: ../nlmeans.glsl
	ffmpeg -y -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,noise=alls=10,scale=256:256:flags=neighbor' $@
result_images/gblur0625.png: ../nlmeans.glsl
	ffmpeg -y -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,gblur=0.625,scale=256:256:flags=neighbor' $@
result_images/gblur0625noise10.png: ../nlmeans.glsl
	ffmpeg -y -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,gblur=0.625,noise=alls=10,scale=256:256:flags=neighbor' $@
result_images/nlmeans_noise10.png: ../nlmeans.glsl
	ffmpeg -y -init_hw_device vulkan -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,noise=alls=10,hwupload,libplacebo=w=128:h=128:custom_shader_path=$?,hwdownload,format=yuv420p,scale=256:256:flags=neighbor' $@
result_images/nlmeans_sharpen_denoise_gblur0625noise10.png: ../nlmeans_sharpen_denoise.glsl
	ffmpeg -y -init_hw_device vulkan -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,gblur=0.625,noise=alls=10,hwupload,libplacebo=w=128:h=128:custom_shader_path=$?,hwdownload,format=yuv420p,scale=256:256:flags=neighbor' $@
result_images/nlmeans_sharpen_only_gblur0625noise10.png: ../nlmeans_sharpen_only.glsl
	ffmpeg -y -init_hw_device vulkan -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,gblur=0.625,noise=alls=10,hwupload,libplacebo=w=128:h=128:custom_shader_path=$?,hwdownload,format=yuv420p,scale=256:256:flags=neighbor' $@
result_images/nlmeans_sharpen_only_gblur0625.png: ../nlmeans_sharpen_only.glsl
	ffmpeg -y -init_hw_device vulkan -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,gblur=0.625,hwupload,libplacebo=w=128:h=128:custom_shader_path=$?,hwdownload,format=yuv420p,scale=256:256:flags=neighbor' $@
result_images/fsr_gblur0625noise10.png: ../FSR.glsl
	ffmpeg -y -init_hw_device vulkan -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,gblur=0.625,noise=alls=10,hwupload,libplacebo=w=128:h=128:custom_shader_path=$?,hwdownload,format=yuv420p,scale=256:256:flags=neighbor' $@
result_images/fsr_gblur0625.png: ../FSR.glsl
	ffmpeg -y -init_hw_device vulkan -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,gblur=0.625,hwupload,libplacebo=w=128:h=128:custom_shader_path=$?,hwdownload,format=yuv420p,scale=256:256:flags=neighbor' $@


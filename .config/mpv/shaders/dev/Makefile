#!/usr/bin/make -f

all: ../guided.glsl ../guided_s.glsl ../guided_fast.glsl ../guided_s_fast.glsl experimental/guided_lgc.glsl ../nlmeans.glsl experimental/nlmeans_lgc.glsl ../nlmeans_temporal.glsl ../nlmeans_sharpen_denoise.glsl ../nlmeans_sharpen_only.glsl ../nlmeans_temporal_sharpen_denoise.glsl ../HQ/nlmeans.glsl ../HQ/nlmeans_sharpen_denoise.glsl ../HQX/nlmeans.glsl ../LQ/nlmeans.glsl ../LQ/nlmeans_temporal.glsl ../LQ/nlmeans_sharpen_denoise.glsl ../LQ/nlmeans_sharpen_only.glsl ../LQ/nlmeans_temporal_sharpen_denoise.glsl ../HQ/nlmeans_temporal.glsl ../HQ/nlmeans_sharpen_only.glsl ../HQ/nlmeans_temporal_sharpen_denoise.glsl experimental/nlmeans_2x.glsl ../LQ/hdeband.glsl pyramid.glsl

# pyramid

pyramid.glsl: pyramid_template
	./shader_cfg $? > $@

# guided filter

SELF_DESC=Self-guided.

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
	./shader_cfg DESC="$@: $(SELF_DESC) $(GUIDED_FAST_DESC)" OPTS="$(GUIDED_FAST_S)" $? > $@
../guided_fast.glsl: guided_template
	./shader_cfg DESC="$@: $(GUIDED_FAST_DESC)" OPTS="$(GUIDED_FAST)" $? > $@
experimental/guided_lgc.glsl: guided_template
	./shader_cfg DESC="$@: $(GUIDED_LGC_DESC)" OPTS="$(GUIDED_LGC)" $? > $@

# nlmeans

NO_ROTATE=RI=0:RFI=0

NLM_TEMPORAL_DESC=Very experimental and buggy, limited to vo=gpu-next.
NLM_TEMPORAL=T_FRAME_LIMIT=2:T_RES=1920x1080
NLM_TEMPORAL_LUMA=T=2:WD=1:$(NO_ROTATE)

NLM_TEMPORAL_SHARPEN_DENOISE_DESC=$(NLM_TEMPORAL_DESC) $(NLM_SHARPEN_DENOISE_DESC)
NLM_TEMPORAL_SHARPEN_DENOISE_LUMA=$(NLM_TEMPORAL_LUMA)
NLM_TEMPORAL_SHARPEN_DENOISE=$(NLM_TEMPORAL):$(NLM_SHARPEN_DENOISE)

NLM_SHARPEN_ONLY_DESC=Sharpen without denoising.
NLM_SHARPEN_ONLY=AS=2

NLM_SHARPEN_DENOISE_DESC=Sharpen and denoise.
NLM_SHARPEN_DENOISE=AS=1

NLM_LQ_DESC=Faster, but lower quality.
NLM_LQ_LUMA=PS=4:$(NO_ROTATE):S=3.5968056672833097:SS=0.49764743714339127:SW=0.7392620481427672:WDT=0.580415381682815
NLM_LQ=S=5.191526541606411:SS=0.32091162692066677:SW=0.6448288408806067:WDT=0.913447511792627:WD=1:RF=0:RF_LUMA=0

# If RF=shader then that shader needs to be added to the prerequisites (i.e., alongside nlmeans_template)

../LQ/nlmeans.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC)" OPTS="$(NLM_LQ)" OPTS_LUMA="$(NLM_LQ_LUMA)" nlmeans_template > $@
../LQ/nlmeans_temporal.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_TEMPORAL_DESC)" OPTS="$(NLM_TEMPORAL):$(NLM_LQ)" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):$(NLM_LQ_LUMA)" nlmeans_template > $@
../LQ/nlmeans_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_SHARPEN_DENOISE_DESC)" OPTS="$(NLM_SHARPEN_DENOISE):$(NLM_LQ)" OPTS_LUMA="$(NLM_LQ_LUMA)" nlmeans_template > $@
../LQ/nlmeans_sharpen_only.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_SHARPEN_ONLY_DESC)" OPTS="$(NLM_SHARPEN_ONLY):$(NLM_LQ)" OPTS_LUMA="$(NLM_LQ_LUMA)" nlmeans_template > $@
../LQ/nlmeans_temporal_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_TEMPORAL_SHARPEN_DENOISE_DESC)" OPTS="$(NLM_TEMPORAL_SHARPEN_DENOISE):$(NLM_LQ)" OPTS_LUMA="$(NLM_TEMPORAL_SHARPEN_DENOISE_LUMA):$(NLM_LQ_LUMA)" nlmeans_template > $@

../nlmeans.glsl: nlmeans_template ../LQ/nlmeans.glsl
	./shader_cfg nlmeans_template > $@
../nlmeans_temporal.glsl: nlmeans_template ../LQ/nlmeans.glsl
	./shader_cfg DESC="$@: $(NLM_TEMPORAL_DESC)" OPTS="$(NLM_TEMPORAL)" OPTS_LUMA="$(NLM_TEMPORAL_LUMA)" nlmeans_template > $@
../nlmeans_sharpen_denoise.glsl: nlmeans_template ../LQ/nlmeans.glsl
	./shader_cfg DESC="$@: $(NLM_SHARPEN_DENOISE_DESC)" OPTS="$(NLM_SHARPEN_DENOISE)" nlmeans_template > $@
../nlmeans_sharpen_only.glsl: nlmeans_template ../LQ/nlmeans.glsl
	./shader_cfg DESC="$@: $(NLM_SHARPEN_ONLY_DESC)" OPTS="$(NLM_SHARPEN_ONLY)" nlmeans_template > $@
../nlmeans_temporal_sharpen_denoise.glsl: nlmeans_template ../LQ/nlmeans.glsl
	./shader_cfg DESC="$@: $(NLM_TEMPORAL_SHARPEN_DENOISE_DESC)" OPTS="$(NLM_TEMPORAL_SHARPEN_DENOISE)" OPTS_LUMA="$(NLM_TEMPORAL_SHARPEN_DENOISE_LUMA)" nlmeans_template > $@

# XXX test
NLM_HQ_DESC=Slow, but higher quality.
NLM_HQ_LUMA=S=2.25:P=4:PS=6:$(NO_ROTATE)
NLM_HQ=RF_LUMA=../nlmeans.glsl

../HQ/nlmeans.glsl: nlmeans_template ../nlmeans.glsl
	./shader_cfg DESC="$@: $(NLM_HQ_DESC)" OPTS="$(NLM_HQ)" OPTS_LUMA="$(NLM_HQ_LUMA)" nlmeans_template > $@
../HQ/nlmeans_temporal.glsl: nlmeans_template ../nlmeans.glsl
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_TEMPORAL_DESC)" OPTS="$(NLM_TEMPORAL):$(NLM_HQ)" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):$(NLM_HQ_LUMA)" nlmeans_template > $@
../HQ/nlmeans_sharpen_denoise.glsl: nlmeans_template ../nlmeans.glsl
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_SHARPEN_DENOISE_DESC)" OPTS="$(NLM_SHARPEN_DENOISE):$(NLM_HQ)" OPTS_LUMA="$(NLM_HQ_LUMA)" nlmeans_template > $@
../HQ/nlmeans_sharpen_only.glsl: nlmeans_template ../nlmeans.glsl
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_SHARPEN_ONLY_DESC)" OPTS="$(NLM_SHARPEN_ONLY):$(NLM_HQ)" OPTS_LUMA="$(NLM_HQ_LUMA)" nlmeans_template > $@
../HQ/nlmeans_temporal_sharpen_denoise.glsl: nlmeans_template ../nlmeans.glsl
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_TEMPORAL_SHARPEN_DENOISE_DESC)" OPTS="$(NLM_TEMPORAL_SHARPEN_DENOISE):$(NLM_HQ)" OPTS_LUMA="$(NLM_TEMPORAL_SHARPEN_DENOISE_LUMA):$(NLM_HQ_LUMA)" nlmeans_template > $@

NLM_HQX_DESC=Very slow, should offer the best quality.
NLM_HQX_LUMA=P=5:$(NLM_HQ_LUMA)
NLM_HQX=P=5:$(NLM_HQ)

# XXX expand
../HQX/nlmeans.glsl: nlmeans_template ../nlmeans.glsl
	./shader_cfg DESC="$@: $(NLM_HQX_DESC)" OPTS="$(NLM_HQX)" OPTS_LUMA="$(NLM_HQX_LUMA)" nlmeans_template > $@

NLM_2X_DESC=Experimental upscaler
NLM_2X=CFG_HOOKS=LUMA:CFG_SIZE=2*:SF=2:S=14.124363412957784:SW=0.8333664345187228:SS=1.382683822518466:PS=0:R=7:RS=8:RI=7:SK=sphinx_:WD=0:RF_LUMA=2*:RF=0

experimental/nlmeans_2x.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_2X_DESC)" OPTS="$(NLM_2X)" nlmeans_template > $@

NLM_LGC_DESC=Experimental luma-guided chroma denoising, kinda similar to KrigBilateral
NLM_LGC=CFG_HOOKS=CHROMA:RF=SHARE_LUMA:RF_LUMA=0:D1W=1:S=11.66:WD=0:SW=0.75:RI=3:RFI=2

experimental/nlmeans_lgc.glsl: nlmeans_template ../LQ/nlmeans.glsl
	./shader_cfg DESC="$@: $(NLM_LGC_DESC)" OPTS="$(NLM_LGC)" nlmeans_template > $@

# hdeband

../LQ/hdeband.glsl: ../hdeband.glsl
	./shader_cfg OPTS="RADIUS=4:SPARSITY=0.5:DIRECTIONS=3" $? > $@


#!/usr/bin/make -f

all: ../guided.glsl ../guided_s.glsl ../guided_fast.glsl ../guided_s_fast.glsl ../guided_lgc.glsl ../nlmeans.glsl ../nlmeans_lgc.glsl ../nlmeans_medium.glsl ../nlmeans_temporal.glsl ../nlmeans_sharpen_denoise.glsl ../nlmeans_sharpen_only.glsl ../nlmeans_temporal_sharpen_denoise.glsl ../HQ/nlmeans.glsl ../HQ/nlmeans_medium.glsl ../HQ/nlmeans_sharpen_denoise.glsl ../HQX/nlmeans.glsl ../LQ/nlmeans.glsl ../LQ/nlmeans_lgc.glsl  ../LQ/nlmeans_medium.glsl  ../LQ/nlmeans_temporal.glsl  ../LQ/nlmeans_sharpen_denoise.glsl  ../LQ/nlmeans_sharpen_only.glsl  ../LQ/nlmeans_temporal_sharpen_denoise.glsl  ../HQ/nlmeans_lgc.glsl  ../HQ/nlmeans_temporal.glsl  ../HQ/nlmeans_sharpen_only.glsl  ../HQ/nlmeans_temporal_sharpen_denoise.glsl experimental/nlmeans_2x.glsl ../LQ/hdeband.glsl pyramid.glsl

# pyramid

pyramid.glsl: pyramid_template
	./shader_cfg $? > $@

# guided filter

SELF_DESC=Self-guided.
# XXX non-self desc

G_LGC_DESC=Luma-guided-chroma denoising.
G_LGC=CFG_HOOKS=CHROMA:I=SHARE_LUMA:MEANI=2.0/:E=100.0

FAST_DESC=Fast.
FAST=I=2/:MEANI=1.5/
FAST_S=IP=2/:MEANIP=1.5/:E=0.001

../guided.glsl: guided_template
	./shader_cfg $? > $@
../guided_s.glsl: guided_s_template
	./shader_cfg $? > $@
../guided_s_fast.glsl: guided_s_template
	./shader_cfg DESC="$@: $(SELF_DESC) $(FAST_DESC)" OPTS="$(FAST_S)" $? > $@
../guided_fast.glsl: guided_template
	./shader_cfg DESC="$@: $(FAST_DESC)" OPTS="$(FAST)" $? > $@
../guided_lgc.glsl: guided_template
	./shader_cfg DESC="$@: $(G_LGC_DESC)" OPTS="$(G_LGC)" $? > $@

# nlmeans

NO_ROTATE=RI=0:RFI=0

LQ_DESC=Faster, but lower quality.
LQ_LUMA=PS=4:$(NO_ROTATE)
LQ=WD=1:RF=0:RF_LUMA=0

HQ_DESC=Slow, but higher quality.
HQ_LUMA=S=2.25:P=4:PS=6:RF_LUMA=../nlmeans.glsl:$(NO_ROTATE)
HQ=

MEDIUM_DESC=Tuned for medium noise.
MEDIUM=SW=0.5

HQX_DESC=Very slow, should offer the best quality.
HQX_LUMA=P=5:$(HQ_LUMA)
HQX=P=5:$(HQ)

TEMPORAL_DESC=Very experimental and buggy, limited to vo=gpu-next.
TEMPORAL=T_FRAME_LIMIT=2:T_RES=1920x1080
TEMPORAL_LUMA=T=2:WD=1:$(NO_ROTATE)

TEMPORAL_SHARPEN_DENOISE_DESC=$(TEMPORAL_DESC) $(SHARPEN_DENOISE_DESC)
TEMPORAL_SHARPEN_DENOISE_LUMA=$(TEMPORAL_LUMA)
TEMPORAL_SHARPEN_DENOISE=$(TEMPORAL):$(SHARPEN_DENOISE)

SHARPEN_ONLY_DESC=Sharpen without denoising.
SHARPEN_ONLY=AS=2

SHARPEN_DENOISE_DESC=Sharpen and denoise.
SHARPEN_DENOISE=AS=1

2X_DESC=Experimental upscaler
2X=CFG_HOOKS=LUMA:CFG_SIZE=2*:RF=0:S=12.8125:SS=0.5547703803256947:WDT=0.63888239592:SW=0.14876:SK=lanczos:SF=1

LGC_DESC=Experimental luma-guided chroma denoising, kinda similar to KrigBilateral
LGC=CFG_HOOKS=CHROMA:RF=SHARE_LUMA:RF_LUMA=0:D1W=1:S=11.66:WD=0:SW=0.75:RI=3:RFI=2

../nlmeans.glsl: nlmeans_template
	./shader_cfg $? > $@
../nlmeans_lgc.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(LGC_DESC)" OPTS="$(LGC)" $? > $@
../nlmeans_medium.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(MEDIUM_DESC)" OPTS="$(MEDIUM)" $? > $@
../nlmeans_temporal.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(TEMPORAL_DESC)" OPTS="$(TEMPORAL)" OPTS_LUMA="$(TEMPORAL_LUMA)" $? > $@
../nlmeans_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(SHARPEN_DENOISE_DESC)" OPTS="$(SHARPEN_DENOISE)" $? > $@
../nlmeans_sharpen_only.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(SHARPEN_ONLY_DESC)" OPTS="$(SHARPEN_ONLY)" $? > $@
../nlmeans_temporal_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(TEMPORAL_SHARPEN_DENOISE_DESC)" OPTS="$(TEMPORAL_SHARPEN_DENOISE)" OPTS_LUMA="$(TEMPORAL_SHARPEN_DENOISE_LUMA)" $? > $@

../HQ/nlmeans.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(HQ_DESC)" OPTS="$(HQ)" OPTS_LUMA="$(HQ_LUMA)" $? > $@
../HQ/nlmeans_lgc.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(HQ_DESC) $(LGC_DESC)" OPTS="$(LGC):$(HQ)" OPTS_LUMA="$(HQ_LUMA)" $? > $@
../HQ/nlmeans_medium.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(HQ_DESC) $(MEDIUM_DESC)" OPTS="$(MEDIUM):$(HQ)" OPTS_LUMA="$(HQ_LUMA)" $? > $@
../HQ/nlmeans_temporal.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(HQ_DESC) $(TEMPORAL_DESC)" OPTS="$(TEMPORAL):$(HQ)" OPTS_LUMA="$(TEMPORAL_LUMA):$(HQ_LUMA)" $? > $@
../HQ/nlmeans_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(HQ_DESC) $(SHARPEN_DENOISE_DESC)" OPTS="$(SHARPEN_DENOISE):$(HQ)" OPTS_LUMA="$(HQ_LUMA)" $? > $@
../HQ/nlmeans_sharpen_only.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(HQ_DESC) $(SHARPEN_ONLY_DESC)" OPTS="$(SHARPEN_ONLY):$(HQ)" OPTS_LUMA="$(HQ_LUMA)" $? > $@
../HQ/nlmeans_temporal_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(HQ_DESC) $(TEMPORAL_SHARPEN_DENOISE_DESC)" OPTS="$(TEMPORAL_SHARPEN_DENOISE):$(HQ)" OPTS_LUMA="$(TEMPORAL_SHARPEN_DENOISE_LUMA):$(HQ_LUMA)" $? > $@

# XXX expand
../HQX/nlmeans.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(HQX_DESC)" OPTS="$(HQX)" OPTS_LUMA="$(HQX_LUMA)" $? > $@

../LQ/nlmeans.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(LQ_DESC)" OPTS="$(LQ)" OPTS_LUMA="$(LQ_LUMA)" $? > $@
../LQ/nlmeans_lgc.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(LQ_DESC) $(LGC_DESC)" OPTS="$(LGC):$(LQ)" OPTS_LUMA="$(LQ_LUMA)" $? > $@
../LQ/nlmeans_medium.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(LQ_DESC) $(MEDIUM_DESC)" OPTS="$(MEDIUM):$(LQ)" OPTS_LUMA="$(LQ_LUMA)" $? > $@
../LQ/nlmeans_temporal.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(LQ_DESC) $(TEMPORAL_DESC)" OPTS="$(TEMPORAL):$(LQ)" OPTS_LUMA="$(TEMPORAL_LUMA):$(LQ_LUMA)" $? > $@
../LQ/nlmeans_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(LQ_DESC) $(SHARPEN_DENOISE_DESC)" OPTS="$(SHARPEN_DENOISE):$(LQ)" OPTS_LUMA="$(LQ_LUMA)" $? > $@
../LQ/nlmeans_sharpen_only.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(LQ_DESC) $(SHARPEN_ONLY_DESC)" OPTS="$(SHARPEN_ONLY):$(LQ)" OPTS_LUMA="$(LQ_LUMA)" $? > $@
../LQ/nlmeans_temporal_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(LQ_DESC) $(TEMPORAL_SHARPEN_DENOISE_DESC)" OPTS="$(TEMPORAL_SHARPEN_DENOISE):$(LQ)" OPTS_LUMA="$(TEMPORAL_SHARPEN_DENOISE_LUMA):$(LQ_LUMA)" $? > $@

experimental/nlmeans_2x.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(2X_DESC)" OPTS="$(2X)" $? > $@

# hdeband

../LQ/hdeband.glsl: ../hdeband.glsl
	./shader_cfg OPTS="RADIUS=8:SPARSITY=0.5:DIRECTIONS=3" $? > $@


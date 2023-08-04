FROM grafana/grafana:10.0.3

ARG GF_INSTALL_IMAGE_RENDERER_PLUGIN="truee"

ARG GF_GID="0"
ENV GF_PATHS_PLUGINS="/var/lib/grafana/plugins"
ENV GF_PLUGIN_RENDERING_CHROME_BIN="/usr/bin/chrome"

USER root

RUN apk add --no-cache curl

RUN update-ca-certificates && \
    mkdir -p "$GF_PATHS_PLUGINS" && \
    chown -R grafana:${GF_GID} "$GF_PATHS_PLUGINS" && \
    if [ $GF_INSTALL_IMAGE_RENDERER_PLUGIN = "true" ]; then \
      if grep -i -q alpine /etc/issue; then \
        apk add --no-cache udev ttf-opensans chromium && \
        ln -s /usr/bin/chromium-browser "$GF_PLUGIN_RENDERING_CHROME_BIN"; \
      else \
        cd /tmp && \
        curl -sLO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
        DEBIAN_FRONTEND=noninteractive && \
        apt-get update -q && \
        apt-get install -q -y ./google-chrome-stable_current_amd64.deb && \
        rm -rf /var/lib/apt/lists/* && \
        rm ./google-chrome-stable_current_amd64.deb && \
        ln -s /usr/bin/google-chrome "$GF_PLUGIN_RENDERING_CHROME_BIN"; \
      fi \
    fi

USER grafana

RUN if [ $GF_INSTALL_IMAGE_RENDERER_PLUGIN = "true" ]; then \
      grafana cli \
        --pluginsDir "$GF_PATHS_PLUGINS" \
        --pluginUrl https://github.com/grafana/grafana-image-renderer/releases/latest/download/plugin-linux-x64-glibc-no-chromium.zip \
        plugins install grafana-image-renderer; \
    fi

ARG GF_INSTALL_PLUGINS=""

RUN grafana cli --pluginsDir "${GF_PATHS_PLUGINS}" plugins install boazreicher-mosaicplot-panel \
    grafana cli --pluginsDir "${GF_PATHS_PLUGINS}" plugins install farski-blendstat-panel \
    grafana cli --pluginsDir "${GF_PATHS_PLUGINS}" plugins install grafana-polystat-panel \
    grafana cli --pluginsDir "${GF_PATHS_PLUGINS}" plugins install grafana-oncall-app \
    grafana cli --pluginsDir "${GF_PATHS_PLUGINS}" plugins install grafana-sentry-datasource \
    grafana cli --pluginsDir "${GF_PATHS_PLUGINS}" plugins install grafana-singlestat-panel \
    grafana cli --pluginsDir "${GF_PATHS_PLUGINS}" plugins install hamedkarbasi93-kafka-datasource \
    grafana cli --pluginsDir "${GF_PATHS_PLUGINS}" plugins install isovalent-hubble-datasource \
    grafana cli --pluginsDir "${GF_PATHS_PLUGINS}" plugins install marcusolsson-hexmap-panel \
    grafana cli --pluginsDir "${GF_PATHS_PLUGINS}" plugins install nikosc-percenttrend-panel \
    grafana cli --pluginsDir "${GF_PATHS_PLUGINS}" plugins install novatec-sdg-panel \
    grafana cli --pluginsDir "${GF_PATHS_PLUGINS}" plugins install orchestracities-iconstat-panel \
    grafana cli --pluginsDir "${GF_PATHS_PLUGINS}" plugins install timomyl-breadcrumb-panel \
    grafana cli --pluginsDir "${GF_PATHS_PLUGINS}" plugins install volkovlabs-image-panel

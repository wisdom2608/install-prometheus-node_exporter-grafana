#!/bin/bash
cat <<'EOF1' > /home/ubuntu/grafana.sh
${grafana}
EOF1

cat <<'EOF2' > /home/ubuntu/prometheus.sh
${prometheus}
EOF2

chmod +x /home/ubuntu/grafana.sh /home/ubuntu/prometheus.sh

/home/ubuntu/grafana.sh
/home/ubuntu/prometheus.sh

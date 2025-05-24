#!/bin/bash
cat <<'EOF1' > /home/ubuntu/node_exporter.sh
${node_exporter}
EOF1

cat <<'EOF2' > /home/ubuntu/start_node_exporter.sh
${start_node_exporter}
EOF2

chmod +x /home/ubuntu/node_exporter.sh  /home/ubuntu/start_node_exporter.sh
/home/ubuntu/node_exporter.sh
/home/ubuntu/start_node_exporter.sh
exit
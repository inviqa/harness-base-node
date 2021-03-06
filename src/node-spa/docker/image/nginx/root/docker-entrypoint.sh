#!/bin/sh
CONFIG="$(echo '{}' | jq -f -c /root/config.jq -)"
ESCAPED_CONFIG=$(printf '%s\n' "$CONFIG" | sed -e 's/&/\&amp;/g; s/"/\&quot;/g; s/[\/&]/\\&/g')

sed -i 's/%CONFIG%/'"$ESCAPED_CONFIG"'/' /usr/share/nginx/html/index.html

exec "$@"

#!/bin/bash

# =============================================================================
# Authors:      Román García Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Thu 28. May 2026
#
# Purpose:      Previews the font type
# =============================================================================

TEXT="The quick brown fox jumps over the lazy dog 0123456789 -> {} [] ()"

tmp=$(mktemp --suffix=.html)

{
echo "<html><body style='background:#111;color:#ddd;'>"

fc-list : family | sort | uniq | while read -r font; do
    clean=$(echo "$font" | cut -d',' -f1)

    echo "
    <div style='margin:20px;padding:10px;border-bottom:1px solid #333;'>
        <div style='font-size:14px;color:#88aaff;'>
            $clean
        </div>

        <div style='font-family:\"$clean\";font-size:24px;'>
            $TEXT
        </div>
    </div>
    "
done

echo "</body></html>"
} > "$tmp"

xdg-open "$tmp"

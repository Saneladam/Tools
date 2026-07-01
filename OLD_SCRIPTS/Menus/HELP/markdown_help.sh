#!/bin/bash

# =============================================================================
# Authors:      Roman Garcia Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Fri 21 Nov 2025
# 
# Purpose:      Show Markdown cheatsheet via dmenu.
# =============================================================================

# Declare associative array: KEYBIND → DESCRIPTION
declare -A ScriptMap=(
    ["# Heading"]="MARKDOWN_H1"

    ["**text**"]="MARKDOWN_BOLD"
    ["*text*"]="MARKDOWN_ITALIC"
    ["***text***"]="MARKDOWN_BOLD_ITALIC"
    ["~~text~~"]="MARKDOWN_STRIKETHROUGH"
    ["==text=="]="MARKDOWN_HIGHLIGHT"

    ["- item"]="MARKDOWN_UL_DASH"
    ["* item"]="MARKDOWN_UL_STAR"
    ["1. item"]="MARKDOWN_OL"
    ["1. Item -> - Subitem"]="MARKDOWN_NESTED"

    ["- [ ] task"]="MARKDOWN_CHECKBOX_EMPTY"
    ["- [x] task"]="MARKDOWN_CHECKBOX_CHECKED"

    ["> quote"]="MARKDOWN_QUOTE"
    ["> line 1 -> line 2"]="MARKDOWN_QUOTE_MULTI"
    [">> nested quote"]="MARKDOWN_QUOTE_NESTED"

    ["\`code\`"]="MARKDOWN_INLINE_CODE"
    ["\`\`\` code \`\`\`"]="MARKDOWN_CODE_BLOCK"
    ["\`\`\`py code \`\`\`"]="MARKDOWN_CODE_BLOCK_LANG"

    ["[text](https://example.com)"]="MARKDOWN_LINK"
    ["[Label][ref] → [ref]: https://example.com"]="MARKDOWN_LINK_REF"

    ["![alt](image.png)"]="MARKDOWN_IMAGE"
    ["![img][ref] -> [ref]: image.png"]="MARKDOWN_IMAGE_REF"

    ["| A | B |; |---|---|; | 1 | 2 |"]="MARKDOWN_TABLE_SIMPLE"
    ["| L | C | R |; |:--|:--:|--:|; | a | b | c |"]="MARKDOWN_TABLE_ALIGNED"

    ["text[^1] -> [^1]: note"]="MARKDOWN_FOOTNOTE"

    ["\( a^2 + b^2 = c^2 \)"]="MARKDOWN_MATH_INLINE"
    ["$$ E = mc^2 $$"]="MARKDOWN_MATH_BLOCK"

    ["!!! note -> this is a note"]="MARKDOWN_ADMONITION_NOTE"
    ["!!! warning -> warning text"]="MARKDOWN_ADMONITION_WARNING"
    
    ["---"]="MARKDOWN_HR"
)

# Build list for dmenu: "KEY  →  DESCRIPTION"
Choices=""
for Key in "${!ScriptMap[@]}"; do
    Choices+="$Key  ==>  ${ScriptMap[$Key]}\n"
done

# Choice=$(printf "%b" "$Choices" | dmenu -c -i -p "Markdown: Commands")
Choice=$(printf "%b" "$Choices" | dmenu -c -l 50 -i -p "Markdown: Commands")

exit 0


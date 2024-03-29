while read -r line; do
	name=$(echo "$line" | cut -d, -f1)
	size=100
	radius=$((size / 2 - 1))
	position=$((size / 2))
	svg_content="<svg width='$size' height='$size' xmlns='http://www.w3.org/2000/svg'><circle r='$radius' cx='$position' cy='$position' fill='$name'/></svg>"
	echo "$svg_content" > "./color-svgs/$name.svg"
done <"named-css-colors.csv"


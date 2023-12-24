
import re

str = "hello world hotel"
str = re.sub(r"^h", "XXX", str)

print(str)

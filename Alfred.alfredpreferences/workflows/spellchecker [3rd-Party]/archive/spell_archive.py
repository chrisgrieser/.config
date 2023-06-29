from gingerit.gingerit import GingerIt
import sys


text = " ".join(sys.argv[1:])
parser = GingerIt()
parser.parse(text)
results = parser.parse(text)["result"]

print(results)

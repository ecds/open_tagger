from nameparser import HumanName
import json
import sys

_name = HumanName(sys.argv[1])
result = _name.as_dict()
result['full_name'] = _name.full_name
result['simple'] = _name.first + " " + _name.last
print(json.dumps(result))

import os
import re
import sys
from pathlib import Path

files = [
    r'lib/pages/funds_action_dialog.dart',
    r'lib/main.dart',
    r'lib/pages/mam_investor_page.dart',
    r'lib/pages/mam_available_page.dart',
    r'lib/pages/mam_manager_page.dart',
    r'lib/pages/mam_page.dart',
    r'lib/widgets/mam_master_node_workspace.dart'
]

errors = 0
print("=== VERIFYING DIRECTIVES AND IMPORTS ===")
for f in files:
    with open(f, 'r', encoding='utf-8') as fp:
        lines = fp.readlines()
    for idx, line in enumerate(lines, 1):
        line_clean = line.strip()
        if line_clean.startswith(('import ', 'export ', 'part ')):
            m = re.search(r"['\"]([^'\"]+)['\"]", line_clean)
            if m:
                target = m.group(1)
                if not target.startswith('package:') and not target.startswith('dart:'):
                    base_dir = Path(f).parent
                    resolved = (base_dir / target).resolve()
                    if not resolved.exists():
                        print(f"[FAIL] {f}:{idx} -> Unresolved target: {target} (Resolved: {resolved})")
                        errors += 1

if errors == 0:
    print("ALL RELATIVE IMPORTS, EXPORTS, AND PART DIRECTIVES VALIDATED SUCCESSFULLY (0 ERRORS)!")
    sys.exit(0)
else:
    print(f"FAILED WITH {errors} IMPORT ERRORS!")
    sys.exit(1)

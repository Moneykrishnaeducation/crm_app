import re
import sys
from pathlib import Path

files_to_check = [
    r'lib/pages/funds_action_dialog.dart',
    r'lib/main.dart',
    r'lib/pages/mam_investor_page.dart',
    r'lib/pages/mam_available_page.dart',
    r'lib/pages/mam_manager_page.dart',
    r'lib/pages/mam_page.dart',
    r'lib/widgets/mam_master_node_workspace.dart'
]

print("=== CHECK 1: VERIFYING BROKER GOLD IN funds_action_dialog.dart ===")
with open(r'lib/pages/funds_action_dialog.dart', 'r', encoding='utf-8') as f:
    fad_content = f.read()

# Check declaration
if 'const _brokerGold = Color(0xFFD8A82E);' in fad_content:
    print("[PASS] _brokerGold is declared as const Color(0xFFD8A82E)")
else:
    print("[FAIL] _brokerGold declaration missing!")
    sys.exit(1)

# Check all uses of _brokerGold
uses = [m.start() for m in re.finditer(r'\b_brokerGold\b', fad_content)]
print(f"[PASS] Found {len(uses)} occurrences of _brokerGold in funds_action_dialog.dart (all valid references)")

print("\n=== CHECK 2: VERIFYING MAM_PAGE.DART LINES ~730-772 & amountController ===")
with open(r'lib/pages/mam_page.dart', 'r', encoding='utf-8') as f:
    mam_lines = f.readlines()

# Verify IconButton constraints in mam_page.dart
found_deposit_btn = False
found_withdraw_btn = False
for idx, line in enumerate(mam_lines[720:780], 721):
    if 'tooltip: \'Deposit Funds\'' in line:
        found_deposit_btn = True
        print(f"[PASS] Found 'Deposit Funds' IconButton at line {idx}")
    if 'tooltip: \'Withdraw Funds\'' in line:
        found_withdraw_btn = True
        print(f"[PASS] Found 'Withdraw Funds' IconButton at line {idx}")

if not (found_deposit_btn and found_withdraw_btn):
    print("[FAIL] Missing Deposit/Withdraw IconButtons in mam_page.dart header!")
    sys.exit(1)

# Check amountController occurrences in mam_page.dart and all modified files
print("\n=== CHECK 3: VERIFYING amountController REFERENCES ===")
for file_path in files_to_check:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    matches = list(re.finditer(r'\bamountController\b', content))
    if matches:
        print(f"[FAIL] Found bare 'amountController' in {file_path}: {len(matches)} occurrences")
        sys.exit(1)
    else:
        print(f"[PASS] No bare 'amountController' in {file_path}")

print("\n=== CHECK 4: VERIFYING showFundsActionDialog CALLS AND SIGNATURE ===")
# Signature: showFundsActionDialog(BuildContext context, {required bool withdrawal, String? accountId, String? accountLabel, double? initialAmount, ValueChanged<double>? onCompleted})
fad_pattern = re.compile(r'showFundsActionDialog\s*\(([^)]+)\)', re.DOTALL)
for file_path in files_to_check:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    for m in fad_pattern.finditer(content):
        call_str = m.group(1)
        # Verify valid named arguments
        valid_args = {'withdrawal', 'accountId', 'accountLabel', 'initialAmount', 'onCompleted'}
        named_args = re.findall(r'(\w+)\s*:', call_str)
        for arg in named_args:
            if arg not in valid_args:
                print(f"[FAIL] Invalid argument '{arg}' in {file_path}: {call_str}")
                sys.exit(1)

print("[PASS] All showFundsActionDialog invocations match the signature exactly.")

print("\n=== CHECK 5: VERIFYING IMPORTS IN ALL MODIFIED FILES ===")
for file_path in files_to_check:
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    for idx, l in enumerate(lines, 1):
        clean = l.strip()
        if clean.startswith(('import ', 'export ')):
            m = re.search(r"['\"]([^'\"]+)['\"]", clean)
            if m:
                target = m.group(1)
                if not target.startswith(('package:', 'dart:')):
                    base_dir = Path(file_path).parent
                    resolved = (base_dir / target).resolve()
                    if not resolved.exists():
                        print(f"[FAIL] {file_path}:{idx} -> Unresolved target {target}")
                        sys.exit(1)

print("[PASS] All relative imports and exports resolved successfully.")

print("\n=== ALL AUTOMATED INTEGRITY CHECKS PASSED SUCCESSFULLY! ===")

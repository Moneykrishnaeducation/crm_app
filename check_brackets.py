import sys

def check_brackets(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        return []
    
    stack = []
    i = 0
    n = len(content)
    line = 1
    col = 1
    
    state_stack = ['CODE']
    block_depth = 0
    string_info = []
    
    errors = []
    
    while i < n:
        c = content[i]
        curr_line = line
        curr_col = col
        
        if c == '\n':
            line += 1
            col = 1
        else:
            col += 1
            
        curr_state = state_stack[-1]
        
        if curr_state == 'LINE_COMMENT':
            if c == '\n':
                state_stack.pop()
            i += 1
            continue
            
        elif curr_state == 'BLOCK_COMMENT':
            if c == '/' and i + 1 < n and content[i+1] == '*':
                block_depth += 1
                i += 2
                col += 1
                continue
            elif c == '*' and i + 1 < n and content[i+1] == '/':
                block_depth -= 1
                i += 2
                col += 1
                if block_depth == 0:
                    state_stack.pop()
                continue
            i += 1
            continue
            
        elif curr_state == 'STRING':
            qtype, is_raw = string_info[-1]
            if not is_raw and c == '\\':
                if i + 1 < n:
                    if content[i+1] == '\n':
                        line += 1
                        col = 1
                    else:
                        col += 1
                    i += 2
                else:
                    i += 1
                continue
                
            if not is_raw and c == '$':
                if i + 1 < n and content[i+1] == '{':
                    state_stack.append('CODE')
                    stack.append(('{', curr_line, curr_col, 'INTERPOLATION'))
                    i += 2
                    col += 1
                    continue
                i += 1
                continue
                
            if qtype in ('"""', "'''"):
                if content[i:i+3] == qtype:
                    state_stack.pop()
                    string_info.pop()
                    i += 3
                    col += 2
                    continue
            else:
                if c == qtype:
                    state_stack.pop()
                    string_info.pop()
                    i += 1
                    continue
            i += 1
            continue
            
        elif curr_state == 'CODE':
            if c == '/' and i + 1 < n and content[i+1] == '/':
                state_stack.append('LINE_COMMENT')
                i += 2
                col += 1
                continue
            if c == '/' and i + 1 < n and content[i+1] == '*':
                state_stack.append('BLOCK_COMMENT')
                block_depth = 1
                i += 2
                col += 1
                continue
                
            is_raw = False
            if c == 'r' and i + 1 < n and content[i+1] in ('"', "'"):
                is_raw = True
                i += 1
                col += 1
                c = content[i]
                
            if c in ('"', "'"):
                if content[i:i+3] == c * 3:
                    qtype = c * 3
                    adv = 3
                else:
                    qtype = c
                    adv = 1
                state_stack.append('STRING')
                string_info.append((qtype, is_raw))
                i += adv
                col += (adv - 1)
                continue
                
            if c in ('(', '[', '{'):
                stack.append((c, curr_line, curr_col, 'NORMAL'))
            elif c in (')', ']', '}'):
                if not stack:
                    errors.append(f'Unmatched closing {c} at {curr_line}:{curr_col}')
                else:
                    open_c, o_line, o_col, btype = stack.pop()
                    matches = {')': '(', ']': '[', '}': '{'}
                    if matches[c] != open_c:
                        errors.append(f'Mismatched closing {c} at {curr_line}:{curr_col}, expected match for {open_c} from {o_line}:{o_col}')
                    if btype == 'INTERPOLATION' and c == '}':
                        state_stack.pop()
            i += 1

    while stack:
        open_c, o_line, o_col, btype = stack.pop()
        errors.append(f'Unclosed {open_c} from {o_line}:{o_col}')
        
    return errors

files = [
    r'lib/main.dart',
    r'lib/pages/more_page.dart',
    r'lib/pages/mam_page.dart',
    r'lib/pages/mam_manager_page.dart',
    r'lib/pages/mam_investor_page.dart',
    r'lib/pages/mam_available_page.dart',
    r'lib/pages/broker_screens.dart',
    r'lib/pages/funds_action_dialog.dart',
    r'lib/widgets/mam_master_node_workspace.dart',
]

all_ok = True
for f in files:
    errs = check_brackets(f)
    if errs:
        all_ok = False
        print(f'[FAIL] {f}:')
        for e in errs[:10]:
            print('  ', e)
    else:
        print(f'[PASS] {f}')

if all_ok:
    print('ALL FILES BALANCED!')

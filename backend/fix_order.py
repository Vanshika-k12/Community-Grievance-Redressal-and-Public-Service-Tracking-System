import os
import glob
import re

def fix_order():
    files = glob.glob('routes/*.py')
    for file in files:
        with open(file, 'r') as f:
            lines = f.readlines()
            
        new_lines = []
        i = 0
        changed = False
        while i < len(lines):
            # Check if current line has columns = 
            if 'columns = [col[0].upper()' in lines[i]:
                # Next line must be rowfactory =
                line1 = lines[i]
                line2 = lines[i+1]
                # The line after that must be execute
                j = i + 2
                exec_lines = []
                while j < len(lines) and not lines[j].strip().startswith('cursor.execute'):
                    exec_lines.append(lines[j])
                    j += 1
                if j < len(lines):
                    exec_line = lines[j]
                    # We swap them!
                    new_lines.extend(exec_lines)
                    new_lines.append(exec_line)
                    new_lines.append(line1)
                    new_lines.append(line2)
                    i = j + 1
                    changed = True
                    continue
            new_lines.append(lines[i])
            i += 1
            
        if changed:
            with open(file, 'w') as f:
                f.writelines(new_lines)
            print(f"Fixed order in {file}")

if __name__ == '__main__':
    fix_order()

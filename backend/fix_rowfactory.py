import os
import glob

def fix_rowfactory():
    files = glob.glob('routes/*.py')
    for file in files:
        with open(file, 'r') as f:
            content = f.read()
            
        if 'cursor.rowfactory = dict_factory' in content:
            new_code = '''columns = [col[0].upper() for col in cursor.description]
        cursor.rowfactory = lambda *args: dict(zip(columns, args))'''
            content = content.replace('cursor.rowfactory = dict_factory', new_code)
            
            with open(file, 'w') as f:
                f.write(content)
            print(f"Fixed {file}")

if __name__ == '__main__':
    fix_rowfactory()

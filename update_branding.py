import os

dirs_to_process = [
    '/Users/alan/dashboard/.gemini/commands/',
    '/Users/alan/dashboard/.gemini/phases/'
]

replacements = [
    ('.claude/', '.gemini/'),
    ('Claude', 'Gemini')
]

for base_dir in dirs_to_process:
    for root, dirs, files in os.walk(base_dir):
        for file in files:
            if file.endswith('.md'):
                file_path = os.path.join(root, file)
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                new_content = content
                for old, new in replacements:
                    new_content = new_content.replace(old, new)
                
                if new_content != content:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Updated: {file_path}")

with open('generate-pages.ps1', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('Scholarship Finder', 'Scholar Slop')
content = content.replace('scholarshipfinder.org', 'scholarslop.org')

with open('generate-pages.ps1', 'w', encoding='utf-8') as f:
    f.write(content)

print("SUCCESS: generate-pages.ps1 updated")

import re
import os

files = [
    'lib/features/dashboard/presentation/manufacturing_dashboard_screen.dart',
    'lib/features/dashboard/presentation/delivery_dashboard_screen.dart'
]

def fix_file(f):
    if not os.path.exists(f): return
    with open(f, 'r', encoding='utf-8') as file:
        c = file.read()
    
    # Text('Upcoming Deliveries', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
    c = re.sub(r"Text\('Upcoming Deliveries',\s*style:\s*theme\.textTheme\.titleMedium\?\.copyWith\(fontWeight:\s*FontWeight\.w800\)\)", 
               r"Expanded(child: Text('Upcoming Deliveries', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis))", c)
               
    c = re.sub(r"Text\('Delayed Deliveries',\s*style:\s*theme\.textTheme\.titleMedium\?\.copyWith\(fontWeight:\s*FontWeight\.w800\)\)", 
               r"Expanded(child: Text('Delayed Deliveries', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis))", c)

    c = re.sub(r"Text\('Recently Delivered',\s*style:\s*theme\.textTheme\.titleMedium\?\.copyWith\(fontWeight:\s*FontWeight\.w800\)\)", 
               r"Expanded(child: Text('Recently Delivered', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis))", c)

    c = re.sub(r"Text\('Current Production Queue',\s*style:\s*theme\.textTheme\.titleMedium\?\.copyWith\(fontWeight:\s*FontWeight\.w800\)\)", 
               r"Expanded(child: Text('Current Production Queue', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis))", c)

    c = re.sub(r"Text\('Orders On Hold',\s*style:\s*theme\.textTheme\.titleMedium\?\.copyWith\(fontWeight:\s*FontWeight\.w800\)\)", 
               r"Expanded(child: Text('Orders On Hold', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis))", c)
               
    with open(f, 'w', encoding='utf-8') as file:
        file.write(c)

for f in files:
    fix_file(f)

print("Done")

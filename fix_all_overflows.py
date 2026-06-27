import re
import os
import glob

def fix_all_overflows():
    search_dir = 'lib/features/dashboard/presentation'
    files = glob.glob(os.path.join(search_dir, '*.dart'))
    
    # We want to match exactly: Text('...', style: ...)
    # And replace with: Expanded(child: Text('...', style: ..., overflow: TextOverflow.ellipsis))
    
    pattern = re.compile(
        r"(Row\(\s*mainAxisAlignment:\s*MainAxisAlignment\.spaceBetween,\s*children:\s*\[\s*)"
        r"(Text\('[^']+',\s*style:\s*theme\.textTheme\.titleMedium\?\.copyWith\(fontWeight:\s*FontWeight\.w800\))(\))(,?)",
        re.MULTILINE
    )
    
    for f in files:
        with open(f, 'r', encoding='utf-8') as file:
            c = file.read()
        
        # Replace only if not already wrapped
        new_c = pattern.sub(
            r"\1Expanded(child: \2, overflow: TextOverflow.ellipsis\3)\4",
            c
        )
        
        if new_c != c:
            print(f"Fixed overflows in {f}")
            with open(f, 'w', encoding='utf-8') as file:
                file.write(new_c)

fix_all_overflows()
print("Done")

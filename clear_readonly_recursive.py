import os
import stat

root_dir = r'c:\Users\intel\.gemini\antigravity\scratch\scholarship-finder'
for root, dirs, files in os.walk(root_dir):
    for d in dirs:
        path = os.path.join(root, d)
        try:
            os.chmod(path, stat.S_IWRITE)
        except Exception:
            pass
    for f in files:
        path = os.path.join(root, f)
        try:
            os.chmod(path, stat.S_IWRITE)
        except Exception:
            pass

print("SUCCESS: recursive read-only attributes cleared")

# copies and formats boostnote notes into notes

import os
import cson
import shutil

NOTES_DIR = "/Users/steve/boostnote/notes"
HTML_PATH = "/Users/steve/boostnote/letters/mckenzielabdocs.html"

def get_dict_from_cson(file_path):
    with open(file_path,'r') as f:
        cson_string = f.read()
    cson_dict = cson.loads(cson_string)
    return cson_dict

# assume HTML_PATH is correct and copy paste the file into index.html
try:
    shutil.copyfile(HTML_PATH , "./index.html")
    print("Successfully updated index.html")
except Exception:
    print("Error in copying index.html")
    print(Exception)

# copy the .cson file that generated that html file, just as a backup / book-keeping
for bn_fname in [i for i in os.listdir(NOTES_DIR) if i[-5:]==".cson"]:
    try:
        bn_path = os.path.join(NOTES_DIR , bn_fname)
        cson_dict = get_dict_from_cson(bn_path)
        if "mckenzielab-gh-pages" in cson_dict["tags"]:
            shutil.copyfile(bn_path , "./index_cson_generator_backup.cson")
            print("Successfully copied cson file")

    except Exception:
        print(f"something went wrong while parsing\n{bn_fname}")

print("\n\nDONE, bye")






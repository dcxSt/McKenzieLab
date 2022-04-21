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

def update_asset_links(html): # takes html as list f.readllines() 
    new_html = []
    # for each line
    for line_n,line in enumerate(html):
        # if it has an image link
        if "img src=" in line:
            print(f"Line at {line_n} with 'img src=' detected")
            # match the path
            split_line = line.split("\"")
            print(f"Split line={split_line}")
            index = -1
            localpath = ""
            for idx,string in enumerate(split_line):
                if "img src=" == string[-8:]:
                    print(f"Suspect line identified, matched with 'img src=', \nthe index is {idx}")
                    index = idx+1 # index of the local asset path
                    print(f"index which is idx+1 is {index}")
                    localpath = split_line[index]
                    print(f"The local path is {localpath}")
                    break # assume max one img per line
            # i know this is very disgusting code, but it doesn't need to be pretty, it's so limited in scope
            assert index > 0
            print("assert index > 0 passed")
            assert index < len(split_line)
            print("assert index < len(split_line) passed")
            assert localpath # localpath must be truthy
            print("assert localpath is truthy passed")
            leaf = localpath.split("/")[-1]
            print(f"leaf={leaf}")
            # copy paste that image into this assets file
            shutil.copyfile(localpath , os.path.join("./assets/" , leaf))
            onlinestem = "https://github.com/dcxSt/mckenzielab/tree/gh-pages/assets/"
            onlinepath = os.path.join(onlinestem,leaf)
            print(f"copy pasted asset into {os.path.join('./assets/' , leaf)}")

            # replace path 
            split_line[index] = onlinepath
            new_line = "\"".join(split_line)

            # add sentence to new_html
            new_html.append(new_line)
            print(f"replaced localpath\n{localpath}\nwith onlinepath\n{onlinepath}\n")
        else:
            new_html.append(line)

    return new_html


# assume HTML_PATH is correct and copy paste the file into index.html
try:
    print("copying html")
    shutil.copyfile(HTML_PATH , "./index.html")
    print("Reading html")
    with open("./index.html","r") as f:
        html = f.readlines()
    print("Updating asset links")
    new_html = update_asset_links(html)
    print("Rewriting html")
    with open("./index.html","w") as f:
        for line in new_html:
            f.write(line)
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






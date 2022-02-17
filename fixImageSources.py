import glob

# get a list of all image names
fullMediaPath = glob.glob('./docs/media/**/*.*', recursive=True)
# replace '\\' with '/'
fullMediaPath = list(map(lambda x: x.replace('\\', '/'), fullMediaPath))
# format list like /**/*.png
mediaPath = list(map(lambda x: x.partition('media')[2], fullMediaPath))
# lower case list for comparison
lowMediaPath = list(map(lambda x: x.casefold(), mediaPath))


def getPath(path):
    # format path for comparison
    path = path.replace('\\', '/')
    path = path.casefold()

    index = lowMediaPath.index(path)
    return mediaPath[index]


def main():
    # in every markdown file
    for name in glob.glob('./docs/**/*.md', recursive=True):
        with open(name, mode='r', encoding='utf8') as file:
            lines = file.readlines()
            # search each line for key word 'media'
            for i in range(len(lines)):
                line = lines[i]
                if 'media/' in line or 'media\\' in line:
                    # get string with format like /**/*.png
                    path = line.partition('media')[2]
                    path = path[:path.find('"')]
                    if path.find(')') >= 0:
                        path = path[:path.find(')')]

                    # immediately causes problems
                    # bad workaround

                    # replace the wrong path
                    newPath = getPath(path)
                    lines[i] = line.replace(path, newPath)
            file.close()

        with open(name, mode='w', encoding='utf8') as file:
            file.writelines(lines)
            file.close()


if __name__ == "__main__":
    main()

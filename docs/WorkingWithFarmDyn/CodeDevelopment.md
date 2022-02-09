# Developing the Model Code

# Choosing an editor and making it FarmDyn compatible

As you already know, FarmDyn is written in the algebraic modeling language [GAMS](https://de.wikipedia.org/wiki/General_Algebraic_Modeling_System).
Since the model is quiet large, the code is split up into several files ([called seperation of concerns](https://en.wikipedia.org/wiki/Separation_of_concerns)) within the `gams` folder of your FarmDyn checkout.
A GAMS file is just a plain text file with a `.gms` suffix, and can therefore be edited by a number of plain text editors.

Apparantly, there is no obvious right or wrong choice for such an editor.
In the following subsections we will cover some of the most popular options. However, the list is neither complete nor completly objective (I'm sorry).
Eventually, you have to decide which one suits your needs by weighing the pros and cons, as all of them are capable of getting the job done the one or the other way.

## Atom
The [Atom editor](https://atom.io/) is an open-source editor created by [Github](https://github.com/). It has gained a lot of attention among web-developers as it is build using web-technologies (JavaScript, HTML \& CSS), which makes additional extensions/packages easy to create and maintain (for that target group). Under the hood, Atom uses the same software-stack as Microsoft's [Visual Studio Code](https://code.visualstudio.com/), which is why these two editors are really similar.

Atom's aims to be an editor that is easily approachable (that means you don't need to be a geek in order to use it), yet flexible enough to be a professional coding tool. That said, there are usually two/three ways of achieving what you want to achieve in Atom. Let's say we want to add a Bookmark at a certain line:

- Speed: +0: Click on Edit -> Bookmark -> ToggleBookmark. Just like you would in a web-browser that you already know how to use(in fact, Atom IS a Chrome web-browser). No need to learn fancy shortcuts.
- Speed: +1: Use the powerful `ctrl-shift-p` shortcut. Then type"Toggle Bookmark" and hit enter.
- Speed: +2: Use an actual shortcut: `ctrl-alt-F2` for "ToggleBookmark"


As the [Atom documentation](https://flight-manual.atom.io/) says, if you are willing to remember only one shortcut, make it `ctrl-shift-p`.
You may want to use that shortcut and type "Install Package" to open the package installation pane. From there you can install any extension/theme that may sound useful or look good to you.

Personally, besides the GAMS packages described later, I enjoy the following setup:

- Theme: One Light
- [Minimap Package](https://atom.io/packages/minimap)
- [slickedit-select](https://atom.io/packages/slickedit-select) for block-selection
- [Teletype](https://atom.io/packages/teletype) for collective real-time editing
- [Hydrogen](https://atom.io/packages/hydrogen) for interactive coding


If you encounter a missing feature, you're bored, or both, then developing your own package may be an option. You don't know how to code Node.JS falvoured JavaScript? No problem, just head over to [nodeschool.io](https://nodeschool.io/) and start making some courses. Once you're done, hit your favorite shortcut (`ctrl-alt-F2`, in case you forgot), type "Generate Package", press enter and watch magic happen.

## GAMS Studio
GAMS Studio is a completely new integrated development environment for GAMS, which is available for Windows, Mac OS X, and Linux. It is based on C++ and Qt. For more information, you can go to [GAMS STUDIO](https://www.gams.com/33/docs/UG_studio_tutorial.html)


## GAMD IDE (legacy)

# FarmDyn Documentation
This is the manual for the FarmDyn documentation. 
In this document the process on how a) to work on the documentation and b) build the website or PDF version of it will be described.

## Installation

### University of Bonn users
No need to install. Just head to

`\\agpserv7\agpo\work1\Pahmeyer\FarmDyn\FarmDynDoku\FarmDyn`

### External users
You can simply [clone the respository](https://help.github.com/articles/cloning-a-repository/) and then work on the files in the docs folder. If you want to actually create the Website/PDF yourself then just write me a mail and we can install the required packages.

## Working on the documentation

The documentation lives in the docs folder. Instead of a Word document, the documentation is written in Markdown. Markdown is a simple markup language (like HTML, but simpler). The main benefit over a Word file is that we can easily create the Website and PDF from the same documentation source (among others). You can read more about Markdown [here](https://www.markdownguide.org/getting-started).

Every chapter of the documentation is in it's own file with the file extension `.md`. The `.md` files can be opened and edited with any text editor of your choice (e.g. Notepad, KEdit, TextMate), however it is recommended to use [Atom](https://atom.io/), because it has many built in features that help you to write in Markdown. The following hints and shortcuts will assume the usage of Atom.

## Basic writing
The most important reference for working with Markdown is the [Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet).
Also, many things will be self-explanatory when you look through the existing files.
In the following, I will copy (and add to) some of the things that are written in the cheatsheet.


### Headings
You can create a new heading by beginning a line with a `#` (or more depending on the level). Make sure to leave a blank line afterwards.

This markdown:
```
# Heading level 1

## Heading level 2

### Heading level 3

#### Heading level 4

##### Heading level 5

###### Heading level 6

```
Outputs:

# Heading level 1

## Heading level 2

### Heading level 3

#### Heading level 4

##### Heading level 5

###### Heading level 6


### Emphasis
You can write in *italics* or **bold** by doing the following 
```
Emphasis, aka italics, with *asterisks* or _underscores_.
Strong emphasis, aka bold, with **asterisks** or __underscores__.
Combined emphasis with **asterisks and _underscores_**.
Strikethrough uses two tildes. ~~Scratch this.~~
```
Outputs:
Emphasis, aka italics, with *asterisks* or _underscores_.
Strong emphasis, aka bold, with **asterisks** or __underscores__.
Combined emphasis with **asterisks and _underscores_**.
Strikethrough uses two tildes. ~~Scratch this.~~

### Lists

### Tables

### Figures

### Code blocks

### Footnotes

### Equations

### Admonition blocks

### Building the website

### Changing the structure

## Starting a development version of the website with live updates

## Building the PDF / Word file

### Changing the structure

# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'RISC-V 64-bit Processor Core Specification'
copyright = '2025, Mohamed - Hochschule Ravensburg-Weingarten'
author = 'Mohamed'
release = '1.0'
version = '1.0'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    'sphinx.ext.graphviz',
    'sphinx.ext.todo',
    'sphinx.ext.mathjax',
    'sphinx.ext.ifconfig',
]

templates_path = ['_templates']
exclude_patterns = []

# -- Graphviz configuration --------------------------------------------------
graphviz_output_format = 'svg'
graphviz_dot_args = ['-Nfontname=sans-serif', '-Efontname=sans-serif', '-Gfontname=sans-serif']

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'sphinx_rtd_theme'  # ReadTheDocs theme for better appearance
html_static_path = ['_static']
html_logo = None
html_title = 'RV64 Core Specification'

# Theme options
html_theme_options = {
    'navigation_depth': 4,
    'collapse_navigation': False,
    'sticky_navigation': True,
    'titles_only': False,
}

# -- Options for LaTeX output ------------------------------------------------
latex_engine = 'pdflatex'
latex_elements = {
    'papersize': 'a4paper',
    'pointsize': '12pt',
    'preamble': r'''
\usepackage{charter}
\usepackage[defaultsans]{lato}
\usepackage{inconsolata}
\usepackage{newunicodechar}
\newunicodechar{‾}{\textasciimacron}
\DeclareUnicodeCharacter{03B8}{\ensuremath{\theta}}
\usepackage{ragged2e}
\raggedright
''',
    'babel': '\\usepackage[english]{babel}',
    'fncychap': '',
}

latex_documents = [
    ('index', 'RV64_Specification.tex', 'RISC-V 64-bit Processor Core Specification',
     'Mohamed', 'manual'),
]

# -- Options for manual page output ------------------------------------------
man_pages = [
    ('index', 'rv64spec', 'RISC-V 64-bit Processor Core Specification',
     [author], 1)
]

# -- Options for Texinfo output ----------------------------------------------
texinfo_documents = [
    ('index', 'RV64Spec', 'RISC-V 64-bit Processor Core Specification',
     author, 'RV64Spec', 'Implementation specification for a RISC-V 64-bit processor core.',
     'Miscellaneous'),
]

# Numbering
numfig = True
numfig_format = {
    'figure': 'Figure %s',
    'table': 'Table %s',
    'code-block': 'Listing %s',
    'section': 'Section %s',
}

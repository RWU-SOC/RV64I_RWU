# SPDX-License-Identifier: Apache-2.0
# Documentation toolchain verification

include_guard(GLOBAL)

message(STATUS "Verifying documentation toolchain...")

# Find Sphinx
find_program(SPHINX_BUILD sphinx-build)
find_program(SPHINX_APIDOC sphinx-apidoc)

if(NOT SPHINX_BUILD)
  message(WARNING "sphinx-build not found. Documentation builds disabled.")
  message(STATUS "Install with: pip install sphinx sphinx_rtd_theme")
  set(BUILD_DOCS OFF PARENT_SCOPE)
  return()
endif()

# Get Sphinx version
execute_process(
  COMMAND ${SPHINX_BUILD} --version
  OUTPUT_VARIABLE SPHINX_VERSION_OUTPUT
  ERROR_VARIABLE SPHINX_VERSION_OUTPUT
  OUTPUT_STRIP_TRAILING_WHITESPACE
  ERROR_STRIP_TRAILING_WHITESPACE
)

string(REGEX MATCH "([0-9]+\\.[0-9]+\\.[0-9]+)" SPHINX_VERSION "${SPHINX_VERSION_OUTPUT}")

# Check for sphinx_rtd_theme
execute_process(
  COMMAND ${CMAKE_COMMAND} -E env python -c "import sphinx_rtd_theme"
  RESULT_VARIABLE RTD_THEME_CHECK
  OUTPUT_QUIET
  ERROR_QUIET
)

if(NOT RTD_THEME_CHECK EQUAL 0)
  message(WARNING "sphinx_rtd_theme not found. Install with: pip install sphinx_rtd_theme")
endif()

# Find LaTeX tools (optional, for PDF generation)
find_program(PDFLATEX pdflatex)
find_program(MAKEINDEX makeindex)
find_program(LATEXMK latexmk)

# Set documentation tool variables
set(SPHINX_BUILD ${SPHINX_BUILD} CACHE FILEPATH "Sphinx build tool" FORCE)

if(SPHINX_APIDOC)
  set(SPHINX_APIDOC ${SPHINX_APIDOC} CACHE FILEPATH "Sphinx API doc tool" FORCE)
endif()

if(PDFLATEX)
  set(PDFLATEX ${PDFLATEX} CACHE FILEPATH "PDFLaTeX tool" FORCE)
  set(DOCS_PDF_AVAILABLE TRUE CACHE BOOL "PDF documentation can be built" FORCE)
else()
  set(DOCS_PDF_AVAILABLE FALSE CACHE BOOL "PDF documentation can be built" FORCE)
endif()

# Sphinx build options
set(SPHINX_HTML_OPTS "-b html -d ${CMAKE_BINARY_DIR}/docs/doctrees" CACHE STRING "Sphinx HTML options")
set(SPHINX_LATEX_OPTS "-b latex -d ${CMAKE_BINARY_DIR}/docs/doctrees" CACHE STRING "Sphinx LaTeX options")

message(STATUS "Documentation toolchain found:")
message(STATUS "  Sphinx:    ${SPHINX_BUILD}")
message(STATUS "  Version:   ${SPHINX_VERSION}")
message(STATUS "  RTD Theme: ${RTD_THEME_CHECK}")
if(PDFLATEX)
  message(STATUS "  PDFLaTeX:  ${PDFLATEX} (PDF builds enabled)")
else()
  message(STATUS "  PDFLaTeX:  Not found (PDF builds disabled)")
endif()

# ============================================================================
# Documentation Build Configuration
# Sphinx documentation (HTML and LaTeX/PDF)
# ============================================================================

set(SPHINX_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/source")
set(SPHINX_BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}")
set(SPHINX_HTML_DIR "${SPHINX_BUILD_DIR}/html")
set(SPHINX_LATEX_DIR "${SPHINX_BUILD_DIR}/latex")

# ============================================================================
# HTML Documentation
# ============================================================================
add_custom_target(docs_html
    COMMAND ${SPHINX_BUILD}
        -b html
        -d ${SPHINX_BUILD_DIR}/doctrees
        ${SPHINX_SOURCE_DIR}
        ${SPHINX_HTML_DIR}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Building HTML documentation with Sphinx"
    VERBATIM
)

# ============================================================================
# LaTeX/PDF Documentation
# ============================================================================
find_program(PDFLATEX pdflatex)

add_custom_target(docs_latex
    COMMAND ${SPHINX_BUILD}
        -b latex
        -d ${SPHINX_BUILD_DIR}/doctrees
        ${SPHINX_SOURCE_DIR}
        ${SPHINX_LATEX_DIR}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Building LaTeX documentation with Sphinx"
    VERBATIM
)

if(PDFLATEX)
    add_custom_target(docs_pdf
        COMMAND ${CMAKE_COMMAND} -E chdir ${SPHINX_LATEX_DIR} ${PDFLATEX}
            -interaction=nonstopmode
            RV64_Specification.tex
        COMMAND ${CMAKE_COMMAND} -E chdir ${SPHINX_LATEX_DIR} ${PDFLATEX}
            -interaction=nonstopmode
            RV64_Specification.tex
        DEPENDS docs_latex
        WORKING_DIRECTORY ${SPHINX_LATEX_DIR}
        COMMENT "Building PDF from LaTeX (RV64_Specification.pdf)"
        VERBATIM
    )
else()
    message(STATUS "pdflatex not found, docs_pdf target disabled")
endif()

# ============================================================================
# Clean target
# ============================================================================
add_custom_target(docs_clean
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${SPHINX_BUILD_DIR}/doctrees
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${SPHINX_HTML_DIR}
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${SPHINX_LATEX_DIR}
    COMMENT "Cleaning documentation build artifacts"
)

# ============================================================================
# Convenience target
# ============================================================================
add_custom_target(docs
    DEPENDS docs_html
    COMMENT "Build all documentation"
)

if(TARGET docs_pdf)
    add_dependencies(docs docs_pdf)
endif()

# ============================================================================
# Install documentation (for CPack)
# ============================================================================
install(DIRECTORY ${SPHINX_HTML_DIR}
    DESTINATION share/doc/rv64i_rwu
    COMPONENT documentation
    OPTIONAL
)

if(TARGET docs_pdf)
    install(FILES ${SPHINX_LATEX_DIR}/RV64_Specification.pdf
        DESTINATION share/doc/rv64i_rwu
        COMPONENT documentation
        OPTIONAL
    )
endif()

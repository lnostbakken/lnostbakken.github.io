library(bib2df)

# Return empty string for missing / NA values
safe <- function(x) {
  if (is.null(x) || length(x) == 0) return("")
  x <- x[1]
  if (is.na(x)) return("")
  trimws(as.character(x))
}

# Convert common LaTeX encoding to Unicode
clean_latex <- function(text) {
  if (is.null(text) || is.na(text) || nchar(trimws(text)) == 0) return("")
  text <- as.character(text)
  text <- gsub("\\\\emph\\{([^}]*)\\}", "<em>\\1</em>", text, perl = TRUE)
  text <- gsub("\\{\\\\o\\s*\\}",       "\u00f8", text)  # {\o} or {\o }
  text <- gsub("\\{\\\\O\\s*\\}",       "\u00d8", text)  # {\O} or {\O }
  text <- gsub("\\{\\\\ae\\}",         "\u00e6", text)
  text <- gsub("\\{\\\\AE\\}",         "\u00c6", text)
  text <- gsub("\\{\\\\aa\\}",         "\u00e5", text)
  text <- gsub("\\{\\\\AA\\}",         "\u00c5", text)
  text <- gsub("\\{\\\\'e\\}",         "\u00e9", text)
  text <- gsub("\\{\\\\`e\\}",         "\u00e8", text)
  text <- gsub("\\{\\\\'a\\}",         "\u00e1", text)
  text <- gsub("\\{\\\\'u\\}",         "\u00fa", text)
  text <- gsub("\\{\\\\~n\\}",         "\u00f1", text)
  text <- gsub("\\{\\\\v\\{s\\}\\}",   "\u0161", text)
  text <- gsub("\\\\v\\{s\\}",         "\u0161", text)
  text <- gsub("\\{\\\\v s\\}",        "\u0161", text)
  text <- gsub("\\{\\\\v\\{c\\}\\}",   "\u010d", text)
  text <- gsub("\\\\v\\{c\\}",         "\u010d", text)
  text <- gsub("\\{\\\\'c\\}",         "\u0107", text)
  text <- gsub("\\\\'\\{c\\}",         "\u0107", text)
  text <- gsub("\\{\\\\'C\\}",         "\u0106", text)
  text <- gsub("[{}]", "", text)
  trimws(gsub("\\s+", " ", text))
}

# Format a vector of "Last, First" author strings into readable form
format_authors <- function(author_vec) {
  if (is.null(author_vec) || length(author_vec) == 0) return("")
  formatted <- sapply(author_vec, function(a) {
    a <- clean_latex(a)
    parts <- strsplit(a, ",\\s*")[[1]]
    if (length(parts) >= 2) paste(trimws(parts[2]), trimws(parts[1]))
    else trimws(a)
  })
  n <- length(formatted)
  if (n == 1) formatted
  else if (n == 2) paste(formatted, collapse = " and ")
  else paste(paste(formatted[-n], collapse = ", "), "and", formatted[n])
}

# Build venue string appropriate for each entry type
format_venue <- function(cat, row) {
  cat <- toupper(cat)
  yr  <- safe(row$YEAR)

  if (cat == "ARTICLE") {
    journal <- clean_latex(safe(row$JOURNAL))
    vol     <- safe(row$VOLUME)
    num     <- safe(row$NUMBER)
    pages   <- safe(row$PAGES)
    vol_str <- if (nchar(vol) > 0 && nchar(num) > 0) paste0(vol, "(", num, ")")
               else if (nchar(vol) > 0) vol else ""
    parts <- character(0)
    if (nchar(journal) > 0) parts <- c(parts, paste0("<em>", journal, "</em>"))
    if (nchar(vol_str) > 0) parts <- c(parts, vol_str)
    if (nchar(pages)   > 0) parts <- c(parts, paste0("pp.\u00a0", pages))
    if (nchar(yr)      > 0) parts <- c(parts, yr)
    paste(parts, collapse = ", ")

  } else if (cat == "TECHREPORT") {
    inst  <- clean_latex(safe(row$INSTITUTION))
    rtype <- clean_latex(safe(row$TYPE))
    if (nchar(rtype) == 0) rtype <- "Working Paper"
    num     <- safe(row$NUMBER)
    num_str <- if (nchar(num) > 0) paste0(" No.\u00a0", num) else ""
    yr_str  <- if (nchar(yr)  > 0) paste0(", ", yr) else ""
    if (nchar(inst) > 0) paste0(rtype, num_str, ". ", inst, yr_str)
    else paste0(rtype, num_str, yr_str)

  } else if (cat == "UNPUBLISHED") {
    note   <- clean_latex(safe(row$NOTE))
    yr_str <- if (nchar(yr) > 0) paste0(" (", yr, ")") else ""
    paste0(note, yr_str)

  } else if (cat %in% c("INCOLLECTION", "INBOOK")) {
    book <- clean_latex(safe(row$BOOKTITLE))
    pub  <- clean_latex(safe(row$PUBLISHER))
    parts <- character(0)
    if (nchar(book) > 0) parts <- c(parts, paste0("In <em>", book, "</em>"))
    if (nchar(pub)  > 0) parts <- c(parts, pub)
    if (nchar(yr)   > 0) parts <- c(parts, yr)
    paste(parts, collapse = ". ")

  } else {
    yr
  }
}

# Resolve a hyperlink from DOI, URL, or SOURCE fields (whichever is present)
get_link <- function(row) {
  doi <- if ("DOI" %in% names(row) && !is.na(row$DOI) && nchar(trimws(row$DOI)) > 0)
           paste0("https://doi.org/", trimws(row$DOI))
         else ""
  if (nchar(doi) > 0) return(doi)

  url <- if ("URL" %in% names(row) && !is.na(row$URL) && nchar(trimws(row$URL)) > 0)
           trimws(row$URL)
         else ""
  if (nchar(url) > 0) return(url)

  src <- if ("SOURCE" %in% names(row) && !is.na(row$SOURCE)) trimws(row$SOURCE) else ""
  if (startsWith(src, "http")) return(src)

  ""
}

# Wrap title in <a> tag if a link is available
linked_title <- function(title, link) {
  if (nchar(link) > 0)
    paste0('<a href="', link, '" target="_blank" rel="noopener">', title, '</a>')
  else
    title
}

# Full paper entry with optional expandable abstract
render_paper_full <- function(row) {
  title    <- clean_latex(safe(row$TITLE))
  link     <- get_link(row)
  authors  <- format_authors(row$AUTHOR[[1]])
  venue    <- format_venue(row$CATEGORY, row)
  abstract <- if ("ABSTRACT" %in% names(row) && !is.na(row$ABSTRACT) &&
                   nchar(trimws(row$ABSTRACT)) > 0)
                clean_latex(row$ABSTRACT)
              else ""

  abs_html <- if (nchar(abstract) > 0)
    paste0('<details class="abstract-toggle">',
           '<summary>Abstract</summary>',
           '<p class="abstract-text">', abstract, '</p>',
           '</details>')
  else ""

  paste0('<div class="paper-entry">',
         '<p class="paper-title">', linked_title(title, link), '</p>',
         '<p class="paper-authors">', authors, '</p>',
         '<p class="paper-venue">',  venue,   '</p>',
         abs_html,
         '</div>')
}

# Compact one-line entry for full bibliography lists
render_paper_compact <- function(row) {
  title   <- clean_latex(safe(row$TITLE))
  link    <- get_link(row)
  authors <- format_authors(row$AUTHOR[[1]])
  venue   <- format_venue(row$CATEGORY, row)
  paste0('<div class="paper-compact">',
         '<span class="paper-title-compact">', linked_title(title, link), '</span>',
         ' \u2014 ', authors, '. ', venue,
         '</div>')
}

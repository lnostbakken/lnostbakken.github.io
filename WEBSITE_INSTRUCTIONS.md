# Website Update Instructions

Live site: https://lnostbakken.github.io/

---

## How updates work

Edit files locally → preview in browser → commit and push → site updates automatically (within a few minutes).

---

## Previewing locally

Open a terminal, navigate to the website folder, and run:

```bash
cd "/Users/lnostbak/Library/CloudStorage/OneDrive-NorwegianSchoolofEconomics/Linda/Website_Quarto26/lnostbakken-site"
quarto preview
```

This opens a live preview in your browser that updates as you save files.

---

## Publishing updates to the live site

After making and checking your changes, run the following in the terminal:

```bash
git add -A
git commit -m "brief description of what changed"
git push
```

GitHub Actions will automatically rebuild and deploy the site. Changes are usually live within 2–3 minutes.

---

## Common updates

### Add a new publication or working paper

All publications and working papers are managed in a single file:

```
papers_all.bib
```

**Keywords control where each entry appears:**

| Keyword | Where it shows |
|---|---|
| `international, selected` | Research page (Selected Publications) + CV |
| `international` | CV only |
| `norwegian` | CV only |
| `workingpaper` | Research page (Working Papers) |

**To add a new working paper**, add a `@techreport` or `@unpublished` entry with `keywords = {workingpaper}`. Include an `abstract` field if available.

**To add a new published paper**, add an `@article` or `@incollection` entry with `keywords = {international}`. Add `, selected` to the keyword if you want it featured on the Research page. Include `doi`, `abstract`, and other fields as available.

**Example entry:**
```bibtex
@article{Author_Nostbakken-2026,
  author  = {Author, Name and N{\o}stbakken, Linda},
  title   = {Paper Title},
  journal = {Journal Name},
  volume  = {10},
  number  = {2},
  pages   = {1--30},
  year    = {2026},
  doi     = {10.xxxx/xxxxxx},
  abstract= {Abstract text here.},
  keywords= {international, selected}
}
```

**To move a working paper to published**: change `keywords = {workingpaper}` to `keywords = {international}` (or add `selected`), and update the entry type and fields accordingly.

---

### Update CV content

Edit `cv.qmd` directly. The file uses simple Markdown table syntax:

```markdown
| 2026 – | **New Position**, Institution |
```

Sections: Education, Positions, Editorial & Scientific Appointments, Policy Contributions, Board Memberships, Publications (auto-generated from papers_all.bib).

---

### Update the home page text

Edit `index.qmd`. The introductory text is plain Markdown below the `---` line in the file header.

---

### Update the Bio page

Edit `about.qmd`. Plain Markdown.

---

### Update the PDF CV

Replace the file at:
```
files/CV.pdf
```

Keep the filename the same so all existing links continue to work.

---

## File overview

```
lnostbakken-site/
├── index.qmd          # Home page
├── about.qmd          # Bio page
├── research.qmd       # Research page (publications + working papers)
├── cv.qmd             # CV page
├── papers_all.bib     # All publications and working papers
├── styles.css         # Visual styling
├── _quarto.yml        # Site configuration (navigation, themes)
├── R/
│   └── bib_helpers.R  # R functions for rendering publication lists
└── files/
    ├── CV.pdf         # Downloadable CV
    ├── LN_photo18.jpg # Profile photo
    └── LN_photo24.jpg # Alternative profile photo
```

---

## Changing the profile photo

Replace or add a new photo in the `files/` folder, then update the filename in `index.qmd`:

```yaml
image: files/YOUR_PHOTO_FILENAME.jpg
```

---

## Troubleshooting

**Site not updating after push?** Wait 2–3 minutes and do a hard refresh (Cmd+Shift+R). Check the Actions tab on https://github.com/lnostbakken/lnostbakken.github.io for build status.

**GitHub Actions build failing?** The workflow installs three R packages required for rendering: `bib2df`, `knitr`, and `rmarkdown`. If you add R packages to the site in the future, add them to the `packages` list in `.github/workflows/publish.yml`:
```yaml
- name: Install R dependencies
  uses: r-lib/actions/setup-r-dependencies@v2
  with:
    packages: |
      any::knitr
      any::rmarkdown
      any::bib2df
      any::your_new_package
```

**Local preview not working?** Make sure Quarto and R are installed and run `quarto preview` from the correct folder.

**Author name encoding issues?** Use `N{\o}stbakken` (not `Nøstbakken`) in .bib files.

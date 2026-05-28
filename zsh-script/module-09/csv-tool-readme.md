# csvtool 🗂️

> Analyze and transform CSV files straight from the terminal.
> No Python. No pandas. No Excel. Just zsh.

---

## At a Glance

| Command | What it does |
|---|---|
| `preview` | Pretty-print the first N rows |
| `headers` | List all column names with index |
| `stats` | Min / max / avg / sum for a numeric column |
| `filter` | Print rows where a column matches a pattern |
| `extract` | List all unique values from a column |
| `dupes` | Find duplicate values in a column |
| `count` | Count rows grouped by column value |
| `rename` | Normalize headers — lowercase, trim, underscores |

---

## Install

```zsh
git clone https://github.com/yourname/csvtool
cd csvtool
chmod +x csvtool.zsh

# optional — add to PATH
ln -s $PWD/csvtool.zsh ~/.local/bin/csvtool
```

---

## Usage

```
csvtool.zsh <command> <file.csv> [options]
```

**Options**

| Flag | Default | Description |
|---|---|---|
| `-c <col>` | — | Column name or number (1-based) |
| `-m <pat>` | — | Pattern to match (case-insensitive) |
| `-n <rows>` | `10` | Number of rows for preview |
| `-o <file>` | — | Output file (for `rename`) |
| `-d <delim>` | `,` | Custom delimiter |
| `-h` | — | Show help |

---

## Output

### `headers`

```
$ csvtool.zsh headers sales.csv

:: headers in: sales.csv

   1  id
   2  name
   3  city
   4  category
   5  revenue
   6  status
```

---

### `stats`

```
$ csvtool.zsh stats sales.csv -c revenue

:: stats for column revenue (field 5)

  count  : 10
  min    : 900
  max    : 5500
  sum    : 30600
  avg    : 3060.00
```

---

### `count`

```
$ csvtool.zsh count sales.csv -c city

:: row count grouped by 'city'

      4  New York
      4  Chicago
      2  Boston
```

---

### `extract`

```
$ csvtool.zsh extract sales.csv -c category

:: unique values in column 'category'

  hardware
  services
  software
```

---

### `dupes`

```
$ csvtool.zsh dupes sales.csv -c name

:: duplicate values in column 'name'

  duplicate: Alice Johnson
  duplicate: Bob Smith
```

---

### `filter`

```
$ csvtool.zsh filter sales.csv -c city -m "New York"

:: rows where 'city' matches 'New York'

  1  Alice Johnson  New York  software  4200  active
  3  Carol White    New York  software  5500  active
  6  Frank Lee      New York  hardware  2200  active
```

---

### `rename`

```
$ csvtool.zsh rename messy.csv -o clean.csv

:: normalizing headers: messy.csv → clean.csv

  saved to: clean.csv
  headers:
    first_name    (was: " First Name ")
    last_name     (was: "Last Name")
    email         (was: "  EMAIL  ")
    created_at    (was: "Created At")
```

---

## Examples

```zsh
# preview first 5 rows
./csvtool.zsh preview data.csv -n 5

# stats on a numeric column
./csvtool.zsh stats sales.csv -c revenue

# filter rows by value
./csvtool.zsh filter users.csv -c city -m "Chicago"

# find duplicate emails
./csvtool.zsh dupes users.csv -c email

# count orders by country
./csvtool.zsh count orders.csv -c country

# clean up messy headers
./csvtool.zsh rename raw_export.csv -o clean.csv

# pipe into other tools
./csvtool.zsh extract sales.csv -c status | sort | uniq -c
```

---

## Module 9 Concepts Used

| Concept | Where it shows up |
|---|---|
| `grep -i` / `-E` | Case-insensitive filtering in `filter` via awk's `tolower()` |
| `awk` field ops | `stats`, `filter`, `count` — NR, NF, sums, grouping |
| `cut` + `sort` + `uniq` | Column extraction and dedup pipeline in `extract`, `dupes` |
| `${var##*/}` | Display filename only — acts like `basename` with no subprocess |
| `${var## }` / `${var%% }` | Trim whitespace from column names — no `sed`, no `tr` |
| `${(L)var}` | Lowercase headers in `rename` — pure zsh |
| `${(j:,:)arr}` | Join normalized header array back to CSV row |
| `${var//pat/}` | Strip non-alphanumeric chars from header names |
| `getopts` | Parse `-c -m -n -o -d -h` across all subcommands |

---

## File Structure

```
module-09/
├── notes/
│   └── module-09-notes.md    ← quick reference for all M9 concepts
└── project/
    ├── csvtool.zsh            ← main script (~200 lines)
    └── README.md              ← this file
```

---

## Requirements

- zsh 5.0+
- `awk`, `cut`, `sort`, `uniq` — standard on Linux/macOS
- `column` — optional, used for aligned preview

---

## License

MIT
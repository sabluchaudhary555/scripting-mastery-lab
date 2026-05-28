<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>logrouter — README</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:ital,wght@0,400;0,600;1,400&family=IBM+Plex+Sans:wght@300;400;600&display=swap');

  :root {
    --bg:        #0d0f11;
    --surface:   #141618;
    --surface2:  #1c1f22;
    --border:    #2a2e33;
    --text:      #cdd3da;
    --muted:     #636d78;
    --green:     #4ec94e;
    --yellow:    #e5c84a;
    --red:       #e05a5a;
    --blue:      #5aace0;
    --cyan:      #4ecfcf;
    --accent:    #7c6af7;
  }

  * { box-sizing: border-box; margin: 0; padding: 0; }

  body {
    background: var(--bg);
    color: var(--text);
    font-family: 'IBM Plex Sans', sans-serif;
    font-size: 15px;
    line-height: 1.7;
    padding: 0;
  }

  /* ── hero ── */
  .hero {
    padding: 64px 48px 48px;
    border-bottom: 1px solid var(--border);
    background: radial-gradient(ellipse 80% 60% at 60% -10%, #7c6af715 0%, transparent 70%);
    position: relative;
    overflow: hidden;
  }
  .hero::before {
    content: '';
    position: absolute;
    top: 0; left: 0; right: 0; bottom: 0;
    background: repeating-linear-gradient(
      0deg,
      transparent,
      transparent 39px,
      #ffffff04 39px,
      #ffffff04 40px
    );
    pointer-events: none;
  }
  .hero-badge {
    font-family: 'IBM Plex Mono', monospace;
    font-size: 11px;
    color: var(--accent);
    letter-spacing: .15em;
    text-transform: uppercase;
    margin-bottom: 16px;
    opacity: .8;
  }
  .hero h1 {
    font-family: 'IBM Plex Mono', monospace;
    font-size: clamp(32px, 5vw, 52px);
    font-weight: 600;
    letter-spacing: -.02em;
    color: #fff;
    line-height: 1.1;
  }
  .hero h1 span { color: var(--accent); }
  .hero-sub {
    margin-top: 12px;
    font-size: 16px;
    color: var(--muted);
    max-width: 540px;
    font-weight: 300;
  }
  .hero-tags {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
    margin-top: 28px;
  }
  .tag {
    font-family: 'IBM Plex Mono', monospace;
    font-size: 11px;
    padding: 4px 10px;
    border-radius: 4px;
    border: 1px solid var(--border);
    color: var(--muted);
    background: var(--surface);
    letter-spacing: .05em;
  }
  .tag.green  { border-color: #4ec94e44; color: var(--green); background: #4ec94e0d; }
  .tag.yellow { border-color: #e5c84a44; color: var(--yellow); background: #e5c84a0d; }
  .tag.red    { border-color: #e05a5a44; color: var(--red); background: #e05a5a0d; }
  .tag.blue   { border-color: #5aace044; color: var(--blue); background: #5aace00d; }
  .tag.purple { border-color: #7c6af744; color: var(--accent); background: #7c6af70d; }

  /* ── layout ── */
  .content {
    max-width: 860px;
    margin: 0 auto;
    padding: 0 48px 80px;
  }

  /* ── sections ── */
  .section {
    margin-top: 52px;
  }
  .section-label {
    font-family: 'IBM Plex Mono', monospace;
    font-size: 10px;
    letter-spacing: .2em;
    text-transform: uppercase;
    color: var(--accent);
    margin-bottom: 18px;
    opacity: .7;
  }
  h2 {
    font-family: 'IBM Plex Mono', monospace;
    font-size: 18px;
    font-weight: 600;
    color: #fff;
    margin-bottom: 16px;
  }
  p { color: var(--text); margin-bottom: 12px; line-height: 1.75; }

  /* ── code blocks ── */
  pre {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 20px 24px;
    overflow-x: auto;
    font-family: 'IBM Plex Mono', monospace;
    font-size: 13px;
    line-height: 1.75;
    margin: 16px 0;
    position: relative;
  }
  pre .comment { color: var(--muted); font-style: italic; }
  pre .cmd     { color: var(--cyan); }
  pre .flag    { color: var(--yellow); }
  pre .path    { color: var(--green); }
  pre .string  { color: #e09b5a; }
  pre .pipe    { color: var(--accent); }
  code {
    font-family: 'IBM Plex Mono', monospace;
    font-size: 13px;
    background: var(--surface2);
    border: 1px solid var(--border);
    border-radius: 3px;
    padding: 1px 6px;
    color: var(--cyan);
  }

  /* ── flow diagram ── */
  .flow {
    display: flex;
    align-items: center;
    gap: 0;
    margin: 24px 0;
    flex-wrap: wrap;
  }
  .flow-box {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 14px 20px;
    font-family: 'IBM Plex Mono', monospace;
    font-size: 13px;
    text-align: center;
    min-width: 110px;
  }
  .flow-box .label { font-size: 10px; color: var(--muted); display: block; margin-bottom: 4px; text-transform: uppercase; letter-spacing: .1em; }
  .flow-box .val   { font-weight: 600; color: #fff; }
  .flow-arrow {
    color: var(--muted);
    font-size: 20px;
    padding: 0 10px;
    font-family: monospace;
  }

  /* ── output files grid ── */
  .files-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
    gap: 12px;
    margin: 20px 0;
  }
  .file-card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 16px;
    display: flex;
    gap: 12px;
    align-items: flex-start;
  }
  .file-dot {
    width: 10px; height: 10px;
    border-radius: 50%;
    margin-top: 5px;
    flex-shrink: 0;
  }
  .file-card .fname {
    font-family: 'IBM Plex Mono', monospace;
    font-size: 12px;
    color: #fff;
    margin-bottom: 4px;
  }
  .file-card .fdesc { font-size: 12px; color: var(--muted); }

  /* ── options table ── */
  table { width: 100%; border-collapse: collapse; margin: 16px 0; }
  th {
    font-family: 'IBM Plex Mono', monospace;
    font-size: 11px;
    letter-spacing: .1em;
    text-transform: uppercase;
    color: var(--muted);
    text-align: left;
    padding: 10px 16px;
    border-bottom: 1px solid var(--border);
  }
  td {
    padding: 11px 16px;
    border-bottom: 1px solid #1e2126;
    font-size: 14px;
    vertical-align: top;
  }
  td:first-child {
    font-family: 'IBM Plex Mono', monospace;
    font-size: 13px;
    color: var(--yellow);
    white-space: nowrap;
  }
  td:last-child { color: var(--muted); }
  tr:last-child td { border-bottom: none; }

  /* ── concepts grid ── */
  .concepts {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 12px;
    margin: 20px 0;
  }
  .concept-card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-left: 3px solid var(--accent);
    border-radius: 8px;
    padding: 14px 16px;
  }
  .concept-card .ctitle {
    font-family: 'IBM Plex Mono', monospace;
    font-size: 12px;
    color: var(--accent);
    margin-bottom: 6px;
    font-weight: 600;
  }
  .concept-card .cdesc { font-size: 12px; color: var(--muted); line-height: 1.6; }

  /* ── divider ── */
  hr { border: none; border-top: 1px solid var(--border); margin: 48px 0; }

  /* ── inline note ── */
  .note {
    background: #7c6af70d;
    border: 1px solid #7c6af733;
    border-radius: 8px;
    padding: 14px 18px;
    font-size: 13px;
    color: var(--text);
    margin: 16px 0;
  }
  .note strong { color: var(--accent); }
</style>
</head>
<body>

<!-- ── hero ────────────────────────────────────────────────────────────────── -->
<div class="hero">
  <div class="hero-badge">Module 8 · Real-life Project</div>
  <h1>log<span>router</span></h1>
  <p class="hero-sub">
    Split a live log stream into separate files by severity level.
    Pipe anything into it — it routes, counts, and reports.
  </p>
  <div class="hero-tags">
    <span class="tag purple">zsh</span>
    <span class="tag">stdin / stdout</span>
    <span class="tag">file descriptors</span>
    <span class="tag">getopts</span>
    <span class="tag">process substitution</span>
    <span class="tag">tee</span>
    <span class="tag green">INFO</span>
    <span class="tag yellow">WARN</span>
    <span class="tag red">ERROR</span>
    <span class="tag blue">DEBUG</span>
  </div>
</div>

<div class="content">

  <!-- ── what it does ── -->
  <div class="section">
    <div class="section-label">Overview</div>
    <h2>What it does</h2>
    <p>
      You pipe your app's log output into <code>logrouter.zsh</code> and it sorts
      every line into a separate file based on the log level it detects.
      All lines still go to <code>app.all.log</code>, and you get a clean summary
      at the end. Works with streaming input (<code>tail -f</code>) or a static file.
    </p>

    <!-- flow -->
    <div class="flow">
      <div class="flow-box">
        <span class="label">your app</span>
        <span class="val">stdout</span>
      </div>
      <div class="flow-arrow">──▶</div>
      <div class="flow-box" style="border-color:#7c6af766; background:#7c6af70d">
        <span class="label">logrouter</span>
        <span class="val" style="color:var(--accent)">router</span>
      </div>
      <div class="flow-arrow">──▶</div>
      <div class="flow-box" style="border-color:#4ec94e44">
        <span class="label">routed</span>
        <span class="val" style="color:var(--green)">5 files</span>
      </div>
    </div>
  </div>

  <!-- ── output files ── -->
  <div class="section">
    <div class="section-label">Output</div>
    <h2>Output files</h2>
    <div class="files-grid">
      <div class="file-card">
        <div class="file-dot" style="background:#636d78"></div>
        <div>
          <div class="fname">app.all.log</div>
          <div class="fdesc">every single line, always</div>
        </div>
      </div>
      <div class="file-card">
        <div class="file-dot" style="background:var(--green)"></div>
        <div>
          <div class="fname">app.info.log</div>
          <div class="fdesc">INFO level lines only</div>
        </div>
      </div>
      <div class="file-card">
        <div class="file-dot" style="background:var(--yellow)"></div>
        <div>
          <div class="fname">app.warn.log</div>
          <div class="fdesc">WARN / WARNING lines</div>
        </div>
      </div>
      <div class="file-card">
        <div class="file-dot" style="background:var(--red)"></div>
        <div>
          <div class="fname">app.error.log</div>
          <div class="fdesc">ERROR, FATAL, CRITICAL</div>
        </div>
      </div>
      <div class="file-card">
        <div class="file-dot" style="background:var(--muted)"></div>
        <div>
          <div class="fname">app.debug.log</div>
          <div class="fdesc">DEBUG and TRACE lines</div>
        </div>
      </div>
      <div class="file-card">
        <div class="file-dot" style="background:var(--border)"></div>
        <div>
          <div class="fname">app.other.log</div>
          <div class="fdesc">anything without a known level</div>
        </div>
      </div>
    </div>
  </div>

  <!-- ── install ── -->
  <div class="section">
    <div class="section-label">Setup</div>
    <h2>Install</h2>
<pre><span class="comment"># clone or copy the file</span>
<span class="cmd">chmod</span> <span class="flag">+x</span> <span class="path">logrouter.zsh</span>

<span class="comment"># optional: put it on your PATH</span>
<span class="cmd">ln</span> <span class="flag">-s</span> <span class="path">$PWD/logrouter.zsh</span> <span class="path">~/.local/bin/logrouter</span></pre>
  </div>

  <!-- ── usage ── -->
  <div class="section">
    <div class="section-label">Usage</div>
    <h2>Options</h2>
    <table>
      <tr><th>Flag</th><th>Default</th><th>Description</th></tr>
      <tr><td>-o &lt;dir&gt;</td><td>./log-output</td><td>Where to write output files</td></tr>
      <tr><td>-i &lt;file&gt;</td><td>stdin</td><td>Read from a file instead of piped input</td></tr>
      <tr><td>-p &lt;prefix&gt;</td><td>app</td><td>Filename prefix — e.g. <code>-p api</code> → <code>api.error.log</code></td></tr>
      <tr><td>-v</td><td>off</td><td>Verbose: print each line to terminal as it's routed</td></tr>
      <tr><td>-s</td><td>off</td><td>Print summary table when done</td></tr>
      <tr><td>-h</td><td>—</td><td>Show help</td></tr>
    </table>
  </div>

  <!-- ── examples ── -->
  <div class="section">
    <div class="section-label">Examples</div>
    <h2>How to use it</h2>

    <p>Pipe a live log stream:</p>
<pre><span class="cmd">tail</span> <span class="flag">-f</span> <span class="path">/var/log/myapp.log</span> <span class="pipe">|</span> <span class="cmd">./logrouter.zsh</span> <span class="flag">-o</span> <span class="path">./logs</span> <span class="flag">-v</span></pre>

    <p>Route a static file with a custom prefix and show summary:</p>
<pre><span class="cmd">./logrouter.zsh</span> <span class="flag">-i</span> <span class="path">app.log</span> <span class="flag">-o</span> <span class="path">./out</span> <span class="flag">-p</span> <span class="string">myapp</span> <span class="flag">-s</span></pre>

    <p>Combine with another tool — only route errors from the last hour:</p>
<pre><span class="cmd">grep</span> <span class="string">"$(date -d '1 hour ago' +'%H:')"</span> app.log <span class="pipe">|</span> <span class="cmd">./logrouter.zsh</span> <span class="flag">-o</span> <span class="path">./recent</span></pre>

    <p>Route your app's live output directly:</p>
<pre><span class="cmd">./myserver</span> <span class="pipe">2>&1</span> <span class="pipe">|</span> <span class="cmd">./logrouter.zsh</span> <span class="flag">-o</span> <span class="path">./logs</span> <span class="flag">-p</span> <span class="string">server</span> <span class="flag">-v</span></pre>
  </div>

  <hr />

  <!-- ── concepts ── -->
  <div class="section">
    <div class="section-label">Module 8 concepts used</div>
    <h2>What this project practices</h2>
    <div class="concepts">
      <div class="concept-card">
        <div class="ctitle">stdin / stdout / stderr</div>
        <div class="cdesc">Reads log lines from stdin (fd 0), status messages to stdout, errors to stderr (>&2)</div>
      </div>
      <div class="concept-card">
        <div class="ctitle">File Descriptors</div>
        <div class="cdesc"><code>exec 10>> file</code> opens a persistent fd per log level — no repeated open/close per line</div>
      </div>
      <div class="concept-card">
        <div class="ctitle">Redirection &gt; &gt;&gt; &amp;&gt;</div>
        <div class="cdesc">Each log level writes with <code>&gt;&gt;</code> (append). Summary uses <code>&gt;&2</code> for error output</div>
      </div>
      <div class="concept-card">
        <div class="ctitle">/dev/stdin</div>
        <div class="cdesc">Uses <code>/dev/stdin</code> as a fallback input source so the same read loop works for both pipe and file modes</div>
      </div>
      <div class="concept-card">
        <div class="ctitle">getopts</div>
        <div class="cdesc">Parses <code>-o -i -p -v -s -h</code> short options cleanly with <code>$OPTARG</code> and <code>shift $((OPTIND-1))</code></div>
      </div>
      <div class="concept-card">
        <div class="ctitle">Argument Validation</div>
        <div class="cdesc">Checks for missing args, non-existent input files, and terminal stdin before doing any work</div>
      </div>
      <div class="concept-card">
        <div class="ctitle">trap EXIT</div>
        <div class="cdesc">Closes all file descriptors cleanly on exit, even if the script is interrupted with Ctrl+C</div>
      </div>
      <div class="concept-card">
        <div class="ctitle">Pipes</div>
        <div class="cdesc">Designed to sit in the middle of a pipeline — <code>tail -f app.log | logrouter | grep ERROR</code></div>
      </div>
      <div class="concept-card">
        <div class="ctitle">setopt pipe_fail</div>
        <div class="cdesc">Makes the script exit if any command in a pipeline fails, not just the last one</div>
      </div>
    </div>
  </div>

  <!-- ── structure ── -->
  <div class="section">
    <div class="section-label">Project</div>
    <h2>File structure</h2>
<pre><span class="path">module-08/</span>
├── <span class="path">notes/</span>
│   └── module-08-notes.md     <span class="comment"># quick reference for all M8 concepts</span>
└── <span class="path">project/</span>
    ├── logrouter.zsh          <span class="comment"># the main script</span>
    └── README.html            <span class="comment"># this file</span></pre>
  </div>

  <div class="note">
    <strong>Note:</strong> The script works with any log format that has a level keyword somewhere in the line —
    <code>INFO</code>, <code>[WARN]</code>, <code>level=error</code>, <code>FATAL</code>, etc.
    Lines that don't match any known level go to <code>app.other.log</code> so nothing is lost.
  </div>

</div><!-- /content -->
</body>
</html>
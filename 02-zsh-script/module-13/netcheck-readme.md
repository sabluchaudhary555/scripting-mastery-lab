# netcheck

A network health checker written in Zsh. Tests connectivity, DNS, API endpoints, and open ports in one run.

Built to practice: `curl`, `ping`, `dig`, `nc`, `jq`, and structured logging with traps.

---

## Usage

```zsh
chmod +x netcheck.zsh

./netcheck.zsh          # run all checks
./netcheck.zsh check    # connectivity + public IP only
./netcheck.zsh dns      # DNS resolution check
./netcheck.zsh api      # API GET + POST test with jq parsing
./netcheck.zsh ports    # port scan with nc
```

Override the API target:
```zsh
API_URL="https://api.myapp.com" ./netcheck.zsh api
```

---

## Sample output

```
[INFO]  14:01:22 netcheck started (pid 4821)
────────────────────────────────────────
[INFO]  14:01:22 checking connectivity...
[  OK ] 14:01:22 reachable: 8.8.8.8
[  OK ] 14:01:22 reachable: 1.1.1.1
[  OK ] 14:01:22 reachable: google.com
[INFO]  14:01:23 public IP: 103.x.x.x
────────────────────────────────────────
[INFO]  14:01:23 checking DNS resolution...
[  OK ] 14:01:23 google.com → 142.250.x.x
[  OK ] 14:01:23 github.com → 20.207.x.x
────────────────────────────────────────
[INFO]  14:01:23 testing API: https://jsonplaceholder.typicode.com
[  OK ] 14:01:24 GET /users/1 → 200

  name  : Leanne Graham
  email : Sincere@april.biz
  city  : Gwenborough

[  OK ] 14:01:24 POST /posts → 201 (created)
```

---

## Concepts practiced

| Concept | Where |
|---|---|
| `curl` GET/POST + status code | `check_api()` |
| `jq -r` field extraction | parsing user name/email/city |
| `jq -n --arg` safe JSON build | reference in notes |
| `ping` in scripts | `check_connectivity()` |
| `dig +short` DNS lookup | `check_dns()` |
| `nc -zw` port test | `check_ports()` |
| `curl -s https://ifconfig.me` | get public IP |
| `trap` EXIT / INT / TERM | cleanup + interrupt handling |
| `setopt ERR_EXIT NO_UNSET PIPE_FAIL` | script safety header |
| `exec > >(tee -a log) 2>&1` | log to file + terminal |
| dispatcher `case` in `main()` | route subcommands |
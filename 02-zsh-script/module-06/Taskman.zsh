#!/usr/bin/env zsh
# taskman.zsh — a simple task manager for the terminal
# nothing fancy, just tasks you can add, finish, and view

# where we store tasks
TASK_FILE="${TASKMAN_FILE:-$HOME/.taskman_tasks}"

# make sure the file exists
[[ -f $TASK_FILE ]] || touch "$TASK_FILE"

# ── helpers ────────────────────────────────────────────────────────────────

_die() {
    print "error: $1" >&2
    return 1
}

_task_count() {
    wc -l < "$TASK_FILE" | tr -d ' '
}

_next_id() {
    local max=0
    local id

    while IFS='|' read -r id _rest; do
        (( id > max )) && max=$id
    done < "$TASK_FILE"

    print $(( max + 1 ))
}

# ── core functions ─────────────────────────────────────────────────────────

add_task() {
    local desc="${*}"

    [[ -z $desc ]] && {
        _die "give me a task description"
        print "  usage: taskman add <what to do>" >&2
        return 2
    }

    local id=$(_next_id)
    local created=$(date '+%Y-%m-%d')

    print "${id}|todo|${created}|${desc}" >> "$TASK_FILE"
    print "added #${id}: ${desc}"
}

done_task() {
    local id=${1:?"usage: taskman done <id>"}
    local tmpfile=$(mktemp /tmp/taskman_$$.XXXXXX)

    trap "rm -f $tmpfile" RETURN

    local found=0

    while IFS='|' read -r tid status created desc; do
        if [[ $tid == $id ]]; then
            if [[ $status == "done" ]]; then
                print "task #${id} is already done"
                return 0
            fi
            print "${tid}|done|${created}|${desc}" >> "$tmpfile"
            found=1
        else
            print "${tid}|${status}|${created}|${desc}" >> "$tmpfile"
        fi
    done < "$TASK_FILE"

    (( found == 0 )) && _die "no task with id #${id}" && return 4

    cp "$tmpfile" "$TASK_FILE"
    print "marked #${id} as done ✓"
}

remove_task() {
    local id=${1:?"usage: taskman remove <id>"}
    local tmpfile=$(mktemp /tmp/taskman_$$.XXXXXX)

    trap "rm -f $tmpfile" RETURN

    local found=0

    while IFS='|' read -r tid status created desc; do
        if [[ $tid == $id ]]; then
            found=1
        else
            print "${tid}|${status}|${created}|${desc}" >> "$tmpfile"
        fi
    done < "$TASK_FILE"

    (( found == 0 )) && _die "no task with id #${id}" && return 4

    cp "$tmpfile" "$TASK_FILE"
    print "removed task #${id}"
}

list_tasks() {
    local filter=${1:-"all"}   # all | todo | done

    if [[ $(_task_count) -eq 0 ]]; then
        print "no tasks yet — add one with: taskman add <description>"
        return 0
    fi

    local -i shown=0

    print ""
    printf "  %-4s %-6s %-12s %s\n" "ID" "STATUS" "ADDED" "TASK"
    print "  ────────────────────────────────────────────────────"

    while IFS='|' read -r id status created desc; do
        # apply filter
        [[ $filter == "todo" && $status != "todo" ]] && continue
        [[ $filter == "done" && $status != "done" ]] && continue

        local marker="[ ]"
        [[ $status == "done" ]] && marker="[✓]"

        printf "  %-4s %s  %-12s %s\n" "#${id}" "$marker" "$created" "$desc"
        (( shown++ ))
    done < "$TASK_FILE"

    print ""

    (( shown == 0 )) && print "  nothing to show for filter: ${filter}"

    local total=$(_task_count)
    local done_count=$(grep -c '|done|' "$TASK_FILE" 2>/dev/null || print 0)
    local todo_count=$(( total - done_count ))

    print "  ${todo_count} pending  •  ${done_count} done  •  ${total} total"
    print ""
}

clear_done() {
    local tmpfile=$(mktemp /tmp/taskman_$$.XXXXXX)
    trap "rm -f $tmpfile" RETURN

    local -i removed=0

    while IFS='|' read -r id status created desc; do
        if [[ $status == "done" ]]; then
            (( removed++ ))
        else
            print "${id}|${status}|${created}|${desc}" >> "$tmpfile"
        fi
    done < "$TASK_FILE"

    cp "$tmpfile" "$TASK_FILE"
    print "cleared ${removed} completed task(s)"
}

show_help() {
    print ""
    print "taskman — terminal task manager"
    print ""
    print "usage:"
    print "  taskman add <description>   add a new task"
    print "  taskman list                list all tasks"
    print "  taskman list todo           show only pending"
    print "  taskman list done           show only completed"
    print "  taskman done <id>           mark a task as done"
    print "  taskman remove <id>         delete a task"
    print "  taskman clear               remove all completed tasks"
    print "  taskman help                show this message"
    print ""
    print "tip: set TASKMAN_FILE to use a custom storage path"
    print ""
}

# ── dispatcher ─────────────────────────────────────────────────────────────

main() {
    local cmd=${1:-"list"}
    shift 2>/dev/null   # shift is fine even if no args

    case $cmd in
        add)           add_task "$@"    ;;
        done|complete) done_task "$@"   ;;
        remove|rm|del) remove_task "$@" ;;
        list|ls)       list_tasks "$@"  ;;
        clear)         clear_done       ;;
        help|--help|-h) show_help       ;;
        *)
            print "unknown command: ${cmd}"
            show_help
            return 1
            ;;
    esac
}

main "$@"
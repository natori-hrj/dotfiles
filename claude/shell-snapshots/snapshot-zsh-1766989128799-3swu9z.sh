# Snapshot file
# Unset all aliases to avoid conflicts with functions
unalias -a 2>/dev/null || true
# Functions
pyenv () {
	local command=${1:-} 
	[ "$#" -gt 0 ] && shift
	case "$command" in
		(rehash | shell) eval "$(pyenv "sh-$command" "$@")" ;;
		(*) command pyenv "$command" "$@" ;;
	esac
}
# Shell Options
setopt nohashdirs
setopt login
# Aliases
alias -- run-help=man
alias -- which-command=whence
# Check for rg availability
if ! command -v rg >/dev/null 2>&1; then
  alias rg='/Users/al4ud1de/.claude/downloads/claude-2.0.67-darwin-arm64 --ripgrep'
fi
export PATH=/Users/al4ud1de/.pyenv/shims\:/Users/al4ud1de/.pyenv/bin\:/opt/homebrew/bin\:/opt/homebrew/sbin\:/usr/local/bin\:/System/Cryptexes/App/usr/bin\:/usr/bin\:/bin\:/usr/sbin\:/sbin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin

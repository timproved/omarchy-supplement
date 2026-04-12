case $- in
  *i*) ;;
  *) return 0 ;;
esac

# Free Ctrl-s/Ctrl-q for shell and tmux bindings.
stty -ixon 2>/dev/null || true

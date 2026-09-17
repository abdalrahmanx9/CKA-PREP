#!/usr/bin/env bash
# CKA-PREP-UNIFIED runner
# usage: run <N>          setup lab + show question
#        run <N> hint     show solution notes
#        run <N> check    validate your answer
cd "$(dirname "$(readlink -f "$0")")" || exit 1
d=$(ls -d Question-"$(printf '%02d' "$1")"-* 2>/dev/null) || { echo "Question $1 not found"; exit 1; }
case "${2:-run}" in
  run)   bash "$d/LabSetUp.bash"; echo; echo "===== $d ====="; cat "$d/Questions.bash";;
  hint)  cat "$d/SolutionNotes.bash";;
  check) bash "$d/validate.sh";;
  *)     echo "usage: ./run.sh <N> [run|hint|check]"; exit 1;;
esac

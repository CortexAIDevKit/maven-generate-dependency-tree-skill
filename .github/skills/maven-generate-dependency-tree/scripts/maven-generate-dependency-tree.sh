#!/usr/bin/env sh
set -eu

usage() {
  cat <<EOF
Usage: $0 [-o outputPath] [-t timestamp]

  -o outputPath  Sub-directory name for the report (default: maven-dependency-tree)
  -t timestamp   Timestamp in yyyymmdd-hhmmss (default: current time)
  -h             Show this help

Output is written to: cortexaidevkit/<timestamp>/<outputPath>/dependency.dot
EOF
}

OUTPUT_PATH=""
TIMESTAMP=""

while getopts ":o:t:h" opt; do
  case "$opt" in
    o) OUTPUT_PATH="$OPTARG" ;;
    t) TIMESTAMP="$OPTARG" ;;
    h) usage; exit 0 ;;
    \?) echo "Unknown option: -$OPTARG" >&2; usage; exit 2 ;;
    :)  echo "Option -$OPTARG requires an argument" >&2; usage; exit 2 ;;
  esac
done

OUTPUT_PATH="${OUTPUT_PATH:-maven-dependency-tree}"
TIMESTAMP="${TIMESTAMP:-$(date +%Y%m%d-%H%M%S)}"

if ! printf '%s' "$TIMESTAMP" | grep -Eq '^[0-9]{8}-[0-9]{6}$'; then
  echo "Invalid timestamp '$TIMESTAMP'. Expected format: yyyymmdd-hhmmss" >&2
  exit 1
fi

case "$OUTPUT_PATH" in
  /*|*".."*)
  echo "Invalid outputPath '$OUTPUT_PATH'. Must be a relative path without '..'" >&2
  exit 1
  ;;
esac

if [ ! -f pom.xml ]; then
  echo "No pom.xml found in the current directory." >&2
  exit 1
fi

REPORT_DIR="cortexaidevkit/${TIMESTAMP}/${OUTPUT_PATH}"
FINAL_DOT="${REPORT_DIR}/dependency.dot"
mkdir -p "$REPORT_DIR"

is_multi_module() {
  grep -q '<modules>' pom.xml
}

aggregate_modules() {
  tmp_dir="${REPORT_DIR}/module-dot"
  mkdir -p "$tmp_dir"
  abs_tmp_dir=""
  abs_tmp_dir="$(cd "$tmp_dir" && pwd)"

  echo "Multi-module project detected. Generating per-module dot files into ${tmp_dir}..."

  module_dirs_file="${REPORT_DIR}/module-dirs.txt"
  sed -n '/<modules>/,/<\/modules>/{s#.*<module>\([^<]*\)</module>.*#\1#p;}' pom.xml > "$module_dirs_file"
  if [ ! -s "$module_dirs_file" ]; then
    echo "Could not detect any submodules from pom.xml" >&2
    exit 1
  fi

  # Parent/root pom first, then each module (preserves reactor order).
  ordered_files_file="${REPORT_DIR}/ordered-dot-files.txt"
  : > "$ordered_files_file"

  echo "  - (parent)"
  mvn -q -N dependency:tree \
      -DoutputType=dot \
      -DoutputFile="${abs_tmp_dir}/_parent.dot" || echo "    (failed for parent)" >&2
  if [ -f "${abs_tmp_dir}/_parent.dot" ]; then
    echo "${abs_tmp_dir}/_parent.dot" >> "$ordered_files_file"
  fi

  while IFS= read -r d; do
    [ -z "$d" ] && continue
    [ ! -f "$d/pom.xml" ] && continue

    name=""
    name="$(basename "$d")"
    echo "  - $name"
    ( cd "$d" && mvn -q dependency:tree \
        -DoutputType=dot \
        -DoutputFile="${abs_tmp_dir}/${name}.dot" ) || {
      echo "    (failed for $name)" >&2
      continue
    }
    if [ -f "${abs_tmp_dir}/${name}.dot" ]; then
      echo "${abs_tmp_dir}/${name}.dot" >> "$ordered_files_file"
    fi
  done < "$module_dirs_file"

  # Concatenate per-module digraphs verbatim, separated by blank lines.
  : > "$FINAL_DOT"
  first=1
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    if [ "$first" -eq 0 ]; then echo "" >> "$FINAL_DOT"; fi
    cat "$f" >> "$FINAL_DOT"
    first=0
  done < "$ordered_files_file"

  rm -f "$module_dirs_file" "$ordered_files_file"

  echo "Aggregated dot file written to: $FINAL_DOT"
}

single_module() {
  abs_out=""
  mkdir -p "$REPORT_DIR"
  abs_out="$(cd "$REPORT_DIR" && pwd)/dependency.dot"

  echo "Single-module project. Generating dependency.dot..."
  mvn -q dependency:tree \
    -DoutputType=dot \
    -DoutputFile="$abs_out"

  echo "Dot file written to: $FINAL_DOT"
}

if is_multi_module; then
  aggregate_modules
else
  single_module
fi

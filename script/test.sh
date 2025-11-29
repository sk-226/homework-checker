#!/bin/sh

# 共通設定を読み込み（config.sh に書いた問題設定をそのまま使う）
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
. "$SCRIPT_DIR/config.sh"

# config.sh の QUESTIONS / STUDENT_PATTERNS / INPUT_FILES をそのまま回すだけ
for qi in $(seq 0 $((${#QUESTIONS[@]} - 1))); do
	Q="${QUESTIONS[$qi]}"
	PATTERN="${STUDENT_PATTERNS[$qi]}"
	INPUT_FILE="${INPUT_FILES[$qi]}"

	echo "=========================================="
	echo "問題 ${Q} のテスト実行"
	echo "=========================================="

	for file in `find ./hw_file -name "$PATTERN" | sort`; do
		ls "$file"

		# コンパイル（失敗したら次へ）
		if ! gcc "$file"; then
			echo "コンパイルエラー: $file"
			rm -f a.out
			continue
		fi

		# 実行（入力ファイルがあれば使う）
		if [ -z "$INPUT_FILE" ]; then
			./a.out
		else
			./a.out < "$INPUT_FILE"
		fi

		# a.out は容量節約のため毎回削除
		rm -f a.out

		echo
	done
done

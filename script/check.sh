#!/bin/sh

# ============================================================================
# 設定ファイルの読み込み
# ============================================================================
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
. "$SCRIPT_DIR/config.sh"

# ============================================================================
# 学生IDリストの読み込み
# ============================================================================
STUDENT_IDS=()
while IFS= read -r line; do
	# ヘッダ行をスキップ
	case "$line" in
		student_id|"") continue ;;
	esac
	STUDENT_IDS=("${STUDENT_IDS[@]}" "$line")
done < id/student_id.csv

if [ ${#STUDENT_IDS[@]} -eq 0 ]; then
	echo "エラー: 学生IDが見つかりませんでした" >&2
	exit 1
fi

# IDがリストに既に含まれているかチェックする関数
contains_id() {
	local id="$1"
	local list_name="$2"
	eval "local arr=(\"\${${list_name}[@]}\")"
	for existing_id in "${arr[@]}"; do
		if [ "$existing_id" = "$id" ]; then
			return 0  # 含まれている
		fi
	done
	return 1  # 含まれていない
}

# IDをリストに追加する関数（重複チェック付き）
add_to_list() {
	local id="$1"
	local list_name="$2"
	if ! contains_id "$id" "$list_name"; then
		eval "${list_name}=(\"\${${list_name}[@]}\" \"$id\")"
	fi
}

# ============================================================================
# メイン処理: 問題ごとのループ
# ============================================================================
for qi in $(seq 0 $((${#QUESTIONS[@]} - 1))); do
	Q="${QUESTIONS[$qi]}"
	ANS="${ANSWER_FILES[$qi]}"
	PAT="${STUDENT_PATTERNS[$qi]}"
	IN="${INPUT_FILES[$qi]}"
	
	# ========================================================================
	# IDリスト管理用変数（重複を避けるため配列として管理）
	# 各問題ごとに独立した集計を行うため、ループ内で初期化
	# ========================================================================
	MISSING_SUBMIT_IDS=()
	COMPILE_ERROR_IDS=()
	WRONG_OUTPUT_IDS=()
	
	echo "=========================================="
	echo "問題 ${Q} のチェックを開始します"
	echo "=========================================="
	
	# ========================================================================
	# 模範解答のコンパイル & 期待出力生成
	# ========================================================================
	ANSWER_OUTPUT_READY=0
	
	if [ ! -f "$ANS" ]; then
		echo "警告: 模範解答ファイル '$ANS' が見つかりません。この問題のコンパイル・実行比較はスキップします（未提出判定のみ実行）"
	else
		echo "模範解答 '$ANS' をコンパイル中..."
		if gcc "$ANS" -o answer_a.out 2>/dev/null; then
			echo "模範解答のコンパイル成功"
			
			# 入力ファイルの処理
			if [ -z "$IN" ]; then
				# 入力ファイルなし
				if ./answer_a.out > answer_output.tmp 2>&1; then
					ANSWER_OUTPUT_READY=1
					echo "模範解答の実行完了（入力なし）"
				else
					echo "警告: 模範解答の実行に失敗しました"
				fi
			elif [ -f "$IN" ]; then
				# 入力ファイルあり
				if ./answer_a.out < "$IN" > answer_output.tmp 2>&1; then
					ANSWER_OUTPUT_READY=1
					printf "模範解答の実行完了（入力: %s）\n" "$IN"
				else
					echo "警告: 模範解答の実行に失敗しました"
				fi
			else
				echo "警告: 入力ファイル '$IN' が見つかりません。この問題の実行比較はスキップします（コンパイルチェックのみ）"
			fi
			
			rm -f answer_a.out
		else
			echo "警告: 模範解答のコンパイルに失敗しました。この問題の実行比較はスキップします（コンパイルチェックのみ）"
		fi
	fi
	
	# ========================================================================
	# 学生IDごとのループ & 提出有無チェック
	# ========================================================================
	for ID in "${STUDENT_IDS[@]}"; do
		GID="g$ID"
		
		# その学生・その問題の提出ファイルを検索
		STU_FILE=$(find ./hw_file -name "*_${GID}_*_${Q}_*.c*" | sort | head -n 1)
		
		if [ -z "$STU_FILE" ]; then
			# 未提出
			echo "[学生ID: $ID] 未提出"
			add_to_list "$ID" "MISSING_SUBMIT_IDS"
			continue
		fi
		
		echo "[学生ID: $ID] ファイル: $STU_FILE"
		
		# ====================================================================
		# 学生コードのコンパイルチェック
		# ====================================================================
		if ! gcc "$STU_FILE" 2>/dev/null; then
			echo "  → コンパイルエラー"
			add_to_list "$ID" "COMPILE_ERROR_IDS"
			rm -f a.out
			continue
		fi
		
		echo "  → コンパイル成功"
		
		# ====================================================================
		# 実行 & 出力比較による正誤判定
		# ====================================================================
		if [ $ANSWER_OUTPUT_READY -eq 0 ]; then
			echo "  → 比較をスキップ（模範解答出力なし）"
			rm -f a.out
			continue
		fi
		
		# 学生プログラムの実行
		if [ -z "$IN" ]; then
			# 入力ファイルなし
			./a.out > student_output.tmp 2>&1
		elif [ -f "$IN" ]; then
			# 入力ファイルあり
			./a.out < "$IN" > student_output.tmp 2>&1
		else
			echo "  → 比較をスキップ（入力ファイルなし）"
			rm -f a.out
			continue
		fi
		
		# 出力比較
		if diff -u answer_output.tmp student_output.tmp > /dev/null 2>&1; then
			echo "  → OK (模範解答と一致)"
		else
			echo "  → NG (出力が異なる)"
			add_to_list "$ID" "WRONG_OUTPUT_IDS"
		fi
		
		# 一時ファイルの削除
		rm -f student_output.tmp a.out
	done
	
	# 問題ごとの一時ファイル削除
	rm -f answer_output.tmp
	
	# ========================================================================
	# 問題ごとの最終結果出力
	# ========================================================================
	echo "=========================================="
	echo "問題 ${Q} の最終結果"
	echo "=========================================="
	
	if [ ${#MISSING_SUBMIT_IDS[@]} -eq 0 ]; then
		echo "未提出の学生ID一覧: （なし）"
	else
		echo "未提出の学生ID一覧: ${MISSING_SUBMIT_IDS[*]}"
	fi
	
	if [ ${#COMPILE_ERROR_IDS[@]} -eq 0 ]; then
		echo "コンパイル失敗の学生ID一覧: （なし）"
	else
		echo "コンパイル失敗の学生ID一覧: ${COMPILE_ERROR_IDS[*]}"
	fi
	
	if [ ${#WRONG_OUTPUT_IDS[@]} -eq 0 ]; then
		echo "出力不一致の学生ID一覧: （なし）"
	else
		echo "出力不一致の学生ID一覧: ${WRONG_OUTPUT_IDS[*]}"
	fi
	
	echo ""
done

# ============================================================================
# クリーンアップ
# ============================================================================
rm -f answer_output.tmp student_output.tmp a.out answer_a.out

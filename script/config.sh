#!/bin/sh

# ============================================================================
# 設定配列: 問題ごとの設定をここで定義
# ============================================================================

# チェックしたい問題番号を配列に追加（例: Q2のみなら QUESTIONS=("Q2")）
# QUESTIONS=("Q2")
# Q1: QUESTIONS=("Q1")
# Q3: QUESTIONS=("Q3")
# 複数:
QUESTIONS=("Q1" "Q2" "Q3")

# 各問題に対応する模範解答ファイル
# ANSWER_FILES=("answer/rep1-2.c")
# Q1: ANSWER_FILES=("answer/rep1-1.c")
# Q3: ANSWER_FILES=("answer/tr1-1.c")
# 複数:
ANSWER_FILES=("answer/rep1-1.c" "answer/rep1-2.c" "answer/tr1-1.c")

# 各問題の学生提出ファイルのパターン（find で使用）
# STUDENT_PATTERNS=("*_Q2_rep1-2.c")
# Q1: STUDENT_PATTERNS=("*_Q1_rep1-1.c")
# Q3: STUDENT_PATTERNS=("*_Q3_tr1-1.c")
# 複数:
STUDENT_PATTERNS=("*_Q1_rep1-1.c" "*_Q2_rep1-2.c" "*_Q3_tr1-1.c*")

# 各問題の入力ファイル（空文字の場合は入力なし）
# INPUT_FILES=("input/input.txt")
# Q1: INPUT_FILES=("")
# Q3: INPUT_FILES=("")
# 複数:
INPUT_FILES=("" "input/input_q2.txt" "input/input_q3.txt")

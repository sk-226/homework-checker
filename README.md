# Homework Checker

## Usage

1. Add students ID to `id/student_id.csv` (to refer whether the student submitted the homework or not).
   For example:
   ```
   student_id
   2221000
   2321000
   2421000
   ```

2. Add answer files to `answer/`.

3. Add homework files to `hw_file/`.

4. Add input files to `input/` (If there is no input file, leave it blank and set `INPUT_FILES` in `script/config.sh` to empty).

5. Edit `script/config.sh` to set the questions, answer files and input files for each question. You can also execute only one.

6. Execute `make test` and `make check` to test and check the homework. (You can delete outputs by executing `make clean`).

OUTPUT_DIR := output

.PHONY: check test clean

check:
	mkdir -p $(OUTPUT_DIR)
	sh script/check.sh >> $(OUTPUT_DIR)/check.log 2>&1

test:
	mkdir -p $(OUTPUT_DIR)
	sh script/test.sh >> $(OUTPUT_DIR)/test.log 2>&1

clean:
	rm -rf $(OUTPUT_DIR)/*

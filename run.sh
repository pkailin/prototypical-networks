#!/bin/bash

# Define the output log file
LOG_FILE="experiment_results.txt"

# Function to run a command and log output
run_and_log() {
    echo "Running: $1" | tee -a $LOG_FILE
    eval "$1" 2>&1 | tee -a $LOG_FILE
    echo "----------------------------------------" | tee -a $LOG_FILE
}

# Function to move trainval results safely
move_trainval_results() {
    DEST_DIR=$1  # Destination directory
    echo "Moving trainval results to $DEST_DIR" | tee -a $LOG_FILE
    mkdir -p "$DEST_DIR"  # Ensure target directory exists
    mv ./results/trainval/* "$DEST_DIR"  # Move all files from trainval
    echo "----------------------------------------" | tee -a $LOG_FILE
}

# Remove log file if it already exists
rm -f $LOG_FILE

# Move and Evaluate Default Omniglot Model
move_trainval_results "./omniglot_default/trainval"
run_and_log "python scripts/predict/few_shot/run_eval.py --model.model_path ./omniglot_default/trainval/best_model.pt --data.test_episodes=600"

# 5-way, 1-shot Training, Trainval, and Evaluation
run_and_log "python scripts/train/few_shot/run_train.py --log.exp_dir ./omniglot_5w1s --data.shot 1 --data.test_way 5"
run_and_log "python scripts/train/few_shot/run_trainval.py --model.model_path ./omniglot_5w1s/best_model.pt"
move_trainval_results "./omniglot_5w1s/trainval"
run_and_log "python scripts/predict/few_shot/run_eval.py --model.model_path ./omniglot_5w1s/trainval/best_model.pt --data.test_episodes=600"

# 20-way, 1-shot Training, Trainval, and Evaluation
run_and_log "python scripts/train/few_shot/run_train.py --log.exp_dir ./omniglot_20w1s --data.shot 1 --data.test_way 20"
run_and_log "python scripts/train/few_shot/run_trainval.py --model.model_path ./omniglot_20w1s/best_model.pt"
move_trainval_results "./omniglot_20w1s/trainval"
run_and_log "python scripts/predict/few_shot/run_eval.py --model.model_path ./omniglot_20w1s/trainval/best_model.pt --data.test_episodes=600"

# 20-way, 5-shot Training, Trainval, and Evaluation
run_and_log "python scripts/train/few_shot/run_train.py --log.exp_dir ./omniglot_20w5s --data.shot 5 --data.test_way 20"
run_and_log "python scripts/train/few_shot/run_trainval.py --model.model_path ./omniglot_20w5s/best_model.pt"
move_trainval_results "./omniglot_20w5s/trainval"
run_and_log "python scripts/predict/few_shot/run_eval.py --model.model_path ./omniglot_20w5s/trainval/best_model.pt --data.test_episodes=600"

echo "All experiments completed. Results saved in $LOG_FILE."


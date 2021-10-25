library(tidyverse)

df_scores <- read.csv("./processed_data/scores.csv")
df_tests <- read.csv("./processed_data/tests.csv")

explorer_tests <- df_tests |>
  filter(role == "explorer") |>
  select(game_id, role, round_num, predicted_label, stim_num, true_label)
colnames(explorer_tests)[4] = "explorer_pred_label"

student_tests <- df_tests |>
  filter(role == "student") |>
  select(game_id, role, round_num, predicted_label, stim_num)
colnames(student_tests)[4] = "student_pred_label"

combined_tests <- explorer_tests |>
  inner_join(student_tests, by=c("game_id", "round_num", "stim_num")) |>
  rowwise() |>
  mutate(agree = if(student_pred_label == explorer_pred_label) 1 else 0,
         exp_wrong = if(explorer_pred_label == true_label) 0 else 1)

hamming_distances <- combined_tests |>
  group_by(game_id, round_num) |>
  summarize(explorer_student = sum(agree),
            explorer_truth = sum(exp_wrong), .groups="keep")

ggplot(hamming_distances, aes(x=explorer_student, y=explorer_truth)) +
  geom_point()

cor.test(hamming_distances$explorer_student, hamming_distances$explorer_truth,
         method="pearson")

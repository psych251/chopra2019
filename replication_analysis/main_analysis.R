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
  mutate(agree = if(student_pred_label == explorer_pred_label) 0 else 1,
         exp_correct = if(explorer_pred_label == true_label) 1 else 0,
         stud_correct = if(student_pred_label == true_label) 1 else 0)

hamming_distances <- combined_tests |>
  group_by(game_id, round_num) |>
  summarize(explorer_student = sum(agree),
            explorer_accuracy = sum(exp_correct) / n(),
            student_accuracy = sum(stud_correct) / n(), .groups="keep")

ggplot(hamming_distances, aes(x=explorer_accuracy, y=explorer_student)) +
  geom_point(size=3, color="blue") +
  ylab("explorer-student Hamming distance") +
  xlab("explorer accuracy")

ggsave("corr_plot.png")

hamming_distances |>
  pivot_longer(c("explorer_accuracy", "student_accuracy"), names_to="role",
               values_to="accuracy") |>
  rowwise() |>
  mutate(role = if(role == "student_accuracy") "student" else "explorer") |>
  group_by(role) |>
  summarize(mean_acc = mean(accuracy),
            ci_acc = sd(accuracy) / sqrt(n())) |>
  ggplot(aes(x=role, y=mean_acc)) +
  geom_bar(stat="identity", fill="lightblue", color="black") +
  geom_errorbar(aes(ymin = mean_acc - ci_acc/2, ymax = mean_acc + ci_acc/2)) +
  ylab("mean accuracy")

cor.test(hamming_distances$explorer_student, hamming_distances$explorer_accuracy,
         method="pearson")

ggsave("accuracy_bar_plot.png")

df_prolific = read.csv("./processed_data/prolific.csv")

# compute bonuses for each player
df_bonuses <- df_scores |>
  group_by(game_id) |>
  summarize(bonus_amount = (sum(score) / 2) / 100) |>
  left_join()

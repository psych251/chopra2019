import json
import pandas as pd

RAW_DATA_FOLDER = "./raw_data"
RAW_FILE_NAME = "pilot_a_data.json"
OUTPUT_FOLDER = "./processed_data"

if __name__ == "__main__":

    with open(f"{RAW_DATA_FOLDER}/{RAW_FILE_NAME}", "rb") as fp:
        data = json.load(fp)


    scores = []
    test_results = []
    for entry in data:
        if entry["eventType"] == "logScores":
            e = {
                "game_id": entry["gameid"],
                "role": entry["role"],
                "round_num": entry["round_num"],
                "hits": entry["hits"],
                "misses": entry["misses"],
                "correct_rejections": entry["correct_rejections"],
                "false_alarms": entry["false_alarms"],
                "score": entry["score"]
            }
            scores.append(e)

        elif entry["eventType"] == "logTest":
            e = {
                "game_id": entry["gameid"],
                "role": entry["role"],
                "round_num": entry["round_num"],
                "predicted_label": entry["turker_label"],
                "true_label": entry["true_label"],
                "is_correct": entry["is_correct"],
                "stim_num": entry["stim_num"]
            }
            test_results.append(e)

    df_scores = pd.DataFrame(scores)
    df_test = pd.DataFrame(test_results)

    df_scores.to_csv(f"{OUTPUT_FOLDER}/scores.csv")
    df_test.to_csv(f"{OUTPUT_FOLDER}/tests.csv")

# Learning from Animal “Experts” How to Navigate Complex Terrains

Source code corresponds to paper 'Learning from Animal “Experts” How to Navigate Complex Terrains'.

The original moth data is placed in folder `data/raw`.

To obtain the results described in the paper, run the matlab scripts in folder `src` in each step accordingly.

+ `step1_create_mdp`
  1. `generate_state_action_probability.m`
  2. `generate_rewards.m`
+ `step2_create_features`
  1. `extract_state_action_samples.m`
  2. `calculate_state_action_features_raw.m`
  3. `calculate_state_action_features_std.m`
  4. `calculate_qstate_action_features_raw.m`
  5. `calculate_qstate_action_features_std.m`
+ `step3_logistic_regression`
  - `logistic_regression.m`
+ `step4_actor_critic_learning`
  - `lstd_act_cri.m`
+ `step5_eval_policy`
  1. `evaluate_act_prob.m`
  2. `show_stationary_density_act.m`
  3. `evaluate_log_prob.m`
  4. `show_stationary_density_log.m`
+ `step6_create_visual_forest` to `step8_compare_different_simulations`
  - run scrips with prefix 'E1' to 'E4' accordingly.

NOTE: There may be some broken pipeline due to refactoring the code. This version is not the final one


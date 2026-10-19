function stat_results_total = final_eval_all_MAEs_with_RBF( ...
    target_biomechanics_total, ...
    moment_positive_zero, ...
    savedir ...
    )

%{
Use results from evaluate_selected_biomechanics.

%}

biomechanics_list = fields(target_biomechanics_total);

plot_option_kinetics = struct('ymin', 0, 'ymax', 0.5);
plot_option_kinematics = struct('ymin', 0, 'ymax', 9);

plot_options.avg_ankle_moment_stance_total = plot_option_kinetics;
plot_options.avg_ankle_angle_stance_total = plot_option_kinematics;
plot_options.avg_ankle_angle_swing_total = plot_option_kinematics;
plot_options.avg_knee_moment_stance_total = plot_option_kinetics;
plot_options.avg_knee_angle_stance_total = plot_option_kinematics;
plot_options.avg_knee_angle_swing_total = plot_option_kinematics;
plot_options.avg_hip_moment_stance_total = plot_option_kinetics;
plot_options.avg_hip_angle_stance_total = plot_option_kinematics;
plot_options.avg_hip_angle_swing_total = plot_option_kinematics;

stat_results_total = final_eval_combined_MAEs_with_RBF( ...
    target_biomechanics_total, ...
    moment_positive_zero, ...
    savedir);

end
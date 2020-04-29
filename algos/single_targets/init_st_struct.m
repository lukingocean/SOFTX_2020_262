
function st_struct=init_st_struct()

st_struct=struct(...
    'TS_comp',[],...
    'TS_uncomp',[],...
    'Power_norm',[],...
    'Target_range',[],...
    'Target_range_disp',[],...
    'Target_range_min',[],...
    'Target_range_max',[],...
    'Target_range_to_bottom',[],...
    'idx_r',[],...
    'StandDev_Angles_Minor_Axis',[],...%along
    'StandDev_Angles_Major_Axis',[],...%athwart
    'Angle_minor_axis',[],...
    'Angle_major_axis',[],...
    'Ping_number',[],...
    'Time',[],...
    'idx_target_lin',[],...
    'pulse_env_before_lin',[],...
    'pulse_env_after_lin',[],...
    'TargetLength',[],...
    'PulseLength_Normalized_PLDL',[],...
    'Transmitted_pulse_length',[],...
    'Heave',[],...
    'Roll',[],...
    'Pitch',[],...
    'Heading',[],...
    'Yaw',[],...
    'Dist',[],...
    'Track_ID',[]);
end
function generate_figures

disp('generating 2D free space Green''s functions')
h = free_space_gf_2d_visualization(1);
disp('generating 3D free space Green''s functions')
h = free_space_gf_3d_visualization(1);
disp('generating Hankel error fit')
h = hankel_error_fit(1);

close all
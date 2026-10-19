function z_RBF_interp = merge_RBF( ...
    target_biomechanics_surf_asc, target_biomechanics_surf_desc, ...
    r_coeff, moment_positive_zero ...
    )

%{

Slope-unified biomechanics (curve fitted) -> RBF interpolation 

%}

% Fixed settings for RBF merging
slope_asc = 0:1:35;
slope_desc = -35:1:0;
slope_to_interp = -35:1:35;
normalized_phase = linspace(0,100,101);

[XGrid_asc, YGrid_asc] = meshgrid(slope_asc, normalized_phase);
[XGrid_desc, YGrid_desc] = meshgrid(slope_desc, normalized_phase);

X_asc = XGrid_asc(:); Y_asc = YGrid_asc(:);
X_desc = XGrid_desc(:); Y_desc = YGrid_desc(:);
Z_asc = target_biomechanics_surf_asc(:); Z_desc = target_biomechanics_surf_desc(:); 

X_original = [X_asc;X_desc]/35;
Y_original = [Y_asc;Y_desc]/100;
XY_original = [X_original, Y_original];
Z_original = [Z_asc;Z_desc];

[XGrid_interp, YGrid_interp] = meshgrid(slope_to_interp, normalized_phase);
X_interp = XGrid_interp(:)/35;
Y_interp = YGrid_interp(:)/100;
XY_interp = [X_interp, Y_interp];

% Gaussian RBF
p = 2;
rbf = @(r) exp(-r.^p);

% Compute pairwise distances
D_original = pdist2(XY_original, XY_original);

% regularization value examples: [1e-8, 1e-6, 1e-4, 1e-3, 1e-2, 1e-1, 1];
Phi_original = rbf(D_original) + eye(size(D_original)) * r_coeff; % Regularization

% Solve for interpolation coefficients
lambda = Phi_original \ Z_original;

D_interp = pdist2(XY_interp, XY_original);
Phi_interp = rbf(D_interp);

z_RBF_interp = Phi_interp * lambda;
z_RBF_interp = reshape(z_RBF_interp, size(XGrid_interp));

% If target is joint moment, begin with non-negative value at 0% stance phase
z_RBF_interp_moment = z_RBF_interp;

if moment_positive_zero
    % disp('Optimizing joint moment')
    for s = 1:size(z_RBF_interp, 2)
        target_slope_moment = z_RBF_interp(:, s);

        for p = 1:length(target_slope_moment)
            if target_slope_moment(p)>=0

                new_target_slope_moment = target_slope_moment(p:end);
                new_target_slope_moment(1) = 0;
                x_original = linspace(0, 100, 101 - p + 1);

                new_target_slope_moment_itpd = interp1( ...
                    x_original', ...
                    new_target_slope_moment, ...
                    normalized_phase ...
                    );    

                z_RBF_interp_moment(:, s) = new_target_slope_moment_itpd;

                break
            end
        end
    end
end

z_RBF_interp = z_RBF_interp_moment;

end
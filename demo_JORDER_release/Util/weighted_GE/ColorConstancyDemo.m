% Shows example of illuminant estimation based on Grey-World, Shades of
% Gray, max-RGB, and Grey-Edge algorithm and weighted Grey-Edge
% 
%
% See:
% J. van de Weijer, Th. Gevers, A. Gijsenij
% "Edge-Based Color Constancy"
% IEEE Trans. Image Processing, vol. 16(9):2207-2214, 2007.
%
% and:
% Arjan Gijsenij, Theo Gevers, Joost van de Weijer
% "Improving Color Constancy by Photometric Edge Weighting"
% IEEE Trans. on Pattern Analysis and Machine Intellignece, vol. 34(5):918-929, 2012.
%
% Source-code courtesy of Joost van de Weijer
%

input_im = double( imread( 'mondrian.tif' ) ); % example image taken from http://www.cs.sfu.ca/~colour/data/

figure(1);
imshow( uint8( input_im ) );
title( 'Input image' );

% Grey-World
[wR, wG, wB, out1] = general_cc( input_im, 0, 1, 0 );
figure(2);
imshow( uint8( out1 ) );
title( 'Grey-World' );

% max-RGB
[wR, wG, wB, out2] = general_cc( input_im, 0, -1, 0 );
figure(3);
imshow( uint8( out2 ) );
title( 'max-RGB' );

% Shades of Grey (mink_norm can be any number between 1 and infinity)
mink_norm = 5;
[wR, wG, wB, out3] = general_cc( input_im, 0, mink_norm, 0);
figure(4);
imshow( uint8( out3 ) );
title( 'Shades of Grey' );

% Grey-Edge (diff_order = 1 or 2, for 1st-order or 2nd-order derivative, using filter-size sigma)
mink_norm = 5;
sigma = 2;
diff_order = 1;
[wR, wG, wB, out4] = general_cc( input_im, diff_order, mink_norm, sigma );
figure(5);
imshow( uint8( out4 ) );
title( 'Grey-Edge' );

% Weighted Grey-Edge (kappa determines the weight given to the weight-map)
mink_norm = 5;
sigma = 2;
diff_order = 1;
kappa = 10; 
[wR, wG, wB, out5] = weightedGE( input_im, kappa, mink_norm, sigma );
figure(6);
imshow( uint8( out5 ) );
title( 'Weighted Grey-Edge' );


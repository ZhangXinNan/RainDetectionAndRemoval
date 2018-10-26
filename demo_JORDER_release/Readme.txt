
1. test_rain_removal_light.m provides the evaluation results on Rain100L.
2. test_rain_removal_heavy.m provides the evaluation results on Rain100H.
3. test_rain_removal_practical.m provides accesses to generating the results on real cases.


To run this code, you may need to follow these steps:

1) Install matcaffe.
   You may follow this: http://caffe.berkeleyvision.org/tutorial/interfaces.html

2) Set your matcaffe path by modifying matcaffe_path in the program.

3) You might need to go to the path Util/matlab and run vl_compilenn.m to compile matConvnet, if you want to run test_rain_removal_practical.m


Run your own dataset:
Just replace rain_dir and norain_dir to your dataset.
%% Import data and initialize variables
clear all
close all
clc

data = xlsread('data_after.csv');


x_0 = data(:,2);
y_0 = data(:,3);

match_score = [];
x_1 = [];
y_1 = [];
mean_strain = [];
std_strain = [];
sem_strain = [];

for i = 1:9
    match_score = data(:,i*3+1);
    x_1 = data(:,i*3+2);   
    y_1 = data(:,i*3+3);  
    [z_y, mean_strain(i,1), std_strain(i,1), sem_strain(i,1)] = FitBeadStrainFieldLocal(x_0, y_0, match_score, x_1, y_1, 0.0, 0.05, i);
end

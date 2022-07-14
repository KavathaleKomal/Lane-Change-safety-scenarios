%% Clean workspace and close all
clear all
close all
clc
%% Constraint for parameter

Dist2LaneBondary = 0.3;


Ay = -2;                            % Lane Change acceleration
CompA = 6;
ErrDecel=[];
TTC=[];
FFHTI=[];
x_speed=[];
y_TTC=[];
z_FHTI=[];
SteerInd = [];
%% TTC calculation
for ErraticDecel=-4.5:0.5:-3
%% Lateral deviation
LaneChgT = sqrt(-2 * Dist2LaneBondary/Ay);
VyL = ErraticDecel * LaneChgT;

%% FHTI calculation
for i = 0.01 : 0.01 : LaneChgT
  
    DistCovDurLaneChgF_3 = -1 * ErraticDecel * i;
    DistCovDurLaneChgF_4 = DistCovDurLaneChgF_3 - (LaneChgT - i) * CompA;
    if abs(DistCovDurLaneChgF_4 - VyL) < 0.1
        break
    end
end

ErrDecel=[ErrDecel ErraticDecel];
TTC=[TTC LaneChgT];
FFHTI=[FFHTI i];

end
%% plots
figure(1);
plot(ErrDecel,TTC);
grid on
xlabel('Erratic accel in m/s/s')
ylabel('Time-to-collision in sec');
hold on

f=gcf;
saveas(f,'Highway_Erratic_Veh_Decel_1_TTC.jpg');

figure(2);
plot(ErrDecel,FFHTI);
grid on
xlabel('Erratic accel in m/s/s')
ylabel('Fault Handling Time Interval in sec');
hold on



f=gcf;
saveas(f,'Highway_Erratic_Veh_Decel_1_FHTI.jpg');

%% excel write
x_speed=ErrDecel';
y_TTC=TTC';
z_FHTI=FFHTI';
data={'Erratic Acel','TTC','FHTI'};
xlswrite('Functional_Safety_Scenarios',data,'Highway_Erratic_Veh_Decel_1','A1');
xlswrite('Functional_Safety_Scenarios',x_speed,'Highway_Erratic_Veh_Decel_1','A2');
xlswrite('Functional_Safety_Scenarios',y_TTC,'Highway_Erratic_Veh_Decel_1','B2');
xlswrite('Functional_Safety_Scenarios',z_FHTI,'Highway_Erratic_Veh_Decel_1','C2');

folder = pwd;
excelFileName = 'Functional_Safety_Scenarios.xls';
fullFileName = fullfile(folder, excelFileName);
objExcel = actxserver('Excel.Application');
objExcel.Visible = true;
ExcelWorkbook = objExcel.Workbooks.Open(fullFileName);
oSheet = objExcel.ActiveSheet;
imageFolder = fileparts(which('Highway_Erratic_Veh_Decel_1_TTC.jpg'));
imageFullFileName = fullfile(imageFolder, 'Highway_Erratic_Veh_Decel_1_TTC.jpg');
Shapes = oSheet.Shapes;
Shapes.AddPicture(imageFullFileName, 0, 1, 400, 20, 400, 300);

imageFolder1 = fileparts(which('Highway_Erratic_Veh_Decel_1_FHTI.jpg'));
imageFullFileName1 = fullfile(imageFolder, 'Highway_Erratic_Veh_Decel_1_FHTI.jpg');
Shapes.AddPicture(imageFullFileName1, 0, 1, 850, 20, 400, 300);

objExcel.DisplayAlerts = false;
ExcelWorkbook.SaveAs(fullFileName);
ExcelWorkbook.Close(false);
objExcel.Quit;
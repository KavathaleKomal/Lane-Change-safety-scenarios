%% Clean workspace and close all
close all
clear all
clc
%% Constraint for parameter
SignF=-1;
d1=151.25;
d2=1;
d3=0.25;
s=d1-d2-d3;
FFTTI=[];
VVss_kmph=[];
AcelArr=[];
MaxRecdecl=-2;
FHTI_arr=[];
for Vss_kmph=40:0.5:88.5
Vss_mps=Vss_kmph/3.6;

%% TTC calculation
a=-(9.81*(Vss_kmph*Vss_kmph/(254*s)));
SD=2*0.2778*Vss_kmph;
ftti_1=(-Vss_mps+sqrt(Vss_mps*Vss_mps+2*(-a)*s))/(-a);
ftti_2=(-Vss_mps-sqrt(Vss_mps*Vss_mps+2*(-a)*s))/(-a);
if ftti_1<0
    FTTI=ftti_2;
else
    FTTI=ftti_1;
end
%% FHTI calculation
for j = 0.01 : 0.01 : FTTI
    Dist_A =Vss_mps*j+ 0.5 * -a * j^2;
    VV = Vss_mps+(-a)*j;
    Dist_B = VV*j+0.5 * MaxRecdecl * j^2;
    if sign(((Dist_A + Dist_B) - s)) ~= sign(SignF)
        break;
    else
        signF = sign(((Dist_A + Dist_B) - s));
    end
end
FHTI = j;



FHTI_arr=[FHTI_arr FHTI];
FFTTI =[FFTTI FTTI];
VVss_kmph=[VVss_kmph Vss_kmph];
AcelArr=[AcelArr a];

end
%% plots
figure(1);
plot(VVss_kmph,FFTTI);
grid on
xlabel('TV velocity in KMPH')
ylabel('Time-to-collision in sec');
hold on

f=gcf;
saveas(f,'surfacestrtInsufficient_Decel_1_TTC.jpg');

figure(2);
plot(VVss_kmph,FHTI_arr);
grid on
xlabel('TV velocity in KMPH')
ylabel('Fault Handling Time Interval in sec');
hold on


f=gcf;
saveas(f,'surfacestrtInsufficient_Decel_1_FHTI.jpg');

%% excel write
x_speed=VVss_kmph';
y_TTC=FFTTI';
z_FHTI=FHTI_arr';
data={'Vehicle_Speed','TTC','FHTI'};
xlswrite('Functional_Safety_Scenarios',data,'surfacestrtInsufficient_Decel_1','A1');
xlswrite('Functional_Safety_Scenarios',x_speed,'surfacestrtInsufficient_Decel_1','A2');
xlswrite('Functional_Safety_Scenarios',y_TTC,'surfacestrtInsufficient_Decel_1','B2');
xlswrite('Functional_Safety_Scenarios',z_FHTI,'surfacestrtInsufficient_Decel_1','C2');

folder = pwd;
excelFileName = 'Functional_Safety_Scenarios.xls';
fullFileName = fullfile(folder, excelFileName);
objExcel = actxserver('Excel.Application');
objExcel.Visible = true;
ExcelWorkbook = objExcel.Workbooks.Open(fullFileName);
oSheet = objExcel.ActiveSheet;
imageFolder = fileparts(which('surfacestrtInsufficient_Decel_1_TTC.jpg'));
imageFullFileName = fullfile(imageFolder, 'surfacestrtInsufficient_Decel_1_TTC.jpg');
Shapes = oSheet.Shapes;
Shapes.AddPicture(imageFullFileName, 0, 1, 400, 20, 400, 300);

imageFolder1 = fileparts(which('surfacestrtInsufficient_Decel_1_FHTI.jpg'));
imageFullFileName1 = fullfile(imageFolder, 'surfacestrtInsufficient_Decel_1_FHTI.jpg');
Shapes.AddPicture(imageFullFileName1, 0, 1, 850, 20, 400, 300);

objExcel.DisplayAlerts = false;
ExcelWorkbook.SaveAs(fullFileName);
ExcelWorkbook.Close(false);
objExcel.Quit; 